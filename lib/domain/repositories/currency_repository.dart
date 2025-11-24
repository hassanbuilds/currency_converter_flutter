abstract class CurrencyRepository {
  // Rates (unchanged - your design is good)
  Future<Map<String, double>> getExchangeRates();
  Future<double> fetchPairRate(String from, String to);

  // Caching (unchanged)
  Future<void> saveCachedRates(Map<String, double> rates);
  Future<Map<String, double>> loadCachedRates();

  // ✅ UPDATED: Conversion method with better signature
  double convertAmount({
    required double amount,
    required String from,
    required String to,
    Map<String, double>? rates,
  });

  // ✅ UPDATED: Chart data from actual history
  Future<List<double>> getHistoricalRates(
    String from,
    String to, {
    int days = 30,
  });

  // ✅ NEW: Currency validation
  Future<bool> validateCurrencyCode(String code);
  Future<List<String>> getSupportedCurrencies();

  // Legacy method (keep for compatibility)
  Future<void> saveRecentPairHistory(String from, String to);
}
