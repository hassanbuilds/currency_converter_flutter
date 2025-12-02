import 'package:courency_converter/core/utils/chart_helper.dart';
import 'package:courency_converter/domain/entities/conversion_result.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/currency_data.dart';
import '../../../core/errors/app_exception.dart';
import '../../../domain/usecases/convert_currency_usecase.dart';
import '../../../domain/usecases/get_exchange_rates_usecase.dart';
import '../../../domain/usecases/get_history_usecase.dart';
import '../../../domain/repositories/preferences_repository.dart';
import '../../../data/models/conversion_history_model.dart';

class CurrencyConverterProvider extends ChangeNotifier {
  // ===== DEPENDENCIES =====
  final ConvertCurrencyUseCase _convertUseCase;
  final GetExchangeRatesUseCase _getRatesUseCase;
  final GetHistoryUseCase _getHistoryUseCase;
  final PreferencesRepository _preferencesRepository;

  // ===== CONTROLLERS & STATE =====
  final TextEditingController amountController = TextEditingController();
  String fromCurrency = 'USD';
  String toCurrency = 'PKR';
  bool isDarkMode = false;

  List<ConversionHistoryModel> history = [];
  List<String> favorites = [];
  List<String> supportedCurrencies = [];
  List<double> chartData = [];

  String result = '';
  bool isLoading = false;
  bool isChartLoading = false;
  String? error;
  String? chartError;

  bool isOnline = true;
  bool isCheckingConnection = false;

  // ===== CONSTRUCTOR =====
  CurrencyConverterProvider({
    required ConvertCurrencyUseCase convertUseCase,
    required GetExchangeRatesUseCase getRatesUseCase,
    required GetHistoryUseCase getHistoryUseCase,
    required PreferencesRepository preferencesRepository,
  }) : _convertUseCase = convertUseCase,
       _getRatesUseCase = getRatesUseCase,
       _getHistoryUseCase = getHistoryUseCase,
       _preferencesRepository = preferencesRepository {
    _initialize();
  }

  get retryConnection => null;

  // ===== INITIALIZATION =====
  Future<void> _initialize() async {
    amountController.text = '1';
    await Future.wait([_loadPreferences(), _loadSupportedCurrencies()]);
    if (supportedCurrencies.isNotEmpty) {
      await convertCurrency(loadChart: true);
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final results = await Future.wait([
        _getHistoryUseCase.execute(),
        _preferencesRepository.getFavorites(),
        _preferencesRepository.isDarkTheme(),
      ]);

      history = results[0] as List<ConversionHistoryModel>;
      favorites = results[1] as List<String>;
      isDarkMode = results[2] as bool;
    } catch (e) {
      error = 'Failed to load preferences: $e';
    }
  }

  Future<void> _loadSupportedCurrencies() async {
    try {
      final rates = await _getRatesUseCase.execute();
      supportedCurrencies = rates.keys.toList()..sort();

      if (!supportedCurrencies.contains(fromCurrency)) {
        fromCurrency = supportedCurrencies.first;
      }
      if (!supportedCurrencies.contains(toCurrency)) {
        toCurrency = supportedCurrencies.first;
      }
    } catch (e) {
      error = 'Failed to load currencies: $e';
      supportedCurrencies = currencySymbols.keys.toList();
    }
  }

  // ===== CONVERSION =====
  Future<void> convertCurrency({bool loadChart = true}) async {
    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      _setInvalidAmount(loadChart, amount);
      return;
    }

    _setLoading(true, loadChart: loadChart);

    try {
      final conversionResult = await _convertUseCase.execute(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        amount: amount,
      );

      _setConversionResult(conversionResult);
      await _saveToHistory(conversionResult);

      if (loadChart) {
        await _loadChartData();
      }
    } on AppException catch (e) {
      _handleConversionError(loadChart, e.message);
    } catch (e) {
      _handleConversionError(loadChart, 'Unexpected error: $e');
    } finally {
      _setLoading(false, loadChart: loadChart);
    }
  }

  void _setInvalidAmount(bool loadChart, double? amount) {
    result = amount == null ? '' : 'Please enter a valid amount';
    if (loadChart) {
      chartData = [];
      chartError = 'Invalid amount';
    }
    notifyListeners();
  }

  void _setLoading(bool value, {bool loadChart = true}) {
    isLoading = value;
    if (loadChart) isChartLoading = value;
    notifyListeners();
  }

  void _setConversionResult(ConversionResult conversionResult) {
    final fromSymbol = currencySymbols[fromCurrency] ?? fromCurrency;
    final toSymbol = currencySymbols[toCurrency] ?? toCurrency;

    result =
        '${conversionResult.originalAmount.toStringAsFixed(2)} $fromSymbol = '
        '${conversionResult.convertedAmount.toStringAsFixed(2)} $toSymbol';
    error = null;
    notifyListeners();
  }

  void _handleConversionError(bool loadChart, String message) {
    result = 'Conversion failed';
    error = message;
    if (loadChart) {
      chartData = [];
      chartError = message;
    }
    notifyListeners();
  }

  // ===== CHART =====
  Future<void> _loadChartData() async {
    try {
      // Always generate dummy chart data
      final currentRate = await _getRatesUseCase.fetchPairRate(
        fromCurrency,
        toCurrency,
      );

      // Generate 7 points of realistic chart data
      chartData = ChartHelper().generateRealisticChartData(
        currentRate,
        points: 7,
      );

      chartError = null; // No errors because it's always dummy data
    } catch (_) {
      // Fallback: if fetching currentRate fails, just use 1.0 as base
      chartData = ChartHelper().generateRealisticChartData(1.0, points: 7);
      chartError = null;
    }

    notifyListeners();
  }

  // ===== HISTORY =====
  Future<void> _saveToHistory(ConversionResult conversion) async {
    try {
      final entry = ConversionHistoryModel.fromConversion(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        originalAmount: conversion.originalAmount,
        convertedAmount: conversion.convertedAmount,
        exchangeRate: conversion.exchangeRate,
      );
      await _getHistoryUseCase.addToHistory(entry);
      history = await _getHistoryUseCase.execute();
    } catch (e) {
      error = 'Failed to save history: $e';
    }
    notifyListeners();
  }

  Future<void> clearHistory() async {
    try {
      await _getHistoryUseCase.clearHistory();
      history = await _getHistoryUseCase.execute();
    } catch (e) {
      error = 'Failed to clear history: $e';
    }
    notifyListeners();
  }

  // ===== FAVORITES =====
  Future<void> addToFavorites() async {
    final pair = '$fromCurrency → $toCurrency';
    if (!favorites.contains(pair)) {
      try {
        favorites.add(pair);
        await _preferencesRepository.saveFavorites(favorites);
      } catch (e) {
        error = 'Failed to add favorite: $e';
        favorites.remove(pair);
      }
      notifyListeners();
    }
  }

  Future<void> removeFavoriteAt(int index) async {
    if (index < 0 || index >= favorites.length) return;

    final removed = favorites[index];
    favorites.removeAt(index);

    try {
      await _preferencesRepository.saveFavorites(favorites);
    } catch (e) {
      error = 'Failed to remove favorite: $e';
      favorites.insert(index, removed);
    }
    notifyListeners();
  }

  void loadFavoritePair(String pair) {
    final parts = pair.split('→');
    if (parts.length == 2) {
      final newFrom = parts[0].trim();
      final newTo = parts[1].trim();
      if (supportedCurrencies.contains(newFrom) &&
          supportedCurrencies.contains(newTo)) {
        fromCurrency = newFrom;
        toCurrency = newTo;
        convertCurrency();
      } else {
        error = 'Invalid currency pair in favorites';
        notifyListeners();
      }
    }
  }

  // ===== THEME =====
  Future<void> toggleTheme() async {
    isDarkMode = !isDarkMode;
    try {
      await _preferencesRepository.setDarkTheme(isDarkMode);
    } catch (e) {
      error = 'Failed to save theme: $e';
      isDarkMode = !isDarkMode;
    }
    notifyListeners();
  }

  // ===== CURRENCY SELECTION =====
  void setFromCurrency(String? value) {
    if (value == null || !supportedCurrencies.contains(value)) return;
    fromCurrency = value;
    convertCurrency(loadChart: false);
  }

  void setToCurrency(String? value) {
    if (value == null || !supportedCurrencies.contains(value)) return;
    toCurrency = value;
    convertCurrency(loadChart: false);
  }

  void reverseCurrencies() {
    final temp = fromCurrency;
    fromCurrency = toCurrency;
    toCurrency = temp;
    convertCurrency();
  }

  // ===== ERROR HANDLING =====
  void clearError() {
    error = null;
    notifyListeners();
  }

  void clearChartError() {
    chartError = null;
    notifyListeners();
  }

  // ===== UTILITY =====
  Map<String, double> getCurrentPriceRange() {
    if (chartData.isEmpty) return {'min': 0.0, 'max': 0.0, 'current': 0.0};
    final min = chartData.reduce((a, b) => a < b ? a : b);
    final max = chartData.reduce((a, b) => a > b ? a : b);
    final current = chartData.last;
    return {'min': min, 'max': max, 'current': current};
  }

  List<String> getHistoryDisplayStrings() =>
      history.map((entry) => entry.toDisplayString()).toList();

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }
}
