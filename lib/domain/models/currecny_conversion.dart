// lib/domain/models/currency_conversion.dart
class CurrencyConversion {
  final String fromCurrency;
  final String toCurrency;
  final double amount;
  final double? result; //  make it nullable (optional)

  CurrencyConversion({
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
    this.result, //  no longer required
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
