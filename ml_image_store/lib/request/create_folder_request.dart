import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_folder_request.freezed.dart';

part 'create_folder_request.g.dart';

@freezed
class CreateFolderRequest with _$CreateFolderRequest {
  const factory CreateFolderRequest({
    required String name,
  }) = _CreateFolderRequest;

  factory CreateFolderRequest.fromJson(Map<String, dynamic> json) => _$CreateFolderRequestFromJson(json);
}
