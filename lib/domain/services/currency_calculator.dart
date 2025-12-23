import 'package:courency_converter/core/errors/app_exception.dart';

class CurrencyCalculator {
  // EXACT COPY of _getPairRate() method from repository
  static double calculatePairRate(
    String from,
    String to,
    Map<String, double> rates,
  ) {
    if (!rates.containsKey(from) || !rates.containsKey(to)) {
      throw ConversionException('Invalid currency pair: $from → $to');
    }

    final fromRate = rates[from]!;
    final toRate = rates[to]!;

    if (fromRate <= 0 || toRate <= 0) {
      throw ConversionException('Invalid exchange rates for conversion');
    }

    return toRate / fromRate;
  }

  // EXACT COPY of the calculation part from convertAmount() method
  // Note: We're only copying the MATH part (amount * rate)
  // The validation before this happens in the repository
  static double calculateConvertedAmount(double amount, double rate) {
    return amount * rate;
  }
}
