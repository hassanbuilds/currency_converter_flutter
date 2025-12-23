/// Business entity for exchange rates between two currencies
class CurrencyRate {
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final DateTime timestamp;

  CurrencyRate({
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.timestamp,
  });

  @override
  String toString() {
    return '1 $fromCurrency = $rate $toCurrency';
  }
}
