import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:ml_image_store/model/image/feature.dart';
import 'package:ml_image_store/model/image/image.dart';
import 'package:ml_image_store/model/paging/paging_params.dart';
import 'package:ml_image_store_app/data/network/ml_image_api.dart';
import 'package:ml_image_store_app/data/storage/folders_storage.dart';

class ImagesRepository {
  final MlImageApi _api;
  final FolderImagesStorage _storage;

  ImagesRepository(this._api, this._storage);

  Future<List<Image>> fetchImages(String folderId, PagingParams? pagingParams) async {
    final images = await _api.getFolderImages(folderId, limit: pagingParams?.limit, offset: pagingParams?.offset);
    _storage.push(folderId, images);
    return images;
  }

  void clearImages(String id) {
    _storage.put(id, const []);
  }

  Stream<List<Image>> watchImages(String id) {
    return _storage.watch(id);
  }

  Future<void> createImage(
    String folderId,
    List<Feature> features,
    Uint8List image,
    String? imageId,
  ) async {
    await _api.createImage(
      folderId: folderId,
      features: jsonEncode(features),
      imageId: imageId,
      image: [MultipartFile.fromBytes(image, contentType: MediaType('image', 'png'), filename: 'image.png')],
    );
    if (imageId == null) {
      try {
        final image = (await _api.getFolderImages(folderId, limit: 1, offset: 0)).first;
        _storage.pushFront(folderId, [image]);
      } catch (_) {}
    }
  }

  Future<Image> getImage(String id) {
    return _api.getImage(id);
  }

  Future<void> deleteImage(String folderId, String id) async {
    await _api.deleteImage(id);
    _storage.remove(folderId, id);
  }
}
