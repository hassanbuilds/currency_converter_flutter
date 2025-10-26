import 'package:courency_converter/presentation/viewmodels/currency_converter_viewmodels.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/currency_dropdown.dart';
import '../widgets/conversion_result_card.dart';
import '../widgets/favorites_list.dart';
import '../widgets/history_list.dart';
import '../widgets/currency_chart.dart';

class CurrencyConverterScreen extends StatelessWidget {
  const CurrencyConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CurrencyConverterViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        actions: [
          IconButton(
            icon: Icon(vm.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: vm.toggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔹 Amount input
            TextField(
              controller: vm.amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Amount',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => vm.updateConversion(),
            ),
            const SizedBox(height: 16),

            // 🔹 From currency dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('From:', style: TextStyle(fontSize: 16)),
                CurrencyDropdown(
                  selectedCurrency: vm.fromCurrency,
                  onChanged: vm.setFromCurrency,
                  value: '',
                ),
              ],
            ),
            const SizedBox(height: 8),

            //  To currency dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('To:', style: TextStyle(fontSize: 16)),
                CurrencyDropdown(
                  selectedCurrency: vm.toCurrency,
                  onChanged: vm.setToCurrency,
                  value: '',
                ),
              ],
            ),
            const SizedBox(height: 16),

            //  Reverse button
            ElevatedButton.icon(
              onPressed: vm.reverseCurrencies,
              icon: const Icon(Icons.swap_vert),
              label: const Text('Reverse'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            //  Conversion result card
            ConversionResultCard(result: vm.result),
            const SizedBox(height: 16),

            //  Add to favorites button
            ElevatedButton.icon(
              onPressed: vm.addToFavorites,
              icon: const Icon(Icons.star),
              label: const Text('Add to Favorites'),
            ),
            const SizedBox(height: 16),

            //  Chart for currency trend
            CurrencyChart(
              fromCurrency: vm.fromCurrency,
              toCurrency: vm.toCurrency,
            ),
            const SizedBox(height: 16),

            //  Favorites list
            FavoritesList(
              favorites: vm.favorites,
              onRemove: (index) => vm.removeFavoriteAt(index),
              onTap: (pair) => vm.loadFavoritePair(pair),
            ),
            const SizedBox(height: 24),

            //  History list
            HistoryList(history: vm.history, onClear: vm.clearHistory),
          ],
        ),
      ),
    );
  }
}
