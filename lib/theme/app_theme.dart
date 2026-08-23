import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: AppTypography.fontFamily,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Color(0xFF1000A9),
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: Color(0xFF0D0096),
      secondary: AppColors.secondary,
      onSecondary: Color(0xFF003731),
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: Color(0xFF004D44),
      tertiary: AppColors.tertiary,
      onTertiary: Color(0xFF67001B),
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: Color(0xFF5B0017),
      error: AppColors.error,
      onError: Color(0xFF690005),
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: const TextTheme(
      displayLarge: AppTypography.displayLarge,
      headlineLarge: AppTypography.headlineLarge,
      titleMedium: AppTypography.titleMedium,
      bodyLarge: AppTypography.bodyLarge,
      bodySmall: AppTypography.bodySmall,
      labelSmall: AppTypography.labelCaps,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLow,
      border: OutlineInputBorder(
        borderRadius: AppRadius.input,
        borderSide: BorderSide(color: AppColors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.input,
        borderSide: BorderSide(color: AppColors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.input,
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
      ),
    ),
  );
}
