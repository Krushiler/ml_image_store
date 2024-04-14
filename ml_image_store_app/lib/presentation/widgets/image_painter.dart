import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ml_image_store/model/image/point.dart';

// TODO: Refactor

class ImagePainter extends CustomPainter {
  final ui.Image image;
  final Point? leftTop;
  final Point? rightBottom;
  final ValueChanged<Size>? sizeChanged;
  final Size? size;

  double get aspectRatio => image.width / image.height;

  ImagePainter(this.image, this.leftTop, this.rightBottom, {this.sizeChanged, this.size});

  final Paint circlePaint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.fill;
  final Paint boxPaint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;

  @override
  void paint(Canvas canvas, Size size) {
    double canvasAspectRatio = size.width / size.height;

    int topOffset = min(0, (canvasAspectRatio / aspectRatio - 1) * size.height ~/ 2);

    int leftOffset = min(0, (aspectRatio / canvasAspectRatio - 1) * size.width ~/ 2);

    double imageWidthRatio = image.width / size.width;

    double imageHeightRatio = image.height / size.height;

    if (this.size != size) {
      sizeChanged?.call(size);
    }
    paintImage(canvas: canvas, rect: Rect.fromLTRB(0, 0, size.width, size.height), image: image);
    if (leftTop != null && rightBottom != null) {
      canvas.drawRect(
        Rect.fromLTRB(
          leftTop!.x.toDouble() / imageWidthRatio + leftOffset,
          leftTop!.y.toDouble() / imageHeightRatio + topOffset,
          rightBottom!.x.toDouble() / imageWidthRatio + leftOffset,
          rightBottom!.y.toDouble() / imageHeightRatio + topOffset,
        ),
        boxPaint,
      );
    }
    if (leftTop != null) {
      canvas.drawCircle(
        ui.Offset(
          leftTop!.x.toDouble() / imageWidthRatio + leftOffset,
          leftTop!.y.toDouble() / imageHeightRatio + topOffset,
        ),
        8,
        circlePaint,
      );
    }
    if (rightBottom != null) {
      canvas.drawCircle(
        ui.Offset(
          rightBottom!.x.toDouble() / imageWidthRatio + leftOffset,
          rightBottom!.y.toDouble() / imageHeightRatio + topOffset,
        ),
        8,
        circlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(ImagePainter oldDelegate) {
    return image != oldDelegate.image || leftTop != oldDelegate.leftTop || rightBottom != oldDelegate.rightBottom;
  }
}
