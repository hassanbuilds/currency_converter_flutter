import 'package:flutter/material.dart';
import '../../../core/constants/currency_data.dart';

class CurrencyDropdown extends StatelessWidget {
  final String selectedCurrency;
  final ValueChanged<String?> onChanged;

  const CurrencyDropdown({
    super.key,
    required this.selectedCurrency,
    required this.onChanged,
    required String value,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedCurrency,
      underline: const SizedBox(),
      style: TextStyle(
        fontSize: 16,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      items:
          exchangeRates.keys.map((currency) {
            return DropdownMenuItem(
              value: currency,
              child: Text('$currency ${currencySymbols[currency]}'),
            );
          }).toList(),
      onChanged: onChanged,
    );
  }
}
