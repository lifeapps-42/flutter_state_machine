part of '../state_machine_base.dart';

mixin ShiftGear<S extends Object> on StateMachine<S> {
  @nonVirtual
  void shift(S newState) {
    final oldState = _state;
    if (_shift(newState)) {
      onShift(oldState, _state);
    }
  }

  @mustCallSuper
  void onShift(S oldState, S newState) {
    print('$runtimeType($hashCode) shifted from $oldState to $newState');
  }
}
