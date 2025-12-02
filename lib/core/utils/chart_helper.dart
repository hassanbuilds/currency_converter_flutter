import 'dart:math';
import 'package:courency_converter/core/errors/app_exception.dart';
import 'package:courency_converter/data/models/conversion_history_model.dart';

class ChartHelper {
  static const int _maxHistoryPoints = 30;
  static const double _reasonableRateMin = 0.0001;
  static const double _reasonableRateMax = 10000.0;

  double _roundToDecimals(double value, int decimals) {
    final factor = pow(10, decimals);
    return (value * factor).round() / factor;
  }

  Random _seededRandom(double seed) {
    return Random((seed * 1000000).toInt());
  }

  List<double> extractRatesFromHistory(
    List<ConversionHistoryModel> history,
    String fromCurrency,
    String toCurrency,
  ) {
    if (history.isEmpty) return [];
    final relevantHistory =
        history
            .where(
              (entry) =>
                  entry.fromCurrency == fromCurrency &&
                  entry.toCurrency == toCurrency,
            )
            .toList();
    if (relevantHistory.isEmpty) return [];

    relevantHistory.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final rates =
        relevantHistory
            .map((entry) => entry.exchangeRate)
            .where((rate) => rate > 0)
            .toList();

    if (rates.isNotEmpty) validateChartData(rates);
    return rates;
  }

  Map<String, double> getPriceRange(List<double> rates) {
    if (rates.isEmpty) return {'min': 0.0, 'max': 0.0, 'current': 0.0};
    final min = rates.reduce((a, b) => a < b ? a : b);
    final max = rates.reduce((a, b) => a > b ? a : b);
    final current = rates.last;
    return {
      'min': _roundToDecimals(min, 4),
      'max': _roundToDecimals(max, 4),
      'current': _roundToDecimals(current, 4),
    };
  }

  void validateChartData(List<double> data) {
    if (data.isEmpty) return;
    if (data.any((rate) => rate.isNaN || rate.isInfinite || rate <= 0)) {
      throw ChartException('Invalid chart data');
    }
  }

  List<double> generateRealisticChartData(
    double currentRate, {
    int points = 30,
  }) {
    if (currentRate <= 0) return [currentRate];
    if (points < 5 || points > 50) points = 30;

    final data = <double>[currentRate];
    final random = Random(DateTime.now().millisecondsSinceEpoch);

    // Random trend: positive = upward, negative = downward
    final trend = (random.nextDouble() - 0.5) * 0.005;

    for (int i = 1; i < points; i++) {
      // Base volatility for sharper curves
      final baseVolatility = currentRate > 1.0 ? 0.02 : 0.03;
      // Smooth wave effect for natural ups and downs
      final oscillation = sin(i / points * pi * 2) * 0.01;
      // Combine random change, oscillation, and overall trend
      final changePercent =
          (random.nextDouble() - 0.5) * baseVolatility + oscillation + trend;
      final newRate = data.last * (1 + changePercent);
      data.add(_roundToDecimals(newRate, 6));
    }

    return data;
  }

  String formatPriceDisplay(double price, String currencyCode) {
    if (price == 0) return '0.00';

    final symbols = {
      'USD': '\$',
      'PKR': 'Rs',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'AUD': 'A\$',
      'CAD': 'C\$',
      'CHF': 'CHF',
      'CNY': '¥',
      'INR': '₹',
      'NZD': 'NZ\$',
      'SGD': 'S\$',
      'ZAR': 'R',
    };

    final symbol = symbols[currencyCode] ?? currencyCode;
    return '$symbol${price.toStringAsFixed(2)}';
  }

  String formatPriceRange(double min, double max, String currencyCode) {
    return '${formatPriceDisplay(min, currencyCode)} to ${formatPriceDisplay(max, currencyCode)}';
  }
}

class ChartException extends AppException {
  const ChartException(String message) : super(message);
}
