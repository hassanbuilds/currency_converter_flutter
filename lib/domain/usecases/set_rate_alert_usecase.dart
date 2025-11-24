import 'package:courency_converter/core/errors/app_exception.dart';

import '../repositories/preferences_repository.dart';

/// Business logic for setting rate alerts with intelligent validation
class SetRateAlertUseCase {
  final PreferencesRepository _repository;

  SetRateAlertUseCase(this._repository);

  /// Sets a rate alert with comprehensive business rule validation
  Future<void> execute({
    required String fromCurrency,
    required String toCurrency,
    required double targetRate,
    required String alertName,
  }) async {
    // Comprehensive input validation
    _validateAlertInputs(fromCurrency, toCurrency, targetRate, alertName);

    // Business rules for target rate validation
    _validateTargetRateLogic(targetRate, fromCurrency, toCurrency);

    try {
      // Save the alert
      await _saveRateAlert(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        targetRate: targetRate,
        alertName: alertName,
      );
    } catch (e) {
      throw CacheException('Failed to set rate alert: $e');
    }
  }

  /// Validates all alert inputs
  void _validateAlertInputs(
    String fromCurrency,
    String toCurrency,
    double targetRate,
    String alertName,
  ) {
    if (fromCurrency.isEmpty || toCurrency.isEmpty) {
      throw ArgumentError('Currency codes cannot be empty');
    }

    if (fromCurrency == toCurrency) {
      throw ArgumentError('Currencies must be different');
    }

    if (targetRate <= 0) {
      throw ArgumentError('Target rate must be positive');
    }

    if (alertName.isEmpty || alertName.length > 50) {
      throw ArgumentError('Alert name must be 1-50 characters');
    }

    // Business rule: Supported currency pairs only
    if (!_isSupportedCurrencyPair(fromCurrency, toCurrency)) {
      throw ArgumentError(
        'Unsupported currency pair: $fromCurrency → $toCurrency',
      );
    }
  }

  /// Business rules for target rate validation
  void _validateTargetRateLogic(
    double targetRate,
    String fromCurrency,
    String toCurrency,
  ) {
    // Business rule: Realistic rate limits based on currency pair
    final maxChange = _getMaxAllowedChange(fromCurrency, toCurrency);

    // For demo, we'll use reasonable ranges
    const realisticRanges = {
      'USD_PKR': [50, 500],
      'USD_EUR': [0.5, 2.0],
      'USD_GBP': [0.5, 2.0],
      'USD_JPY': [50, 200],
    };

    final pairKey = '${fromCurrency}_$toCurrency';
    final range = realisticRanges[pairKey];

    if (range != null && (targetRate < range[0] || targetRate > range[1])) {
      throw ArgumentError(
        'Target rate seems unrealistic for $fromCurrency→$toCurrency',
      );
    }

    // Business rule: Minimum meaningful change
    if (_isTooCloseToCurrent(targetRate, fromCurrency, toCurrency)) {
      throw ArgumentError(
        'Target rate too close to current rate - set a more meaningful target',
      );
    }
  }

  /// Saves the rate alert to repository
  Future<void> _saveRateAlert({
    required String fromCurrency,
    required String toCurrency,
    required double targetRate,
    required String alertName,
  }) async {
    final alert = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'targetRate': targetRate,
      'alertName': alertName,
      'createdAt': DateTime.now().toIso8601String(),
      'isActive': true,
    };

    // In real implementation, you'd save this
    // For now, we'll just print it
    print(
      'Rate Alert Set: $alertName - $fromCurrency→$toCurrency at $targetRate',
    );
  }

  /// Determines maximum allowed rate change based on currency pair volatility
  double _getMaxAllowedChange(String fromCurrency, String toCurrency) {
    const volatilePairs = {
      'USD_PKR': 50.0, // 50% max change
      'USD_ARS': 100.0, // 100% max change (high inflation)
      'EUR_TRY': 75.0, // 75% max change
    };

    const stablePairs = {
      'USD_EUR': 10.0, // 10% max change
      'USD_GBP': 15.0, // 15% max change
      'USD_CAD': 12.0, // 12% max change
    };

    final pairKey = '${fromCurrency}_$toCurrency';
    final reverseKey = '${toCurrency}_$fromCurrency';

    if (volatilePairs.containsKey(pairKey) ||
        volatilePairs.containsKey(reverseKey)) {
      return volatilePairs[pairKey] ?? volatilePairs[reverseKey] ?? 25.0;
    }

    if (stablePairs.containsKey(pairKey) ||
        stablePairs.containsKey(reverseKey)) {
      return stablePairs[pairKey] ?? stablePairs[reverseKey] ?? 25.0;
    }

    return 25.0; // Default 25% max change
  }

  /// Checks if target rate is too close to current (demo implementation)
  bool _isTooCloseToCurrent(
    double targetRate,
    String fromCurrency,
    String toCurrency,
  ) {
    // In real app, you'd fetch current rate from repository
    // For demo, we'll use reasonable current rates
    const currentRates = {'USD_PKR': 280.0, 'USD_EUR': 0.85, 'USD_GBP': 0.75};

    final pairKey = '${fromCurrency}_$toCurrency';
    final reverseKey = '${toCurrency}_$fromCurrency';

    double? currentRate = currentRates[pairKey] ?? currentRates[reverseKey];

    if (currentRate != null) {
      final difference = ((targetRate - currentRate) / currentRate * 100).abs();
      return difference < 0.5; // Less than 0.5% difference
    }

    return false;
  }

  /// Returns supported currency pairs for alerts
  bool _isSupportedCurrencyPair(String fromCurrency, String toCurrency) {
    const supportedPairs = [
      'USD_PKR',
      'USD_EUR',
      'USD_GBP',
      'USD_JPY',
      'EUR_GBP',
      'USD_CAD',
      'USD_AUD',
      'EUR_JPY',
      'GBP_JPY',
    ];

    final pairKey = '${fromCurrency}_$toCurrency';
    final reverseKey = '${toCurrency}_$fromCurrency';

    return supportedPairs.contains(pairKey) ||
        supportedPairs.contains(reverseKey);
  }

  /// Gets all active alerts
  Future<List<Map<String, dynamic>>> getActiveAlerts() async {
    // In real implementation, you'd fetch from repository
    // For demo, return empty list
    return [];
  }

  /// Deletes a specific alert
  Future<void> deleteAlert(String alertId) async {
    // In real implementation, you'd delete from repository
    print('Deleting alert: $alertId');
  }
}
