import 'package:flutter/material.dart';
import 'package:ml_image_store_app/presentation/style/theme/app_colors.dart';
import 'package:ml_image_store/model/theme/theme_config.dart';
import 'package:ml_image_store_app/presentation/util/color_util.dart';

class AppTheme {
  final ThemeConfig themeConfig;

  late final AppColors appColors = AppColors(
    primary: MaterialColorGenerator.hexToMaterialColor(themeConfig.primaryColor),
    accent: MaterialColorGenerator.hexToMaterialColor(themeConfig.accentColor),
    brightness: themeConfig.isDark ? Brightness.dark : Brightness.light,
  );

  AppTheme(this.themeConfig);

  ThemeData createTheme() {
    return ThemeData(
      fontFamily: 'Roboto',
      brightness: appColors.brightness,
      primaryColor: appColors.primary,
      useMaterial3: false,
      extensions: [appColors],
      colorScheme: ColorScheme.light(
        primary: appColors.primary,
        secondary: appColors.accent,
        background: appColors.background,
        surface: appColors.accent.shade100,
        tertiaryContainer: appColors.accent.shade200,
        brightness: appColors.brightness,
      ),
      tabBarTheme: TabBarTheme(
        overlayColor: MaterialStatePropertyAll<Color>(appColors.primary),
        tabAlignment: TabAlignment.start,
      ),
      scaffoldBackgroundColor: appColors.background,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: appColors.primary,
        foregroundColor: appColors.foreground,
      ),
      dialogBackgroundColor: appColors.background,
      cardColor: appColors.background,
      cardTheme: CardTheme(
        color: appColors.background,
      ),
    );
  }
}
