import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../cubit/converter_cubit.dart';
import '../../../data/models/job_model.dart';
import '../cubit/converter_state.dart';

class ConverterScreen extends StatelessWidget {
  const ConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.navConverter)),
      body: BlocBuilder<ConverterCubit, ConverterState>(
        builder: (context, state) => switch (state) {
          ConverterIdle()       => const _FormView(),
          ConverterLoading()    => const _FormView(loading: true),
          ConverterRunning()    => _ProgressView(state: state),
          ConverterDone()       => _DoneView(state: state),
          ConverterPublishing() => _DoneView(state: state, publishing: true),
          ConverterPublished()  => _PublishedView(state: state),
          ConverterError()      => _ErrorView(state: state),
          ConverterCancelled()  => _CancelledView(),
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Form
// ---------------------------------------------------------------------------

enum _ParseMode { pattern, followNext }

class _FormView extends StatefulWidget {
  const _FormView({this.loading = false});
  final bool loading;

  @override
  State<_FormView> createState() => _FormViewState();
}

class _FormViewState extends State<_FormView> {
  final _urlCtrl   = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _startCtrl = TextEditingController(text: '1');
  final _endCtrl   = TextEditingController();
  final _limitCtrl = TextEditingController();
  _ParseMode _mode = _ParseMode.pattern;

  @override
  void dispose() {
    _urlCtrl.dispose();
    _titleCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _limitCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final url   = _urlCtrl.text.trim();
    final title = _titleCtrl.text.trim();
    if (url.isEmpty || title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.fillFields)),
      );
      return;
    }
    final followNext = _mode == _ParseMode.followNext;
    final start = int.tryParse(_startCtrl.text) ?? 1;
    final end = followNext
        ? (int.tryParse(_limitCtrl.text) ?? 0) + start - 1
        : (int.tryParse(_endCtrl.text) ?? 9999);
    context.read<ConverterCubit>().startParsing(
      url: url,
      title: title,
      start: followNext ? 1 : start,
      end: (followNext && _limitCtrl.text.trim().isEmpty) ? 9999 : end,
      followNext: followNext,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ModeSelector(
            selected: _mode,
            onChanged: (m) => setState(() => _mode = m),
          ),
          const SizedBox(height: 20),
          if (_mode == _ParseMode.pattern) ...[
            AppTextField(
              controller: _urlCtrl,
              label: AppTexts.urlPatternLabel,
              hint: 'https://site.com/chapter-{n}',
              helperText: AppTexts.urlPatternHelper,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: AppTextField(
                  controller: _startCtrl,
                  label: AppTexts.fromChapter,
                  hint: '1',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  controller: _endCtrl,
                  label: AppTexts.toChapter,
                  hint: AppTexts.toChapterAutoHint,
                  helperText: AppTexts.toChapterAutoHelper,
                  keyboardType: TextInputType.number,
                ),
              ),
            ]),
          ] else ...[
            AppTextField(
              controller: _urlCtrl,
              label: AppTexts.urlFirstChapterLabel,
              hint: 'https://site.com/chapter-1',
              helperText: AppTexts.urlFirstChapterHelper,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _limitCtrl,
              label: AppTexts.limitLabel,
              hint: AppTexts.limitHint,
              helperText: AppTexts.limitHelper,
              keyboardType: TextInputType.number,
            ),
          ],
          const SizedBox(height: 16),
          AppTextField(
            controller: _titleCtrl,
            label: AppTexts.titleLabel,
            hint: AppTexts.titleHint,
          ),
          const SizedBox(height: 32),
          AppButton(
            label: AppTexts.processBtn,
            loading: widget.loading,
            onPressed: () => _submit(context),
          ),
        ],
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.selected, required this.onChanged});
  final _ParseMode selected;
  final ValueChanged<_ParseMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppTexts.modeLabel,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 8),
        SegmentedButton<_ParseMode>(
          style: SegmentedButton.styleFrom(
            backgroundColor: AppColors.surface,
            selectedBackgroundColor: AppColors.primary.withValues(alpha: 0.15),
            selectedForegroundColor: AppColors.primary,
            foregroundColor: AppColors.textMuted,
            side: const BorderSide(color: AppColors.border),
          ),
          segments: const [
            ButtonSegment(
              value: _ParseMode.pattern,
              label: Text(AppTexts.modePattern),
              icon: Icon(Icons.tag, size: 16),
            ),
            ButtonSegment(
              value: _ParseMode.followNext,
              label: Text(AppTexts.modeFollowNext),
              icon: Icon(Icons.arrow_forward, size: 16),
            ),
          ],
          selected: {selected},
          onSelectionChanged: (s) => onChanged(s.first),
        ),
        const SizedBox(height: 6),
        Text(
          selected == _ParseMode.pattern
              ? AppTexts.modePatternDesc
              : AppTexts.modeFollowNextDesc,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Progress
// ---------------------------------------------------------------------------

class _ProgressView extends StatelessWidget {
  const _ProgressView({required this.state});
  final ConverterRunning state;

  @override
  Widget build(BuildContext context) {
    final job = state.job;
    return _CenteredColumn(
      children: [
        const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
        const SizedBox(height: 32),
        Text(
          job.current.isEmpty ? AppTexts.starting : job.current,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          textAlign: TextAlign.center,
        ),
        if (job.total > 0) ...[
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: job.progressFraction,
              minHeight: 8,
              color: AppColors.primary,
              backgroundColor: AppColors.border,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${job.progress} / ${job.total} ${AppTexts.chapters}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
        const SizedBox(height: 40),
        const Text(
          AppTexts.dontClose,
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => context.read<ConverterCubit>().cancel(),
          child: const Text(
            AppTexts.cancelBtn,
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Done
// ---------------------------------------------------------------------------

class _DoneView extends StatelessWidget {
  const _DoneView({required this.state, this.publishing = false});
  final ConverterState state;
  final bool publishing;

  JobModel get _job => switch (state) {
        ConverterDone(job: final j)       => j,
        ConverterPublishing(job: final j) => j,
        _ => throw StateError('unexpected'),
      };

  @override
  Widget build(BuildContext context) {
    final job = _job;
    return _CenteredColumn(
      children: [
        const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 80),
        const SizedBox(height: 20),
        Text(
          '${job.total} ${AppTexts.readySuffix}',
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          AppTexts.publishHint,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        AppButton(
          label: AppTexts.publishBtn,
          icon: Icons.rocket_launch,
          loading: publishing,
          onPressed: () => context.read<ConverterCubit>().publish(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Published
// ---------------------------------------------------------------------------

class _PublishedView extends StatelessWidget {
  const _PublishedView({required this.state});
  final ConverterPublished state;

  @override
  Widget build(BuildContext context) {
    return _CenteredColumn(
      children: [
        const Icon(Icons.rocket_launch, color: AppColors.primary, size: 80),
        const SizedBox(height: 20),
        const Text(
          AppTexts.bookPublished,
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          AppTexts.siteUpdateHint,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 40),
        if (state.job.siteUrl != null)
          AppButton(
            label: AppTexts.openLibrary,
            icon: Icons.open_in_browser,
            onPressed: () => launchUrl(
              // Add timestamp to bypass browser cache
              Uri.parse('${state.job.siteUrl!}?v=${DateTime.now().millisecondsSinceEpoch}'),
              mode: LaunchMode.externalApplication,
            ),
          ),
        const SizedBox(height: 14),
        TextButton(
          onPressed: () => context.read<ConverterCubit>().reset(),
          child: const Text(
            AppTexts.backToConverter,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Error
// ---------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.state});
  final ConverterError state;

  @override
  Widget build(BuildContext context) {
    return _CenteredColumn(
      children: [
        const Icon(Icons.error_outline, color: AppColors.error, size: 80),
        const SizedBox(height: 20),
        const Text(
          AppTexts.somethingWrong,
          style: TextStyle(color: AppColors.error, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          state.message,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        AppButton(
          label: AppTexts.tryAgain,
          onPressed: () => context.read<ConverterCubit>().reset(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Cancelled
// ---------------------------------------------------------------------------

class _CancelledView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _CenteredColumn(
      children: [
        const Icon(Icons.cancel_outlined, color: AppColors.textMuted, size: 72),
        const SizedBox(height: 20),
        const Text(
          AppTexts.cancelledTitle,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
        ),
        const SizedBox(height: 40),
        AppButton(
          label: AppTexts.backToConverter,
          onPressed: () => context.read<ConverterCubit>().reset(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared layout
// ---------------------------------------------------------------------------

class _CenteredColumn extends StatelessWidget {
  const _CenteredColumn({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }
}
