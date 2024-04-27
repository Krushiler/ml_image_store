import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:ml_image_store/model/image/feature.dart';
import 'package:ml_image_store/model/image/image.dart';
import 'package:image/image.dart' as img_util;
import 'package:ml_image_store/model/image/point.dart';

abstract interface class DownloadEncoder {
  FutureOr<Uint8List> encode(String filePath, List<Image> images, int? width, int? height, bool maintainAspect);
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

  return ImageData(
    resized,
    Image(
      id: image.id,
      features: pointsData.toList(),
      fileId: image.fileId,
      createdAt: image.createdAt,
    ),
  );
}

class ImageData {
  ImageData(this.bytes, this.image);

  final img_util.Image bytes;
  final Image image;
}
