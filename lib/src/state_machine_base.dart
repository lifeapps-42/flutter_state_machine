// TODO: Put public facing types in this file.

import 'dart:async';

import 'package:meta/meta.dart';

part 'gears/shift_gear.dart';
part 'gears/event_gear.dart';

/// Checks if you are awesome. Spoiler: you are.
abstract class StateMachine<S extends Object> {
  StateMachine(this._initialState) {
    start();
  }
  final S _initialState;
  late S _state;
  // final E? initialEvent;
  // final _handlersMap = <Type, Function>{};
  // final StateReference _reference;
  late final StreamController<S> _stateStreamController;

  @nonVirtual
  bool _shift(S newState) {
    if (_state == newState) return false;
    _state = newState;
    _stateStreamController.add(newState);
    return true;
  }

  // StateReference get reference => _reference;
  S get state => _state;
  Stream<S> get stateStream => _stateStreamController.stream;

  // void handle<ET extends E>(Function(ET event) handler) {
  //   _handlersMap[ET] = handler;
  // }

  // void addEvent(E event) {
  //   final handler = _handlersMap[event.runtimeType];
  //   if (handler != null) {
  //     handler(event);
  //   } else {
  //     throw EventHandlerNotRegistered(event);
  //   }
  // }

  @mustCallSuper
  void start() {
    _stateStreamController = StreamController<S>.broadcast();
    _state = _initialState;
  }

  @mustCallSuper
  void stop() {
    // _reference.cancel();
    _stateStreamController.close();
    print('$runtimeType($hashCode) is stopped');
    // _messageStreamController.close();
  }
}
