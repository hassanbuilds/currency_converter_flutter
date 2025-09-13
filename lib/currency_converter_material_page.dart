import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class CurrencyConverterPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;
  const CurrencyConverterPage({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'PKR';
  String _result = '';
  List<String> _history = [];
  List<String> _favorites = [];

  final Map<String, String> _currencySymbols = {
    'USD': '\$',
    'PKR': 'Rs',
    'EUR': '€',
    'GBP': '£',
  };

  final Map<String, double> _exchangeRates = {
    'USD': 1.0,
    'PKR': 277.0,
    'EUR': 0.92,
    'GBP': 0.78,
  };

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadFavorites();
  }

  // ------------------- HISTORY -------------------
  void _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('conversion_history') ?? [];
    });
  }

  void _saveToHistory(String entry) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history.insert(0, entry);
      prefs.setStringList('conversion_history', _history);
    });
  }

  void _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('conversion_history');
    setState(() {
      _history = [];
    });
  }

  // ------------------- FAVORITES -------------------
  void _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = prefs.getStringList('favorites') ?? [];
    });
  }

  void _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    String pair = '$_fromCurrency → $_toCurrency';

    setState(() {
      if (_favorites.contains(pair)) {
        _favorites.remove(pair);
      } else {
        _favorites.add(pair);

        //  Popup on add
        showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text("Favorite Added"),
                content: Text(
                  "$_fromCurrency → $_toCurrency has been added to favorites!",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      }
    });

    prefs.setStringList('favorites', _favorites);
  }

  // ------------------- CONVERSION -------------------
  void _convertCurrency() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    double fromRate = _exchangeRates[_fromCurrency]!;
    double toRate = _exchangeRates[_toCurrency]!;
    double result = amount * (toRate / fromRate);

    setState(() {
      _result =
          '${amount.toStringAsFixed(1)} ${_currencySymbols[_fromCurrency]} = ${result.toStringAsFixed(2)} ${_currencySymbols[_toCurrency]}';
    });

    String entry =
        '${_currencySymbols[_fromCurrency]}$amount $_fromCurrency → ${_currencySymbols[_toCurrency]}${result.toStringAsFixed(2)} $_toCurrency';
    _saveToHistory(entry);
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
  }

  // ------------------- DUMMY CHART DATA -------------------
  List<double> _getDummyChartData(String from, String to) {
    if (from == "USD" && to == "PKR") {
      return [276, 277, 278, 276.5, 277.2, 278.1, 277.9];
    } else if (from == "EUR" && to == "PKR") {
      return [297, 298, 299, 298.5, 299.2, 300.1, 299.8];
    } else if (from == "GBP" && to == "PKR") {
      return [350, 351, 349, 352, 351.5, 353, 352.2];
    } else {
      return [1, 1.1, 1.05, 1.2, 1.15, 1.18, 1.22];
    }
  }

  Widget _buildCurrencyDropdown(String value, ValueChanged<String?> onChanged) {
    return DropdownButton<String>(
      value: value,
      underline: Container(),
      style: TextStyle(
        fontSize: 16,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      items:
          _exchangeRates.keys
              .map(
                (currency) => DropdownMenuItem(
                  value: currency,
                  child: Text('$currency ${_currencySymbols[currency]}'),
                ),
              )
              .toList(),
      onChanged: onChanged,
    );
  }

  // ------------------- UI -------------------
  @override
  Widget build(BuildContext context) {
    List<double> chartData = _getDummyChartData(_fromCurrency, _toCurrency);
    String currentPair = '$_fromCurrency → $_toCurrency';
    bool isFavorite = _favorites.contains(currentPair);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.toggleTheme,
          ),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? Colors.amber : null,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // ---------------- INPUT ----------------
              const Text(
                'Currency Converter',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter Amount',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCurrencyDropdown(
                    _fromCurrency,
                    (val) => setState(() => _fromCurrency = val!),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _swapCurrencies,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      shape: const CircleBorder(),
                    ),
                    child: const Icon(Icons.swap_horiz),
                  ),
                  const SizedBox(width: 20),
                  _buildCurrencyDropdown(
                    _toCurrency,
                    (val) => setState(() => _toCurrency = val!),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _convertCurrency,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(double.infinity, 0),
                ),
                child: const Text('Convert', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 24),

              if (_result.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _result,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              // ---------------- CHART ----------------
              const Divider(height: 32),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Exchange Rate Trend: $_fromCurrency → $_toCurrency (Last 7 Days)",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "1 $_fromCurrency = ${chartData.last.toStringAsFixed(2)} $_toCurrency",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                isCurved: true,
                                color: Colors.blue,
                                barWidth: 3,
                                spots:
                                    chartData
                                        .asMap()
                                        .entries
                                        .map(
                                          (e) =>
                                              FlSpot(e.key.toDouble(), e.value),
                                        )
                                        .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---------------- FAVORITES ----------------
              const Divider(height: 32),
              if (_favorites.isNotEmpty) ...[
                const Text(
                  'Favorite Currency Pairs',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    String fav = _favorites[index];
                    String from = fav.split("→")[0].trim();
                    String to = fav.split("→")[1].trim();

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.star, color: Colors.amber),
                        title: Text(
                          fav,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Rate: 1 $from = ${_exchangeRates[to]?.toStringAsFixed(2) ?? 'N/A'} $to",
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            setState(() {
                              _favorites.removeAt(index);
                              prefs.setStringList('favorites', _favorites);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],

              // ---------------- HISTORY ----------------
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Conversion History',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _clearHistory,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      "Clear",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_history.isEmpty)
                Center(
                  child: Text(
                    'No history yet.',
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _history.length,
                  itemBuilder:
                      (context, index) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.history, size: 20),
                          title: Text(_history[index]),
                        ),
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
