import 'dart:convert';
import 'package:http/http.dart' as http;

class CoinGeckoService {
  final String baseUrl = "https://api.coingecko.com/api/v3/";

  Future<List<dynamic>> getCurrencies() async {
    try {
      var response = await http.get(
        Uri.parse(
            '${baseUrl}coins/markets?vs_currency=usd&order=market_cap_desc'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load currencies from CoinGecko');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }
}
