import 'dart:async';

import 'package:flutter/material.dart';

import '../../state_machine.dart';

class Target<S extends Object, T extends Object> {
  final T? Function(S state) target;

  const Target(this.target);

  T? call(S state) => target(state);
}

abstract class StateFilter<S extends Object> {
  const StateFilter();
  bool Function(S oldState, S newState) get shouldIgnore;
}

class EqualStateFilter<S extends Object> extends StateFilter<S> {
  const EqualStateFilter();
  @override
  bool Function(S oldState, S newState) get shouldIgnore {
    return (oldState, newState) => oldState == newState;
  }
}

class TypeStateFilter<S extends Object> extends StateFilter<S> {
  const TypeStateFilter();
  @override
  bool Function(S oldState, S newState) get shouldIgnore {
    return (oldState, newState) => oldState.runtimeType == newState.runtimeType;
  }
}

class PreciseStateFilter<S extends Object, T extends Object>
    extends StateFilter<S> {
  final Target<S, T> target;
  const PreciseStateFilter(this.target);
  @override
  bool Function(S oldState, S newState) get shouldIgnore {
    return (oldState, newState) => target(oldState) == target(newState);
  }
}

class MultiplePreciseStateFilter<S extends Object> extends StateFilter<S> {
  final Set<Target<S, Object>> targets;
  const MultiplePreciseStateFilter(this.targets);

  @override
  bool Function(S oldState, S newState) get shouldIgnore =>
      _didAnyTargetChanged;

  bool _didAnyTargetChanged(S oldState, S newState) {
    for (final target in targets) {
      if (target(oldState) != target(newState)) return true;
    }
    return false;
  }
}

class CustomStateFilter<S extends Object> extends StateFilter<S> {
  final bool Function(S oldState, S newState) ignoreWhen;
  const CustomStateFilter(this.ignoreWhen);
  @override
  bool Function(S oldState, S newState) get shouldIgnore => ignoreWhen;
}

class MachineBuilder<S extends Object> extends StatefulWidget {
  const MachineBuilder({
    Key? key,
    required this.machineFactory,
    required this.builder,
    this.stateFilter = const EqualStateFilter(),
    this.child = const SizedBox(),
  }) : super(key: key);

  final MachineFactory<S> machineFactory;
  final Widget Function(BuildContext context, S state, Widget child) builder;
  final StateFilter stateFilter;
  final Widget child;

  @override
  State<MachineBuilder> createState() => _MachineBuilderState<S>();
}

class _MachineBuilderState<S extends Object> extends State<MachineBuilder<S>> {
  late final MachineFactory<S> _machineFactory;
  late S _state;
  late final StreamSubscription<S> _stateSubscription;

  bool _shouldIgnore(S newState) {
    return widget.stateFilter.shouldIgnore(_state, newState);
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
    return widget.builder(context, _state, widget.child);
  }
}

class MachineListener<S extends Object> extends StatefulWidget {
  const MachineListener({
    Key? key,
    required this.machineFactory,
    required this.onChange,
    this.stateFilter = const EqualStateFilter(),
    this.child = const SizedBox(),
  }) : super(key: key);

  final MachineFactory<S> machineFactory;
  final void Function(BuildContext context, S oldState, S newState) onChange;
  final StateFilter stateFilter;
  final Widget child;

  @override
  State<MachineListener<S>> createState() => _MachineListenerState<S>();
}

class _MachineListenerState<S extends Object>
    extends State<MachineListener<S>> {
  late final MachineFactory<S> _machineFactory;
  late S _state;
  late final StreamSubscription<S> _stateSubscription;

  bool _shouldIgnore(S newState) {
    return widget.stateFilter.shouldIgnore(_state, newState);
  }

  void _maybeCall(S newState) {
    if (!mounted) return;
    if (_shouldIgnore(newState)) return;
    widget.onChange(context, _state, newState);
  }

  void _subscribeToMachine() {
    _stateSubscription = widget.machineFactory.stateStream.listen(_maybeCall);
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
    return widget.child;
  }
}
