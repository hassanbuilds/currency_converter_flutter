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
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final horizontalPadding = isTablet ? size.width * 0.1 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(vm.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: vm.toggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 16.0,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //   Amount input
                TextField(
                  controller: vm.amountController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done, //  Adds "Done" button
                  onSubmitted: (value) {
                    //  Trigger conversion + close keyboard
                    FocusScope.of(context).unfocus();
                    if (value.isNotEmpty) {
                      vm.updateConversion();
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Enter Amount',
                    border: OutlineInputBorder(),
                  ),
                ),

                //  Convert button (manual conversion trigger)
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    FocusScope.of(context).unfocus(); //  Close keyboard
                    vm.updateConversion();
                  },
                  icon: const Icon(Icons.currency_exchange),
                  label: const Text('Convert'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                    textStyle: TextStyle(fontSize: isTablet ? 18 : 14),
                  ),
                ),
                const SizedBox(height: 16),

                //  From & To dropdowns
                isTablet
                    ? Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'From:',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              CurrencyDropdown(
                                selectedCurrency: vm.fromCurrency,
                                onChanged: vm.setFromCurrency,
                                value: '',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('To:', style: TextStyle(fontSize: 16)),
                              const SizedBox(height: 4),
                              CurrencyDropdown(
                                selectedCurrency: vm.toCurrency,
                                onChanged: vm.setToCurrency,
                                value: '',
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                    : Column(
                      children: [
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
                      ],
                    ),

                const SizedBox(height: 16),

                //  Reverse button
                ElevatedButton.icon(
                  onPressed: vm.reverseCurrencies,
                  icon: const Icon(Icons.swap_vert),
                  label: const Text('Reverse'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                    textStyle: TextStyle(fontSize: isTablet ? 18 : 14),
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
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                    textStyle: TextStyle(fontSize: isTablet ? 18 : 14),
                  ),
                ),
                const SizedBox(height: 16),

                //  Currency trend chart
                SizedBox(
                  height: isTablet ? 300 : 200,
                  child: CurrencyChart(
                    fromCurrency: vm.fromCurrency,
                    toCurrency: vm.toCurrency,
                  ),
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
        ),
      ),
    );
  }
}
