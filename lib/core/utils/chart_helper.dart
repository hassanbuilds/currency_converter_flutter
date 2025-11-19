import 'package:courency_converter/data/local/shared_prefs_service.dart';

class ChartHelper {
  final SharedPrefsService _prefsService = SharedPrefsService();

  // ---------------- Helper functions ----------------
  List<double> _toDoubleList(List<dynamic> list) {
    return list.map((e) => e is double ? e : double.tryParse(e.toString()) ?? 0.0).toList();
  }

  List<double> _invertRates(List<double> rates) {
    return rates.map((rate) => rate == 0 ? 0.0 : 1.0 / rate).toList();
  }

  // ---------------- Public Methods ----------------
  Future<List<double>> getChartData(
    String from,
    String to, {
    required Map<String, double> rates,
    bool reverse = false,
  }) async {
    final key = "${from}_$to";

    List<double> history = _toDoubleList(await _prefsService.getDoubleList(key));

    if (history.isEmpty) {
      final reverseKey = "${to}_$from";
      List<double> reverseHistory = _toDoubleList(await _prefsService.getDoubleList(reverseKey));

      if (reverseHistory.isNotEmpty) {
        history = _invertRates(reverseHistory);
      } else {
        final liveRate = rates.containsKey(to) && rates.containsKey(from)
            ? rates[to]! / rates[from]!
            : 0.0;
        history = [liveRate];
        await _prefsService.saveDoubleList(key, history);
      }
    }

    if (reverse) {
      history = _invertRates(history);
    }

    return history;
  }

  Future<void> saveRate(String from, String to, double rate) async {
    final key = "${from}_$to";
    List<double> history = _toDoubleList(await _prefsService.getDoubleList(key));
    history.add(rate);
    if (history.length > 30) history.removeAt(0);
    await _prefsService.saveDoubleList(key, history);
  }

  Future<void> saveRateBatch(List<Map<String, dynamic>> batch) async {
    for (var item in batch) {
      await saveRate(item['from'], item['to'], item['rate']);
    }
  }
}
