import 'package:flutter/material.dart';
import 'package:ml_image_store_app/presentation/util/color_util.dart';

class AppColors extends ThemeExtension<AppColors> {
  final error = const Color(0xFFFD5F5F);

  final MaterialColor ternary = const MaterialColor(0xFF101317, {
    50: Color(0xFFF7F7F8),
    100: Color(0xFFF0F1F2),
    200: Color(0xFFDADDE0),
    300: Color(0xFFB4B9BF),
    400: Color(0xFF6E7883),
    500: Color(0xFF596471),
    600: Color(0xFF414D59),
    700: Color(0xFF282F37),
    800: Color(0xFF1F252B),
    900: Color(0xFF161A1F),
  });

  final MaterialColor primary;
  final MaterialColor accent;
  final Brightness brightness;

  late final Color background;
  late final Color foreground;

  AppColors({required this.primary, required this.accent, required this.brightness}) {
    background = brightness == Brightness.dark ? ternary.shade900 : ternary.shade50;
    foreground = brightness == Brightness.dark ? ternary.shade50 : ternary.shade900;
  }

  @override
  ThemeExtension<AppColors> copyWith({
    MaterialColor? primary,
    MaterialColor? accent,
    Brightness? brightness,
  }) =>
      AppColors(
        primary: primary ?? this.primary,
        accent: accent ?? this.accent,
        brightness: brightness ?? this.brightness,
      );

  @override
  ThemeExtension<AppColors> lerp(covariant AppColors other, double t) => AppColors(
    primary: MaterialColorGenerator.from(Color.lerp(primary, other.primary, t) ?? primary),
    accent: MaterialColorGenerator.from(Color.lerp(accent, other.accent, t) ?? accent),
    brightness: brightness,
  );
}