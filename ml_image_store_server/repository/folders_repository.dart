import 'package:ml_image_store/model/folder/folder.dart';

import '../database/storage.dart';

class FoldersRepository {
  FoldersRepository(this._storage);

  final Storage _storage;

  Future<void> createFolder(String userId, String folderName) async {
    await _storage.createFolder(userId, folderName);
  }

  Future<void> deleteFolder(String userId, String folderId) async {
    final folder = (await _storage.getFolder(folderId))?.toColumnMap();
    if (folder == null) throw Exception('Folder does not exist');
    if (folder['ownerId'.toLowerCase()] != userId) throw Exception('You do not own this folder');
    final images = (await _storage.getFolderImages(folderId)).map((e) => e.toColumnMap());
    for (final image in images) {
      final features = (await _storage.getFeatures(image['id'].toString())).map((e) => e.toColumnMap());
      for (final feature in features) {
        await _storage.deleteFeaturePoints(feature['id'].toString());
      }
      await _storage.deleteImageFeatures(image['id'].toString());
      await _storage.deleteImage(image['id'].toString());
    }
    await _storage.deleteFolder(folderId);
  }

  Future<Folder> getFolder(String id) async {
    final e = (await _storage.getFolder(id))?.toColumnMap();
    if (e == null) throw Exception('Folder does not exist');
    return Folder(
      id: e['id'].toString(),
      name: e['name'].toString(),
      ownerId: e['ownerId'.toLowerCase()].toString(),
    );
  }

  Future<List<Folder>> getUserFolders(String userId) async {
    final folders = await _storage.getUserFolders(userId);
    return folders
        .map((e) => e.toColumnMap())
        .map(
          (e) => Folder(
            id: e['id'].toString(),
            name: e['name'].toString(),
            ownerId: e['ownerId'.toLowerCase()].toString(),
          ),
        )
        .toList();
  }
}
