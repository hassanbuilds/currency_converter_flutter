class CurrencyRateModel {
  final String currencyCode;
  final double rate;
  final DateTime lastUpdated;
  final String source;

  CurrencyRateModel({
    required this.currencyCode,
    required this.rate,
    required this.lastUpdated,
    required this.source,
  });

  factory CurrencyRateModel.fromApiResponse(String currency, double rate) {
    return CurrencyRateModel(
      currencyCode: currency,
      rate: rate,
      lastUpdated: DateTime.now(),
      source: 'api',
    );
  }

  factory CurrencyRateModel.fromCache(Map<String, dynamic> json) {
    return CurrencyRateModel(
      currencyCode: json['currencyCode'] as String,
      rate: (json['rate'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      source: json['source'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currencyCode': currencyCode,
      'rate': rate,
      'lastUpdated': lastUpdated.toIso8601String(),
      'source': source,
    };
  }

  @override
  String toString() {
    return 'CurrencyRateModel{$currencyCode: $rate}';
  }
}
