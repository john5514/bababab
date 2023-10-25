import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bicrypto/Controllers/market/chart__controller.dart';
import 'package:http/http.dart' as http;

class MarketService {
  final String _wsBaseUrl = "wss://v3.mash3div.com/exchange/";
  WebSocket? _webSocket; // Made it nullable
  final _controller = StreamController<List<Market>>.broadcast();

  Map<String, String?> tokens = {
    'access-token': null,
    'refresh-token': null,
    'csrf-token': null,
    'session-id': null,
  };

  Stream<List<Market>> get marketUpdates => _controller.stream;

  // This is the new getter to check if the StreamController is closed
  bool get isControllerClosed => _controller.isClosed;
  bool _wasClosedIntentionally = false;

  void dispose() {
    _wasClosedIntentionally = true; // set to true when disposing
    if (_webSocket != null) {
      _webSocket!.close();
    }
    _controller.close();
  }

  // Load tokens from shared preferences
  Future<void> loadTokens() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var key in tokens.keys) {
      tokens[key] = prefs.getString(key);
    }
  }

  // Initialize the WebSocket connection
  void connect(String link) async {
    final fullUrl = "$_wsBaseUrl$link";

    try {
      _webSocket = await WebSocket.connect(fullUrl);
      _webSocket!.listen(
        (data) {
          if (_webSocket == null || _webSocket!.readyState != WebSocket.open) {
            // If WebSocket is not open, just return and don't process data
            return;
          }
          try {
            final decoded = json.decode(data);

            final tickersData = decoded['watchTickers'];

            if (tickersData is Map<String, dynamic>) {
              final markets = tickersData.entries.map((e) {
                // Pass both the key (e.g., "BTC/USDT") and the associated data to Market.fromJson
                return Market.fromJson(e.key, e.value);
              }).toList();
              _controller.add(markets);
            } else {
              print("Unexpected data structure received.");
            }
          } catch (e) {
            print("Error processing WebSocket data: $e");
          }
        },
        onError: (error) {
          print("WebSocket error: $error");
          // Trying to reconnect
          if (_webSocket == null || _webSocket!.readyState != WebSocket.open) {
            Future.delayed(Duration(seconds: 5), () {
              print("Attempting to reconnect...");
              connect(link);
            });
          }
        },
        onDone: () {
          print("WebSocket closed for $link");
          if (!_wasClosedIntentionally &&
              (_webSocket == null ||
                  _webSocket!.readyState != WebSocket.open)) {
            Future.delayed(Duration(seconds: 5), () {
              print("Attempting to reconnect...");
              connect(link);
            });
          }
        },
      );
    } catch (e) {
      print("Error connecting to WebSocket: $e");
      // Trying to reconnect after a delay
      Future.delayed(Duration(seconds: 5), () {
        print("Attempting to reconnect...");
        connect(link);
      });
    }
  }

  int intervalToMilliseconds(String interval) {
    switch (interval) {
      case '1s':
        return 1000;
      case '1m':
        return 60 * 1000;
      case '3m':
        return 3 * 60 * 1000;
      case '15m':
        return 15 * 60 * 1000;
      case '30m':
        return 30 * 60 * 1000;
      case '1h':
        return 60 * 60 * 1000;
      case '2h':
        return 2 * 60 * 60 * 1000;
      case '4h':
        return 4 * 60 * 60 * 1000;
      case '6h':
        return 6 * 60 * 60 * 1000;
      case '8h':
        return 8 * 60 * 60 * 1000;
      case '12h':
        return 12 * 60 * 60 * 1000;
      case '1d':
        return 24 * 60 * 60 * 1000;
      case '3d':
        return 3 * 24 * 60 * 60 * 1000;
      default:
        throw ArgumentError('Invalid interval: $interval');
    }
  }

  Future<List<CustomKLineEntity>> fetchHistoricalData(
      String symbol, String interval,
      {int numCandles = 72}) async {
    const int maxRetries = 3;
    const int delayBetweenRetries = 5; // in seconds

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        print("Starting fetchHistoricalData for $symbol...");

        await loadTokens();
        print("Loaded tokens: $tokens");

        final DateTime toDate = DateTime.now();
        final int toTimestamp = toDate.millisecondsSinceEpoch.toInt();
        print("To Timestamp: $toTimestamp");

        // Calculate the 'since' value
        final int since = numCandles * intervalToMilliseconds(interval);
        int sinceTimestamp = toTimestamp - since;

        final String requestUrl =
            'https://v3.mash3div.com/api/exchange/chart/historical?symbol=$symbol&interval=$interval&from=$sinceTimestamp&to=$toTimestamp&duration=$since';
        print("Making request to: $requestUrl");

        // Add the tokens to the headers
        final headers = {
          'accept': 'application/json',
          'access-token': tokens['access-token'] ?? "",
          'refresh-token': tokens['refresh-token'] ?? "",
          'csrf-token': tokens['csrf-token'] ?? "",
          'session-id': tokens['session-id'] ?? "",
        };

        print("Headers being used: $headers");

        final response =
            await http.get(Uri.parse(requestUrl), headers: headers);

        print("Received response status: ${response.statusCode}");
        print("Received response headers: ${response.headers}");
        print("Received response body: ${response.body}");

        if (response.statusCode == 200) {
          final body = json.decode(response.body);

          if (body['status'] == "success") {
            if (body['data']['result'] is List &&
                (body['data']['result'] as List).isEmpty) {
              final noDataMessage =
                  "No data available for $symbol during the specified time interval.";
              print(noDataMessage);
              throw Exception(noDataMessage);
            }

            // Adjust this if the structure is different.
            if (body['data']['result'] is List) {
              final candles = (body['data']['result'] as List)
                  .map((e) => CustomKLineEntity(
                        time: e[0].toInt(),
                        open: e[1].toDouble(),
                        high: e[2].toDouble(),
                        low: e[3].toDouble(),
                        close: e[4].toDouble(),
                        vol: e[5].toDouble(),
                      ))
                  .toList();

              print("Returning ${candles.length} candles.");
              return candles;
            } else {
              final error = "Unexpected data format in result";
              print(error);
              throw Exception(error);
            }
          } else {
            final errorMessage = body['error']?['message'] ?? 'Unknown error';
            print("API Error: $errorMessage");
            throw Exception('API returned an error: $errorMessage');
          }
        } else {
          final error =
              'Failed to load historical data with status code: ${response.statusCode}';
          print(error);
          throw Exception(error);
        }
      } catch (e) {
        // If we've used all our retries, throw the exception
        if (attempt == maxRetries - 1) {
          throw Exception('Failed to fetch data after $maxRetries attempts');
        }

        // Print the error and wait before the next attempt
        print('Attempt $attempt failed with error: $e');
        await Future.delayed(Duration(seconds: delayBetweenRetries));
      }
    }

    // This line should never be reached because we either return candles or throw an exception
    throw Exception('Failed to fetch data');
  }

  void subscribeToTradeData(String symbol, String type,
      {int? limit, String? interval}) {
    if (_webSocket != null && _webSocket!.readyState == WebSocket.open) {
      final data = {
        "method": "SUBSCRIBE",
        "params": {
          "symbol": symbol,
          "type": type,
          if (limit != null) "limit": limit,
          if (interval != null) "interval": interval
        }
      };
      _webSocket!.add(json.encode(data)); // Added null assertion
    } else {
      print("WebSocket not initialized or not open.");
      // Optionally: reconnect logic here
    }
  }

  void unsubscribeFromTradeData(String symbol, String type) {
    if (_webSocket != null && _webSocket!.readyState == WebSocket.open) {
      final data = {
        "method": "UNSUBSCRIBE",
        "params": {"symbol": symbol, "type": type}
      };
      _webSocket!.add(json.encode(data)); // Added null assertion
    } else {
      print("WebSocket not initialized or not open.");
      // Optionally: reconnect logic here
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
  double price; // Changed from final to mutable
  double change; // Changed from final to mutable
  double volume; // Changed from final to mutable
  final double high24h;
  final double low24h;

  Market({
    required this.id,
    required this.symbol,
    required this.pair,
    required this.isTrending,
    required this.isHot,
    required this.metadata,
    required this.status,
    required this.price,
    required this.change,
    required this.volume,
    required this.high24h,
    required this.low24h,
  });
  // Factory constructor to create a Market object from a map
  factory Market.fromJson(String marketName, Map<String, dynamic> json) {
    final splitMarketName = marketName.split('/');
    final symbol = splitMarketName[0];
    final pair = splitMarketName.length > 1 ? splitMarketName[1] : '';

    return Market(
      id: 0, // Not present in the data; using 0 as a default value
      symbol: symbol,
      pair: pair,
      isTrending:
          false, // Not present in the data; using false as a default value
      isHot: false, // Not present in the data; using false as a default value
      metadata: MarketMetadata.fromJson(
          {}), // No metadata in the data; using an empty map
      status: true, // Not present in the data; using true as a default value
      price: (json['last'] ?? 0.0).toDouble(),
      change: (json['change'] ?? 0.0).toDouble(),
      volume: (json['baseVolume'] ?? 0.0).toDouble(),
      high24h: (json['high24h'] ?? 0.0).toDouble(),
      low24h: (json['low24h'] ?? 0.0).toDouble(),
    );
  }
  // Add this method to update dynamic fields
  void updateWith(Market other) {
    if (this.symbol == other.symbol && this.pair == other.pair) {
      this.price = other.price;
      this.change = other.change;
      this.volume = other.volume;
      // Add any other dynamic fields here
    }
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
      symbol: json['symbol'] ?? '',
      base: json['base'] ?? '',
      quote: json['quote'] ?? '',
      precision: json['precision'] ?? {},
      limits: json['limits'] ?? {},
      taker: (json['taker'] ?? 0.0).toDouble(),
      maker: (json['maker'] ?? 0.0).toDouble(),
    );
  }
}
