import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:ml_image_store/model/auth/user.dart';
import 'package:ml_image_store/request/create_folder_request.dart';

import '../../repository/folders_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _onGet(context),
    HttpMethod.post => _onPost(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onGet(RequestContext context) async {
  final user = context.read<User>();
  final foldersRepository = context.read<FoldersRepository>();
  final folders = await foldersRepository.getUserFolders(user.id);
  final jsonArray = folders.map((e) => e.toJson()).toList();
  return Response.json(body: jsonArray);
}

Future<Response> _onPost(RequestContext context) async {
  final user = context.read<User>();
  final body = (await context.request.json()) as Map<String, dynamic>;
  final request = CreateFolderRequest.fromJson(body);
  final foldersRepository = context.read<FoldersRepository>();
  await foldersRepository.createFolder(user.id, request.name);
  return Response();
}
