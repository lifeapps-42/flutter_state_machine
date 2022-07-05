part of '../state_machine_base.dart';

class HandlerNotRegisteredError extends StateMachineError {
  final Type eventType;

  HandlerNotRegisteredError(this.eventType);
  @override
  String get message => 'No handler is registered for $eventType';
}

class HandlerFunction<E extends Object, S extends Object> {
  final FutureOr<void> Function(E event, Handler<S> handler) _function;
  const HandlerFunction(this._function);

  FutureOr<void> call(E event, Handler<S> handler) => _function(event, handler);

  Type get eventType => E;
}

class Handler<S extends Object> {
  final Object _event;
  final StateMachine<S> _machine;
  bool _isDone = false;

  Handler(this._event, this._machine);

  void shift(S newState) {
    if (_isDone) return;
    final oldState = _machine.state;
    if (_machine._shift(newState)) {
      (_machine as EventGear).onShift(_event, oldState, newState);
    }
  }

  bool get isDone => _isDone;

  void close() {
    _isDone = true;
  }
}

mixin EventGear<S extends Object, E extends Object> on StateMachine<S> {
  final _handlerFunctions = <HandlerFunction<E, S>>{};

  bool _debugHandlersRegistered = false;

  void handler<EE extends E>(
    FutureOr<void> Function(EE event, Handler<S> handler) function,
  ) {
    assert(
      !_debugHandlersRegistered,
      'Handlers are to be registered only once with registerHandlers()',
    );
    final toAdd = HandlerFunction<EE, S>(function);
    assert(
        !_handlerFunctions
            .any((handler) => handler.eventType == toAdd.eventType),
        'Handler for ${toAdd.eventType} is already registered');
    _handlerFunctions.add(toAdd);
  }

  void registerHandlers();

  void addEvent(E event) async {
    try {
      final handlerFunction = _handlerFunctions.firstWhere(
        (handler) => handler.eventType == event.runtimeType,
      );

      final handler = Handler<S>(event, this);

      await handlerFunction(event, handler);
      handler.close();
    } on StateError {
      throw HandlerNotRegisteredError(event.runtimeType);
    }
  }

  @mustCallSuper
  void onShift(E event, S oldState, S newState) {
    print('$runtimeType($hashCode) shifted from $oldState to $newState');
  }

  @override
  void start() {
    registerHandlers();
    _debugHandlersRegistered = true;
    super.start();
  }
}
