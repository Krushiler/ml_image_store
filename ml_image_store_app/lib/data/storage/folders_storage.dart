import 'package:ml_image_store/model/folder/folder.dart';
import 'package:ml_image_store/response/folder_response.dart';
import 'package:ml_image_store_app/data/storage/base/hive_json_storage.dart';

class FoldersStorage extends ListHiveJsonStorage<Folder> {
  FoldersStorage() : super(key: 'folders', fromJson: Folder.fromJson, toJson: (e) => e.toJson());
}

class FolderImagesStorage extends ListHiveJsonStorage<FolderResponse> {
  FolderImagesStorage()
      : super(
          key: 'folder_images',
          fromJson: FolderResponse.fromJson,
          toJson: (e) => e.toJson(),
        );
}
