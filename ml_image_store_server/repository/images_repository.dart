import 'package:ml_image_store/model/image/feature.dart';
import 'package:ml_image_store/model/image/image.dart';
import 'package:ml_image_store/model/image/point.dart';
import 'package:ml_image_store/model/paging/paging_params.dart';
import 'package:uuid/uuid.dart';

import '../database/storage.dart';

class ImagesRepository {
  ImagesRepository(this._storage);

  final Storage _storage;

  Future<void> createImage(
    String folderId,
    String filePath,
    List<Feature> features,
    String? imageId,
  ) async {
    final id = imageId ?? const Uuid().v4();
    if (imageId != null) {
      final features = (await _storage.getFeatures(imageId)).map((e) => e.toColumnMap());
      for (final feature in features) {
        await _storage.deleteFeaturePoints(feature['id'].toString());
      }
      await _storage.deleteImageFeatures(imageId);
      await _storage.updateImage(id, filePath);
    } else {
      await _storage.createImage(id, filePath, folderId, DateTime.now().millisecondsSinceEpoch);
    }
    for (final feature in features) {
      final featureId = const Uuid().v4();
      await _storage.createFeature(featureId, id, feature);
      for (final point in feature.points) {
        await _storage.createPoint(id, featureId, point);
      }
    }
  }

  Future<void> deleteImage(
    String id,
  ) async {
    final features = (await _storage.getFeatures(id)).map((e) => e.toColumnMap());
    for (final feature in features) {
      await _storage.deleteFeaturePoints(feature['id'].toString());
    }
    await _storage.deleteImageFeatures(id);
    await _storage.deleteImage(id);
  }

  Future<List<Feature>> getFeatures(String imageId) async {
    final features = await _storage.getFeatures(imageId);
    final res = <Feature>[];
    for (final feature in features) {
      final map = feature.toColumnMap();
      final pointsRes = await _storage.getPoints(map['id'].toString());
      final points = <Point>[];
      for (final p in pointsRes) {
        final e = p.toColumnMap();
        points.add(
          Point(
            x: int.parse(e['lefttopx'].toString()),
            y: int.parse(e['lefttopy'].toString()),
            id: e['id'].toString(),
          ),
        );
      }
      res.add(
        Feature(
          className: map['classname'].toString(),
          points: points,
          id: map['id'].toString(),
        ),
      );
    }
    return res;
  }

  Future<List<Image>> getImages(String folderId, [PagingParams? pagingParams]) async {
    final folders = await _storage.getFolderImages(folderId, pagingParams);
    final maps = folders.map((e) => e.toColumnMap());
    final images = <Image>[];
    for (final imageMap in maps) {
      final features = await getFeatures(imageMap['id'].toString());
      images.add(
        Image(
          id: imageMap['id'].toString(),
          features: features,
          fileId: imageMap['path'].toString(),
          createdAt: DateTime.fromMicrosecondsSinceEpoch(imageMap['createdat']),
        ),
      );
    }
    return images;
  }

  Future<Image> getImage(String id) async {
    final e = (await _storage.getImage(id))?.toColumnMap();
    if (e == null) throw Exception('Image not found');
    return Image(
      id: e['id'].toString(),
      fileId: e['path'].toString(),
      features: await getFeatures(id),
      createdAt: DateTime.fromMicrosecondsSinceEpoch(e['createdat']),
    );
  }
}
