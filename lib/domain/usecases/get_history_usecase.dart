import 'package:courency_converter/core/errors/app_exception.dart';
import 'package:courency_converter/data/models/conversion_history_model.dart';
import '../repositories/preferences_repository.dart';

class GetHistoryUseCase {
  final PreferencesRepository _repository;

  GetHistoryUseCase(this._repository);

  Future<List<ConversionHistoryModel>> execute({int maxEntries = 50}) async {
    try {
      final history = await _repository.getConversionHistory();

      if (history.length > maxEntries * 2) {
        await _cleanupOldEntries(history, maxEntries); //  Remove .cast()
        return await _repository.getConversionHistory();
      }

      return history;
    } catch (e) {
      throw CacheException('Failed to load history: $e');
    }
  }

  //  Remove wrong type casting
  Future<void> addToHistory(ConversionHistoryModel conversionEntry) async {
    if (!_isValidHistoryEntry(conversionEntry)) {
      throw ArgumentError('Invalid history entry format');
    }

    final history = await execute();
    final now = DateTime.now();
    final recentDuplicate = history.any(
      (entry) =>
          entry.fromCurrency == conversionEntry.fromCurrency &&
          entry.toCurrency == conversionEntry.toCurrency &&
          entry.originalAmount == conversionEntry.originalAmount &&
          entry.timestamp.difference(now).inMinutes.abs() < 1,
    );

    if (recentDuplicate) {
      return;
    }

    try {
      await _repository.saveToHistory(conversionEntry); // Remove 'as String'
    } catch (e) {
      throw CacheException('Failed to save history: $e');
    }
  }

  Future<void> clearHistory() async {
    final history = await execute();
    if (history.isEmpty) {
      throw CacheException('History is already empty');
    }
    if (history.length > 10) {
      print('Warning: Clearing ${history.length} history entries');
    }
    await _repository.clearHistory();
  }

  Future<List<ConversionHistoryModel>> searchHistory(String query) async {
    final history = await execute();
    return history
        .where(
          (entry) =>
              entry.fromCurrency.toLowerCase().contains(query.toLowerCase()) ||
              entry.toCurrency.toLowerCase().contains(query.toLowerCase()) ||
              entry.originalAmount.toString().contains(query) ||
              entry.convertedAmount.toString().contains(query),
        )
        .toList();
  }

  Future<Map<String, dynamic>> getHistoryStats() async {
    final history = await execute();
    return {
      'totalConversions': history.length,
      'mostRecent':
          history.isNotEmpty ? history.first.toDisplayString() : 'None',
      'oldest': history.isNotEmpty ? history.last.toDisplayString() : 'None',
      'isEmpty': history.isEmpty,
      'totalAmountConverted': history.fold(
        0.0,
        (sum, entry) => sum + entry.originalAmount,
      ),
      'mostPopularPair': _getMostPopularPair(history),
    };
  }

  //  Remove wrong type casting
  Future<void> _cleanupOldEntries(
    List<ConversionHistoryModel> history,
    int maxEntries,
  ) async {
    final recentHistory = history.take(maxEntries).toList();
    await _repository.clearHistory();

    for (final entry in recentHistory.reversed) {
      await _repository.saveToHistory(entry); // Remove 'as String'
    }
  }

  bool _isValidHistoryEntry(ConversionHistoryModel entry) {
    return entry.id.isNotEmpty &&
        entry.fromCurrency.isNotEmpty &&
        entry.toCurrency.isNotEmpty &&
        entry.originalAmount > 0 &&
        entry.convertedAmount > 0 &&
        entry.exchangeRate > 0 &&
        !entry.timestamp.isAfter(DateTime.now());
  }

  String _getMostPopularPair(List<ConversionHistoryModel> history) {
    if (history.isEmpty) return 'None';

    final pairCount = <String, int>{};
    for (final entry in history) {
      final pair = '${entry.fromCurrency}→${entry.toCurrency}';
      pairCount[pair] = (pairCount[pair] ?? 0) + 1;
    }

    final mostPopular = pairCount.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
    return mostPopular.key;
  }
}
