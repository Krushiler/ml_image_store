import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:ml_image_store/request/register_request.dart';
import 'package:ml_image_store/response/auth_response.dart';

import '../../repository/auth_repository.dart';

Future<Response> onRequest(RequestContext context) {
  return switch (context.request.method) {
    HttpMethod.post => _onPost(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onPost(RequestContext context) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final request = RegisterRequest.fromJson(body);

  final authenticator = context.read<AuthRepository>();

  final token = await authenticator.register(request.username, request.password);

  if (token == null) {
    return Response(statusCode: HttpStatus.unauthorized, body: 'Incorrect loigin or password');
  } else {
    return Response.json(body: AuthResponse(token: token).toJson());
  }
}
