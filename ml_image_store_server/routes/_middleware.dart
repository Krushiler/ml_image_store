import 'package:dart_frog/dart_frog.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import '../middleware/app_auth.dart';
import '../middleware/providers.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(appAuth())
      .use(imagesMiddlewareProvider())
      .use(authMiddlewareProvider())
      .use(foldersMiddlewareProvider())
      .use(storageMiddlewareProvider())
      .use(
        fromShelfMiddleware(
          corsHeaders(
            headers: {ACCESS_CONTROL_ALLOW_ORIGIN: '*'},
          ),
        ),
      );
}
