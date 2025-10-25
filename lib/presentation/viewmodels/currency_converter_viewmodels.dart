// lib/presentation/viewmodels/currency_converter_viewmodel.dart
import 'package:courency_converter/domain/models/currecny_conversion.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/currency_data.dart';
import '../../../data/local/shared_prefs_service.dart';
import '../../../data/repositories/currency_repository.dart';
import '../../../domain/usecases/convert_currency_usecase.dart';

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

  final SharedPrefsService _prefsService = SharedPrefsService();
  late final CurrencyRepository _repository;
  late final ConvertCurrencyUseCase _convertUseCase;

  CurrencyConverterViewModel() {
    _repository = CurrencyRepository();
    _convertUseCase = ConvertCurrencyUseCase(_repository);
    _init();
  }

  // ---------------- INITIALIZATION ----------------
  Future<void> _init() async {
    await _loadHistory();
    await _loadFavorites();
  }

  // ---------------- THEME ----------------
  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  // ---------------- CONVERSION ----------------
  void updateConversion() {
    final amount = double.tryParse(amountController.text);
    if (amount == null) {
      result = '';
      notifyListeners();
      return;
    }

    final conversion = CurrencyConversion(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      amount: amount,
      result: null,
    );

    final converted = _convertUseCase.execute(
      conversion.fromCurrency,
      conversion.toCurrency,
      conversion.amount,
    );
    result =
        '${amount.toStringAsFixed(2)} ${currencySymbols[fromCurrency]} = '
        '${converted.toStringAsFixed(2)} ${currencySymbols[toCurrency]}';

    _saveToHistory(
      '${currencySymbols[fromCurrency]}$amount $fromCurrency → '
      '${currencySymbols[toCurrency]}${converted.toStringAsFixed(2)} $toCurrency',
    );

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
