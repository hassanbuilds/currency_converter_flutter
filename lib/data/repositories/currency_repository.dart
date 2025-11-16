import '../../core/constants/currency_data.dart';
import '../remote/currency_api_service.dart';
import '../local/shared_prefs_service.dart';
import '../../core/utils/chart_helper.dart';

class CurrencyRepository {
  final CurrencyApiService apiService = CurrencyApiService();
  final SharedPrefsService prefsService = SharedPrefsService();
  final ChartHelper chartHelper = ChartHelper();

  Map<String, double>? _cachedRates;
  DateTime? _lastFetched;

  /// Fetch live exchange rates from API, cache for 5 minutes
  Future<Map<String, double>> getExchangeRates() async {
    try {
      if (_cachedRates != null &&
          _lastFetched != null &&
          DateTime.now().difference(_lastFetched!) < Duration(minutes: 5)) {
        return _cachedRates!;
      }

      final rates = await apiService.fetchLatestRates();
      _cachedRates = rates;
      _lastFetched = DateTime.now();

      await saveRatesHistory(rates);
      return rates;
    } catch (e) {
      print("Error fetching rates: $e");
      // fallback: return last cached rates if available
      if (_cachedRates != null) return _cachedRates!;
      return {};
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

  /// Save live rates into chart history
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

  /// Get chart history for a currency pair
  Future<List<double>> getChartData(
    String from,
    String to, {
    Map<String, double>? rates,
  }) async {
    List<double> history = await prefsService.getDoubleList("${from}_$to");

    history =
        history
            .map((e) => e is double ? e : double.tryParse(e.toString()) ?? 0.0)
            .toList();

    if (history.isEmpty &&
        rates != null &&
        rates.containsKey(from) &&
        rates.containsKey(to)) {
      final liveRate = convert(amount: 1.0, from: from, to: to, rates: rates);
      history = [liveRate];
      await prefsService.saveDoubleList("${from}_$to", history);
    }

    return history;
  }
}
