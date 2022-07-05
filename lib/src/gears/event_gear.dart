part of '../state_machine_base.dart';

class HandlerFunction<E extends Object, S extends Object> {
  final FutureOr<void> Function(E event, Handler<S> handler) _function;
  const HandlerFunction(this._function);
  FutureOr<void> call(E event, Handler<S> handler) => _function(event, handler);
}

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
  final _handlerFunctions = <HandlerFunction<E, S>>{};

  void handler<EE extends E>(
    FutureOr<void> Function(EE event, Handler<S> handler) function,
  ) {
    _handlerFunctions.add(HandlerFunction<EE, S>(function));
  }

  void registerHandlers();

  void addEvent<EE extends E>(E event) async {
    final handlerFunction = _handlerFunctions.firstWhere(
      (handler) => handler.runtimeType == HandlerFunction<EE, Handler<S>>,
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
    registerHandlers();
    super.start();
  }
}
