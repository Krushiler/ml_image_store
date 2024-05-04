import 'package:ml_image_store/model/theme/theme_config.dart';
import 'package:ml_image_store_app/data/storage/theme_config_storage.dart';

class ConfigRepository {
  final ThemeConfigStorage _storage;

  ConfigRepository(this._storage);

  Stream<ThemeConfig?> watchConfig() => _storage.watch();

  Future<void> saveConfig({
    String? primaryColor,
    String? accentColor,
    bool? isDark,
  }) async {
    final config = await _storage.get();
    await _storage.put(
      config?.copyWith(
              primaryColor: primaryColor ?? config.primaryColor,
              accentColor: accentColor ?? config.accentColor,
              isDark: isDark ?? config.isDark) ??
          ThemeConfig.defaultTheme(),
    );
  }
}
