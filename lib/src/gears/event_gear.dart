part of '../state_machine_base.dart';

typedef EventHandlerFunction<E extends Object, S extends Object>
    = FutureOr<void> Function(E event, Handler<S> handler);

class Handler<S extends Object> {
  final Object _event;
  final StateMachine<S> _machine;
  bool _isDone = false;

  Handler(this._event, this._machine);

  void shift(S newState) {
    if (_isDone) return;
    _machine._shift(newState);
    (_machine as EventGear).onShift(_event, _machine.state, newState);
  }

  bool get isDone => _isDone;

  void close() {
    _isDone = true;
  }
}

mixin EventGear<S extends Object, E extends Object> on StateMachine<S> {
  final _handlerFunctions = <EventHandlerFunction<E, S>>{};

  void handler<EE extends E>(EventHandlerFunction<EE, S> handler) {
    _handlerFunctions.add(handler as EventHandlerFunction<E, S>);
  }

  void _registerHandlers();

  void addEvent<EE extends E>(E event) async {
    final handlerFunction = _handlerFunctions.firstWhere(
      (handler) => handler.runtimeType == EventHandlerFunction<EE, Handler<S>>,
      //TODO catch  error
    );

    final handler = Handler<S>(event, this);

    await handlerFunction(event, handler);
    handler.close();
  }

  @mustCallSuper
  void onShift(E event, S oldState, S newState) {
    print('$runtimeType($hashCode) shifted from $oldState to $newState');
  }

  @override
  void start() {
    super.start();
    _registerHandlers();
  }
}
