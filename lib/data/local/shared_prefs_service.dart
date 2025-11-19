import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const String _historyKey = 'conversion_history';
  static const String _favoritesKey = 'favorites';

  // In-memory cache to reduce writes
  final Map<String, dynamic> _cache = {};

  // String Helpers
  Future<void> saveString(String key, String value) async {
    _cache[key] = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    if (_cache.containsKey(key)) return _cache[key] as String?;
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);
    if (value != null) _cache[key] = value;
    return value;
  }

  // List<String>
  Future<List<String>> loadList(String key) async {
    if (_cache.containsKey(key)) return List<String>.from(_cache[key]);
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key) ?? [];
    _cache[key] = list;
    return list;
  }

  Future<void> saveList(String key, List<String> values) async {
    _cache[key] = values;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, values);
  }

  Future<void> clearKey(String key) async {
    _cache.remove(key);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // List<double>
  Future<void> saveDoubleList(String key, List<double> values) async {
    _cache[key] = values;
    final stringList = values.map((e) => e.toString()).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, stringList);
  }

  Future<List<double>> getDoubleList(String key) async {
    if (_cache.containsKey(key)) return List<double>.from(_cache[key]);
    final prefs = await SharedPreferences.getInstance();
    final stringList = prefs.getStringList(key) ?? [];
    final doubleList =
        stringList.map((e) => double.tryParse(e) ?? 0.0).toList();
    _cache[key] = doubleList;
    return doubleList;
  }

  //  Map<String, double>
  Future<void> saveDoubleMap(String key, Map<String, double> map) async {
    _cache[key] = map;
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(map);
    await prefs.setString(key, jsonString);
  }

  Future<Map<String, double>> getDoubleMap(String key) async {
    if (_cache.containsKey(key)) return Map<String, double>.from(_cache[key]);
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null || jsonString.isEmpty) return {};
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    final map = jsonMap.map((k, v) => MapEntry(k, (v as num).toDouble()));
    _cache[key] = map;
    return map;
  }

  // Legacy Aliases
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

  // Optional: flush cache
  Future<void> flush() async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in _cache.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value is String) await prefs.setString(key, value);
      if (value is List<String>) await prefs.setStringList(key, value);
      if (value is List<double>) {
        final stringList = value.map((e) => e.toString()).toList();
        await prefs.setStringList(key, stringList);
      }
      if (value is Map<String, double>) {
        final jsonString = json.encode(value);
        await prefs.setString(key, jsonString);
      }
    }
  }
}
