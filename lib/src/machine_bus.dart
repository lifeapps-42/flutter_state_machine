import 'dart:async';

import 'package:state_machine/src/constructable_resource.dart';

class MachineBus {
  MachineBus._();
  static MachineBus? _instance;

  factory MachineBus() {
    _instance ??= MachineBus._();
    return _instance!;
  }

  final _busResources = <ConstructableResource>{};

  R getResource<R>(covariant ConstructableResource<R> resourceFactory) {
    final factory = _busResources.firstWhere(
      (element) => element == resourceFactory,
    );

    return factory.resourceInstance;
  }

  void registerResource(ConstructableResource resource) {
    print('registerResource: ${resource.runtimeType}');
    _busResources.add(resource);
    print(_busResources);
  }
}
