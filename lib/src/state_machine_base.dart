// TODO: Put public facing types in this file.

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:state_machine/src/state_reference.dart';

import 'event_handler.dart';
import 'exceptions/state_machine_exception.dart';

/// Checks if you are awesome. Spoiler: you are.
abstract class StateMachine<E extends Object, S, M> {
  StateMachine(this._state, this._reference, {this.initialEvent}) {
    _stateStreamController = StreamController<S>.broadcast();
    _messageStreamController = StreamController<M>.broadcast();

    if (initialEvent != null) {
      addEvent(initialEvent!);
    }
  }

  S _state;
  final E? initialEvent;
  final _handlersMap = <Type, Function>{};
  final StateReference _reference;
  late final StreamController<S> _stateStreamController;
  late final StreamController<M> _messageStreamController;

  set state(S newState) {
    if (_state == newState) return;
    _state = newState;
    _stateStreamController.add(newState);
  }

  S get state => _state;
  Stream<S> get stateStream => _stateStreamController.stream;
  Stream<M> get messages => _messageStreamController.stream;

  void handle<ET extends E>(Function(ET) handler) {
    _handlersMap[ET] = handler;
  }

  void addEvent(E event) {
    final handler = _handlersMap[event.runtimeType];
    if (handler != null) {
      handler(event);
    } else {
      throw EventHandlerNotRegistered(event);
    }
  }

  void addMessage(M message) {
    _messageStreamController.add(message);
  }

  @mustCallSuper
  void close() {
    _reference.cancel();
    _stateStreamController.close();
    _messageStreamController.close();
  }
}
