import 'dart:async';

import 'package:state_machine/src/event_handler.dart';
import 'package:state_machine/src/resource_locator.dart';
import 'package:state_machine/src/state_reference.dart';
import 'package:state_machine/state_machine.dart';

import 'currency_event.dart';
import 'currency_message.dart';
import 'currency_state.dart';
import 'repo.dart';

class CurrencyRatesStateMachine extends StateMachine<CurrencyRatesEvent,
    CurrencyRatesState, CurrencyRatesMessage> {
  CurrencyRatesStateMachine(StateReference reference)
      : super(const CurrencyRatesNotInitializedState(), reference) {
    handle<CurrencyRatesStartEvent>(_onStart);

    _repo = reference.getResource();
  }

  late final Repo _repo;

  void _onStart(CurrencyRatesStartEvent event) {
    _repo.getSome();
  }
}
