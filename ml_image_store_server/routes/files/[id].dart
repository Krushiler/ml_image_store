import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  return switch (context.request.method) {
    HttpMethod.get => _onGet(context, id),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onGet(RequestContext context, String id) async {
  try {
    final file = File('./uploads/$id.png');
    final bytes = await file.readAsBytes();
    return Response.bytes(
      body: bytes,
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.binary.value,
      },
    );
  } catch (_) {
    return Response(statusCode: HttpStatus.notFound);
  }
}
