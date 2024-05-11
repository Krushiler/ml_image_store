import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:ml_image_store/model/paging/paging_params.dart';

import '../../../repository/images_repository.dart';

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
  final repository = context.read<ImagesRepository>();
  final limit = int.tryParse(context.request.url.queryParameters['limit'] ?? '');
  final offset = int.tryParse(context.request.url.queryParameters['offset'] ?? '');
  final pagingParams = limit != null && offset != null ? PagingParams(limit: limit, offset: offset) : null;
  final images = await repository.getImages(id, pagingParams);
  return Response.json(body: images);
}
