import 'package:courency_converter/presentation/viewmodels/currency_converter_viewmodels.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'presentation/views/currency_converter_screen.dart';

import 'core/theme/app_theme.dart'; // your theme class

void main() {
  runApp(const CurrencyConverterApp());
}

class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CurrencyConverterViewModel(),
      child: Consumer<CurrencyConverterViewModel>(
        builder: (context, vm, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: vm.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
            home: const CurrencyConverterScreen(),
          );
        },
      ),
    );
  }
}
