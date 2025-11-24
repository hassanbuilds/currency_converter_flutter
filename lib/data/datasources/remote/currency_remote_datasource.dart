import 'dart:convert';
import 'package:courency_converter/core/errors/app_exception.dart';
import 'package:http/http.dart' as http;

class CurrencyRemoteDataSource {
  static const String _baseUrl =
      "https://api.currencyfreaks.com/v2.0/rates/latest";
  static const String _apiKey = "8e52bf806547426492687c4067a48cdb";

  Future<Map<String, double>> fetchLatestRates() async {
    final url = Uri.parse("$_baseUrl?apikey=$_apiKey");

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);

        if (jsonBody['rates'] == null) {
          throw NetworkException("Invalid API response: missing 'rates'");
        }

        final rates = Map<String, double>.from(
          (jsonBody['rates'] as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, double.parse(v.toString())),
          ),
        );

        // ✅ FIX: Ensure USD is always 1.0 (base currency)
        rates['USD'] = 1.0;

        return rates;
      } else {
        throw NetworkException(
          "HTTP ${response.statusCode}: ${response.reasonPhrase}",
        );
      }
    } catch (e) {
      throw NetworkException("Network/API error: $e");
    }
  }

  fetchLatestRatesRaw() {}
}
