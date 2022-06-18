class Currency {
  final String id;
  final String code;
  final String name;

  const Currency({
    required this.id,
    required this.code,
    required this.name,
  });
}

class CurrencyRate {
  final Currency currency;
  final double rate;
  final bool isGrowing;

  const CurrencyRate({
    required this.currency,
    required this.rate,
    required this.isGrowing,
  });
}
