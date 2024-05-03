import 'package:flutter/material.dart';
import 'package:ml_image_store/model/image/point.dart';
import 'package:rxdart/rxdart.dart';

abstract class LabelingTool {
  final _points = BehaviorSubject<List<Point>>.seeded(const []);

  List<Point> get points => _points.value;

  set points(List<Point> points) => _points.value = points;

  Stream<List<Point>> watchPoints() => _points.stream;

  void onTapDown(Offset offset) {}

  void onTapUp(Offset offset) {}

  void onPanStart(Offset offset) {}

  void onPanUpdate(Offset offset) {}

  bool get isValid => false;
}
