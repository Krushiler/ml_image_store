import 'package:ml_image_store_app/data/storage/base/hive_json_storage.dart';

class AuthStorage extends StringHiveJsonStorage {
  AuthStorage() : super(key: 'auth');
}
