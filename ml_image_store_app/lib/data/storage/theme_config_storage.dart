import 'package:ml_image_store/model/theme/theme_config.dart';
import 'package:ml_image_store_app/data/storage/base/hive_json_storage.dart';

class ThemeConfigStorage extends HiveJsonStorage<ThemeConfig> {
  ThemeConfigStorage()
      : super(
          key: 'theme_config',
          fromJson: ThemeConfig.fromJson,
          toJson: (e) => e.toJson(),
        );
}
