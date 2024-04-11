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
    if (folder['ownerId'] != userId) throw Exception('You do not own this folder');
    await _storage.deleteFolder(folderId);
  }

  Future<List<Folder>> getUserFolders(String userId) async {
    final folders = await _storage.getUserFolders(userId);
    return folders
        .map((e) => e.toColumnMap())
        .map(
          (e) => Folder(
            id: e['id'].toString(),
            name: e['name'].toString(),
            ownerId: e['ownerId'].toString(),
          ),
        )
        .toList();
  }
}
