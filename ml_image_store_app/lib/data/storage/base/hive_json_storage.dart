import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:ml_image_store_app/data/storage/base/base_storage.dart';
import 'package:ml_image_store_app/data/storage/base/hive_json_object.dart';
import 'package:rxdart/rxdart.dart';

typedef FromJsonFunc<T> = T Function(Map<String, dynamic> json);
typedef ToJsonFunc<T> = Map<String, dynamic> Function(T value);

class HiveJsonStorage<T> implements BaseStorage<T> {
  static const String _jsonBoxId = 'json_box';

  final BehaviorSubject<T?> _subject = BehaviorSubject<T?>();
  final String _key;
  final FromJsonFunc<T> _fromJson;
  final ToJsonFunc<T> _toJson;

  HiveJsonStorage({
    required String key,
    required FromJsonFunc<T> fromJson,
    required ToJsonFunc<T> toJson,
  })  : _key = key,
        _fromJson = fromJson,
        _toJson = toJson {
    _initialize();
  }

  static HiveJsonStorage<String> string({required String key}) {
    return StringHiveJsonStorage(key: key);
  }

  static HiveJsonStorage<List<M>> list<M>({
    required String key,
    required FromJsonFunc<M> fromJson,
    required ToJsonFunc<M> toJson,
  }) {
    return ListHiveJsonStorage<M>(key: key, fromJson: fromJson, toJson: toJson);
  }

  Future<Box<HiveJsonObject>> _getBox() => Hive.openBox<HiveJsonObject>(_jsonBoxId);

  Future<void> _initialize() async {
    final value = await _getFromBox();
    _subject.add(value);
  }

  @override
  Stream<T?> watch() => _subject.stream;

  @override
  Future<T?> get() async {
    return _subject.valueOrNull ?? (await _getFromBox());
  }

  Future<T?> _getFromBox() async {
    try {
      final model = (await _getBox()).get(_key);
      final jsonStr = model?.json ?? '';
      if (jsonStr.isEmpty) return null;

      final json = jsonDecode(jsonStr);
      return _fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> put(T value) async {
    _subject.add(value);
    final json = jsonEncode(_toJson(value));
    (await _getBox()).put(_key, HiveJsonObject(json));
  }

  @override
  Future<void> clear() async {
    _subject.add(null);
    await (await _getBox()).delete(_key);
  }
}

class StringHiveJsonStorage extends HiveJsonStorage<String> {
  StringHiveJsonStorage({required super.key}) : super(toJson: (id) => {'id': id}, fromJson: (map) => map['id']);
}

class ListHiveJsonStorage<T> extends HiveJsonStorage<List<T>> {
  ListHiveJsonStorage({
    required super.key,
    required FromJsonFunc<T> fromJson,
    required ToJsonFunc<T> toJson,
  }) : super(
          toJson: (list) => {'list': list.map((e) => toJson(e)).toList()},
          fromJson: (map) => map['list']?.map((e) => fromJson(e))?.cast<T>()?.toList(),
        );
}
