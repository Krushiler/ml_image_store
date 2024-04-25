import 'package:collection/collection.dart';
import 'package:ml_image_store/model/folder/folder.dart';
import 'package:ml_image_store/request/create_folder_request.dart';
import 'package:ml_image_store/response/folder_response.dart';
import 'package:ml_image_store_app/data/network/ml_image_api.dart';
import 'package:ml_image_store_app/data/storage/base/base_storage.dart';
import 'package:ml_image_store_app/data/storage/folders_storage.dart';

class FoldersRepository {
  final MlImageApi _api;
  final FoldersStorage _storage;
  final BaseStorage<List<FolderResponse>> _imagesStorage;

  FoldersRepository(this._api, this._storage, this._imagesStorage);

  Future<void> fetchFolders() async {
    final folders = await _api.getFolders();
    _storage.put(folders);
  }

  Stream<List<Folder>?> watchFolders() {
    return _storage.watch();
  }

  Future<void> fetchFolder(String id) async {
    final folder = await _api.getFolder(id);
    try {
      final storageData = await _imagesStorage.get();
      if (storageData == null) {
        await _imagesStorage.put([folder]);
        return;
      }
      final newList = storageData.where((element) => element.folder.id != folder.folder.id).toList();
      await _imagesStorage.put([...newList, folder]);
    } catch (e) {
      await _imagesStorage.put([folder]);
    }
  }

  Future<Folder> getFolder(String id) async {
    final folder = await _getFolder(id);
    return folder ?? (await _api.getFolder(id)).folder;
  }

  Future<Folder?> _getFolder(String id) async {
    final folder = (await _storage.get())?.firstWhereOrNull((element) => element.id == id);
    return folder;
  }

  Stream<FolderResponse?> watchFolder(String id) => _imagesStorage.watch().map(
        (event) => event?.where((element) => element.folder.id == id).firstOrNull,
      );

  Future<void> createFolder(String name, LabelType type) {
    return _api.createFolder(CreateFolderRequest(name: name, type: type.index));
  }

  Future<void> deleteFolder(String id) {
    return _api.deleteFolder(id);
  }
}
