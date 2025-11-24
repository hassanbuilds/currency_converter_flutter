import 'package:courency_converter/core/errors/app_exception.dart';

/// Business entity for conversion results with fees and validation
class ConversionResult {
  final String fromCurrency;
  final String toCurrency;
  final double originalAmount;
  final double convertedAmount;
  final double exchangeRate;
  final double feeAmount;
  final DateTime timestamp;
  final bool feeApplied;

  ConversionResult({
    required this.fromCurrency,
    required this.toCurrency,
    required this.originalAmount,
    required this.convertedAmount,
    required this.exchangeRate,
    required this.feeAmount,
    required this.timestamp,
    required this.feeApplied,
  });

  /// Business rule: Final amount after fees
  double get finalAmount => convertedAmount - feeAmount;

  /// Business rule: Get the rate (alias for exchangeRate)
  double get rate => exchangeRate;

  /// Business rule: Validate conversion result
  void validate() {
    if (originalAmount <= 0) {
      throw ConversionException('Original amount must be positive');
    }
    if (convertedAmount <= 0) {
      throw ConversionException('Converted amount must be positive');
    }
    if (feeAmount < 0) {
      throw ConversionException('Fee cannot be negative');
    }
    if (finalAmount <= 0) {
      throw ConversionException('Final amount after fees must be positive');
    }
  }

  @override
  String toString() {
    return '${originalAmount.toStringAsFixed(2)} $fromCurrency → ${finalAmount.toStringAsFixed(2)} $toCurrency (Fee: \$${feeAmount.toStringAsFixed(2)})';
  }
}
