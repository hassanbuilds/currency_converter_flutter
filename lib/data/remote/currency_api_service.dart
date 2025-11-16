import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyApiService {
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
          throw Exception("Invalid API response: missing 'rates'");
        }

        // Convert rates from String -> double
        final rates = Map<String, double>.from(
          (jsonBody['rates'] as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, double.parse(v.toString())),
          ),
        );

        return rates;
      } else {
        throw Exception(
          "HTTP ${response.statusCode}: ${response.reasonPhrase}",
        );
      }
    } catch (e) {
      throw Exception("Network/API error: $e");
    }
  }
}
