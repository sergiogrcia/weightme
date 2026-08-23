import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const fontFamily = 'Inter';

  static const displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    height: 56 / 48,
    letterSpacing: -0.96,
    color: AppColors.textPrimary,
  );

  static const headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: -0.32,
    color: AppColors.textPrimary,
  );

  static const titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    color: AppColors.textPrimary,
  );

  static const bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: AppColors.textPrimary,
  );

  static const bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.textSecondary,
  );

  static const labelCaps = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: 0.6,
    color: AppColors.textSecondary,
  );
}
