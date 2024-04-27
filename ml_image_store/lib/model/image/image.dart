import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ml_image_store/model/image/feature.dart';

part 'image.freezed.dart';
part 'image.g.dart';

@freezed
class Image with _$Image {
  const factory Image({
    required String id,
    required List<Feature> features,
    required String fileId,
    required DateTime createdAt,
  }) = _Image;

  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);
}
