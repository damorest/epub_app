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
          ConverterIdle()      => const _FormView(),
          ConverterLoading()   => const _FormView(loading: true),
          ConverterRunning()   => _ProgressView(state: state),
          ConverterDone()      => _DoneView(state: state),
          ConverterPublishing()=> _DoneView(state: state, publishing: true),
          ConverterPublished() => _PublishedView(state: state),
          ConverterError()     => _ErrorView(state: state),
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Form
// ---------------------------------------------------------------------------

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
  bool _followNext = false;

  @override
  void dispose() {
    _urlCtrl.dispose();
    _titleCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
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
    context.read<ConverterCubit>().startParsing(
      url: url,
      title: title,
      start: int.tryParse(_startCtrl.text) ?? 1,
      end: int.tryParse(_endCtrl.text) ?? 9999,
      followNext: _followNext,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: _urlCtrl,
            label: AppTexts.urlLabel,
            hint: AppTexts.urlHint,
            helperText: AppTexts.urlHelper,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _titleCtrl,
            label: AppTexts.titleLabel,
            hint: AppTexts.titleHint,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
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
                  hint: AppTexts.toChapterHint,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _FollowNextToggle(
            value: _followNext,
            onChanged: (v) => setState(() => _followNext = v),
          ),
          const SizedBox(height: 36),
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

class _FollowNextToggle extends StatelessWidget {
  const _FollowNextToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile(
        title: const Text(
          AppTexts.followNext,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        subtitle: const Text(
          AppTexts.followNextHint,
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        value: value,
        onChanged: onChanged,
      ),
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
              Uri.parse(state.job.siteUrl!),
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
