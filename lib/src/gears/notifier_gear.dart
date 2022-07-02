import 'dart:async';

import '../../state_machine.dart';

mixin MessengerGear<M> on StateMachine {
  final _messageStreamController = StreamController<M>.broadcast();
  Stream<M> get messages => _messageStreamController.stream;

  void addMessage(M message) {
    _messageStreamController.add(message);
  }
}
