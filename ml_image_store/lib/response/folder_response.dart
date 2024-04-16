import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ml_image_store/model/folder/folder.dart';
import 'package:ml_image_store/model/image/image.dart';

part 'folder_response.freezed.dart';

part 'folder_response.g.dart';

@freezed
class FolderResponse with _$FolderResponse {
  const factory FolderResponse({
    required Folder folder,
    required List<Image> images,
  }) = _FolderReposponse;

  factory FolderResponse.fromJson(Map<String, dynamic> json) => _$FolderResponseFromJson(json);
}
