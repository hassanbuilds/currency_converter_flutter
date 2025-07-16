import 'package:flutter/material.dart';

class CurrencyConverterMaterialPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const CurrencyConverterMaterialPage({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  State<CurrencyConverterMaterialPage> createState() =>
      _CurrencyConverterMaterialPageState();
}

class _CurrencyConverterMaterialPageState
    extends State<CurrencyConverterMaterialPage> {
  final TextEditingController textEditingController = TextEditingController();
  double result = 0;
  bool isReversed = false;

  final border = OutlineInputBorder(
    borderSide: const BorderSide(width: 2.0),
    borderRadius: BorderRadius.circular(8),
  );

  void convertCurrency() {
    final inputText = textEditingController.text;
    final double? input = double.tryParse(inputText);

    if (input != null) {
      setState(() {
        result = isReversed ? input / 280 : input * 280;
      });
    } else {
      setState(() {
        result = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String fromCurrency = isReversed ? 'PKR' : 'USD';
    String toCurrency = isReversed ? 'USD' : 'PKR';

    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.black : Colors.blueGrey[50]!,
      appBar: AppBar(
        backgroundColor:
            widget.isDarkMode ? Colors.black : Colors.blueGrey[50]!,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Currency Converter ($fromCurrency → $toCurrency)',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              color:
                  widget.isDarkMode
                      ? Colors.grey[850]
                      : Colors.blueGrey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    Text(
                      '$toCurrency ${result.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color:
                            widget.isDarkMode
                                ? Colors.white
                                : Colors.blueGrey[900],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: textEditingController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter amount in $fromCurrency',
                        prefixIcon: const Icon(Icons.monetization_on),
                        border: border,
                        focusedBorder: border,
                        enabledBorder: border,
                        filled: true,
                        fillColor:
                            widget.isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[200],
                      ),
                      style: TextStyle(
                        color:
                            widget.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: convertCurrency,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            widget.isDarkMode
                                ? Colors.white
                                : Colors.blueGrey[900],
                        foregroundColor:
                            widget.isDarkMode ? Colors.black : Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Convert'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Reverse Conversion",
                          style: TextStyle(
                            color:
                                widget.isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        Switch(
                          value: isReversed,
                          onChanged: (value) {
                            setState(() {
                              isReversed = value;
                              result = 0;
                              textEditingController.clear();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
