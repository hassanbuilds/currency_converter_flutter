import 'package:courency_converter/core/errors/app_exception.dart';
import 'package:courency_converter/data/models/conversion_history_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyLocalDataSource {
  static const String _cachedRatesKey = 'cached_exchange_rates';
  static const String _lastFetchTimeKey = 'last_fetch_time';
  static const String _chartDataPrefix = 'chart_data_';

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  Future<void> cacheExchangeRates(Map<String, double> rates) async {
    try {
      final prefs = await _prefs;
      final ratesJson = _convertRatesToJson(rates);
      await prefs.setString(_cachedRatesKey, ratesJson);
      await prefs.setString(
        _lastFetchTimeKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw CacheException('Failed to cache rates: $e');
    }
  }

  Future<Map<String, double>> getCachedRates({
    Duration maxAge = const Duration(hours: 1),
  }) async {
    try {
      final prefs = await _prefs;
      final ratesJson = prefs.getString(_cachedRatesKey);
      final lastFetchString = prefs.getString(_lastFetchTimeKey);

      if (ratesJson == null || lastFetchString == null) return {};

      final lastFetch = DateTime.parse(lastFetchString);
      if (DateTime.now().difference(lastFetch) > maxAge) {
        await clearCache();
        return {};
      }

      return _parseRatesFromJson(ratesJson);
    } catch (e) {
      throw CacheException('Failed to read cached rates: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(_cachedRatesKey);
      await prefs.remove(_lastFetchTimeKey);
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }

  Future<void> saveChartData(String from, String to, List<double> data) async {
    try {
      final prefs = await _prefs;
      final key = '${_chartDataPrefix}${from}_$to';
      final dataString = data.map((e) => e.toString()).join(',');
      await prefs.setString(key, dataString);
    } catch (e) {
      throw CacheException('Failed to save chart data: $e');
    }
  }

  Future<List<double>> getChartData(String from, String to) async {
    try {
      final prefs = await _prefs;
      final key = '${_chartDataPrefix}${from}_$to';
      final dataString = prefs.getString(key);
      if (dataString == null) return [];
      return dataString
          .split(',')
          .map((e) => double.tryParse(e) ?? 0.0)
          .toList();
    } catch (e) {
      throw CacheException('Failed to load chart data: $e');
    }
  }

  String _convertRatesToJson(Map<String, double> rates) {
    return rates.entries.map((e) => '${e.key}:${e.value}').join(';');
  }

  Map<String, double> _parseRatesFromJson(String json) {
    final Map<String, double> rates = {};
    final entries = json.split(';');
    for (final entry in entries) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        final value = double.tryParse(parts[1]);
        if (value != null) rates[parts[0]] = value;
      }
    }
    return rates;
  }

  getHistoricalRates(String from, String to, {required int days}) {}

  saveConversionHistoryEntry(ConversionHistoryModel entry) {}

  getCachedRatesRaw() {}

  getConversionHistory() {}
}
