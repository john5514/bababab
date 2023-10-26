import 'dart:convert';
import 'package:http/http.dart' as http;

class CryptoNewsService {
  final String _baseUrl =
      'https://min-api.cryptocompare.com/data/v2/news/?lang=EN';
  Future<List<dynamic>> fetchCryptoNews(int page, {int limit = 20}) async {
    final requestUrl = "$_baseUrl&limit=$limit&page=$page";
    final response = await http.get(Uri.parse(requestUrl));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data['Data'];
    } else {
      throw Exception('Failed to load news');
    }
  }
}
