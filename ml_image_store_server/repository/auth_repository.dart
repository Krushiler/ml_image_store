import 'package:ml_image_store/model/auth/user.dart';

import '../database/storage.dart';

class AuthRepository {
  AuthRepository(this._storage);

  final Storage _storage;

  Future<String?> login(String name, String password) async {
    final userRow = (await _storage.getUserByLogin(name))?.toColumnMap();
    if (userRow == null) return null;
    if (userRow['password'] != password) return null;
    return userRow['token']?.toString();
  }

  Future<String?> register(String name, String password) async {
    final userRow = (await _storage.getUserByLogin(name))?.toColumnMap();
    if (userRow != null) return null;
    return _storage.createUser(name, password);
  }
}
