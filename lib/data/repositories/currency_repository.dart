import '../../core/constants/currency_data.dart';
import '../remote/currency_api_service.dart';
import '../local/shared_prefs_service.dart';
import '../../core/utils/chart_helper.dart';

class CurrencyRepository {
  final CurrencyApiService apiService = CurrencyApiService();
  final SharedPrefsService prefsService = SharedPrefsService();
  final ChartHelper chartHelper = ChartHelper(); // <-- use helper

  // Get available exchange rates (from API or fallback)
  Future<Map<String, double>> getExchangeRates() async {
    try {
      final data = await apiService.fetchLatestRates();
      final rates = Map<String, double>.from(data['data']);

      // Save rates to chart history
      await saveRatesHistory(rates);

      return rates;
    } catch (e) {
      // Fallback to dummy data
      return exchangeRates;
    }
  }

  // Convert currency
  double convert({
    required double amount,
    required String from,
    required String to,
    Map<String, double>? rates,
  }) {
    final currentRates = rates ?? exchangeRates;
    final fromRate = currentRates[from]!;
    final toRate = currentRates[to]!;
    return amount * (toRate / fromRate);
  }

  // Save rates to local history (last 30 entries per pair)
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

        // Use ChartHelper to append rate safely
        await chartHelper.saveRate(from, to, convertedRate);
      }
    }
  }

  // Get chart data from SharedPreferences or fallback
  Future<List<double>> getChartData(
    String from,
    String to, {
    Map<String, double>? rates,
  }) async {
    final key = "${from}_$to";
    List<double> history = await prefsService.getDoubleList(key);

    if (history.isEmpty) {
      // Check reverse pair
      final reverseKey = "${to}_$from";
      List<double> reverseHistory = await prefsService.getDoubleList(
        reverseKey,
      );
      if (reverseHistory.isNotEmpty) {
        history = reverseHistory.map((e) => 1 / e).toList();
      } else if (rates != null) {
        // Append live rate if history empty
        final liveRate = convert(amount: 1.0, from: from, to: to, rates: rates);
        history = [liveRate];
        await prefsService.saveDoubleList(key, history);
      } else {
        // fallback dummy chart data
        if (from == "USD" && to == "PKR") {
          history = [276, 277, 278, 276.5, 277.2, 278.1, 277.9];
        } else if (from == "EUR" && to == "PKR") {
          history = [297, 298, 299, 298.5, 299.2, 300.1, 299.8];
        } else if (from == "GBP" && to == "PKR") {
          history = [350, 351, 349, 352, 351.5, 353, 352.2];
        } else {
          history = [1, 1.1, 1.05, 1.2, 1.15, 1.18, 1.22];
        }
      }
    } else if (rates != null) {
      // Append new live rate if different from last
      final liveRate = convert(amount: 1.0, from: from, to: to, rates: rates);
      if (history.isEmpty || history.last != liveRate) {
        history.add(liveRate);
        if (history.length > 30) history.removeAt(0); // keep last 30
        await prefsService.saveDoubleList(key, history);
      }
    }

    return history;
  }
}
