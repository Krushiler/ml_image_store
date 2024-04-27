import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../../repository/folders_repository.dart';
import '../../../repository/images_repository.dart';
import '../../../util/download/coco_encoder.dart';
import '../../../util/download/csv_encoder.dart';
import '../../../util/download/download_encoder.dart';
import '../../../util/download/json_encoder.dart';
import '../../../util/download/yolo_encoder.dart';

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
  final foldersRepository = context.read<FoldersRepository>();
  final folder = await foldersRepository.getFolder(id);
  final repository = context.read<ImagesRepository>();
  final images = await repository.getImages(id);

  final type = context.request.url.queryParameters['type'] ?? 'fullJson';
  final width = int.tryParse(context.request.url.queryParameters['width'] ?? '');
  final height = int.tryParse(context.request.url.queryParameters['height'] ?? '');
  final maintainAspect = bool.tryParse(context.request.url.queryParameters['maintainAspect'] ?? '') ?? false;

  final filePath = './temp/${folder.id}-$type.zip';

  final zipFile = File(filePath);
  if (zipFile.existsSync()) {
    zipFile.deleteSync();
  }

  final DownloadEncoder encoder = switch (type) {
    'yolo' => YoloEncoder(),
    'csv' => CsvEncoder(),
    'coco' => CocoEncoder(),
    'fullJson' => JsonEncoder(),
    String() => JsonEncoder(),
  };

  final bytes = await encoder.encode(filePath, images, width, height, maintainAspect);

  return Response.bytes(
    body: bytes,
    headers: {
      'Content-Disposition': 'attachment; filename=${folder.name}-$type.zip',
    },
  );
}
