import 'package:flutter/material.dart';

abstract final class AppColors {
  // Surfaces
  static const ink        = Color(0xFF090D18);
  static const bg         = Color(0xFF0E1426);
  static const bgGrad1    = Color(0xFF121A30);
  static const bgGrad2    = Color(0xFF0B1020);
  static const surface    = Color(0xFF161F38);
  static const surface2   = Color(0xFF1C2742);
  static const line       = Color(0x14D6E2FF);
  static const lineStrong = Color(0x29D6E2FF);

  // Gold
  static const gold       = Color(0xFFD9B870);
  static const goldBright = Color(0xFFEFD193);
  static const goldDeep   = Color(0xFFB0894A);
  static const goldSoft   = Color(0x22D9B870);
  static const goldLine   = Color(0x4DD9B870);

  // Text
  static const text   = Color(0xFFF4F6FB);
  static const text2  = Color(0xFFA7B2CA);
  static const text3  = Color(0xFF69748F);

  // Status
  static const danger = Color(0xFFFF6E5C);
  static const ok     = Color(0xFF6FCF97);

  // Component-specific
  static const inkBtn         = Color(0xFF1A1305);
  static const inputFocusedBg = Color(0xFF18223D);
  static const dialogBarrier  = Color(0xFF060912);
  static const segActiveText  = Color(0xFF2E2207);

  // Splash
  static const splashBg1   = Color(0xFF141D33);
  static const splashBg2   = Color(0xFF0D1326);
  static const splashBg3   = Color(0xFF080C17);
  static const splashCard1  = Color(0xFF1D2848);
  static const splashCard2  = Color(0xFF131C33);

  // Dialog surfaces
  static const dialogSurf1 = Color(0xFF1A2440);
  static const dialogSurf2 = Color(0xFF141D34);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [goldBright, gold, goldDeep],
    stops: [0.0, 0.55, 1.0],
  );

  static const RadialGradient bgGradient = RadialGradient(
    center: Alignment(0, -1),
    radius: 1.2,
    colors: [bgGrad1, bg, bgGrad2],
    stops: [0.0, 0.46, 1.0],
  );
}
