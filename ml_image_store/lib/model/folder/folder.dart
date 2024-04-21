import 'package:freezed_annotation/freezed_annotation.dart';

part 'folder.freezed.dart';

part 'folder.g.dart';

@freezed
class Folder with _$Folder {
  const factory Folder({
    required String id,
    required String name,
    required String ownerId,
    required LabelType type,
  }) = _Folder;

  factory Folder.fromJson(Map<String, dynamic> json) => _$FolderFromJson(json);
}

enum LabelType {
  bbox('BBox'),
  polygon('Polygon');

  final String name;

  const LabelType(this.name);
}
