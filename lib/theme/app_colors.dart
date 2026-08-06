import 'package:flutter/material.dart';

/// Semantic accent colors, each with exactly one meaning, layered on top of
/// a warm "academic paper" base. Keep this the single source of truth for
/// color so no widget hardcodes a hue directly.
class AppColors extends ThemeExtension<AppColors> {
  final Color parchment;
  final Color surface;
  final Color surfaceRaised;
  final Color ink;
  final Color inkMuted;
  final Color border;

  /// Warm accent — primary actions, emphasis.
  final Color amber;
  final Color amberOn;

  /// Cool accent — interactive / active states (selected tabs, toggles).
  final Color teal;
  final Color tealOn;

  /// Reserved only for save/success actions.
  final Color success;
  final Color successOn;

  /// Reserved only for destructive actions, errors, key-rejected state.
  final Color rose;
  final Color roseOn;

  const AppColors({
    required this.parchment,
    required this.surface,
    required this.surfaceRaised,
    required this.ink,
    required this.inkMuted,
    required this.border,
    required this.amber,
    required this.amberOn,
    required this.teal,
    required this.tealOn,
    required this.success,
    required this.successOn,
    required this.rose,
    required this.roseOn,
  });

  static const light = AppColors(
    parchment: Color(0xFFF6F1E6),
    surface: Color(0xFFFFFDF8),
    surfaceRaised: Color(0xFFFFFFFF),
    ink: Color(0xFF2A2722),
    inkMuted: Color(0xFF6B6459),
    border: Color(0xFFE1D8C4),
    amber: Color(0xFFB8863E),
    amberOn: Color(0xFFFFFFFF),
    teal: Color(0xFF2F5D62),
    tealOn: Color(0xFFFFFFFF),
    success: Color(0xFF3F7D53),
    successOn: Color(0xFFFFFFFF),
    rose: Color(0xFFAE3E36),
    roseOn: Color(0xFFFFFFFF),
  );

  @override
  AppColors copyWith({
    Color? parchment,
    Color? surface,
    Color? surfaceRaised,
    Color? ink,
    Color? inkMuted,
    Color? border,
    Color? amber,
    Color? amberOn,
    Color? teal,
    Color? tealOn,
    Color? success,
    Color? successOn,
    Color? rose,
    Color? roseOn,
  }) {
    return AppColors(
      parchment: parchment ?? this.parchment,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      border: border ?? this.border,
      amber: amber ?? this.amber,
      amberOn: amberOn ?? this.amberOn,
      teal: teal ?? this.teal,
      tealOn: tealOn ?? this.tealOn,
      success: success ?? this.success,
      successOn: successOn ?? this.successOn,
      rose: rose ?? this.rose,
      roseOn: roseOn ?? this.roseOn,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      parchment: Color.lerp(parchment, other.parchment, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
      amberOn: Color.lerp(amberOn, other.amberOn, t)!,
      teal: Color.lerp(teal, other.teal, t)!,
      tealOn: Color.lerp(tealOn, other.tealOn, t)!,
      success: Color.lerp(success, other.success, t)!,
      successOn: Color.lerp(successOn, other.successOn, t)!,
      rose: Color.lerp(rose, other.rose, t)!,
      roseOn: Color.lerp(roseOn, other.roseOn, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
