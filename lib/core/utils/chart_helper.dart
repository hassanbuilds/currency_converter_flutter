import 'package:courency_converter/data/local/shared_prefs_service.dart';

class ChartHelper {
  final SharedPrefsService _prefsService = SharedPrefsService();

  Future<List<double>> getChartData(
    String from,
    String to, {
    required Map<String, double> rates,
    bool reverse = false,
  }) async {
    List<double> history = await _prefsService.getDoubleList("${from}_$to");
    history =
        history
            .map((e) => e is double ? e : double.tryParse(e.toString()) ?? 0.0)
            .toList();

    if (history.isEmpty) {
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
        history =
            reverseHistory.map((rate) => rate == 0 ? 0.0 : 1.0 / rate).toList();
      } else {
        final liveRate =
            rates.containsKey(to) && rates.containsKey(from)
                ? rates[to]! / rates[from]!
                : 0.0;
        history = [liveRate];
        await _prefsService.saveDoubleList("${from}_$to", history);
      }
    }

    if (reverse) {
      history = history.map((rate) => rate == 0 ? 0.0 : 1.0 / rate).toList();
    }

    return history;
  }

  Future<void> saveRate(String from, String to, double rate) async {
    final key = "${from}_$to";
    List<double> history = await _prefsService.getDoubleList(key);
    history =
        history
            .map((e) => e is double ? e : double.tryParse(e.toString()) ?? 0.0)
            .toList();

    history.add(rate);
    if (history.length > 30) history.removeAt(0);
    await _prefsService.saveDoubleList(key, history);
  }
}
