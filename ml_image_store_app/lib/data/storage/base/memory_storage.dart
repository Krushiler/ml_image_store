import 'dart:async';

import 'package:ml_image_store_app/data/storage/base/base_storage.dart';
import 'package:rxdart/rxdart.dart';

abstract class MemoryStorage<T> implements BaseStorage<T> {
  final BehaviorSubject<T?> _data = BehaviorSubject();

  MemoryStorage({T? initialData}) {
    if (initialData != null) {
      _data.add(initialData);
    }
  }

  @override
  Stream<T?> watch() => _data.stream;

  @override
  T? get() => _data.valueOrNull;

  @override
  void put(T data) {
    _data.add(data);
  }
}
