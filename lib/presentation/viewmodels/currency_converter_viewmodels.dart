import 'package:flutter/material.dart';
import '../../../core/constants/currency_data.dart';
import '../../../data/local/shared_prefs_service.dart';
import '../../../data/repositories/currency_repository.dart';

class CurrencyConverterViewModel extends ChangeNotifier {
  // ---------------- CONTROLLERS ----------------
  final TextEditingController amountController = TextEditingController();

  // ---------------- STATE ----------------
  String fromCurrency = 'USD';
  String toCurrency = 'PKR';
  String result = '';
  bool isDarkMode = false;

  List<String> history = [];
  List<String> favorites = [];

  // ---------------- CHART ----------------
  List<double> chartData = [];
  bool isChartLoading = false;
  String? chartError;

  final SharedPrefsService _prefsService = SharedPrefsService();
  late final CurrencyRepository _repository;

  CurrencyConverterViewModel() {
    _repository = CurrencyRepository();
    _init();
  }

  // ---------------- INITIALIZATION ----------------
  Future<void> _init() async {
    await _loadHistory();
    await _loadFavorites();
    await updateConversion(); // fetch live rates on init
  }

  // ---------------- THEME ----------------
  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  // ---------------- CONVERSION ----------------
  Future<void> updateConversion() async {
    final amount = double.tryParse(amountController.text);
    if (amount == null) {
      result = '';
      notifyListeners();
      return;
    }

    isChartLoading = true;
    chartError = null;
    notifyListeners();

    try {
      // Always fetch live rates first
      final rates = await _repository.getExchangeRates();

      final converted = _repository.convert(
        amount: amount,
        from: fromCurrency,
        to: toCurrency,
        rates: rates,
      );

      result =
          '${amount.toStringAsFixed(2)} ${currencySymbols[fromCurrency]} = '
          '${converted.toStringAsFixed(2)} ${currencySymbols[toCurrency]}';

      _saveToHistory(
        '${currencySymbols[fromCurrency]}$amount $fromCurrency → '
        '${currencySymbols[toCurrency]}${converted.toStringAsFixed(2)} $toCurrency',
      );

      // ---------------- CHART FIX ----------------
      final liveRate = _repository.convert(
        amount: 1.0,
        from: fromCurrency,
        to: toCurrency,
        rates: rates,
      );

      // Get existing chart history
      chartData = await _repository.getChartData(
        fromCurrency,
        toCurrency,
        rates: rates,
      );

      // Append new live rate
      chartData.add(liveRate);
      if (chartData.length > 30) chartData.removeAt(0); // keep last 30 points

      // Save updated chart to SharedPreferences
      await _repository.prefsService.saveDoubleList(
        "${fromCurrency}_$toCurrency",
        chartData,
      );
      // ------------------------------------------
    } catch (e) {
      result = 'Error fetching live rates';
      chartError = e.toString();
    }

    isChartLoading = false;
    notifyListeners();
  }

  void setFromCurrency(String? value) {
    if (value == null) return;
    fromCurrency = value;
    updateConversion();
  }

  void setToCurrency(String? value) {
    if (value == null) return;
    toCurrency = value;
    updateConversion();
  }

  void reverseCurrencies() {
    final temp = fromCurrency;
    fromCurrency = toCurrency;
    toCurrency = temp;
    updateConversion();
  }

  // ---------------- HISTORY ----------------
  Future<void> _loadHistory() async {
    history = await _prefsService.loadList('conversion_history');
    notifyListeners();
  }

  Future<void> _saveToHistory(String entry) async {
    history.insert(0, entry);
    await _prefsService.saveList('conversion_history', history);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _prefsService.clearKey('conversion_history');
    history.clear();
    notifyListeners();
  }

  // ---------------- FAVORITES ----------------
  Future<void> _loadFavorites() async {
    favorites = await _prefsService.loadList('favorites');
    notifyListeners();
  }

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

  void loadFavoritePair(String pair) {
    final parts = pair.split('→');
    if (parts.length == 2) {
      fromCurrency = parts[0].trim();
      toCurrency = parts[1].trim();
      updateConversion();
    }
  }
}
