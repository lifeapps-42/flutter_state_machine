import 'currency.dart';

abstract class CurrencyRatesState {
  const CurrencyRatesState();
}

class CurrencyRatesNotInitializedState extends CurrencyRatesState {
  const CurrencyRatesNotInitializedState();
}

class CurrencyRatesLoadingState extends CurrencyRatesState {
  const CurrencyRatesLoadingState();
}

class CurrencyRatesDataState extends CurrencyRatesState {
  final List<CurrencyRate> rates;
  const CurrencyRatesDataState(this.rates);
}
