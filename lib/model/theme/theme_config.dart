import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme_config.freezed.dart';

part 'theme_config.g.dart';

@freezed
class ThemeConfig with _$ThemeConfig {
  const ThemeConfig._();

  const factory ThemeConfig({
    required String primaryColor,
    required String accentColor,
    required bool isDark,
  }) = _ThemeConfig;

  factory ThemeConfig.defaultTheme() => const ThemeConfig(
        primaryColor: '#673AB7',
        accentColor: '#448AFF',
        isDark: false,
      );

  factory ThemeConfig.fromJson(Map<String, dynamic> json) => _$ThemeConfigFromJson(json);
}
