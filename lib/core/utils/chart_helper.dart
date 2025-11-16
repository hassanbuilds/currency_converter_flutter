import 'package:courency_converter/data/local/shared_prefs_service.dart';

class ChartHelper {
  final SharedPrefsService _prefsService = SharedPrefsService();

  /// Fetch chart data for a given pair from history.
  /// If `reverse` is true, the pair is reversed (to → from)
  Future<List<double>> getChartData(
    String from,
    String to, {
    required Map<String, double> rates,
    bool reverse = false,
  }) async {
    List<double> history = await _prefsService.getDoubleList("${from}_$to");

    if (history.isEmpty) {
      final reverseKey = "${to}_$from";
      List<double> reverseHistory = await _prefsService.getDoubleList(
        reverseKey,
      );

      if (reverseHistory.isNotEmpty) {
        history = reverseHistory.map((e) => 1 / e).toList();
      } else {
        // Append live rate if history empty
        final liveRate =
            rates[from] != null && rates[to] != null
                ? rates[to]! / rates[from]!
                : 1.0;
        history = [liveRate];
        await _prefsService.saveDoubleList("${from}_$to", history);
      }
    }

    if (reverse) {
      history = history.map((rate) => 1 / rate).toList();
    }

    return history;
  }

  /// Save new rate to history (keeps max 30 points)
  Future<void> saveRate(String from, String to, double rate) async {
    final key = "${from}_$to";
    List<double> history = await _prefsService.getDoubleList(key);
    history.add(rate);
    if (history.length > 30) history.removeAt(0); // keep last 30
    await _prefsService.saveDoubleList(key, history);
  }
}
