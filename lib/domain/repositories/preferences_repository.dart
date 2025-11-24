import 'package:courency_converter/data/models/conversion_history_model.dart';

abstract class PreferencesRepository {
  // ✅ UPDATED: History methods using ConversionHistoryModel
  Future<List<ConversionHistoryModel>> getConversionHistory();
  Future<void> saveToHistory(ConversionHistoryModel entry);
  Future<void> clearHistory();

  // Favorites (unchanged - String is correct for simple pairs)
  Future<List<String>> getFavorites();
  Future<void> saveFavorites(List<String> favorites);

  // Theme (unchanged)
  Future<bool> isDarkTheme();
  Future<void> setDarkTheme(bool isDark);

  // ✅ NEW: History management methods
  Future<List<ConversionHistoryModel>> searchHistory(String query);
  Future<void> cleanupOldHistory({int maxEntries = 50});
  Future<Map<String, dynamic>> getHistoryStats();
}
