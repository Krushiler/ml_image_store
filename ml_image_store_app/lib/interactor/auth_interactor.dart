import 'package:ml_image_store_app/data/repository/auth_repository.dart';

class AuthInteractor {
  final AuthRepository _authRepository;

  const AuthInteractor(this._authRepository);

  Future<void> login(String name, String password) => _authRepository.login(name, password);

  Future<void> register(String name, String password) => _authRepository.register(name, password);

  Future<void> logout() => _authRepository.clear();

  Stream<String?> watchAuth() => _authRepository.watchAuth();
}
