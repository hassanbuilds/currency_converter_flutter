import 'package:courency_converter/presentation/viewmodels/currency_converter_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AmountInput extends StatelessWidget {
  const AmountInput({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CurrencyConverterProvider>();
    final width = MediaQuery.of(context).size.width;

    final bool isTablet = width > 600;
    final double fontSize = isTablet ? 20 : (width < 360 ? 14 : 16);
    final double verticalPadding = isTablet ? 18 : 14;

    return TextField(
      controller: provider.amountController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      onSubmitted: (value) {
        FocusScope.of(context).unfocus();
        if (value.isNotEmpty) {
          provider.convertCurrency();
        }
      },
      decoration: InputDecoration(
        labelText: 'Enter Amount',
        labelStyle: TextStyle(fontSize: fontSize),
        contentPadding: EdgeInsets.symmetric(
          vertical: verticalPadding,
          horizontal: 16,
        ),
        border: const OutlineInputBorder(),
      ),
      style: TextStyle(fontSize: fontSize),
    );
  }
}
