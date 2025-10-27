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
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return SizedBox(
      width: isTablet ? size.width * 0.35 : size.width * 0.45, // adaptive width
      child: DropdownButton<String>(
        value: selectedCurrency,
        isExpanded: true,
        underline: const SizedBox(),
        style: TextStyle(
          fontSize: isTablet ? 18 : 16,
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
      ),
    );
  }
}
