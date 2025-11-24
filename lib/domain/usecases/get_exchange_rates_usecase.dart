import 'package:courency_converter/core/errors/app_exception.dart';

import '../repositories/currency_repository.dart';

/// Business logic for fetching exchange rates with smart caching
class GetExchangeRatesUseCase {
  final CurrencyRepository _repository;

  GetExchangeRatesUseCase(this._repository);

  /// Fetches exchange rates with validation and business rules
  Future<Map<String, double>> execute({bool forceRefresh = false}) async {
    try {
      // Business rule: Rate limiting check
      _checkRateLimit();

      Map<String, double> rates;

      if (forceRefresh) {
        // Force fresh data from API
        rates = await _repository.getExchangeRates();
      } else {
        // Try cached first, then API if needed
        final cachedRates = await _repository.loadCachedRates();
        rates =
            cachedRates.isNotEmpty
                ? cachedRates
                : await _repository.getExchangeRates();
      }

      // Business rule: Validate rate data quality
      _validateRatesData(rates);

      return rates;
    } catch (e) {
      throw ConversionException('Failed to fetch exchange rates: $e');
    }
  }

  /// Business rule: Prevent too many API calls
  void _checkRateLimit() {
    // In real app, you'd track last API call time
    // For now, we'll just implement the pattern
    final lastCallTime = DateTime.now(); // You'd get this from storage
    final timeSinceLastCall = DateTime.now().difference(lastCallTime);

    if (timeSinceLastCall.inSeconds < 30) {
      throw ConversionException('Rate limit: Wait 30 seconds between fetches');
    }
  }

  /// Business rule: Validate that rates are complete and reasonable
  void _validateRatesData(Map<String, double> rates) {
    if (rates.isEmpty) {
      throw ConversionException('No exchange rate data available');
    }

    // Check for essential currencies
    const requiredCurrencies = ['USD', 'EUR', 'GBP', 'JPY', 'PKR'];
    final missingCurrencies =
        requiredCurrencies
            .where((currency) => !rates.containsKey(currency))
            .toList();

    if (missingCurrencies.isNotEmpty) {
      throw ConversionException(
        'Missing essential currencies: ${missingCurrencies.join(', ')}',
      );
    }

    // Validate rate sanity - prevent garbage data
    final usdToPkr = rates['PKR']! / rates['USD']!;
    if (usdToPkr < 50 || usdToPkr > 500) {
      throw ConversionException('Suspicious exchange rate detected');
    }

    // Check for extreme values
    final extremeRates =
        rates.entries
            .where((entry) => entry.value <= 0.0001 || entry.value > 10000)
            .toList();

    if (extremeRates.isNotEmpty) {
      throw ConversionException('Unrealistic exchange rates detected');
    }
  }

  /// Gets rates for specific currencies only (optimized)
  Future<Map<String, double>> executeForCurrencies(
    List<String> currencies,
  ) async {
    if (currencies.isEmpty) {
      throw ArgumentError('Currency list cannot be empty');
    }

    final allRates = await execute();

    // Filter only requested currencies
    return Map.fromEntries(
      allRates.entries.where((entry) => currencies.contains(entry.key)),
    );
  }

  /// Gets cross rates between two specific currencies
  Future<double> getCrossRate(String fromCurrency, String toCurrency) async {
    final rates = await execute();

    if (!rates.containsKey(fromCurrency) || !rates.containsKey(toCurrency)) {
      throw ConversionException(
        'Unsupported currency pair: $fromCurrency → $toCurrency',
      );
    }

    return rates[toCurrency]! / rates[fromCurrency]!;
  }

  getHistoricalRates(
    String fromCurrency,
    String toCurrency, {
    required int days,
  }) {}

  fetchPairRate(String fromCurrency, String toCurrency) {}
}
