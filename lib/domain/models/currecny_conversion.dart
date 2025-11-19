class CurrencyConversion {
  final String fromCurrency;
  final String toCurrency;
  final double amount;
  final double? result;

  CurrencyConversion({
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
    this.result,
  });

  @override
  String toString() {
    final resultText =
        result != null
            ? result!.toStringAsFixed(2)
            : '?'; // fallback if result not yet calculated
    return '$amount $fromCurrency → $resultText $toCurrency';
  }
}
