import 'package:courency_converter/presentation/viewmodels/currency_converter_viewmodels.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AmountInput extends StatelessWidget {
  const AmountInput({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CurrencyConverterViewModel>();

    return TextField(
      controller: vm.amountController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      onSubmitted: (value) {
        FocusScope.of(context).unfocus();
        if (value.isNotEmpty) {
          vm.updateConversion();
        }
      },
      decoration: const InputDecoration(
        labelText: 'Enter Amount',
        border: OutlineInputBorder(),
      ),
    );
  }
}
