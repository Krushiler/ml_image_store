import 'package:ml_image_store/model/folder/folder.dart';
import 'package:ml_image_store/model/image/image.dart';
import 'package:ml_image_store_app/data/storage/base/memory_storage.dart';
import 'package:rxdart/rxdart.dart';

class FoldersStorage extends MemoryStorage<List<Folder>> {
  FoldersStorage() : super();
}

class FolderImagesStorage {
  final Map<String, BehaviorSubject<List<Image>>> _data = {};

  void put(String id, List<Image> images) {
    (_data[id] ??= BehaviorSubject.seeded([])).add(images);
  }

  void push(String id, List<Image> images) {
    final data = (_data[id] ??= BehaviorSubject.seeded([])).valueOrNull ?? [];
    _data[id]?.add([...data, ...images]);
  }

  void pushFront(String id, List<Image> images) {
    final data = (_data[id] ??= BehaviorSubject.seeded([])).valueOrNull ?? [];
    _data[id]?.add([...images, ...data]);
  }

  void replace(String folderId, String imageId, Image image) {
    final data = (_data[folderId] ??= BehaviorSubject.seeded([])).valueOrNull?.toList() ?? [];
    int? idx;
    for (var i = 0; i < data.length; i++) {
      if (imageId == data[i].id) {
        idx = i;
        break;
      }
    }
    if (idx != null) {
      data[idx] = image;
    } else {
      pushFront(folderId, [image]);
    }
    _data[folderId]?.add(data);
  }

  void remove(String folderId, String imageId) {
    final data = (_data[folderId] ??= BehaviorSubject.seeded([])).valueOrNull?.toList() ?? [];
    data.removeWhere((element) => element.id == imageId);
    _data[folderId]?.add(data);
  }

  List<Image> get(String id) {
    return _data[id]?.valueOrNull ?? [];
  }

  Stream<List<Image>> watch(String id) {
    return _data[id] ??= BehaviorSubject.seeded([]);
  }
}
