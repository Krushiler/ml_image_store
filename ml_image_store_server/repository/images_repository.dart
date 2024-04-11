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
    Point leftTop,
    Point rightBottom,
  ) async {
    final id = const Uuid().v4();
    await _storage.createImage(id, filePath, folderId, leftTop, rightBottom);
  }

  Future<void> deleteImage(
    String id,
  ) async {
    await _storage.deleteImage(id);
  }

  Future<List<Image>> getImages(String folderId) async {
    final folders = await _storage.getFolderImages(folderId);
    return folders.map((e) => e.toColumnMap()).map(
      (e) {
        return Image(
          id: e['id'].toString(),
          fileId: e['path'].toString(),
          leftTop: Point(
            x: int.parse(e['lefttopx'].toString()),
            y: int.parse(e['lefttopy'].toString()),
          ),
          rightBottom: Point(
            x: int.parse(e['rightbottomx'].toString()),
            y: int.parse(e['rightbottomy'].toString()),
          ),
        );
      },
    ).toList();
  }

  Future<Image> getImage(String id) async {
    final e = (await _storage.getImage(id))?.toColumnMap();
    if (e == null) throw Exception('Image not found');
    return Image(
      id: e['id'].toString(),
      fileId: e['path'].toString(),
      leftTop: Point(
        x: int.parse(e['lefttopx'].toString()),
        y: int.parse(e['lefttopy'].toString()),
      ),
      rightBottom: Point(
        x: int.parse(e['rightbottomx'].toString()),
        y: int.parse(e['rightbottomy'].toString()),
      ),
    );
  }
}
