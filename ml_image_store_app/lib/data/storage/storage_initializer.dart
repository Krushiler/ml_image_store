import 'package:hive_flutter/hive_flutter.dart';
import 'package:ml_image_store_app/data/storage/base/hive_json_object.dart';

class StorageInitializer {
  const StorageInitializer._();

  static const _dbVersion = 'v1';

  static Future<void> init() async {
    await Hive.initFlutter(_dbVersion);

    Hive.registerAdapter(HiveJsonObjectAdapter());
  }
}
