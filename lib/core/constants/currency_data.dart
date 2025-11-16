// core/constants/currency_data.dart

/// Currency symbols for display in UI
final Map<String, String> currencySymbols = {
  'USD': '\$',
  'PKR': 'Rs',
  'EUR': '€',
  'GBP': '£',
  'JPY': '¥',
  'AUD': 'A\$',
  'CAD': 'C\$',
  'CHF': 'CHF',
  'CNY': '¥',
  'INR': '₹',
  'NZD': 'NZ\$',
  'SGD': 'S\$',
  'ZAR': 'R',
};

/// Full info for dropdowns: currency name + flag emoji
final Map<String, Map<String, String>> currencyInfo = {
  'USD': {'name': 'US Dollar', 'flag': '🇺🇸'},
  'PKR': {'name': 'Pakistani Rupee', 'flag': '🇵🇰'},
  'EUR': {'name': 'Euro', 'flag': '🇪🇺'},
  'GBP': {'name': 'British Pound', 'flag': '🇬🇧'},
  'JPY': {'name': 'Japanese Yen', 'flag': '🇯🇵'},
  'AUD': {'name': 'Australian Dollar', 'flag': '🇦🇺'},
  'CAD': {'name': 'Canadian Dollar', 'flag': '🇨🇦'},
  'CHF': {'name': 'Swiss Franc', 'flag': '🇨🇭'},
  'CNY': {'name': 'Chinese Yuan', 'flag': '🇨🇳'},
  'INR': {'name': 'Indian Rupee', 'flag': '🇮🇳'},
  'NZD': {'name': 'New Zealand Dollar', 'flag': '🇳🇿'},
  'SGD': {'name': 'Singapore Dollar', 'flag': '🇸🇬'},
  'ZAR': {'name': 'South African Rand', 'flag': '🇿🇦'},
};
