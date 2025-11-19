import 'package:flutter/material.dart';
import '../../../core/constants/currency_data.dart';
import '../../../data/local/shared_prefs_service.dart';
import '../../../data/repositories/currency_repository.dart';

class CurrencyConverterViewModel extends ChangeNotifier {
  // ------------------ Controllers & State ------------------
  final TextEditingController amountController = TextEditingController();
  String fromCurrency = 'USD';
  String toCurrency = 'PKR';
  String result = '';
  bool isDarkMode = false;

  List<String> history = [];
  List<String> favorites = [];

  List<double> chartData = [];
  bool isChartLoading = false;
  String? chartError;

  final SharedPrefsService _prefsService = SharedPrefsService();
  late final CurrencyRepository _repository;

  Map<String, double> _cachedRates = {}; // memory cache
  List<String> supportedCurrencies = [];

  // ------------------ Constructor ------------------
  CurrencyConverterViewModel() {
    _repository = CurrencyRepository();
    _init();
  }

  // ------------------ Initialization ------------------
  Future<void> _init() async {
    // Load local data quickly (history, favorites, cached rates)
    final results = await Future.wait([
      _prefsService.loadList('conversion_history'),
      _prefsService.loadList('favorites'),
      _repository.loadCachedRates(),
    ]);

    history = results[0] as List<String>;
    favorites = results[1] as List<String>;
    _cachedRates = results[2] as Map<String, double>;
    supportedCurrencies = _cachedRates.keys.toList();

    // Ensure default currencies exist
    if (!supportedCurrencies.contains(fromCurrency) &&
        supportedCurrencies.isNotEmpty) {
      fromCurrency = supportedCurrencies.first;
    }
    if (!supportedCurrencies.contains(toCurrency) &&
        supportedCurrencies.isNotEmpty) {
      toCurrency = supportedCurrencies.first;
    }
    if (amountController.text.isEmpty) amountController.text = '1';

    notifyListeners(); // only once after local load

    // Instant conversion using cached data
    if (_cachedRates.isNotEmpty) {
      updateConversion(loadChart: false);
    }

    // Background fetches (non-blocking)
    _fetchLatestPairRate();
    _fetchAllRatesForCharts();
  }

  // Fetch selected currency pair rate
  Future<void> _fetchLatestPairRate() async {
    try {
      final pairRate = await _repository.fetchPairRate(
        fromCurrency,
        toCurrency,
      );
      _cachedRates[fromCurrency] = 1.0;
      _cachedRates[toCurrency] = pairRate;
      updateConversion(); // update result & chart
    } catch (e) {
      print("Selected pair fetch failed: $e");
    }
  }

  // Fetch all rates for dropdowns and charts
  Future<void> _fetchAllRatesForCharts() async {
    try {
      final rates = await _repository.getExchangeRates();
      _cachedRates = rates;
      supportedCurrencies = rates.keys.toList();
      notifyListeners(); // update UI after fetching all rates
    } catch (e) {
      print("Background fetch failed: $e");
    }
  }

  // ------------------ Theme ------------------
  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  // ------------------ Conversion ------------------
  Future<void> updateConversion({bool loadChart = true}) async {
    final amount = double.tryParse(amountController.text);
    if (amount == null || _cachedRates.isEmpty) {
      result = amount == null ? '' : 'Loading rates...';
      if (loadChart) {
        chartData = [];
        chartError = amount == null ? null : 'Rates not loaded';
      }
      notifyListeners();
      return;
    }

    if (loadChart) {
      isChartLoading = true;
      chartError = null;
      notifyListeners();
    }

    try {
      if (!_cachedRates.containsKey(fromCurrency) ||
          !_cachedRates.containsKey(toCurrency)) {
        result = 'Error: selected currency not supported';
        if (loadChart) {
          chartError = 'Currency pair missing';
          chartData = [];
        }
      } else {
        final converted = _repository.convert(
          amount: amount,
          from: fromCurrency,
          to: toCurrency,
          rates: _cachedRates,
        );

        result =
            '${amount.toStringAsFixed(2)} ${currencySymbols[fromCurrency]} = '
            '${converted.toStringAsFixed(2)} ${currencySymbols[toCurrency]}';

        // Save to history without extra notify
        _saveToHistory(
          '${currencySymbols[fromCurrency]}$amount $fromCurrency → ${currencySymbols[toCurrency]}${converted.toStringAsFixed(2)} $toCurrency',
          notify: false,
        );

        // Load chart data only if needed
        if (loadChart) {
          chartData = await _repository.getChartData(
            fromCurrency,
            toCurrency,
            rates: _cachedRates,
          );
        }
      }
    } catch (e) {
      result = 'Error fetching conversion';
      if (loadChart) {
        chartError = e.toString();
        chartData = [];
      }
    } finally {
      if (loadChart) {
        isChartLoading = false;
      }
      notifyListeners(); // only once at the end
    }
  }

  // ------------------ Currency Selection ------------------
  void setFromCurrency(String? value) {
    if (value == null || _cachedRates.isEmpty) return;
    fromCurrency = value;
    updateConversion(loadChart: false);
  }

  void setToCurrency(String? value) {
    if (value == null || _cachedRates.isEmpty) return;
    toCurrency = value;
    updateConversion(loadChart: false);
  }

  void reverseCurrencies() {
    final temp = fromCurrency;
    fromCurrency = toCurrency;
    toCurrency = temp;
    if (_cachedRates.isNotEmpty) updateConversion();
  }

  void loadFavoritePair(String pair) {
    final parts = pair.split('→');
    if (parts.length == 2) {
      fromCurrency = parts[0].trim();
      toCurrency = parts[1].trim();
      updateConversion();
    }
  }

  // ------------------ History ------------------
  Future<void> _saveToHistory(String entry, {bool notify = true}) async {
    history.insert(0, entry);
    await _prefsService.saveList('conversion_history', history);
    if (notify) notifyListeners();
  }

  Future<void> clearHistory() async {
    await _prefsService.clearKey('conversion_history');
    history.clear();
    notifyListeners();
  }

  // ------------------ Favorites ------------------
  Future<void> addToFavorites() async {
    final pair = '$fromCurrency → $toCurrency';
    if (!favorites.contains(pair)) {
      favorites.add(pair);
      await _prefsService.saveList('favorites', favorites);
      notifyListeners();
    }
  }

  Future<void> removeFavoriteAt(int index) async {
    favorites.removeAt(index);
    await _prefsService.saveList('favorites', favorites);
    notifyListeners();
  }
}
