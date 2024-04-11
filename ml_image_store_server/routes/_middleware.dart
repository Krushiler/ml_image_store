import 'package:dart_frog/dart_frog.dart';

import '../middleware/app_auth.dart';
import '../middleware/providers.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(appAuth())
      .use(imagesMiddlewareProvider())
      .use(authMiddlewareProvider())
      .use(foldersMiddlewareProvider())
      .use(storageMiddlewareProvider());
}
