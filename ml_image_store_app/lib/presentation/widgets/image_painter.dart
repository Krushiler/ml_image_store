import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ml_image_store/model/image/feature.dart';
import 'package:ml_image_store/model/image/point.dart';

// TODO: Refactor

class ImagePainter extends CustomPainter {
  final ui.Image image;
  final List<Feature> features;
  final List<Point> points;
  final ValueChanged<Size>? sizeChanged;
  final Size? size;

  double get aspectRatio => image.width / image.height;

  ImagePainter(this.image, this.features, {this.points = const [], this.sizeChanged, this.size});

  late final featureColorMap = _createColorMap();

  Map<String, Color> _createColorMap() {
    final map = <String, Color>{};
    final names = features.map((e) => e.className).toSet();
    var index = 0;
    for (final name in names) {
      map[name] = colors[index % colors.length];
      index += 1;
    }
    return map;
  }

  static const colors = [
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.yellow,
    Colors.purpleAccent,
  ];

  void drawPoints(Canvas canvas, Size size, List<Point> points, String? name) {
    if (points.isEmpty) return;

    double canvasAspectRatio = size.width / size.height;

    int topOffset = min(0, (canvasAspectRatio / aspectRatio - 1) * size.height ~/ 2);

    int leftOffset = min(0, (aspectRatio / canvasAspectRatio - 1) * size.width ~/ 2);

    double imageWidthRatio = image.width / size.width;

    double imageHeightRatio = image.height / size.height;

    final color = name == null ? Colors.red : featureColorMap[name] ?? Colors.red;

    final Paint circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final Paint boxPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    if (name != null) {
      final textStyle = TextStyle(
        color: color,
        fontSize: 24,
      );
      final textSpan = TextSpan(
        text: name,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      textPainter.paint(
        canvas,
        Offset(
          points[0].x.toDouble() / imageWidthRatio + leftOffset - 48,
          points[0].y.toDouble() / imageHeightRatio + topOffset - 48,
        ),
      );
    }

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      canvas.drawCircle(
        ui.Offset(
          point.x.toDouble() / imageWidthRatio + leftOffset,
          point.y.toDouble() / imageHeightRatio + topOffset,
        ),
        8,
        circlePaint,
      );
      if (points.length == 1) break;
      final nextPoint = points[(i + 1) % points.length];
      canvas.drawLine(
        ui.Offset(
          point.x.toDouble() / imageWidthRatio + leftOffset,
          point.y.toDouble() / imageHeightRatio + topOffset,
        ),
        ui.Offset(
          nextPoint.x.toDouble() / imageWidthRatio + leftOffset,
          nextPoint.y.toDouble() / imageHeightRatio + topOffset,
        ),
        boxPaint,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (this.size != size) {
      sizeChanged?.call(size);
    }
    paintImage(canvas: canvas, rect: Rect.fromLTRB(0, 0, size.width, size.height), image: image);
    drawPoints(canvas, size, points, null);
    for (final feature in features) {
      drawPoints(canvas, size, feature.points, feature.className);
    }
  }

  @override
  bool shouldRepaint(ImagePainter oldDelegate) {
    return image != oldDelegate.image ||
        points != oldDelegate.points ||
        features != oldDelegate.features ||
        features.length != features.length;
  }
}
