import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:ml_image_store/model/image/point.dart';
import 'package:uuid/uuid.dart';

import '../../repository/images_repository.dart';

Future<Response> onRequest(RequestContext context) {
  return switch (context.request.method) {
    HttpMethod.post => _onPost(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onPost(RequestContext context) async {
  final data = await context.request.formData();
  final image = data.files['image'];
  if (image == null) return Response(statusCode: HttpStatus.badRequest);
  final bytes = await image.readAsBytes();
  final fileName = const Uuid().v4();
  final file = await File('./uploads/$fileName.png').create(recursive: true);
  await file.writeAsBytes(bytes);
  final repository = context.read<ImagesRepository>();
  await repository.createImage(
    data.fields['folderId']!,
    fileName,
    Point.fromJson(jsonDecode(data.fields['leftTop']!) as Map<String, dynamic>),
    Point.fromJson(jsonDecode(data.fields['rightBottom']!) as Map<String, dynamic>),
  );
  return Response();
}
