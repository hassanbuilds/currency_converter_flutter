// core/constants/currency_data.dart

final Map<String, String> currencySymbols = {
  'USD': '\$',
  'PKR': 'Rs',
  'EUR': '€',
  'GBP': '£',
  'JPY': '¥',
  // Add more symbols here
};

final Map<String, double> exchangeRates = {
  'USD': 1.0,
  'PKR': 277.0,
  'EUR': 0.92,
  'GBP': 0.78,
  'JPY': 150.0,
  // Add more exchange rates here
};

// Full info for dropdowns: currency name + flag emoji
final Map<String, Map<String, String>> currencyInfo = {
  'USD': {'name': 'US Dollar', 'flag': '🇺🇸'},
  'PKR': {'name': 'Pakistani Rupee', 'flag': '🇵🇰'},
  'EUR': {'name': 'Euro', 'flag': '🇪🇺'},
  'GBP': {'name': 'British Pound', 'flag': '🇬🇧'},
  'JPY': {'name': 'Japanese Yen', 'flag': '🇯🇵'},
  // Add more currencies here as needed
};
