import 'package:ml_image_store/model/image/feature.dart';
import 'package:ml_image_store/model/image/image.dart';
import 'package:ml_image_store/model/image/point.dart';
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
    if (imageId != null) {
      await deleteImage(imageId);
    }
    final id = imageId ?? const Uuid().v4();
    await _storage.createImage(id, filePath, folderId);
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

  Future<List<Image>> getImages(String folderId) async {
    final folders = await _storage.getFolderImages(folderId);
    final maps = folders.map((e) => e.toColumnMap());
    final images = <Image>[];
    for (final imageMap in maps) {
      final features = await getFeatures(imageMap['id'].toString());
      images.add(
        Image(
          id: imageMap['id'].toString(),
          features: features,
          fileId: imageMap['path'].toString(),
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
    );
  }
}
