import 'package:courency_converter/presentation/viewmodels/currency_converter_viewmodels.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/currency_dropdown.dart';
import '../widgets/conversion_result_card.dart';
import '../widgets/favorites_list.dart';
import '../widgets/history_list.dart';
import '../widgets/currency_chart.dart';
import '../widgets/amount_input.dart';
import '../widgets/convert_button.dart';
import '../widgets/reverse_switch.dart';
import '../widgets/loading_indicator.dart';

class CurrencyConverterScreen extends StatelessWidget {
  const CurrencyConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CurrencyConverterViewModel>();
    final size = MediaQuery.of(context).size;

    // Define breakpoints
    final isTablet = size.width > 800; // wider screens
    final isLargePhone = size.width > 450 && size.width <= 800;
    final horizontalPadding =
        isTablet
            ? size.width * 0.1
            : isLargePhone
            ? 24.0
            : 16.0;

    final buttonPadding =
        isTablet
            ? 16.0
            : isLargePhone
            ? 14.0
            : 12.0;
    final buttonFontSize =
        isTablet
            ? 18.0
            : isLargePhone
            ? 16.0
            : 14.0;

    final chartHeight =
        isTablet
            ? 300.0
            : isLargePhone
            ? 250.0
            : 200.0;

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
                const AmountInput(),
                const SizedBox(height: 16),

                ConvertButton(isTablet: isTablet),
                const SizedBox(height: 16),

                // From & To dropdowns
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
                            ),
                          ],
                        ),
                      ],
                    ),
                const SizedBox(height: 16),

                ReverseSwitch(
                  onPressed: vm.reverseCurrencies,
                  isTablet: isTablet,
                ),
                const SizedBox(height: 16),

                ConversionResultCard(result: vm.result),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: vm.addToFavorites,
                  icon: const Icon(Icons.star),
                  label: const Text('Add to Favorites'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: buttonPadding),
                    textStyle: TextStyle(fontSize: buttonFontSize),
                  ),
                ),
                const SizedBox(height: 16),

                // Chart with loading indicator
                vm.isChartLoading
                    ? const LoadingIndicator(size: 60)
                    : SizedBox(
                      height: chartHeight,
                      child: CurrencyChart(
                        fromCurrency: vm.fromCurrency,
                        toCurrency: vm.toCurrency,
                        chartData: vm.chartData,
                        isLoading: vm.isChartLoading,
                        error: vm.chartError,
                      ),
                    ),
                const SizedBox(height: 16),

                FavoritesList(
                  favorites: vm.favorites,
                  onRemove: (index) => vm.removeFavoriteAt(index),
                  onTap: (pair) => vm.loadFavoritePair(pair),
                ),
                const SizedBox(height: 24),

                HistoryList(history: vm.history, onClear: vm.clearHistory),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
