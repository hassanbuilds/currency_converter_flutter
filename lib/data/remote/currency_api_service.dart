import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyApiService {
  static const String _baseUrl = "https://api.freecurrencyapi.com/v1/latest";
  static const String _apiKey =
      "fca_live_UfrcgGfKm1u1q3jPqQvEZoo1PjXXsv5Ym5PvvEfB";

  Future<Map<String, dynamic>> fetchLatestRates() async {
    final url = Uri.parse("$_baseUrl?apikey=$_apiKey");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        if (jsonBody == null || jsonBody.isEmpty) {
          throw Exception("Empty response from API");
        }
        return jsonBody;
      } else if (response.statusCode == 400) {
        throw Exception("Bad request — incorrect parameters");
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized — API key issue");
      } else if (response.statusCode == 404) {
        throw Exception("Endpoint not found");
      } else if (response.statusCode == 500) {
        throw Exception("API Server down");
      } else {
        throw Exception("Unexpected status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }
}
