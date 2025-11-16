import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const String _historyKey = 'conversion_history';
  static const String _favoritesKey = 'favorites';

  // ----------------------------
  // String helpers for caching
  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // ----------------------------
  // Load/Save List<String>
  Future<List<String>> loadList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? [];
  }

  Future<void> saveList(String key, List<String> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, values);
  }

  Future<void> clearKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // ----------------------------
  // Load/Save List<double> for charts
  Future<void> saveDoubleList(String key, List<double> values) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> stringList = values.map((e) => e.toString()).toList();
    await prefs.setStringList(key, stringList);
  }

  Future<List<double>> getDoubleList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = prefs.getStringList(key) ?? [];
    return stringList.map((e) => double.tryParse(e) ?? 0.0).toList();
  }

  // ----------------------------
  // NEW: Load/Save Map<String, double>
  Future<void> saveDoubleMap(String key, Map<String, double> map) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(map);
    await prefs.setString(key, jsonString);
  }

  Future<Map<String, double>> getDoubleMap(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null || jsonString.isEmpty) return {};
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return jsonMap.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }

  // Legacy aliases for convenience
  Future<List<String>> loadHistory() => loadList(_historyKey);
  Future<void> saveToHistory(String entry) async {
    final list = await loadList(_historyKey);
    list.insert(0, entry);
    await saveList(_historyKey, list);
  }

  Future<void> clearHistory() async => clearKey(_historyKey);

  Future<List<String>> loadFavorites() => loadList(_favoritesKey);
  Future<void> saveFavorites(List<String> favorites) =>
      saveList(_favoritesKey, favorites);
}
