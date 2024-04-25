import 'package:ml_image_store/model/folder/folder.dart';
import 'package:ml_image_store/response/folder_response.dart';
import 'package:ml_image_store_app/data/storage/base/memory_storage.dart';

class FoldersStorage extends MemoryStorage<List<Folder>> {
  FoldersStorage() : super();
}

class FolderImagesStorage extends MemoryStorage<List<FolderResponse>> {
  FolderImagesStorage() : super();
}
