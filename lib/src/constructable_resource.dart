import 'dart:async';

import 'package:flutter/foundation.dart';

import '../state_machine.dart';

abstract class ConstructableResource<T> {
  ConstructableResource() {
    _initFactory();
  }

  T? _resource;
  T Function(MachineBus bus) get _factory;
  bool get isLazy;

  @nonVirtual
  void _registerInBus() {
    final bus = MachineBus.instance;
    bus.registerResource(this);
  }

  @nonVirtual
  T get _resourceInstance {
    _resource ??= _factory(MachineBus.instance);
    return _resource!;
  }

  @mustCallSuper
  void _initFactory() {
    _registerInBus();
    if (!isLazy) {
      _resource = _factory(MachineBus.instance);
    }
  }

  @mustCallSuper
  void _dispose() {
    _resource = null;
  }
}

class ResourceFactory<T> extends ConstructableResource {
  ResourceFactory(
    this._resourceFactory, {
    this.lazy = true,
    this.autoDispose = false,
  });

  final T Function(MachineBus bus) _resourceFactory;
  final bool lazy;
  final bool autoDispose;

  @override
  T Function(MachineBus bus) get _factory => _resourceFactory;

  @override
  bool get isLazy => lazy;

  void dispose() {
    _dispose();
  }
}

class MachineFactory<M extends StateMachine<S>, S>
    extends ConstructableResource<StateMachine<S>> {
  MachineFactory(
    this._machineFactory, {
    this.autoStart = true,
    this.autoStop = false,
  }) {
    _initFactory();
  }

  final StateMachine<S> Function(MachineBus bus) _machineFactory;
  final bool autoStart;
  final bool autoStop;

  late final SynchronousStreamController<S> _machineStateStreamController;

  StreamSubscription<S>? _machineStateStreamSubscription;

  Stream<S> get stateStream => _machineStateStreamController.stream;
  S get state => _resourceInstance.state;

  @override
  StateMachine<S> Function(MachineBus bus) get _factory => _machineFactory;

  @override
  bool get isLazy => autoStart;

  void _onListen() {
    _machineStateStreamSubscription = _resourceInstance.stateStream.listen(
      _machineStateStreamController.add,
    );
  }

  void _onCancel() {
    _machineStateStreamSubscription?.cancel();
    if (autoStop) {
      _resourceInstance.stop();
      _resource = null;
    }
    _dispose();
  }

  @override
  void _initFactory() {
    super._initFactory();
    _machineStateStreamController = StreamController<S>.broadcast(
      sync: true,
      onListen: _onListen,
      onCancel: _onCancel,
    ) as SynchronousStreamController<S>;
  }
}
