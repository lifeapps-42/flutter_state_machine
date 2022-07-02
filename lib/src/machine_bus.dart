import 'dart:async';

import 'package:state_machine/src/constructable_resource.dart';

class Bus {
  Bus._();
  static Bus? _instance;

  factory Bus() {
    _instance ??= Bus._();
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
