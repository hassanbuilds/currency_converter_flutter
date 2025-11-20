import '../remote/currency_api_service.dart';
import '../local/shared_prefs_service.dart';
import '../../core/utils/chart_helper.dart';

class CurrencyRepository {
  final CurrencyApiService apiService = CurrencyApiService();
  final SharedPrefsService prefsService = SharedPrefsService();
  final ChartHelper chartHelper = ChartHelper();

  Map<String, double>? _cachedRates;
  static const String cacheKey = 'cached_rates';

  //Helpers
  double getPairRate(String from, String to, Map<String, double> rates) {
    return rates[to]! / rates[from]!;
  }

  // Public Methods
  Future<Map<String, double>> loadCachedRates() async {
    _cachedRates = await prefsService.getDoubleMap(cacheKey);
    return _cachedRates ?? {};
  }

  Future<void> saveCachedRates(Map<String, double> rates) async {
    _cachedRates = rates;
    await prefsService.saveDoubleMap(cacheKey, rates);
  }

  Future<double> fetchPairRate(String from, String to) async {
    if (_cachedRates == null) {
      _cachedRates = await loadCachedRates();
    }

    if (_cachedRates!.containsKey(from) && _cachedRates!.containsKey(to)) {
      return getPairRate(from, to, _cachedRates!);
    }

    final rates = await apiService.fetchLatestRates();
    await saveCachedRates(rates);
    final pairRate = getPairRate(from, to, rates);
    await chartHelper.saveRate(from, to, pairRate);
    return pairRate;
  }

  Future<Map<String, double>> getExchangeRates() async {
    try {
      final rates = await apiService.fetchLatestRates();
      await saveCachedRates(rates);
      return rates;
    } catch (e) {
      print("Error fetching all rates: $e");
      return _cachedRates ?? {};
    }
  }

  double convert({
    required double amount,
    required String from,
    required String to,
    Map<String, double>? rates,
  }) {
    final usedRates = rates ?? _cachedRates;
    if (usedRates == null ||
        !usedRates.containsKey(from) ||
        !usedRates.containsKey(to)) {
      return 0.0;
    }
    return amount * getPairRate(from, to, usedRates);
  }

  Future<void> saveRecentPairHistory(String from, String to) async {
    if (_cachedRates == null) return;
    final rate = convert(amount: 1.0, from: from, to: to, rates: _cachedRates);
    await chartHelper.saveRate(from, to, rate);
  }

  Future<List<double>> getChartData(
    String from,
    String to, {
    Map<String, double>? rates,
  }) async {
    return await chartHelper.getChartData(
      from,
      to,
      rates: rates ?? _cachedRates ?? {},
    );
  }
}
