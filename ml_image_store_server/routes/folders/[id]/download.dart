import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart' as archive;
import 'package:dart_frog/dart_frog.dart';
import 'package:image/image.dart' as img_util;
import 'package:ml_image_store/model/image/feature.dart';
import 'package:ml_image_store/model/image/image.dart';
import 'package:ml_image_store/model/image/point.dart';

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

  final type = context.request.url.queryParameters['type'] ?? 'fullJson';
  final size = int.tryParse(context.request.url.queryParameters['type'] ?? '') ?? 640;

  final filePath = './temp/${folder.id}-$type.zip';

  final zipFile = File(filePath);
  if (zipFile.existsSync()) {
    zipFile.deleteSync();
  }

  final bytes = switch (type) {
    'yolo' => _encodeYolo(filePath, images, size),
    'fullJson' => _encodeFullJson(filePath, images, size),
    String() => _encodeFullJson(filePath, images, size),
  };

  return Response.bytes(
    body: bytes,
    headers: {
      'Content-Disposition': 'attachment; filename=${folder.name}-$type.zip',
    },
  );
}

Point resizePoint(Point point, int size, int originalWidth, int originalHeight) {
  return Point(
    x: ((point.x / originalWidth) * size).toInt(),
    y: ((point.y / originalHeight) * size).toInt(),
    id: point.id,
  );
}

Feature resizeFeature(Feature feature, int size, int originalWidth, int originalHeight) {
  return Feature(
    id: feature.id,
    points: feature.points.map((e) => resizePoint(e, size, originalWidth, originalHeight)).toList(),
    className: feature.className,
  );
}

ImageData resizeImage(Image image, int size) {
  final bytes = File('./uploads/${image.fileId}.png').readAsBytesSync();
  final img = img_util.decodePng(bytes);
  final resized = img_util.copyResize(img!, width: size, height: size);
  final pointsData = image.features.map((e) => resizeFeature(e, size, img.width, img.height));

  return ImageData(resized, Image(id: image.id, features: pointsData.toList(), fileId: image.fileId));
}

class ImageData {
  ImageData(this.bytes, this.image);

  final img_util.Image bytes;
  final Image image;
}

Uint8List _encodeFullJson(String filePath, List<Image> images, int size) {
  final encoder = archive.ZipFileEncoder()..create(filePath);

  for (var i = 0; i < images.length; i++) {
    final image = resizeImage(images[i], size);
    encoder
      ..addArchiveFile(archive.ArchiveFile('image-$i.png', 0, img_util.encodePng(image.bytes)))
      ..addArchiveFile(archive.ArchiveFile('points-$i.json', 0, jsonEncode(image.image.features)));
  }

  encoder.close();

  return File(filePath).readAsBytesSync();
}

Uint8List _encodeYolo(String filePath, List<Image> images, int size) {
  final encoder = archive.ZipFileEncoder()..create(filePath);

  final labels = <String, int>{};
  final labelsReversed = <int, String>{};
  var labelIndex = 0;

  for (var i = 0; i < images.length; i++) {
    final image = resizeImage(images[i], size);

    final pointsBuffer = StringBuffer();

    for (final feature in image.image.features) {
      if (feature.points.length != 2) continue;
      if (labels[feature.className] == null) {
        labels[feature.className] = labelIndex;
        labelsReversed[labelIndex] = feature.className;
        labelIndex++;
      }
      final centerX = (feature.points[0].x - feature.points[1].x).abs() / 2;
      final centerY = (feature.points[0].y - feature.points[1].y).abs() / 2;
      final width = (feature.points[0].x - feature.points[1].x).abs();
      final height = (feature.points[0].y - feature.points[1].y).abs();

      final yoloCenterX = centerX / size;
      final yoloCenterY = centerY / size;
      final yoloWidth = width / size;
      final yoloHeight = height / size;

      pointsBuffer.writeln('${labels[feature.className]} $yoloCenterX $yoloCenterY $yoloWidth $yoloHeight');
    }

    encoder
      ..addArchiveFile(archive.ArchiveFile('images/image-$i.png', 0, img_util.encodePng(image.bytes)))
      ..addArchiveFile(archive.ArchiveFile('labels/labels-$i.json', 0, pointsBuffer.toString()));
  }

  final classesBuffer = StringBuffer();

  for (var i = 0; i < labelIndex; i++) {
    classesBuffer.writeln(labelsReversed[i]);
  }

  encoder
    ..addArchiveFile(archive.ArchiveFile('classes.txt', 0, classesBuffer.toString()))
    ..close();

  return File(filePath).readAsBytesSync();
}
