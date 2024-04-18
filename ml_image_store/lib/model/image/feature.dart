import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ml_image_store/model/image/point.dart';

part 'feature.freezed.dart';

part 'feature.g.dart';

@freezed
class Feature with _$Feature {
  const factory Feature({
    required List<Point> points,
    required String className,
  }) = _Feature;

  factory Feature.fromJson(Map<String, dynamic> json) => _$FeatureFromJson(json);
}
