import 'package:freezed_annotation/freezed_annotation.dart';

part 'point.freezed.dart';

part 'point.g.dart';

@freezed
class Point with _$Point {
  const factory Point({
    required String id,
    required int x,
    required int y,
    @Default(0) int radius,
  }) = _Point;

  factory Point.fromJson(Map<String, dynamic> json) => _$PointFromJson(json);
}
