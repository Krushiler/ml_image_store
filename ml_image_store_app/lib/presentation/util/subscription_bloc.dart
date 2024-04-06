import 'dart:async';

import 'package:bloc/bloc.dart';

mixin SubscriptionBloc<S> on BlocBase<S> {
  final List<StreamSubscription> _subscriptions = [];

  StreamSubscription<T> subscribe<T>(Stream<T> stream, void Function(T event) onData) {
    final StreamSubscription<T> subscription = stream.listen(onData);
    _subscriptions.add(subscription);
    return subscription;
  }

  @override
  Future<void> close() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    return super.close();
  }
}
