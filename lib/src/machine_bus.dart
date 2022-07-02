import 'package:state_machine/src/constructable_resource.dart';

class MachineBus {
  MachineBus._();
  static MachineBus? _instance;
  static MachineBus get instance => _instance ?? MachineBus._();

  final _busResources = <Object>{};

  T getResource<T extends ConstructableResource>(T resource) {
    final resourceInstance = _busResources.firstWhere(
      (element) => element == resource,
    );

    return resourceInstance as T;
  }

  void registerResource(ConstructableResource resource) {
    _busResources.add(resource);
  }
}
