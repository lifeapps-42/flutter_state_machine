import 'dart:async';

import 'package:flutter/material.dart';
import 'package:state_machine/src/gears/notifier_gear.dart';
import 'package:state_machine/state_machine.dart';

class MachineNotifications<M extends StateMachine, N extends Object>
    extends StatefulWidget {
  const MachineNotifications({
    Key? key,
    this.child = const SizedBox(),
    required this.machineFactory,
    required this.onNotification,
  }) : super(key: key);

  final Widget child;
  final MachineFactory<M, Object> machineFactory;
  final void Function(BuildContext context, N notification) onNotification;

  @override
  State<MachineNotifications<M, N>> createState() =>
      _NotificationsListenerState<M, N>();
}

class _NotificationsListenerState<M extends StateMachine, N extends Object>
    extends State<MachineNotifications<M, N>> {
  late final NotifierGear<Object, N> _gear;
  late final StreamSubscription _subscription;

  void _onNotification(N notification) {
    widget.onNotification(context, notification);
  }

  @override
  void initState() {
    assert(widget.machineFactory.resourceInstance is NotifierGear);
    _gear = widget.machineFactory.resourceInstance as NotifierGear<Object, N>;
    _subscription = widget.machineFactory.stateStream.listen((_) {});
    _gear.startListener(_onNotification);
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _gear.stopListener(_onNotification);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
