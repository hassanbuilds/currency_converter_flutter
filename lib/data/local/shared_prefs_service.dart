import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const String _historyKey = 'conversion_history';
  static const String _favoritesKey = 'favorites';

  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<List<String>> loadList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? [];
  }

  Future<void> saveList(String key, List<String> values) async {
    final prefs = await SharedPreferences.getInstance();
    // Only write if changed (avoid unnecessary writes)
    final old = prefs.getStringList(key) ?? [];
    if (!listEquals(old, values)) {
      await prefs.setStringList(key, values);
    }
  }

  Future<void> clearKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

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

  Future<List<String>> loadHistory() => loadList(_historyKey);

  Future<void> saveToHistory(String entry) async {
    final list = await loadList(_historyKey);
    list.insert(0, entry);
    await saveList(_historyKey, list); // now only writes if changed
  }

  Future<void> clearHistory() async => clearKey(_historyKey);

  Future<List<String>> loadFavorites() => loadList(_favoritesKey);

  Future<void> saveFavorites(List<String> favorites) async =>
      saveList(_favoritesKey, favorites); // only writes if changed
}
