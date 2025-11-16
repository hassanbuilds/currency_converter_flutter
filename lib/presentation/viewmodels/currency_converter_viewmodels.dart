import 'package:flutter/material.dart';
import '../../../core/constants/currency_data.dart';
import '../../../data/local/shared_prefs_service.dart';
import '../../../data/repositories/currency_repository.dart';

class CurrencyConverterViewModel extends ChangeNotifier {
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

  Map<String, double> _cachedRates = {}; // Cached rates for instant conversion
  List<String> supportedCurrencies = [];

  CurrencyConverterViewModel() {
    _repository = CurrencyRepository();
    _init();
  }

  // Initialize ViewModel
  Future<void> _init() async {
    await _loadHistory();
    await _loadFavorites();

    try {
      // Fetch exchange rates once and cache them
      _cachedRates = await _repository.getExchangeRates();
      supportedCurrencies = _cachedRates.keys.toList();

      // Adjust default currencies if not supported
      if (!supportedCurrencies.contains(fromCurrency))
        fromCurrency = supportedCurrencies.first;
      if (!supportedCurrencies.contains(toCurrency))
        toCurrency = supportedCurrencies.first;

      // Set default amount if empty
      if (amountController.text.isEmpty) amountController.text = '1';

      // Perform the first conversion after caching rates
      await updateConversion();
    } catch (e) {
      result = 'Error fetching rates';
      chartData = [];
      chartError = e.toString();
      notifyListeners();
    }
  }

  // Toggle light/dark theme
  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  // Update conversion and chart
  Future<void> updateConversion() async {
    final amount = double.tryParse(amountController.text);
    if (amount == null) {
      result = '';
      chartData = [];
      notifyListeners();
      return;
    }

    // Prevent conversion if rates are not loaded yet
    if (_cachedRates.isEmpty) {
      result = 'Loading rates...';
      chartData = [];
      notifyListeners();
      return;
    }

    isChartLoading = true;
    chartError = null;
    notifyListeners();

    try {
      if (!_cachedRates.containsKey(fromCurrency) ||
          !_cachedRates.containsKey(toCurrency)) {
        result = 'Error: live rate not available';
        chartError = 'Selected currency not supported by API';
        chartData = [];
        return;
      }

      // Perform conversion
      final converted = _repository.convert(
        amount: amount,
        from: fromCurrency,
        to: toCurrency,
        rates: _cachedRates,
      );

      result =
          '${amount.toStringAsFixed(2)} ${currencySymbols[fromCurrency]} = '
          '${converted.toStringAsFixed(2)} ${currencySymbols[toCurrency]}';

      // Save conversion to history
      _saveToHistory(
        '${currencySymbols[fromCurrency]}$amount $fromCurrency → ${currencySymbols[toCurrency]}${converted.toStringAsFixed(2)} $toCurrency',
      );

      // Load chart data
      chartData = await _repository.getChartData(
        fromCurrency,
        toCurrency,
        rates: _cachedRates,
      );

      chartError = null;
    } catch (e) {
      result = 'Error fetching live rates';
      chartError = e.toString();
      chartData = [];
    } finally {
      isChartLoading = false;
      notifyListeners();
    }
  }

  // Change base currency
  void setFromCurrency(String? value) {
    if (value == null || _cachedRates.isEmpty) return;
    fromCurrency = value;
    updateConversion();
  }

  // Change target currency
  void setToCurrency(String? value) {
    if (value == null || _cachedRates.isEmpty) return;
    toCurrency = value;
    updateConversion();
  }

  // Swap currencies
  void reverseCurrencies() {
    final temp = fromCurrency;
    fromCurrency = toCurrency;
    toCurrency = temp;
    if (_cachedRates.isNotEmpty) updateConversion();
  }

  // Load conversion history
  Future<void> _loadHistory() async {
    history = await _prefsService.loadList('conversion_history');
    notifyListeners();
  }

  // Save a new entry to history
  Future<void> _saveToHistory(String entry) async {
    history.insert(0, entry);
    await _prefsService.saveList('conversion_history', history);
    notifyListeners();
  }

  // Clear conversion history
  Future<void> clearHistory() async {
    await _prefsService.clearKey('conversion_history');
    history.clear();
    notifyListeners();
  }

  // Load favorite currency pairs
  Future<void> _loadFavorites() async {
    favorites = await _prefsService.loadList('favorites');
    notifyListeners();
  }

  // Add current pair to favorites
  Future<void> addToFavorites() async {
    final pair = '$fromCurrency → $toCurrency';
    if (!favorites.contains(pair)) {
      favorites.add(pair);
      await _prefsService.saveList('favorites', favorites);
      notifyListeners();
    }
  }

  // Remove favorite pair by index
  Future<void> removeFavoriteAt(int index) async {
    favorites.removeAt(index);
    await _prefsService.saveList('favorites', favorites);
    notifyListeners();
  }

  // Load a favorite pair
  void loadFavoritePair(String pair) {
    final parts = pair.split('→');
    if (parts.length == 2) {
      fromCurrency = parts[0].trim();
      toCurrency = parts[1].trim();
      updateConversion();
    }
  }
}
