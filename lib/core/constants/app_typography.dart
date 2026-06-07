import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  static TextStyle get eyebrow => TextStyle(fontFamily: 'Manrope', 
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.18 * 12,
        color: AppColors.goldDeep,
      );

  static TextStyle get displayTitle => TextStyle(fontFamily: 'Lora', 
        fontSize: 34,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.01 * 34,
        height: 1.05,
        color: AppColors.text,
      );

  static TextStyle get serifH2 => TextStyle(fontFamily: 'Lora', 
        fontSize: 23,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      );

  static TextStyle get bookTitle => TextStyle(fontFamily: 'Lora', 
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.goldBright,
      );

  static TextStyle get body => TextStyle(fontFamily: 'Manrope', 
        fontSize: 16,
        color: AppColors.text,
      );

  static TextStyle get label => TextStyle(fontFamily: 'Manrope', 
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: AppColors.text2,
      );

  static TextStyle get hint => TextStyle(fontFamily: 'Manrope', 
        fontSize: 12.5,
        color: AppColors.text3,
      );

  static TextStyle get meta => TextStyle(fontFamily: 'Manrope', 
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.text3,
      );

  static TextStyle get btnPrimary => TextStyle(fontFamily: 'Manrope', 
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.inkBtn,
      );

  static TextStyle get tabLabel => TextStyle(fontFamily: 'Manrope',
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.01 * 11.5,
      );

  static TextStyle get code => const TextStyle(
        fontFamily: 'monospace',
        fontSize: 12,
        color: AppColors.text2,
      );

  static TextStyle get splashLogo => const TextStyle(
        fontFamily: 'Lora',
        fontSize: 38,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.16 * 38,
        color: Colors.white,
      );
}
