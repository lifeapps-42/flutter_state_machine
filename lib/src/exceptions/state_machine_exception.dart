abstract class StateMachineError extends Error {
  String get message;
  StateMachineError();

  @override
  String toString() {
    return '$runtimeType: $message';
  }
}
