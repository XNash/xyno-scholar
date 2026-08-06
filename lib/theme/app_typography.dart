import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Central font definitions. Every widget should pull fonts from the
/// [ThemeData.textTheme] (via this class) rather than hardcoding families.
class AppTypography {
  /// Serif display font — headings, topic titles, the problématique quote.
  static TextStyle serif({
    FontWeight weight = FontWeight.w600,
    FontStyle style = FontStyle.normal,
    double? fontSize,
    Color? color,
  }) => GoogleFonts.fraunces(
    fontWeight: weight,
    fontStyle: style,
    fontSize: fontSize,
    color: color,
  );

  /// Sans-serif — UI chrome and body prose.
  static TextStyle sans({
    FontWeight weight = FontWeight.w400,
    double? fontSize,
    Color? color,
  }) => GoogleFonts.inter(fontWeight: weight, fontSize: fontSize, color: color);

  /// Monospace — JSON inspector / technical bits.
  static TextStyle mono({
    FontWeight weight = FontWeight.w400,
    double? fontSize,
    Color? color,
  }) => GoogleFonts.jetBrainsMono(
    fontWeight: weight,
    fontSize: fontSize,
    color: color,
  );

  static TextTheme textTheme(AppColors colors) {
    final base = GoogleFonts.interTextTheme();
    return base
        .copyWith(
          displayLarge: serif(
            weight: FontWeight.w600,
            fontSize: 40,
            color: colors.ink,
          ),
          displayMedium: serif(
            weight: FontWeight.w600,
            fontSize: 32,
            color: colors.ink,
          ),
          displaySmall: serif(
            weight: FontWeight.w600,
            fontSize: 26,
            color: colors.ink,
          ),
          headlineLarge: serif(
            weight: FontWeight.w600,
            fontSize: 24,
            color: colors.ink,
          ),
          headlineMedium: serif(
            weight: FontWeight.w600,
            fontSize: 20,
            color: colors.ink,
          ),
          headlineSmall: serif(
            weight: FontWeight.w600,
            fontSize: 18,
            color: colors.ink,
          ),
          titleLarge: sans(
            weight: FontWeight.w600,
            fontSize: 18,
            color: colors.ink,
          ),
          titleMedium: sans(
            weight: FontWeight.w600,
            fontSize: 15,
            color: colors.ink,
          ),
          titleSmall: sans(
            weight: FontWeight.w600,
            fontSize: 13,
            color: colors.ink,
          ),
          bodyLarge: sans(fontSize: 16, color: colors.ink),
          bodyMedium: sans(fontSize: 14, color: colors.ink),
          bodySmall: sans(fontSize: 12, color: colors.inkMuted),
          labelLarge: sans(
            weight: FontWeight.w600,
            fontSize: 14,
            color: colors.ink,
          ),
          labelMedium: sans(
            weight: FontWeight.w500,
            fontSize: 12,
            color: colors.inkMuted,
          ),
          labelSmall: sans(
            weight: FontWeight.w500,
            fontSize: 11,
            color: colors.inkMuted,
          ),
        )
        .apply(bodyColor: colors.ink, displayColor: colors.ink);
  }
}
