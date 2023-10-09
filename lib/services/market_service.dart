import 'dart:convert';
import 'package:http/http.dart' as http;

class MarketService {
  final String baseUrl = "https://v3.mash3div.com/api/exchange/";

  // Fetches the list of markets
  Future<List<Market>> getMarkets() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}markets'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        if (responseBody['status'] == 'success') {
          List<dynamic> marketList = responseBody['data']['result'];

          // Convert the list of maps to a list of Market objects
          return marketList.map((m) => Market.fromJson(m)).toList();
        } else {
          throw Exception(responseBody['error']['message']);
        }
      } else {
        throw Exception(
            'Failed to fetch markets with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw e;
    }
  }
}

class Market {
  final int id;
  final String symbol;
  final String pair;
  final bool isTrending;
  final bool isHot;
  final MarketMetadata metadata;
  final bool status;
  final double price; // <-- Add this line
  final double change; // <-- Add this line
  final double volume; // <-- Add this line

  Market({
    required this.id,
    required this.symbol,
    required this.pair,
    required this.isTrending,
    required this.isHot,
    required this.metadata,
    required this.status,
    required this.price, // <-- Add this line
    required this.change, // <-- Add this line
    required this.volume, // <-- Add this line
  });

  // Factory constructor to create a Market object from a map
  // Factory constructor to create a Market object from a map
  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      id: json['id'],
      symbol: json['symbol'],
      pair: json['pair'],
      isTrending: json['is_trending'],
      isHot: json['is_hot'],
      metadata: MarketMetadata.fromJson(json['metadata']),
      status: json['status'],
      price: (json['price'] ?? 0.0).toDouble(), // Provide default value if null
      change:
          (json['change'] ?? 0.0).toDouble(), // Provide default value if null
      volume:
          (json['volume'] ?? 0.0).toDouble(), // Provide default value if null
    );
  }
}

class MarketMetadata {
  final String symbol;
  final String base;
  final String quote;
  final Map<String, dynamic> precision;
  final Map<String, dynamic> limits;
  final double taker;
  final double maker;

  MarketMetadata({
    required this.symbol,
    required this.base,
    required this.quote,
    required this.precision,
    required this.limits,
    required this.taker,
    required this.maker,
  });

  // Factory constructor to create a MarketMetadata object from a map
  factory MarketMetadata.fromJson(Map<String, dynamic> json) {
    return MarketMetadata(
      symbol: json['symbol'],
      base: json['base'],
      quote: json['quote'],
      precision: json['precision'],
      limits: json['limits'],
      taker: json['taker'],
      maker: json['maker'],
    );
  }
}
