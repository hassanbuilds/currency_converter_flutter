class ConversionHistoryModel {
  final String id;
  final String fromCurrency;
  final String toCurrency;
  final double originalAmount;
  final double convertedAmount;
  final double exchangeRate;
  final DateTime timestamp;

  ConversionHistoryModel({
    required this.id,
    required this.fromCurrency,
    required this.toCurrency,
    required this.originalAmount,
    required this.convertedAmount,
    required this.exchangeRate,
    required this.timestamp,
  });

  factory ConversionHistoryModel.fromConversion({
    required String fromCurrency,
    required String toCurrency,
    required double originalAmount,
    required double convertedAmount,
    required double exchangeRate,
  }) {
    return ConversionHistoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      originalAmount: originalAmount,
      convertedAmount: convertedAmount,
      exchangeRate: exchangeRate,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'originalAmount': originalAmount,
      'convertedAmount': convertedAmount,
      'exchangeRate': exchangeRate,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ConversionHistoryModel.fromJson(Map<String, dynamic> json) {
    return ConversionHistoryModel(
      id: json['id'] as String,
      fromCurrency: json['fromCurrency'] as String,
      toCurrency: json['toCurrency'] as String,
      originalAmount: (json['originalAmount'] as num).toDouble(),
      convertedAmount: (json['convertedAmount'] as num).toDouble(),
      exchangeRate: (json['exchangeRate'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  get amount => null;

  String toDisplayString() {
    return '${originalAmount.toStringAsFixed(2)} $fromCurrency → ${convertedAmount.toStringAsFixed(2)} $toCurrency';
  }

  @override
  String toString() {
    return 'ConversionHistoryModel{$fromCurrency→$toCurrency: $originalAmount→$convertedAmount}';
  }
}
