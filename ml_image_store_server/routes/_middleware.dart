import 'package:dart_frog/dart_frog.dart';

import '../middleware/providers.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(authMiddlewareProvider())
      .use(storageMiddlewareProvider());
}
