import 'package:dart_frog/dart_frog.dart';

import '../database/storage.dart';
import '../repository/auth_repository.dart';
import '../repository/folders_repository.dart';
import '../repository/images_repository.dart';

Middleware storageMiddlewareProvider() {
  return provider<Storage>((context) => Storage());
}

Middleware authMiddlewareProvider() {
  return provider<AuthRepository>((context) => AuthRepository(context.read()));
}

Middleware foldersMiddlewareProvider() {
  return provider<FoldersRepository>((context) => FoldersRepository(context.read()));
}

Middleware imagesMiddlewareProvider() {
  return provider<ImagesRepository>((context) => ImagesRepository(context.read()));
}
