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
    print('_initFactory: $runtimeType, $hashCode');
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
  });

  final T Function(MachineBus bus) _resourceFactory;
  final bool lazy;

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

  late final StreamController<S> _factoryStateStreamController;

  StreamSubscription<S>? _machineStateStreamSubscription;

  Stream<S> get stateStream => _factoryStateStreamController.stream;
  S get state => resourceInstance.state;

  @override
  StateMachine<S> Function(MachineBus bus) get _factory => _machineFactory;

  @override
  bool get isLazy => autoStart;

  void _onListen() {
    _machineStateStreamSubscription = resourceInstance.stateStream.listen(
      _factoryStateStreamController.add,
    );
    print('${resourceInstance.stateStream} subscription started');
  }

  void _onCancel() {
    _machineStateStreamSubscription?.cancel();
    print('${resourceInstance.stateStream} subscription cancelled');
    if (autoStop) {
      resourceInstance.stop();
      _dispose();
    }
  }

  @override
  void _initFactory() {
    super._initFactory();
    _factoryStateStreamController = StreamController<S>.broadcast(
      onListen: _onListen,
      onCancel: _onCancel,
    );
  }
}
