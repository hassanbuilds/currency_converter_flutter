import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const String _historyKey = 'conversion_history';
  static const String _favoritesKey = 'favorites';

  // Load Conversion History
  Future<List<String>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historyKey) ?? [];
  }

  // Save New Entry to History
  Future<void> saveToHistory(String entry) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];
    history.insert(0, entry);
    await prefs.setStringList(_historyKey, history);
  }

  // Clear History
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // Load Favorites
  Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  // Save Favorites
  Future<void> saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites);
  }

  loadList(String s) {}

  saveList(String s, List<String> history) {}

  clearKey(String s) {}
}
