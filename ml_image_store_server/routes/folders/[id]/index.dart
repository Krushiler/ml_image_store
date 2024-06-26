import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:ml_image_store/model/auth/user.dart';
import 'package:ml_image_store/model/paging/paging_params.dart';

import '../../../repository/folders_repository.dart';
import '../../../repository/images_repository.dart';

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
  final foldersRepository = context.read<FoldersRepository>();
  final folder = await foldersRepository.getFolder(id);
  return Response.json(body: folder);
}

Future<Response> _onDelete(RequestContext context, String id) async {
  try {
    final user = context.read<User>();
    final repository = context.read<FoldersRepository>();
    await repository.deleteFolder(user.id, id);
    return Response();
  } catch (_) {
    return Response(statusCode: HttpStatus.notFound);
  }
}
