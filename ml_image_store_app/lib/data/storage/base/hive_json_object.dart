import 'package:hive_flutter/hive_flutter.dart';

part 'hive_json_object.g.dart';

@HiveType(typeId: 0)
class HiveJsonObject {
  @HiveField(1)
  final String json;

  HiveJsonObject(this.json);
}