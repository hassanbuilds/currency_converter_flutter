import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const CurrencyConverterApp());
}

class CurrencyConverterApp extends StatefulWidget {
  const CurrencyConverterApp({super.key});

  @override
  State<CurrencyConverterApp> createState() => _CurrencyConverterAppState();
}

class _CurrencyConverterAppState extends State<CurrencyConverterApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: CurrencyConverterPage(
        isDarkMode: _isDarkMode,
        toggleTheme: _toggleTheme,
      ),
    );
  }
}

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

  final Map<String, String> _currencySymbols = {
    'USD': '\$',
    'PKR': '₨',
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
  }

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

  void _convertCurrency() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    double fromRate = _exchangeRates[_fromCurrency]!;
    double toRate = _exchangeRates[_toCurrency]!;
    double result = amount * (toRate / fromRate);

    setState(() {
      _result = '${_currencySymbols[_toCurrency]} ${result.toStringAsFixed(2)}';
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

  Widget _buildCurrencyDropdown(String value, ValueChanged<String?> onChanged) {
    return DropdownButton<String>(
      value: value,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildCurrencyDropdown(
                    _fromCurrency,
                    (val) => setState(() => _fromCurrency = val!),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: _swapCurrencies,
                ),
                Expanded(
                  child: _buildCurrencyDropdown(
                    _toCurrency,
                    (val) => setState(() => _toCurrency = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _convertCurrency,
              child: const Text('Convert'),
            ),
            const SizedBox(height: 16),
            if (_result.isNotEmpty)
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Converted Amount: $_result',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            const Divider(),
            const Text(
              'Conversion History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder:
                    (context, index) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(_history[index]),
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
