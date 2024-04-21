import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:ml_image_store/model/image/feature.dart';
import 'package:ml_image_store/model/image/image.dart';
import 'package:ml_image_store_app/data/network/ml_image_api.dart';

class ImagesRepository {
  final MlImageApi _api;

  ImagesRepository(this._api);

  Future<void> createImage(
    String folderId,
    List<Feature> features,
    Uint8List image,
    String? imageId,
  ) {
    return _api.createImage(
      folderId: folderId,
      features: jsonEncode(features),
      imageId: imageId,
      image: [MultipartFile.fromBytes(image, contentType: MediaType('image', 'png'), filename: 'image.png')],
    );
  }

  Future<Image> getImage(String id) {
    return _api.getImage(id);
  }

  Future<void> deleteImage(String id) {
    return _api.deleteImage(id);
  }
}
