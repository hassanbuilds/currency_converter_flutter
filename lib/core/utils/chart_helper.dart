import 'package:courency_converter/data/local/shared_prefs_service.dart';

class ChartHelper {
  final SharedPrefsService _prefsService = SharedPrefsService();

  /// Get chart history for a single currency pair
  Future<List<double>> getChartData(
    String from,
    String to, {
    required Map<String, double> rates,
    bool reverse = false,
  }) async {
    final key = "${from}_$to";

    // Load history for the requested pair only
    List<double> history = await _prefsService.getDoubleList(key);

    // Convert all entries to double once
    history =
        history
            .map((e) => e is double ? e : double.tryParse(e.toString()) ?? 0.0)
            .toList();

    if (history.isEmpty) {
      // Check if reverse history exists
      final reverseKey = "${to}_$from";
      List<double> reverseHistory = await _prefsService.getDoubleList(
        reverseKey,
      );
      reverseHistory =
          reverseHistory
              .map(
                (e) => e is double ? e : double.tryParse(e.toString()) ?? 0.0,
              )
              .toList();

      if (reverseHistory.isNotEmpty) {
        // Only compute inverse if reverse history exists
        history =
            reverseHistory.map((rate) => rate == 0 ? 0.0 : 1.0 / rate).toList();
      } else {
        // Otherwise, generate live rate for first entry
        final liveRate =
            rates.containsKey(to) && rates.containsKey(from)
                ? rates[to]! / rates[from]!
                : 0.0;
        history = [liveRate];
        await _prefsService.saveDoubleList(key, history);
      }
    }

    // Apply reverse if requested
    if (reverse) {
      history = history.map((rate) => rate == 0 ? 0.0 : 1.0 / rate).toList();
    }

    return history;
  }

  /// Save a new rate for a currency pair (with max 30 entries)
  Future<void> saveRate(String from, String to, double rate) async {
    final key = "${from}_$to";

    // Load only relevant history
    List<double> history = await _prefsService.getDoubleList(key);
    history =
        history
            .map((e) => e is double ? e : double.tryParse(e.toString()) ?? 0.0)
            .toList();

    // Append new rate
    history.add(rate);

    // Keep last 30 entries only
    if (history.length > 30) history.removeAt(0);

    await _prefsService.saveDoubleList(key, history);
  }

  /// Optional: Save batch of rates (future optimization for repository)
  Future<void> saveRateBatch(List<Map<String, dynamic>> batch) async {
    for (var item in batch) {
      await saveRate(item['from'], item['to'], item['rate']);
    }
  }
}
