import 'package:ml_image_store/model/theme/theme_config.dart';
import 'package:ml_image_store_app/data/storage/base/base_storage.dart';

class ThemeConfigStorage extends BaseStorage<ThemeConfig> {
  ThemeConfigStorage() : super(initialData: ThemeConfig.defaultTheme());
}
