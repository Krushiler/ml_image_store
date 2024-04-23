import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart' as archive;
import 'package:dart_frog/dart_frog.dart';
import 'package:ml_image_store/model/image/image.dart';

import 'package:image/image.dart' as IMG;
import '../../../repository/folders_repository.dart';
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
  final foldersRepository = context.read<FoldersRepository>();
  final folder = await foldersRepository.getFolder(id);
  final repository = context.read<ImagesRepository>();
  final images = await repository.getImages(id);

  final type = context.request.url.queryParameters['type'] ?? 'full';
  final size = int.tryParse(context.request.url.queryParameters['type'] ?? '') ?? 640;

  final filePath = './temp/${folder.id}-$type.zip';

  final zipFile = File(filePath);
  if (zipFile.existsSync()) {
    zipFile.deleteSync();
  }

  final bytes = _encodeFullJson(filePath, images, size);

  return Response.bytes(
    body: bytes,
    headers: {
      'Content-Disposition': 'attachment; filename=${folder.name}-$type.zip',
    },
  );
}

Uint8List _encodeFullJson(String filePath, List<Image> images, int size) {
  final encoder = archive.ZipFileEncoder()..create(filePath);

  for (var i = 0; i < images.length; i++) {
    final image = images[i];
    final bytes = File('./uploads/${image.fileId}.png').readAsBytesSync();
    final img = IMG.decodePng(bytes);
    final resized = IMG.copyResize(img!, width: size, height: size);
    encoder.addArchiveFile(archive.ArchiveFile('image-$i.png', 0, IMG.encodePng(resized)));

    final pointsData = jsonEncode(image.features);
    encoder.addArchiveFile(archive.ArchiveFile('points-$i.json', 0, pointsData));
  }

  encoder.close();

  return File(filePath).readAsBytesSync();
}

Uint8List _encodeYolo(String filePath, List<Image> images, int size) {
  final encoder = archive.ZipFileEncoder()..create(filePath);

  for (var i = 0; i < images.length; i++) {
    final image = images[i];
    final bytes = File('./uploads/${image.fileId}.png').readAsBytesSync();
    encoder.addArchiveFile(archive.ArchiveFile('image-$i.png', 0, bytes));

    final pointsData = jsonEncode(image.features);
    encoder.addArchiveFile(archive.ArchiveFile('points-$i.json', 0, pointsData));
  }

  encoder.close();

  return File(filePath).readAsBytesSync();
}
