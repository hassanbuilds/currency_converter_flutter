import 'package:courency_converter/presentation/viewmodels/currency_converter_viewmodels.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConvertButton extends StatelessWidget {
  const ConvertButton({super.key, required this.isTablet});

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CurrencyConverterViewModel>();

    return ElevatedButton.icon(
      onPressed: () {
        FocusScope.of(context).unfocus();
        vm.updateConversion();
      },
      icon: const Icon(Icons.currency_exchange),
      label: const Text('Convert'),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
        textStyle: TextStyle(fontSize: isTablet ? 18 : 14),
      ),
    );
  }
}
