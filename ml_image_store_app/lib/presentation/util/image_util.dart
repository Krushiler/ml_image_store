import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:ml_image_store/model/image/point.dart' as domain;
import 'package:ml_image_store_app/data/model/server_config.dart';

String createImageUrl(ServerConfig config, String imageId) {
  return '${config.baseUrl}/files/$imageId';
}

extension PointUiExtension on domain.Point {
  Offset get offset => Offset(x.toDouble(), y.toDouble());
}

Offset convertToCanvasOffset(Offset original, Size imageSize, Size canvasSize) {
  final double widthMultiplier = min(1, canvasSize.height / imageSize.height);

  final double heightMultiplier = min(1, canvasSize.height / imageSize.height);

  final double sizeMultiplier = min(widthMultiplier, heightMultiplier);

  final imageViewSize = imageSize * sizeMultiplier;

  final imageStart = canvasSize.center(Offset(-imageViewSize.width / 2, -imageViewSize.height / 2));

  return Offset(imageStart.dx + original.dx * sizeMultiplier, imageStart.dy + original.dy * sizeMultiplier);
}

Offset convertToImageOffset(Offset original, Size imageSize, Size canvasSize) {
  final double widthMultiplier = min(1, canvasSize.height / imageSize.height);

  final double heightMultiplier = min(1, canvasSize.height / imageSize.height);

  final double sizeMultiplier = min(widthMultiplier, heightMultiplier);

  final imageViewSize = imageSize * sizeMultiplier;

  final imageStart = canvasSize.center(Offset(-imageViewSize.width / 2, -imageViewSize.height / 2));

  return Offset(-imageStart.dx + original.dx / sizeMultiplier, -imageStart.dy + original.dy / sizeMultiplier);
}
