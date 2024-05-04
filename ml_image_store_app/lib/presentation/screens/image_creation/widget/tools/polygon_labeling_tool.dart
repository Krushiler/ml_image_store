import 'package:flutter/material.dart';
import 'package:ml_image_store_app/presentation/screens/image_creation/widget/tools/labeling_tool.dart';
import 'package:ml_image_store_app/presentation/util/image_util.dart';

class PolygonLabelingTool extends LabelingTool {
  bool addedPoint = false;

  @override
  void onTapDown(Offset offset) {
    addedPoint = true;
    points = [...points, createPointFromOffset(offset)];
  }

  @override
  void onPanStart(Offset offset) {
    if (!addedPoint) {
      points = [...points, createPointFromOffset(offset)];
      addedPoint = false;
    }
  }

  @override
  void onPanUpdate(Offset offset) {
    final previous = points.toList();
    previous.removeLast();
    points = [...previous, createPointFromOffset(offset)];
    addedPoint = false;
  }

  @override
  bool get isValid => points.isNotEmpty;
}
