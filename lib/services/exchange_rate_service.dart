
import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeRateService {
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest/';

  Future<Map<String, double>> fetchExchangeRates(String baseCurrency) async {
    final url = '$_baseUrl$baseCurrency';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        return rates.map((key, value) => MapEntry(key, (value as num).toDouble()));
      } else {
        // Log the error for debugging
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load exchange rates from API.');
      }
    } catch (e) {
      // Log the exception
      print('Network or parsing error: $e');
      // You could return cached data or a default set of rates here as a fallback
      throw Exception('Failed to connect to the exchange rate service. Please check your internet connection.');
    }
  }
}
