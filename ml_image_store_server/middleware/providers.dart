import 'package:dart_frog/dart_frog.dart';

import '../database/storage.dart';
import '../repository/auth_repository.dart';

Middleware storageMiddlewareProvider() {
  return provider<Storage>((context) => Storage());
}

Middleware authMiddlewareProvider() {
  return provider<AuthRepository>((context) => AuthRepository(context.read()));
}
