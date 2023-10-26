import 'dart:convert';
import 'package:http/http.dart' as http;

class CryptoNewsService {
  final String _baseUrl =
      'https://min-api.cryptocompare.com/data/v2/news/?lang=EN';

  Future<List<dynamic>> fetchCryptoNews(int value) async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data['Data'];
    } else {
      throw Exception('Failed to load news');
    }
  }
}
