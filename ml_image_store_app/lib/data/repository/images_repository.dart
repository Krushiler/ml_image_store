import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:ml_image_store/model/image/image.dart';
import 'package:ml_image_store/model/image/point.dart';
import 'package:ml_image_store_app/data/network/ml_image_api.dart';
import 'package:http_parser/http_parser.dart';

class ImagesRepository {
  final MlImageApi _api;

  ImagesRepository(this._api);

  Future<void> createImage(
    String folderId,
    Point leftTop,
    Point rightBottom,
    Uint8List image,
  ) {
    return _api.createImage(
      folderId: folderId,
      leftTop: leftTop.toJson(),
      rightBottom: rightBottom.toJson(),
      image: [MultipartFile.fromBytes(image, contentType: MediaType('image', 'png'))],
    );
  }

  Future<Image> getImage(String id) {
    return _api.getImage(id);
  }

  Future<void> deleteImage(String id) {
    return _api.deleteImage(id);
  }
}
