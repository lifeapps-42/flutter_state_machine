abstract class StateMachineError extends Error {
  String get message;
  StateMachineError();
}

class EventHandlerNotRegistered extends StateMachineError {
  final Object event;

  EventHandlerNotRegistered(this.event);

  @override
  String get message => 'No handler is registered for ${event.runtimeType}';
}
