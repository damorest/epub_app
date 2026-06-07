import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/job_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../cubit/converter_cubit.dart';
import '../cubit/converter_state.dart';

// ─── Entry widget ─────────────────────────────────────────────────────────────
class ConverterScreen extends StatelessWidget {
  const ConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: BlocBuilder<ConverterCubit, ConverterState>(
        builder: (context, state) => switch (state) {
          ConverterIdle()       => const _FormView(),
          ConverterLoading()    => const _WakingView(),
          ConverterRunning()    => _RunningView(state: state),
          ConverterDone()       => _DoneView(state: state),
          ConverterPublishing() => _DoneView(state: state, publishing: true),
          ConverterPublished()  => _PublishedView(state: state),
          ConverterError()      => _ErrorView(state: state),
          ConverterCancelled()  => const _CancelledView(),
        },
      ),
    );
  }
}

// ─── Shared header ────────────────────────────────────────────────────────────
class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(22, top + 20, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.converterEyebrow,
            style: AppTypography.eyebrow,
          ),
          const SizedBox(height: 7),
          Text(
            AppTexts.navConverter,
            style: AppTypography.displayTitle,
          ),
        ],
      ),
    );
  }
}

// ─── Form ─────────────────────────────────────────────────────────────────────
enum _ParseMode { followNext, pattern }

class _FormView extends StatefulWidget {
  const _FormView();

  @override
  State<_FormView> createState() => _FormViewState();
}

class _FormViewState extends State<_FormView> {
  final _urlCtrl   = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _chapterNumCtrl = TextEditingController(text: '1');
  final _endCtrl   = TextEditingController();
  final _limitCtrl = TextEditingController();
  _ParseMode _mode = _ParseMode.followNext;

  @override
  void initState() {
    super.initState();
    _urlCtrl.addListener(() => setState(() {}));
    _chapterNumCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _urlCtrl.dispose(); _titleCtrl.dispose(); _chapterNumCtrl.dispose();
    _endCtrl.dispose(); _limitCtrl.dispose();
    super.dispose();
  }

  // Знаходить останнє входження номера розділу в URL і замінює на {n}
  String? get _detectedPattern {
    final url = _urlCtrl.text.trim();
    final numStr = _chapterNumCtrl.text.trim();
    if (url.isEmpty || numStr.isEmpty) return null;
    final lastIndex = url.lastIndexOf(numStr);
    if (lastIndex == -1) return null;
    return '${url.substring(0, lastIndex)}{n}${url.substring(lastIndex + numStr.length)}';
  }

  void _submit(BuildContext context) {
    final title = _titleCtrl.text.trim();
    final followNext = _mode == _ParseMode.followNext;

    if (followNext) {
      final url = _urlCtrl.text.trim();
      if (url.isEmpty || title.isEmpty) {
        _showError(context); return;
      }
      final limit = int.tryParse(_limitCtrl.text.trim());
      context.read<ConverterCubit>().startParsing(
        url: url, title: title,
        start: 1,
        end: limit ?? 9999,
        followNext: true,
      );
    } else {
      final pattern = _detectedPattern ?? _urlCtrl.text.trim();
      if (pattern.isEmpty || title.isEmpty) {
        _showError(context); return;
      }
      final start = int.tryParse(_chapterNumCtrl.text) ?? 1;
      final end   = int.tryParse(_endCtrl.text.trim()) ?? 9999;
      context.read<ConverterCubit>().startParsing(
        url: pattern, title: title,
        start: start, end: end,
        followNext: false,
      );
    }
  }

  void _showError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppTexts.fillFields)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ScreenHeader(),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ModeSelector(
                  selected: _mode,
                  onChanged: (m) => setState(() {
                    _mode = m;
                    _urlCtrl.clear();
                  }),
                ),
                const SizedBox(height: 24),

                if (_mode == _ParseMode.followNext) ...[
                  _Field(
                    label: AppTexts.urlFirstChapterLabel,
                    controller: _urlCtrl,
                    hint: AppTexts.urlFirstChapterHint,
                    helper: const _SimpleHint(AppTexts.followNextHelper),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  _Field(
                    label: AppTexts.limitLabel,
                    controller: _limitCtrl,
                    hint: AppTexts.limitHint,
                    helper: const _SimpleHint(AppTexts.limitHelper),
                    keyboardType: TextInputType.number,
                  ),
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _Field(
                          label: AppTexts.urlAnyChapterLabel,
                          controller: _urlCtrl,
                          hint: AppTexts.urlAnyChapterHint,
                          keyboardType: TextInputType.url,
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 72,
                        child: _Field(
                          label: AppTexts.chapterNumLabel,
                          controller: _chapterNumCtrl,
                          hint: '23',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  // Pattern preview
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: _detectedPattern != null
                        ? _PatternPreview(pattern: _detectedPattern!)
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _Field(
                          label: AppTexts.fromChapter,
                          controller: _chapterNumCtrl,
                          hint: '1',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          label: AppTexts.toChapter,
                          controller: _endCtrl,
                          hint: AppTexts.endChapterHint,
                          helper: const _SimpleHint(AppTexts.toChapterHelper),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),
                _Field(
                  label: AppTexts.titleLabel,
                  controller: _titleCtrl,
                  hint: AppTexts.titleHint,
                ),
                const SizedBox(height: 32),
                GoldButton(
                  label: AppTexts.processBtn,
                  icon: Icons.auto_stories,
                  onPressed: () => _submit(context),
                ),
              ],
            ),
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
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(child: _SegOpt(
            topLabel: AppTexts.modeFollowNextLabel,
            subLabel: AppTexts.modeFollowNext,
            active: selected == _ParseMode.followNext,
            onTap: () => onChanged(_ParseMode.followNext),
          )),
          const SizedBox(width: 5),
          Expanded(child: _SegOpt(
            topLabel: AppTexts.modePatternLabel,
            subLabel: AppTexts.modePatternSub,
            active: selected == _ParseMode.pattern,
            onTap: () => onChanged(_ParseMode.pattern),
          )),
        ],
      ),
    );
  }
}

class _PatternPreview extends StatelessWidget {
  const _PatternPreview({required this.pattern});
  final String pattern;

  @override
  Widget build(BuildContext context) {
    // Виділяємо {n} жирним золотим кольором
    final parts = pattern.split('{n}');
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.goldSoft,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.goldLine),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.gold, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: AppTypography.code,
                children: [
                  for (var i = 0; i < parts.length; i++) ...[
                    TextSpan(text: parts[i]),
                    if (i < parts.length - 1)
                      TextSpan(
                        text: '{n}',
                        style: AppTypography.code.copyWith(
                          color: AppColors.goldBright,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegOpt extends StatelessWidget {
  const _SegOpt({
    required this.topLabel,
    required this.subLabel,
    required this.active,
    required this.onTap,
  });
  final String topLabel;
  final String subLabel;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
        decoration: BoxDecoration(
          gradient: active ? AppColors.goldGradient : null,
          borderRadius: BorderRadius.circular(11),
          boxShadow: active
              ? [BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )]
              : null,
        ),
        child: Column(
          children: [
            Text(
              topLabel,
              style: AppTypography.label.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? AppColors.inkBtn : AppColors.text3,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subLabel,
              style: AppTypography.meta.copyWith(
                fontSize: 10.5,
                color: active ? AppColors.segActiveText : AppColors.text3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatefulWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.helper,
    this.keyboardType = TextInputType.text,
  });
  final String label;
  final TextEditingController controller;
  final String hint;
  final Widget? helper;
  final TextInputType keyboardType;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: AppTypography.label),
        const SizedBox(height: 9),
        Focus(
          onFocusChange: (f) => setState(() => _focused = f),
          child: TextField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            style: AppTypography.body,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTypography.body.copyWith(color: AppColors.text3),
              filled: true,
              fillColor: _focused ? AppColors.inputFocusedBg : AppColors.surface,
              border: _border(),
              enabledBorder: _border(),
              focusedBorder: _border(color: AppColors.goldLine),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            ),
          ),
        ),
        if (widget.helper != null) ...[
          const SizedBox(height: 8),
          DefaultTextStyle(
            style: AppTypography.hint,
            child: widget.helper!,
          ),
        ],
      ],
    );
  }

  OutlineInputBorder _border({Color color = AppColors.line}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: 1.5),
      );
}

class _SimpleHint extends StatelessWidget {
  const _SimpleHint(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text);
}

// ─── Status layout ────────────────────────────────────────────────────────────
class _StatusView extends StatelessWidget {
  const _StatusView({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.extra,
    this.actions = const [],
  });
  final Widget icon;
  final String title;
  final String subtitle;
  final Widget? extra;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        children: [
          const _ScreenHeader(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.06),
          icon,
          const SizedBox(height: 32),
          Text(
            title,
            style: AppTypography.serifH2,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 280,
            child: Text(
              subtitle,
              style: AppTypography.body.copyWith(fontSize: 14.5, color: AppColors.text3, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
          if (extra != null) ...[const SizedBox(height: 20), extra!],
          const SizedBox(height: 40),
          ...actions,
        ],
      ),
    );
  }
}

// ─── Waking view ──────────────────────────────────────────────────────────────
class _WakingView extends StatefulWidget {
  const _WakingView();
  @override
  State<_WakingView> createState() => _WakingViewState();
}

class _WakingViewState extends State<_WakingView> {
  int _elapsed = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1),
        (_) { if (mounted) setState(() => _elapsed++); });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  (String, String) get _stage =>
      AppTexts.wakingStages[(_elapsed ~/ 7).clamp(0, AppTexts.wakingStages.length - 1)];

  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = _stage;
    return _StatusView(
      icon: const _GoldRing(size: 200, spinning: true, child: Icon(Icons.auto_stories, color: AppColors.gold, size: 52)),
      title: title,
      subtitle: subtitle,
      extra: Text('$_elapsed с',
          style: AppTypography.meta.copyWith(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.goldDeep)),
      actions: [
        TextButton(
          onPressed: () => context.read<ConverterCubit>().cancel(),
          child: Text(AppTexts.cancelBtn,
              style: AppTypography.btnPrimary.copyWith(fontSize: 15, color: AppColors.danger)),
        ),
      ],
    );
  }
}

// ─── Running view ─────────────────────────────────────────────────────────────
class _RunningView extends StatelessWidget {
  const _RunningView({required this.state});
  final ConverterRunning state;

  @override
  Widget build(BuildContext context) {
    final job = state.job;
    return _StatusView(
      icon: SizedBox(
        width: 200,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: job.total > 0 ? job.progressFraction : null,
                strokeWidth: 5,
                color: AppColors.gold,
                backgroundColor: AppColors.goldSoft,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${job.progress}',
                  style: const TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    color: AppColors.goldBright,
                    height: 1,
                  ),
                ),
                if (job.total > 0)
                  Text(
                    '/ ${job.total}',
                    style: AppTypography.body.copyWith(color: AppColors.text3),
                  ),
              ],
            ),
          ],
        ),
      ),
      title: job.current.isEmpty ? AppTexts.loadingTitle : job.current,
      subtitle: AppTexts.dontClose,
      extra: job.total > 0
          ? ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: LinearProgressIndicator(
                value: job.progressFraction,
                minHeight: 5,
                backgroundColor: AppColors.goldSoft,
                color: AppColors.gold,
              ),
            )
          : null,
      actions: [
        TextButton(
          onPressed: () => context.read<ConverterCubit>().cancel(),
          child: Text(AppTexts.cancelBtn,
              style: AppTypography.btnPrimary.copyWith(fontSize: 15, color: AppColors.danger)),
        ),
      ],
    );
  }
}

// ─── Done view ────────────────────────────────────────────────────────────────
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
    return _StatusView(
      icon: const _GoldRing(
        size: 200,
        child: Icon(Icons.check_rounded, color: AppColors.goldBright, size: 64),
      ),
      title: '${job.total} ${AppTexts.readySuffix}',
      subtitle: AppTexts.epubBuiltHint,
      actions: [
        GoldButton(
          label: AppTexts.publishBtn,
          icon: Icons.rocket_launch,
          loading: publishing,
          onPressed: publishing ? null : () => context.read<ConverterCubit>().publish(),
        ),
        const SizedBox(height: 14),
        TextLinkButton(
          label: AppTexts.backToConverter,
          onPressed: () => context.read<ConverterCubit>().reset(),
        ),
      ],
    );
  }
}

// ─── Published view ───────────────────────────────────────────────────────────
class _PublishedView extends StatelessWidget {
  const _PublishedView({required this.state});
  final ConverterPublished state;

  @override
  Widget build(BuildContext context) {
    return _StatusView(
      icon: const Icon(Icons.rocket_launch, color: AppColors.gold, size: 64),
      title: AppTexts.bookPublished,
      subtitle: AppTexts.publishedHint,
      actions: [
        GoldButton(
          label: AppTexts.openLibrary,
          icon: Icons.library_books,
          onPressed: () => context.go('/library'),
        ),
        const SizedBox(height: 14),
        TextLinkButton(
          label: AppTexts.backToConverter,
          onPressed: () => context.read<ConverterCubit>().reset(),
        ),
      ],
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.state});
  final ConverterError state;

  @override
  Widget build(BuildContext context) {
    return _StatusView(
      icon: Container(
        width: 96, height: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.danger.withValues(alpha: 0.12),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.3), width: 2),
        ),
        child: const Icon(Icons.error_outline, color: AppColors.danger, size: 40),
      ),
      title: AppTexts.somethingWrong,
      subtitle: state.message,
      actions: [
        GoldButton(
          label: AppTexts.tryAgain,
          onPressed: () => context.read<ConverterCubit>().reset(),
        ),
      ],
    );
  }
}

// ─── Cancelled view ───────────────────────────────────────────────────────────
class _CancelledView extends StatelessWidget {
  const _CancelledView();

  @override
  Widget build(BuildContext context) {
    return _StatusView(
      icon: Container(
        width: 96, height: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          border: Border.all(color: AppColors.lineStrong, width: 1.5),
        ),
        child: const Icon(Icons.close_rounded, color: AppColors.text3, size: 38),
      ),
      title: AppTexts.cancelledTitle,
      subtitle: AppTexts.nothingDownloaded,
      actions: [
        GoldButton(
          label: AppTexts.backToConverter,
          onPressed: () => context.read<ConverterCubit>().reset(),
        ),
      ],
    );
  }
}

// ─── Shared: gold ring ────────────────────────────────────────────────────────
class _GoldRing extends StatelessWidget {
  const _GoldRing({required this.size, required this.child, this.spinning = false});
  final double size;
  final Widget child;
  final bool spinning;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: spinning ? null : 1.0,
              strokeWidth: 5,
              color: AppColors.gold,
              backgroundColor: AppColors.goldSoft,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
