import '../../state_machine.dart';

mixin NotifierGear<N> on StateMachine<Object> {
  final _listeners = <void Function(N notification)>[];

  void notify(N notification, {bool onlyNewest = false}) {
    if (_listeners.isEmpty) return;
    if (onlyNewest) {
      _listeners.first(notification);
    } else {
      for (final listener in _listeners) {
        listener(notification);
      }
    }
  }

  void startListener(void Function(N notification) callback) {
    _listeners.insert(0, callback);
  }

  void stopListener(void Function(N notification) callback) {
    _listeners.remove(callback);
  }
}
