import 'package:courency_converter/core/errors/app_exception.dart';
import 'package:courency_converter/data/models/conversion_history_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesDataSource {
  static const String _historyKey = 'conversion_history';
  static const String _favoritesKey = 'favorites';
  static const String _themeKey = 'is_dark_theme';

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  //  History Methods with proper JSON serialization
  Future<List<ConversionHistoryModel>> getConversionHistory() async {
    try {
      final prefs = await _prefs;
      final historyJson = prefs.getStringList(_historyKey) ?? [];

      final List<ConversionHistoryModel> history = [];
      for (final jsonString in historyJson) {
        try {
          final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
          history.add(ConversionHistoryModel.fromJson(jsonMap));
        } catch (e) {
          print('Skipping invalid history entry: $e');
          continue;
        }
      }
      return history;
    } catch (e) {
      throw CacheException('Failed to load history: $e');
    }
  }

  // Save with proper validation
  Future<void> saveToHistory(ConversionHistoryModel entry) async {
    try {
      // Validate entry before saving
      _validateHistoryEntry(entry);

      final prefs = await _prefs;
      final history = await getConversionHistory();

      // Add new entry at beginning
      history.insert(0, entry);

      // Keep only last 50 entries to prevent storage bloat
      final limitedHistory =
          history.length > 50 ? history.sublist(0, 50) : history;

      // Convert to JSON strings
      final historyJson =
          limitedHistory.map((entry) => jsonEncode(entry.toJson())).toList();

      await prefs.setStringList(_historyKey, historyJson);
    } catch (e) {
      throw CacheException('Failed to save history: $e');
    }
  }

  //  Ensure data integrity
  void _validateHistoryEntry(ConversionHistoryModel entry) {
    if (entry.id.isEmpty) {
      throw ArgumentError('History entry must have a valid ID');
    }
    if (entry.fromCurrency.isEmpty || entry.toCurrency.isEmpty) {
      throw ArgumentError('Currencies cannot be empty');
    }
    if (entry.originalAmount <= 0 || entry.convertedAmount <= 0) {
      throw ArgumentError('Amounts must be positive');
    }
    if (entry.exchangeRate <= 0) {
      throw ArgumentError('Exchange rate must be positive');
    }
    if (entry.timestamp.isAfter(DateTime.now())) {
      throw ArgumentError('Timestamp cannot be in the future');
    }
  }

  Future<void> clearHistory() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(_historyKey);
    } catch (e) {
      throw CacheException('Failed to clear history: $e');
    }
  }

  // Favorites Methods (unchanged)
  Future<List<String>> getFavorites() async {
    try {
      final prefs = await _prefs;
      return prefs.getStringList(_favoritesKey) ?? [];
    } catch (e) {
      throw CacheException('Failed to load favorites: $e');
    }
  }

  Future<void> saveFavorites(List<String> favorites) async {
    try {
      final prefs = await _prefs;
      await prefs.setStringList(_favoritesKey, favorites);
    } catch (e) {
      throw CacheException('Failed to save favorites: $e');
    }
  }

  // Theme Methods (unchanged)
  Future<bool> isDarkTheme() async {
    try {
      final prefs = await _prefs;
      return prefs.getBool(_themeKey) ?? false;
    } catch (e) {
      throw CacheException('Failed to load theme: $e');
    }
  }

  Future<void> setDarkTheme(bool isDark) async {
    try {
      final prefs = await _prefs;
      await prefs.setBool(_themeKey, isDark);
    } catch (e) {
      throw CacheException('Failed to save theme: $e');
    }
  }
}
