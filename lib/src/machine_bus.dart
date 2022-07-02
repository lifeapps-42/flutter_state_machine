import 'dart:async';

import 'package:state_machine/src/constructable_resource.dart';

class MachineBus {
  MachineBus._();
  static MachineBus? _instance;
  static MachineBus get instance => _instance ?? MachineBus._();

  final _busResources = <ConstructableResource>{};

  R getResource<R>(covariant ConstructableResource<R> resourceFactory) {
    final factory = _busResources.firstWhere(
      (element) => element == resourceFactory,
    );

    return factory.resourceInstance;
  }

  void registerResource(ConstructableResource resource) {
    print('registerResource: ${resource.runtimeType}');
    print(_busResources);
    _busResources.add(resource);
  }
}
