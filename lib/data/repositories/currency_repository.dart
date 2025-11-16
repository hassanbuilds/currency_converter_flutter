import 'dart:convert';
import '../remote/currency_api_service.dart';
import '../local/shared_prefs_service.dart';
import '../../core/utils/chart_helper.dart';

class CurrencyRepository {
  final CurrencyApiService apiService = CurrencyApiService();
  final SharedPrefsService prefsService = SharedPrefsService();
  final ChartHelper chartHelper = ChartHelper();

  Map<String, double>? _cachedRates;
  static const String cacheKey = 'cached_rates';

  /// Load cached rates from SharedPreferences
  Future<Map<String, double>> loadCachedRates() async {
    _cachedRates = await prefsService.getDoubleMap(cacheKey);
    return _cachedRates ?? {};
  }

  /// Save rates to SharedPreferences
  Future<void> saveCachedRates(Map<String, double> rates) async {
    await prefsService.saveDoubleMap(cacheKey, rates);
    _cachedRates = rates;
  }

  /// Fetch only selected currency pair rate (fast first conversion)
  Future<double> fetchPairRate(String from, String to) async {
    // Load cached rates if not loaded
    if (_cachedRates == null) {
      _cachedRates = await loadCachedRates();
    }

    // Return instantly if pair is cached
    if (_cachedRates != null &&
        _cachedRates!.containsKey(from) &&
        _cachedRates!.containsKey(to)) {
      return _cachedRates![to]! / _cachedRates![from]!;
    }

    // Otherwise fetch from API
    final rates = await apiService.fetchLatestRates();
    await saveCachedRates(rates);

    final pairRate = rates[to]! / rates[from]!;

    // Save only this pair for chart history
    await chartHelper.saveRate(from, to, pairRate);

    return pairRate;
  }

  /// Fetch all rates in background (non-blocking)
  Future<Map<String, double>> getExchangeRates() async {
    try {
      final rates = await apiService.fetchLatestRates();
      await saveCachedRates(rates);
      await saveRatesHistory(rates);
      return rates;
    } catch (e) {
      print("Error fetching all rates: $e");
      return _cachedRates ?? {};
    }
  }

  /// Convert amount from one currency to another
  double convert({
    required double amount,
    required String from,
    required String to,
    Map<String, double>? rates,
  }) {
    if (rates == null || !rates.containsKey(from) || !rates.containsKey(to)) {
      return 0.0;
    }
    return amount * (rates[to]! / rates[from]!);
  }

  /// Save all rates to chart history
  Future<void> saveRatesHistory(Map<String, double> rates) async {
    for (String from in rates.keys) {
      for (String to in rates.keys) {
        if (from == to) continue;
        final convertedRate = convert(
          amount: 1.0,
          from: from,
          to: to,
          rates: rates,
        );
        await chartHelper.saveRate(from, to, convertedRate);
      }
    }
  }

  /// Get chart history for a pair
  Future<List<double>> getChartData(
    String from,
    String to, {
    Map<String, double>? rates,
  }) async {
    final history = await chartHelper.getChartData(
      from,
      to,
      rates: rates ?? _cachedRates ?? {},
    );
    return history;
  }
}
