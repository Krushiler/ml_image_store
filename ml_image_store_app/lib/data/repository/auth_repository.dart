import 'package:ml_image_store/request/register_request.dart';
import 'package:ml_image_store_app/data/network/ml_image_api.dart';
import 'package:ml_image_store_app/data/storage/auth_storage.dart';
import 'package:ml_image_store/request/login_request.dart';

class AuthRepository {
  final MlImageApi _api;
  final AuthStorage _authStorage;

  const AuthRepository(this._api, this._authStorage);

  Future<void> login(String name, String password) async {
    final response = await _api.login(LoginRequest(username: name, password: password));
    _authStorage.put(response.token);
  }

  Future<void> register(String name, String password) async {
    final response = await _api.register(RegisterRequest(username: name, password: password));
    _authStorage.put(response.token);
  }

  Future<void> clear() async {
    await _authStorage.clear();
  }

  Stream<String?> watchAuth() => _authStorage.watch();
}
