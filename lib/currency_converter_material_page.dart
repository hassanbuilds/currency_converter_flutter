import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  void _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('conversion_history');
    setState(() {
      _history = [];
    });
  }

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
      body: Column(
        children: [
          // Bold centered title
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 16.0),
            child: Text(
              'Currency Converter',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter Amount',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  //  Centered Currency Dropdown Row with spacing
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCurrencyDropdown(
                          _fromCurrency,
                          (val) => setState(() => _fromCurrency = val!),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.swap_horiz),
                          onPressed: _swapCurrencies,
                        ),
                        const SizedBox(width: 12),
                        _buildCurrencyDropdown(
                          _toCurrency,
                          (val) => setState(() => _toCurrency = val!),
                        ),
                      ],
                    ),
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
                    child: const Text(
                      'Convert',
                      style: TextStyle(fontSize: 16),
                    ),
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
                  const Divider(height: 32),

                  //  Conversion History Header with Clear Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Conversion History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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

                  //  History List
                  Expanded(
                    child:
                        _history.isEmpty
                            ? Center(
                              child: Text(
                                'No history yet.',
                                style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            )
                            : ListView.builder(
                              itemCount: _history.length,
                              itemBuilder:
                                  (context, index) => Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                      leading: const Icon(
                                        Icons.history,
                                        size: 20,
                                      ),
                                      title: Text(_history[index]),
                                    ),
                                  ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
