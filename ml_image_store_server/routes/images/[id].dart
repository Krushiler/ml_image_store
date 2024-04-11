import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../repository/images_repository.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  return switch (context.request.method) {
    HttpMethod.get => _onGet(context, id),
    HttpMethod.delete => _onDelete(context, id),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onGet(RequestContext context, String id) async {
  try {
    final repository = context.read<ImagesRepository>();
    return Response.json(body: (await repository.getImage(id)).toJson());
  } catch (_) {
    return Response(statusCode: HttpStatus.notFound);
  }
}

Future<Response> _onDelete(RequestContext context, String id) async {
  try {
    final repository = context.read<ImagesRepository>();
    await repository.deleteImage(id);
    return Response();
  } catch (_) {
    return Response(statusCode: HttpStatus.notFound);
  }
}
