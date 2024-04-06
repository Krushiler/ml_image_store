import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../repository/auth_repository.dart';

Future<Response> onRequest(RequestContext context) {
  return switch (context.request.method) {
    HttpMethod.post => _onPost(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onPost(RequestContext context) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final username = body['username'] as String?;
  final password = body['password'] as String?;

  if (username == null || password == null) {
    return Response(statusCode: HttpStatus.badRequest);
  }

  final authenticator = context.read<AuthRepository>();

  final token = await authenticator.register(username, password);

  if (token == null) {
    return Response(statusCode: HttpStatus.unauthorized);
  } else {
    return Response.json(
      body: {'token': token},
    );
  }
}
