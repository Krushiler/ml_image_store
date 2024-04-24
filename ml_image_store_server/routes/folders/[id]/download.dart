import 'dart:convert';
import 'dart:io';
import 'dart:math';
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
  final width = int.tryParse(context.request.url.queryParameters['width'] ?? '');
  final height = int.tryParse(context.request.url.queryParameters['height'] ?? '');
  final maintainAspect = bool.tryParse(context.request.url.queryParameters['maintainAspect'] ?? '') ?? false;

  final filePath = './temp/${folder.id}-$type.zip';

  final zipFile = File(filePath);
  if (zipFile.existsSync()) {
    zipFile.deleteSync();
  }

  final bytes = switch (type) {
    'yolo' => _encodeYolo(filePath, images, width, height, maintainAspect),
    'fullJson' => _encodeFullJson(filePath, images, width, height, maintainAspect),
    String() => _encodeFullJson(filePath, images, width, height, maintainAspect),
  };

  return Response.bytes(
    body: bytes,
    headers: {
      'Content-Disposition': 'attachment; filename=${folder.name}-$type.zip',
    },
  );
}

Point resizePoint(Point point, int width, int height, int originalWidth, int originalHeight, bool maintainAspect) {
  if (!maintainAspect) {
    return Point(
      x: ((point.x / originalWidth) * width).toInt(),
      y: ((point.y / originalHeight) * height).toInt(),
      id: point.id,
    );
  }
  final double widthMultiplier = width / originalWidth;
  final double heightMultiplier = height / originalHeight;

  final double sizeMultiplier = min(widthMultiplier, heightMultiplier);

  final imageViewWidth = originalWidth * sizeMultiplier;
  final imageViewHeight = originalHeight * sizeMultiplier;

  final imageStartX = (width - imageViewWidth) / 2;
  final imageStartY = (height - imageViewHeight) / 2;

  return Point(
    x: (imageStartX + point.x * sizeMultiplier).toInt(),
    y: (imageStartY + point.y * sizeMultiplier).toInt(),
    id: point.id,
  );
}

Feature resizeFeature(
  Feature feature,
  int width,
  int height,
  int originalWidth,
  int originalHeight,
  bool maintainAspect,
) {
  return Feature(
    id: feature.id,
    points: feature.points
        .map((e) => resizePoint(e, width, height, originalWidth, originalHeight, maintainAspect))
        .toList(),
    className: feature.className,
  );
}

ImageData resizeImage(Image image, int? width, int? height, bool maintainAspect) {
  final bytes = File('./uploads/${image.fileId}.png').readAsBytesSync();
  final img = img_util.decodeImage(bytes);
  if (width == null || height == null) {
    return ImageData(img!, image);
  }
  final resized = img_util.copyResize(img!, width: width, height: height, maintainAspect: maintainAspect);
  final pointsData = image.features.map((e) => resizeFeature(e, width, height, img.width, img.height, maintainAspect));

  return ImageData(resized, Image(id: image.id, features: pointsData.toList(), fileId: image.fileId));
}

class ImageData {
  ImageData(this.bytes, this.image);

  final img_util.Image bytes;
  final Image image;
}

Uint8List _encodeFullJson(String filePath, List<Image> images, int? width, int? height, bool maintainAspect) {
  final encoder = archive.ZipFileEncoder()..create(filePath);

  for (var i = 0; i < images.length; i++) {
    final image = resizeImage(images[i], width, height, maintainAspect);

    final encodedImage = img_util.encodePng(image.bytes);
    final pointsString = jsonEncode(image.image.features);

    encoder
      ..addArchiveFile(archive.ArchiveFile('image-$i.png', encodedImage.length, encodedImage))
      ..addArchiveFile(archive.ArchiveFile('points-$i.json', pointsString.codeUnits.length, pointsString));
  }

  encoder.close();

  return File(filePath).readAsBytesSync();
}

Uint8List _encodeYolo(String filePath, List<Image> images, int? width, int? height, bool maintainAspect) {
  final encoder = archive.ZipFileEncoder()..create(filePath);

  final labels = <String, int>{};
  final labelsReversed = <int, String>{};
  var labelIndex = 0;

  for (var i = 0; i < images.length; i++) {
    final image = resizeImage(images[i], width, height, maintainAspect);

    final pointsBuffer = StringBuffer();

    for (final feature in image.image.features) {
      if (feature.points.length != 2) continue;
      if (labels[feature.className] == null) {
        labels[feature.className] = labelIndex;
        labelsReversed[labelIndex] = feature.className;
        labelIndex++;
      }
      final centerX = (feature.points[0].x + feature.points[1].x).abs() / 2;
      final centerY = (feature.points[0].y + feature.points[1].y).abs() / 2;
      final centerWidth = (feature.points[0].x - feature.points[1].x).abs();
      final centerHeight = (feature.points[0].y - feature.points[1].y).abs();

      final yoloCenterX = centerX / (width ?? image.bytes.width);
      final yoloCenterY = centerY / (height ?? image.bytes.height);
      final yoloWidth = centerWidth / (width ?? image.bytes.width);
      final yoloHeight = centerHeight / (height ?? image.bytes.height);
      pointsBuffer.writeln('${labels[feature.className]} $yoloCenterX $yoloCenterY $yoloWidth $yoloHeight');
    }

    final pointsString = pointsBuffer.toString();
    final encodedImage = img_util.encodePng(image.bytes);

    encoder
      ..addArchiveFile(archive.ArchiveFile('images/image-$i.png', encodedImage.length, encodedImage))
      ..addArchiveFile(archive.ArchiveFile('labels/image-$i.txt', pointsString.codeUnits.length, pointsString));
  }

  final classesBuffer = StringBuffer();

  for (var i = 0; i < labelIndex; i++) {
    classesBuffer.writeln(labelsReversed[i]);
  }

  final classesString = classesBuffer.toString();

  encoder
    ..addArchiveFile(archive.ArchiveFile('classes.txt', classesString.codeUnits.length, classesString))
    ..close();

  return File(filePath).readAsBytesSync();
}
