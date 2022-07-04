import 'package:flutter/material.dart';

import '../../state_machine.dart';

class SubmachineBuilder<S extends Object, T> extends StatefulWidget {
  const SubmachineBuilder({
    Key? key,
    required this.machineFactory,
    required this.builder,
    this.buildFilter = BuildFilter.equal,
    required this.subStateFactory,
  }) : super(key: key);

  final MachineFactory<S> machineFactory;
  final Widget Function(BuildContext context, S state, T subState) builder;
  final T Function(S state) subStateFactory;
  final BuildFilter buildFilter;

  @override
  State<SubmachineBuilder<S, T>> createState() =>
      _SubmachineBuilderState<S, T>();
}

class _SubmachineBuilderState<S extends Object, T>
    extends State<SubmachineBuilder<S, T>> {
  T? _currentSubState;
  Widget? _currentChild;

  bool _shouldIgnore(T newSubState) {
    final old = _currentSubState;
    if (old == null || _currentChild == null) return false;

    switch (widget.buildFilter) {
      case BuildFilter.equal:
        return old == newSubState;
      case BuildFilter.type:
        return old.runtimeType == newSubState.runtimeType;
    }
  }

  Widget _handleNewState(BuildContext context, S newState) {
    final subState = widget.subStateFactory(newState);
    if (_shouldIgnore(subState)) return _currentChild!;
    final newChild = widget.builder(context, newState, subState);
    setState(() {
      _currentSubState = subState;
      _currentChild = newChild;
    });
    return newChild;
  }

  @override
  Widget build(BuildContext context) {
    return MachineBuilder(
      machineFactory: widget.machineFactory,
      buildFilter: BuildFilter.equal,
      builder: _handleNewState,
    );
  }
}
