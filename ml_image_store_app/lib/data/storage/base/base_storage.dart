import 'package:rxdart/rxdart.dart';

abstract class BaseStorage<T> {
  final BehaviorSubject<T> _data = BehaviorSubject();

  BaseStorage({T? initialData}) {
    if (initialData != null) {
      _data.add(initialData);
    }
  }

  Stream<T> watch() => _data.stream;

  T get() => _data.value;

  T? getOrNull() => _data.valueOrNull;

  void put(T data) {
    _data.add(data);
  }
}
