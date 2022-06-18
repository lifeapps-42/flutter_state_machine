import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:state_machine/state_machine.dart';

import 'state_watch.dart';

class StateReference {
  final BuildContext _context;

  StateReference(this._context);

  StateMachine getMachine<SM extends StateMachine>(StateWatch watch) {
    final machine = _context.read<SM>();
    _registerWatch(watch);
    return machine;
  }

  T getResource<T>() {
    return _context.read<T>();
  }

  final _watches = <StateWatch>{};

  void _registerWatch(StateWatch watch) {
    _watches.add(watch);
  }

  void cancel() {
    for (final watch in _watches) {
      watch.close();
    }
  }
}
