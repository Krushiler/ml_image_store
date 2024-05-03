import 'package:flutter/material.dart';
import 'package:ml_image_store_app/presentation/screens/image_creation/widget/tools/labeling_tool.dart';
import 'package:ml_image_store_app/presentation/util/image_util.dart';

class PolygonLabelingTool extends LabelingTool {
  @override
  void onTapDown(Offset offset) {
    points = [...points, createPointFromOffset(offset)];
  }

  @override
  bool get isValid => points.isNotEmpty;
}
