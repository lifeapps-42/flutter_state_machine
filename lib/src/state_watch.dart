import 'dart:async';

import 'state_reference.dart';
import '../state_machine.dart';

enum WatchType { type, equality }

class StateWatch<SM extends StateMachine<E, S, Object>, E extends Object, S> {
  final StateReference reference;
  final WatchType watchType;
  final void Function(S state) onChange;

  StateWatch(
    this.reference, {
    this.watchType = WatchType.equality,
    required this.onChange,
  }) {
    _initWatch();
  }
  late final SM _machine;
  late final StreamSubscription<S> _subscription;
  late S _lastWatchedState;
  late S _lastKnownState;

  S get currentState => _lastKnownState;

  void _listener(S state) {
    _lastKnownState = state;
    if (_shouldIgnore(state)) return;
    _lastWatchedState = state;
    onChange(state);
  }

  bool _shouldIgnore(S state) {
    switch (watchType) {
      case WatchType.equality:
        return _lastWatchedState == state;
      case WatchType.type:
        return _lastWatchedState.runtimeType == state.runtimeType;
    }
  }

  void _initWatch() {
    _machine = reference.getMachine<SM>(this) as SM;
    _lastKnownState = _machine.state;
    final stream = _machine.stateStream;
    _subscription = stream.listen(_listener);
  }

  void addEvent(E event) {
    _machine.addEvent(event);
  }

  void close() {
    _subscription.cancel();
  }
}
