import '../state_machine.dart';

class ResourceLocator<T> {
  final StateReference _reference;

  const ResourceLocator(this._reference);

  T get resource => _reference.getResource<T>();
}
