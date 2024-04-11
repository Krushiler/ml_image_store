import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:ml_image_store/model/auth/user.dart';

import '../repository/auth_repository.dart';

Middleware appAuth() {
  return bearerAuthentication<User>(
    authenticator: (context, token) async {
      final repo = context.read<AuthRepository>();
      return repo.getUserByToken(token);
    },
    applies: (context) async {
      if (context.request.url.pathSegments[0] == 'auth') {
        return false;
      }
      return true;
    },
  );
}
