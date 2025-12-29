import 'package:courency_converter/presentation/viewmodels/currency_converter_provider.dart';
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
import '../widgets/error_banner.dart';
import '../widgets/offline_banner.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  DateTime? _lastBackPressTime;

  Future<bool> _onWillPop() async {
    final now = DateTime.now();

    // First time or more than 2 seconds since last press
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;

      // Show the message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Press back again to exit'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
        ),
      );

      return false; // Don't exit
    }

    return true; // Exit the app
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CurrencyConverterProvider>();
    final size = MediaQuery.of(context).size;

    final isTablet = size.width > 800;
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

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Currency Converter'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                provider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: provider.toggleTheme,
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
                  // Offline banner
                  if (!provider.isOnline)
                    OfflineBanner(
                      onRetry: provider.retryConnection,
                      isRetrying: provider.isCheckingConnection,
                    ),

                  // Error banner
                  if (provider.error != null)
                    ErrorBanner(
                      message: provider.error!,
                      onDismiss: provider.clearError,
                    ),

                  const AmountInput(),
                  const SizedBox(height: 16),

                  ConvertButton(
                    isTablet: isTablet,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      provider.convertCurrency();
                    },
                    isLoading: provider.isLoading,
                    isOffline: !provider.isOnline,
                  ),
                  const SizedBox(height: 16),

                  _buildCurrencyDropdowns(provider, isTablet),
                  const SizedBox(height: 16),

                  ReverseSwitch(
                    onPressed: provider.reverseCurrencies,
                    isTablet: isTablet,
                  ),
                  const SizedBox(height: 16),

                  ConversionResultCard(result: provider.result),
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: provider.addToFavorites,
                    icon: const Icon(Icons.star),
                    label: const Text('Add to Favorites'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: buttonPadding),
                      textStyle: TextStyle(fontSize: buttonFontSize),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildChartSection(provider, chartHeight),
                  const SizedBox(height: 16),

                  FavoritesList(
                    favorites: provider.favorites,
                    onRemove: (index) => provider.removeFavoriteAt(index),
                    onTap: (pair) => provider.loadFavoritePair(pair),
                  ),
                  const SizedBox(height: 24),

                  HistoryList(
                    history: provider.getHistoryDisplayStrings(),
                    onClear: provider.clearHistory,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdowns(
    CurrencyConverterProvider provider,
    bool isTablet,
  ) {
    if (isTablet) {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('From:', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                CurrencyDropdown(
                  selectedCurrency: provider.fromCurrency,
                  onChanged: provider.setFromCurrency,
                  supportedCurrencies: provider.supportedCurrencies,
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
                  selectedCurrency: provider.toCurrency,
                  onChanged: provider.setToCurrency,
                  supportedCurrencies: provider.supportedCurrencies,
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('From:', style: TextStyle(fontSize: 16)),
              CurrencyDropdown(
                selectedCurrency: provider.fromCurrency,
                onChanged: provider.setFromCurrency,
                supportedCurrencies: provider.supportedCurrencies,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('To:', style: TextStyle(fontSize: 16)),
              CurrencyDropdown(
                selectedCurrency: provider.toCurrency,
                onChanged: provider.setToCurrency,
                supportedCurrencies: provider.supportedCurrencies,
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildChartSection(
    CurrencyConverterProvider provider,
    double chartHeight,
  ) {
    if (provider.isChartLoading) {
      return const LoadingIndicator(size: 60);
    }

    if (provider.chartError != null) {
      return ErrorBanner(
        message: provider.chartError!,
        onDismiss: provider.clearChartError,
        isWarning: true,
      );
    }

    if (provider.chartData.isEmpty) {
      return SizedBox(
        height: chartHeight,
        child: const Center(
          child: Text(
            'No chart data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      height: chartHeight,
      child: CurrencyChart(
        fromCurrency: provider.fromCurrency,
        toCurrency: provider.toCurrency,
        chartData: provider.chartData,
        isLoading: provider.isChartLoading,
        error: provider.chartError,
      ),
    );
  }
}
