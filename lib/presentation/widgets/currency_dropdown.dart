import 'package:flutter/material.dart';
import '../../../core/constants/currency_data.dart';

class CurrencyDropdown extends StatelessWidget {
  final String selectedCurrency;
  final ValueChanged<String?> onChanged;

  const CurrencyDropdown({
    super.key,
    required this.selectedCurrency,
    required this.onChanged,
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
            currencyInfo.keys.map((currency) {
              final info = currencyInfo[currency];
              return DropdownMenuItem(
                value: currency,
                child: Row(
                  children: [
                    Text(info?['flag'] ?? ''), // flag emoji
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$currency - ${info?['name'] ?? ''} (${currencySymbols[currency]})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
