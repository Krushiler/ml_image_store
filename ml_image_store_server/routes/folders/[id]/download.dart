import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart' as archive;
import 'package:dart_frog/dart_frog.dart';

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

  final filePath = './temp/${folder.id}.zip';

  final zipFile = File(filePath);
  if (zipFile.existsSync()) {
    zipFile.deleteSync();
  }

  final encoder = archive.ZipFileEncoder()..create(filePath);

  for (var i = 0; i < images.length; i++) {
    final image = images[i];
    final bytes = File('./uploads/${image.fileId}.png').readAsBytesSync();
    encoder.addArchiveFile(archive.ArchiveFile('image-$i.png', 0, bytes));

    final pointsData = jsonEncode(image.features);
    encoder.addArchiveFile(archive.ArchiveFile('points-$i.dat', 0, pointsData));
  }

  encoder.close();

  final bytes = File(filePath).readAsBytesSync();
  return Response.bytes(
    body: bytes,
    headers: {
      'Content-Disposition': 'attachment; filename=${folder.name}.zip',
    },
  );
}
