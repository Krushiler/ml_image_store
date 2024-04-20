import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ml_image_store/model/image/feature.dart';
import 'package:ml_image_store/model/image/point.dart';
import 'package:ml_image_store_app/presentation/util/image_util.dart';

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

  void drawPoints(Canvas canvas, Size canvasSize, List<Point> points, String? name, Size imageSize) {
    if (points.isEmpty) return;

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
        maxWidth: canvasSize.width ?? 0,
      );
      textPainter.paint(
        canvas,
        convertToCanvasOffset(points[0].offset, imageSize, canvasSize) - const Offset(48, 48),
      );
    }

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      canvas.drawCircle(convertToCanvasOffset(point.offset, imageSize, canvasSize), 4, circlePaint);
      if (points.length == 1) break;
      final nextPoint = points[(i + 1) % points.length];
      canvas.drawLine(
        convertToCanvasOffset(point.offset, imageSize, canvasSize),
        convertToCanvasOffset(nextPoint.offset, imageSize, canvasSize),
        boxPaint,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (this.size != size) {
      sizeChanged?.call(size);
    }
    final fittedSize = applyBoxFit(
      BoxFit.fill,
      ui.Size(image.width.toDouble(), image.height.toDouble()),
      size,
    );

    final imageSize = fittedSize;

    paintImage(canvas: canvas, rect: Rect.fromLTRB(0, 0, size.width, size.height), image: image);
    drawPoints(canvas, size, points, null, imageSize.source);
    for (final feature in features) {
      drawPoints(canvas, size, feature.points, feature.className, imageSize.source);
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
