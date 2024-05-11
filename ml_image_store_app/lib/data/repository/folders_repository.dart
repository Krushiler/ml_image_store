import 'package:collection/collection.dart';
import 'package:ml_image_store/model/folder/folder.dart';
import 'package:ml_image_store/request/create_folder_request.dart';
import 'package:ml_image_store_app/data/network/ml_image_api.dart';
import 'package:ml_image_store_app/data/storage/base/base_storage.dart';

class FoldersRepository {
  final MlImageApi _api;
  final BaseStorage<List<Folder>> _storage;

  FoldersRepository(this._api, this._storage);

  Future<void> fetchFolders() async {
    final folders = await _api.getFolders();
    _storage.put(folders);
  }

  Stream<List<Folder>?> watchFolders() {
    return _storage.watch();
  }

  Future<void> fetchFolder(String id) async {
    try {
      final folder = await _api.getFolder(id);
      final data = (await _storage.get())?.toList() ?? [];
      int? dataIndex;
      for (var i = 0; i < data.length; i ++) {
        if (data[i].id == folder.id) {
          dataIndex = i;
          break;
        }
      }
      if (dataIndex != null) {
        data[dataIndex] = folder;
      } else {
        data.add(folder);
      }
      _storage.put(data);
    } catch (_) {}
  }

  Future<Folder> getFolder(String id) async {
    final folder = await _getFolder(id);
    return folder ?? (await _api.getFolder(id));
  }

  Future<Folder?> _getFolder(String id) async {
    final folder = (await _storage.get())?.firstWhereOrNull((element) => element.id == id);
    return folder;
  }

  Stream<Folder?> watchFolder(String id) => _storage.watch().map(
        (event) => event?.where((element) => element.id == id).firstOrNull,
      );

  Future<void> createFolder(String name, LabelType type) {
    return _api.createFolder(CreateFolderRequest(name: name, type: type.index));
  }

  Future<void> deleteFolder(String id) {
    return _api.deleteFolder(id);
  }
}
