import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_texts.dart';
import '../../core/constants/app_typography.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _glowCtrl;
  late final AnimationController _barCtrl;
  late final AnimationController _riseCtrl;
  late final AnimationController _exitCtrl;

  late final Animation<double> _glowScale;
  late final Animation<double> _glowOpacity;
  late final Animation<double> _barWidth;
  late final Animation<double> _riseY;
  late final Animation<double> _riseScale;
  late final Animation<double> _exitOpacity;
  late final Animation<double> _exitScale;

  @override
  void initState() {
    super.initState();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _riseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _glowScale = Tween(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
    _glowOpacity = Tween(begin: 0.55, end: 0.9).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
    _barWidth = Tween(begin: 0.04, end: 1.0).animate(
      CurvedAnimation(parent: _barCtrl, curve: Curves.easeInOutCubic),
    );
    _riseY = Tween(begin: 13.0, end: 0.0).animate(
      CurvedAnimation(parent: _riseCtrl, curve: Curves.easeOut),
    );
    _riseScale = Tween(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _riseCtrl, curve: Curves.easeOut),
    );
    _exitOpacity = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn),
    );
    _exitScale = Tween(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn),
    );

    // After 1.65s, start exit animation
    Future.delayed(const Duration(milliseconds: 1650), () {
      if (!mounted) return;
      _exitCtrl.forward().then((_) {
        if (mounted) widget.onDone();
      });
    });
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _barCtrl.dispose();
    _riseCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowCtrl, _barCtrl, _riseCtrl, _exitCtrl]),
      builder: (context, _) {
        return Opacity(
          opacity: _exitOpacity.value,
          child: Transform.scale(
            scale: _exitScale.value,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.3),
                  radius: 1.4,
                  colors: [AppColors.splashBg1, AppColors.splashBg2, AppColors.splashBg3],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: Transform.translate(
                    offset: Offset(0, _riseY.value),
                    child: Transform.scale(
                      scale: _riseScale.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Emblem
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Glow
                              Transform.scale(
                                scale: _glowScale.value,
                                child: Opacity(
                                  opacity: _glowOpacity.value,
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          AppColors.gold.withValues(alpha: 0.35),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Card
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(26),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [AppColors.splashCard1, AppColors.splashCard2],
                                    transform: GradientRotation(160 * math.pi / 180),
                                  ),
                                  border: Border.all(
                                    color: AppColors.goldLine,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.gold.withValues(alpha: 0.25),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.auto_stories,
                                  color: AppColors.gold,
                                  size: 46,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Wordmark
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColors.goldGradient.createShader(bounds),
                            child: Text(
                              AppTexts.splashWordmark,
                              style: AppTypography.splashLogo,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppTexts.splashSubtitle,
                            style: AppTypography.eyebrow.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text3,
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Loading bar
                          Container(
                            width: 168,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.goldSoft,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: _barWidth.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.goldDeep, AppColors.goldBright],
                                  ),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ),
          ),
        );
      },
    );
  }
}
