import 'dart:async';

import 'package:flutter/material.dart';

import '../../state_machine.dart';

enum BuildFilter {
  equal,
  type,
}

class MachineBuilder<S extends Object> extends StatefulWidget {
  const MachineBuilder({
    Key? key,
    required this.machineFactory,
    required this.builder,
    this.buildFilter = BuildFilter.equal,
  }) : super(key: key);

  final MachineFactory<S> machineFactory;
  final Widget Function(BuildContext context, S state) builder;
  final BuildFilter buildFilter;

  @override
  State<MachineBuilder> createState() =>
      _MachineBuilderState<StateMachine<S>, S>();
}

class _MachineBuilderState<M extends StateMachine<S>, S extends Object>
    extends State<MachineBuilder<S>> {
  late final MachineFactory<S> _machineFactory;
  late S _state;
  late final StreamSubscription<S> _stateSubscription;

  bool _shouldIgnore(S newState) {
    switch (widget.buildFilter) {
      case BuildFilter.equal:
        return _state == newState;
      case BuildFilter.type:
        return _state.runtimeType == newState.runtimeType;
    }
  }

  void _maybeRebuild(S newState) {
    if (!mounted) return;
    if (_shouldIgnore(newState)) return;
    setState(() {
      _state = newState;
    });
  }

  void _subscribeToMachine() {
    _stateSubscription =
        widget.machineFactory.stateStream.listen(_maybeRebuild);
  }

  @override
  void initState() {
    super.initState();
    _machineFactory = widget.machineFactory;
    _state = _machineFactory.state;
    _subscribeToMachine();
  }

  @override
  void dispose() {
    _stateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _state);
  }
}
