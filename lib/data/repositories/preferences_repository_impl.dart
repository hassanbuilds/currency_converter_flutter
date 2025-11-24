import 'package:courency_converter/core/errors/app_exception.dart';
import 'package:courency_converter/data/models/conversion_history_model.dart';
import 'package:courency_converter/domain/repositories/preferences_repository.dart';
import '../datasources/local/preferences_datasource.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  final PreferencesDataSource _dataSource;

  PreferencesRepositoryImpl(this._dataSource);

  @override
  Future<List<ConversionHistoryModel>> getConversionHistory() async {
    try {
      return await _dataSource.getConversionHistory();
    } catch (e) {
      throw CacheException('Failed to load history: $e');
    }
  }

  @override
  Future<void> saveToHistory(ConversionHistoryModel entry) async {
    try {
      await _dataSource.saveToHistory(entry);
    } catch (e) {
      throw CacheException('Failed to save history: $e');
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      await _dataSource.clearHistory();
    } catch (e) {
      throw CacheException('Failed to clear history: $e');
    }
  }

  // ✅ ADDED: Missing methods from interface
  @override
  Future<List<ConversionHistoryModel>> searchHistory(String query) async {
    try {
      final history = await _dataSource.getConversionHistory();
      return history
          .where(
            (entry) =>
                entry.fromCurrency.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                entry.toCurrency.toLowerCase().contains(query.toLowerCase()) ||
                entry.originalAmount.toString().contains(query) ||
                entry.convertedAmount.toString().contains(query),
          )
          .toList();
    } catch (e) {
      throw CacheException('Failed to search history: $e');
    }
  }

  @override
  Future<void> cleanupOldHistory({int maxEntries = 50}) async {
    try {
      final history = await _dataSource.getConversionHistory();
      if (history.length > maxEntries) {
        final recentHistory = history.take(maxEntries).toList();
        await _dataSource.clearHistory();
        for (final entry in recentHistory.reversed) {
          await _dataSource.saveToHistory(entry);
        }
      }
    } catch (e) {
      throw CacheException('Failed to cleanup history: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getHistoryStats() async {
    try {
      final history = await _dataSource.getConversionHistory();

      if (history.isEmpty) {
        return {
          'totalConversions': 0,
          'totalAmountConverted': 0.0,
          'mostPopularPair': 'None',
          'isEmpty': true,
        };
      }

      final totalAmount = history.fold(
        0.0,
        (sum, entry) => sum + entry.originalAmount,
      );

      final pairCount = <String, int>{};
      for (final entry in history) {
        final pair = '${entry.fromCurrency}→${entry.toCurrency}';
        pairCount[pair] = (pairCount[pair] ?? 0) + 1;
      }

      final mostPopular =
          pairCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      return {
        'totalConversions': history.length,
        'totalAmountConverted': totalAmount,
        'mostPopularPair': mostPopular,
        'isEmpty': false,
      };
    } catch (e) {
      throw CacheException('Failed to get history stats: $e');
    }
  }

  @override
  Future<List<String>> getFavorites() async {
    try {
      return await _dataSource.getFavorites();
    } catch (e) {
      throw CacheException('Failed to load favorites: $e');
    }
  }

  @override
  Future<void> saveFavorites(List<String> favorites) async {
    try {
      await _dataSource.saveFavorites(favorites);
    } catch (e) {
      throw CacheException('Failed to save favorites: $e');
    }
  }

  @override
  Future<bool> isDarkTheme() async {
    try {
      return await _dataSource.isDarkTheme();
    } catch (e) {
      throw CacheException('Failed to load theme: $e');
    }
  }

  @override
  Future<void> setDarkTheme(bool isDark) async {
    try {
      await _dataSource.setDarkTheme(isDark);
    } catch (e) {
      throw CacheException('Failed to save theme: $e');
    }
  }
}
