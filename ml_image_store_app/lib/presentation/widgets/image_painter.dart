import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ml_image_store/model/folder/folder.dart';
import 'package:ml_image_store/model/image/feature.dart';
import 'package:ml_image_store/model/image/point.dart';
import 'package:ml_image_store_app/presentation/util/image_util.dart';

class ImagePainter extends CustomPainter {
  final ui.Image image;
  final List<Feature> features;
  final List<Point> points;
  final ValueChanged<Size>? sizeChanged;
  final Size? size;
  final LabelType labelType;
  final String? selectedFeatureId;
  final double selectionProgress;

  double get aspectRatio => image.width / image.height;

  ImagePainter(
    this.image,
    this.features, {
    required this.labelType,
    this.points = const [],
    this.sizeChanged,
    this.size,
    this.selectedFeatureId,
    this.selectionProgress = 0,
  });

  @override
  bool shouldRepaint(ImagePainter oldDelegate) {
    return image != oldDelegate.image ||
        points != oldDelegate.points ||
        points.length != oldDelegate.points.length ||
        features != oldDelegate.features ||
        features.length != oldDelegate.features.length ||
        labelType != oldDelegate.labelType ||
        selectedFeatureId != oldDelegate.selectedFeatureId ||
        selectionProgress != oldDelegate.selectionProgress;
  }

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

  void drawPoints(Canvas canvas, Size canvasSize, List<Point> points, String? name, Size imageSize,
      [bool isDeleting = false]) {
    if (points.isEmpty) return;

    final color = name == null ? Colors.red : featureColorMap[name] ?? Colors.red;

    final Paint circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final Paint boxPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final Paint deletePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = selectionProgress * 8;

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
        maxWidth: canvasSize.width,
      );
      textPainter.paint(
        canvas,
        convertToCanvasOffset(points[0].offset, imageSize, canvasSize) - const Offset(48, 48),
      );
    }

    if (labelType == LabelType.polygon) {
      for (int i = 0; i < points.length; i++) {
        final point = points[i];
        if (isDeleting) {
          canvas.drawCircle(convertToCanvasOffset(point.offset, imageSize, canvasSize), 4, deletePaint);
        }
        canvas.drawCircle(convertToCanvasOffset(point.offset, imageSize, canvasSize), 4, circlePaint);
        if (points.length == 1) break;
        final nextPoint = points[(i + 1) % points.length];
        if (isDeleting) {
          canvas.drawLine(
            convertToCanvasOffset(point.offset, imageSize, canvasSize),
            convertToCanvasOffset(nextPoint.offset, imageSize, canvasSize),
            deletePaint,
          );
        }
        canvas.drawLine(
          convertToCanvasOffset(point.offset, imageSize, canvasSize),
          convertToCanvasOffset(nextPoint.offset, imageSize, canvasSize),
          boxPaint,
        );
      }
    } else if (labelType == LabelType.bbox) {
      if (points.length == 1) {
        final point = points[0];
        canvas.drawCircle(convertToCanvasOffset(point.offset, imageSize, canvasSize), 4, circlePaint);
      } else if (points.length > 1) {
        final p1 = points[0];
        if (isDeleting) {
          canvas.drawCircle(convertToCanvasOffset(p1.offset, imageSize, canvasSize), 4, deletePaint);
        }
        canvas.drawCircle(convertToCanvasOffset(p1.offset, imageSize, canvasSize), 4, circlePaint);
        final p2 = points[1];
        if (isDeleting) {
          canvas.drawCircle(convertToCanvasOffset(p2.offset, imageSize, canvasSize), 4, deletePaint);
        }
        canvas.drawCircle(convertToCanvasOffset(p2.offset, imageSize, canvasSize), 4, circlePaint);
        if (isDeleting) {
          canvas.drawRect(
            ui.Rect.fromPoints(
              convertToCanvasOffset(p1.offset, imageSize, canvasSize),
              convertToCanvasOffset(p2.offset, imageSize, canvasSize),
            ),
            deletePaint,
          );
        }
        canvas.drawRect(
          ui.Rect.fromPoints(
            convertToCanvasOffset(p1.offset, imageSize, canvasSize),
            convertToCanvasOffset(p2.offset, imageSize, canvasSize),
          ),
          boxPaint,
        );
      }
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
      drawPoints(
        canvas,
        size,
        feature.points,
        feature.className,
        imageSize.source,
        selectedFeatureId == feature.id,
      );
    }
  }
}
