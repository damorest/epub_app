import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class ProceduralCover extends StatelessWidget {
  const ProceduralCover({
    super.key,
    required this.title,
    this.width = 46,
    this.height = 63,
    this.borderRadius = 7,
  });

  final String title;
  final double width;
  final double height;
  final double borderRadius;

  static const _schemes = [
    (Color(0xFF214D3D), Color(0xFF0C2620), Color(0xFF3C8F6E)),
    (Color(0xFF3A2150), Color(0xFF180E2B), Color(0xFF7A4FB0)),
    (Color(0xFF5A1E2A), Color(0xFF260E14), Color(0xFFB24A5A)),
    (Color(0xFF1E2C5A), Color(0xFF0E1730), Color(0xFF4A63C0)),
    (Color(0xFF154149), Color(0xFF0A2127), Color(0xFF2F96A8)),
    (Color(0xFF4A3217), Color(0xFF23150B), Color(0xFFB5894A)),
    (Color(0xFF48173A), Color(0xFF220C1C), Color(0xFFA8457E)),
    (Color(0xFF2F3A18), Color(0xFF15190C), Color(0xFF7E9A3A)),
  ];

  (Color, Color, Color) get _scheme {
    var h = 0;
    for (final c in title.codeUnits) {
      h = (h * 31 + c) & 0x7FFFFFFF;
    }
    return _schemes[h % _schemes.length];
  }

  @override
  Widget build(BuildContext context) {
    final (g0, g1, glow) = _scheme;
    final letter = title.isNotEmpty ? title[0].toUpperCase() : '?';
    final fontSize = width * 0.46;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [g0, g1],
            transform: const GradientRotation(150 * 3.14159 / 180),
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.07),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: glow.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Spine line
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),
            // Glow
            Positioned(
              top: -width * 0.3,
              left: -width * 0.2,
              child: Container(
                width: width * 0.8,
                height: width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      glow.withValues(alpha: 0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // First letter
            Center(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.goldBright, AppColors.goldDeep],
                ).createShader(bounds),
                child: Text(
                  letter,
                  style: AppTypography.bookTitle.copyWith(
                    fontSize: fontSize,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
