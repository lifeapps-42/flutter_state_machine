import 'dart:async';

import 'package:flutter/material.dart';

class EventHandler<E> {
  final FutureOr<void> Function(E) handle;

  const EventHandler(this.handle);
}
