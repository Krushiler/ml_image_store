import 'dart:async';

abstract interface class BaseStorage<T> {
  Stream<T?> watch();

  FutureOr<T?> get();

  FutureOr<void> put(T data);

  FutureOr<void> clear();
}
