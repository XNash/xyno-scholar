import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData light() {
    const colors = AppColors.light;
    final textTheme = AppTypography.textTheme(colors);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.amber,
      brightness: Brightness.light,
      primary: colors.amber,
      onPrimary: colors.amberOn,
      secondary: colors.teal,
      onSecondary: colors.tealOn,
      error: colors.rose,
      onError: colors.roseOn,
      surface: colors.surface,
      onSurface: colors.ink,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.parchment,
      colorScheme: colorScheme,
      textTheme: textTheme,
      extensions: const [colors],
      dividerColor: colors.border,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.ink,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.serif(
          weight: FontWeight.w600,
          fontSize: 22,
          color: colors.ink,
        ),
        iconTheme: IconThemeData(color: colors.ink),
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceRaised,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.border),
        ),
      ),
      dividerTheme: DividerThemeData(color: colors.border, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.teal, width: 1.5),
        ),
        hintStyle: AppTypography.sans(color: colors.inkMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.amber,
          foregroundColor: colors.amberOn,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTypography.sans(weight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.ink,
          side: BorderSide(color: colors.border),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTypography.sans(weight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.teal,
          textStyle: AppTypography.sans(weight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.parchment,
        selectedColor: colors.teal.withValues(alpha: 0.16),
        labelStyle: AppTypography.sans(fontSize: 13, color: colors.ink),
        side: BorderSide(color: colors.border),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colors.teal,
        unselectedLabelColor: colors.inkMuted,
        indicatorColor: colors.teal,
        labelStyle: AppTypography.sans(weight: FontWeight.w600),
        unselectedLabelStyle: AppTypography.sans(weight: FontWeight.w500),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.ink,
        contentTextStyle: AppTypography.sans(color: colors.parchment),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.teal),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? colors.teal : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.teal.withValues(alpha: 0.4)
              : null,
        ),
      ),
    );
  }
}
