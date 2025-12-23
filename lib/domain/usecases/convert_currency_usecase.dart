import 'package:courency_converter/core/errors/app_exception.dart';
import 'package:courency_converter/domain/entities/conversion_result.dart';
import '../repositories/currency_repository.dart';

class ConvertCurrencyUseCase {
  final CurrencyRepository _repository;

  ConvertCurrencyUseCase(this._repository);

  Future<ConversionResult> execute({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
    bool applyFees = false, // Optional: fees can be disabled
  }) async {
    _validateInput(fromCurrency, toCurrency, amount);

    try {
      final exchangeRate = await _repository.fetchPairRate(
        fromCurrency,
        toCurrency,
      );

      if (exchangeRate <= 0) {
        throw ConversionException('Invalid exchange rate: $exchangeRate');
      }

      // Convert the amount
      double convertedAmount = amount * exchangeRate;
      double feeAmount = 0.0;

      if (applyFees) {
        final feeResult = _calculateFee(
          convertedAmount,
          amount,
          fromCurrency,
          toCurrency,
        );
        convertedAmount = feeResult['finalAmount']!;
        feeAmount = feeResult['feeAmount']!;
      }

      return ConversionResult(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        originalAmount: amount,
        convertedAmount: convertedAmount,
        exchangeRate: exchangeRate,
        feeAmount: feeAmount,
        timestamp: DateTime.now(),
        feeApplied: feeAmount > 0,
      );
    } catch (e) {
      throw ConversionException('Conversion failed: $e');
    }
  }

  void _validateInput(String fromCurrency, String toCurrency, double amount) {
    if (fromCurrency.isEmpty || toCurrency.isEmpty) {
      throw ArgumentError('Currency codes cannot be empty');
    }
    if (fromCurrency == toCurrency) {
      throw ConversionException('Cannot convert between same currencies');
    }
    if (amount <= 0) {
      throw ConversionException('Amount must be greater than zero');
    }
  }

  Map<String, double> _calculateFee(
    double convertedAmount,
    double originalAmount,
    String fromCurrency,
    String toCurrency,
  ) {
    double feePercentage;

    if (originalAmount < 50) {
      feePercentage = 0.03;
    } else if (originalAmount <= 1000) {
      feePercentage = 0.015;
    } else {
      feePercentage = 0.008;
    }

    // Optional: Only apply extra for high-risk currencies
    if (_isHighRiskPair(fromCurrency, toCurrency)) {
      feePercentage += 0.01;
    }

    double feeAmount = convertedAmount * feePercentage;
    feeAmount = feeAmount < 0.5 ? 0.5 : feeAmount;
    double finalAmount = convertedAmount - feeAmount;

    return {'finalAmount': finalAmount, 'feeAmount': feeAmount};
  }

  bool _isHighRiskPair(String from, String to) {
    const highRiskPairs = [
      {'USD', 'PKR'},
      {'USD', 'ARS'},
      {'EUR', 'TRY'},
      {'USD', 'VES'},
    ];
    return highRiskPairs.any(
      (pair) => pair.contains(from) && pair.contains(to),
    );
  }
}
