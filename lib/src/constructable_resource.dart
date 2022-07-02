import 'dart:async';

import 'package:flutter/foundation.dart';

import '../state_machine.dart';
import 'machine_bus.dart';

class MachineBus {
  const MachineBus._fromBus(this._bus);

  final Bus _bus;

  R getResource<R>(covariant ConstructableResource<R> resourceFactory) =>
      _bus.getResource(resourceFactory);
}

abstract class ConstructableResource<T> {
  ConstructableResource() {
    _initFactory();
  }

  T? _resource;
  T Function(MachineBus bus) get _factory;
  bool get isLazy;

  @nonVirtual
  void _registerInBus() {
    final bus = Bus();
    bus.registerResource(this);
  }

  @nonVirtual
  T get resourceInstance {
    _createResourceIfNull();
    return _resource!;
  }

  void _createResourceIfNull() {
    late final machineBus = MachineBus._fromBus(Bus());
    _resource ??= _factory(machineBus);
  }

  @mustCallSuper
  void _initFactory() {
    _registerInBus();
    if (!isLazy) {
      _createResourceIfNull();
    }
  }

  @mustCallSuper
  void _dispose() {
    _resource = null;
  }
}

class ResourceFactory<T> extends ConstructableResource<T> {
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

class MachineFactory<S extends Object>
    extends ConstructableResource<StateMachine<S>> {
  MachineFactory(
    this._machineFactory, {
    this.autoStart = true,
    this.autoStop = false,
  });

  final StateMachine<S> Function(MachineBus bus) _machineFactory;
  final bool autoStart;
  final bool autoStop;

  late final SynchronousStreamController<S> _machineStateStreamController;

  StreamSubscription<S>? _machineStateStreamSubscription;

  Stream<S> get stateStream => _machineStateStreamController.stream;
  S get state => resourceInstance.state;

  @override
  StateMachine<S> Function(MachineBus bus) get _factory => _machineFactory;

  @override
  bool get isLazy => autoStart;

  void _onListen() {
    _machineStateStreamSubscription = resourceInstance.stateStream.listen(
      _machineStateStreamController.add,
    );
  }

  void _onCancel() {
    _machineStateStreamSubscription?.cancel();
    if (autoStop) {
      resourceInstance.stop();
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
