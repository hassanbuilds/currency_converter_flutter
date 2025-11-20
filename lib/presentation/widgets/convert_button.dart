import 'package:courency_converter/presentation/viewmodels/currency_converter_viewmodels.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConvertButton extends StatelessWidget {
  const ConvertButton({super.key, required this.isTablet});

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CurrencyConverterViewModel>();
    final width = MediaQuery.of(context).size.width;

    final double fontSize = isTablet ? 20 : (width < 360 ? 14 : 16);
    final double paddingY = isTablet ? 18 : 12;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          FocusScope.of(context).unfocus();
          vm.updateConversion();
        },
        icon: const Icon(Icons.currency_exchange, size: 22),
        label: Text('Convert'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: paddingY),
          textStyle: TextStyle(fontSize: fontSize),
          minimumSize: Size(double.infinity, isTablet ? 60 : 48),
        ),
      ),
    );
  }
}
