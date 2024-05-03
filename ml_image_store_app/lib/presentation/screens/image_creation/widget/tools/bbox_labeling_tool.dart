import 'package:flutter/material.dart';
import 'package:ml_image_store_app/presentation/screens/image_creation/widget/tools/labeling_tool.dart';
import 'package:ml_image_store_app/presentation/util/image_util.dart';

class BboxLabelingTool extends LabelingTool {
  @override
  void onPanStart(Offset offset) {
    points = [createPointFromOffset(offset)];
  }

  @override
  void onPanUpdate(Offset offset) {
    if (points.isNotEmpty) {
      points = [points[0], createPointFromOffset(offset)];
    } else {
      points = [createPointFromOffset(offset)];
    }
  }

  @override
  bool get isValid => points.length == 2;
}
