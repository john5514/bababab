import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:bicrypto/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bicrypto/Controllers/market/chart__controller.dart';
import 'package:http/http.dart' as http;

class MarketService {
  late final ApiService apiService;
  final String domain = const String.fromEnvironment('BASE_DOMAIN',
      defaultValue: 'v3.mash3div.com');
  String get baseUrl => 'https://$domain';
  String get _wsBaseUrl => 'wss://$domain/exchange/';

  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  WebSocket? _webSocket;
  late StreamController<List<Market>> _controller;

  MarketService(this.apiService) {
    _controller = StreamController<List<Market>>.broadcast();
  }

  Map<String, String?> tokens = {
    'access-token': null,
    'refresh-token': null,
    'csrf-token': null,
    'session-id': null,
  };

  // Load tokens from shared preferences
  Future<void> loadTokens() async {
    await apiService.loadTokens();
  }

  // Use consistent header setup method
  Map<String, String> get headers => {
        'access-token': apiService.tokens['access-token'] ?? "",
        'refresh-token': apiService.tokens['refresh-token'] ??
            "", // Keep the 'Bearer ' prefix
        'csrf-token': apiService.tokens['csrf-token'] ?? "",
        'session-id': apiService.tokens['session-id'] ?? "",
        'Content-Type': 'application/json',
        'Client-Platform': 'app',
      };

  // Initialize the WebSocket connection

  Stream<List<Market>> get marketUpdates => _controller.stream;
  bool get isControllerClosed => _controller.isClosed;
  bool _wasClosedIntentionally = false;

  void dispose() {
    _wasClosedIntentionally = true;
    _webSocket?.close();
    _webSocket = null;
    _controller.close();
  }

  void restartWebSocket(String link, VoidCallback onCompleted) {
    _wasClosedIntentionally = true;
    _webSocket?.close();
    _webSocket = null;

    // Wait for a brief moment before reconnecting
    Future.delayed(Duration(milliseconds: 500), () {
      _wasClosedIntentionally = false;
      connect(link);
      onCompleted(); // Call the completion callback after reconnecting
    });
  }

  void _reconnect(String link) {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print("Max reconnection attempts reached.");
      return;
    }

    // Close the existing WebSocket if it's open
    if (_webSocket != null) {
      _wasClosedIntentionally = true;
      _webSocket!.close();
      _webSocket = null;
    }

    // Increment reconnection attempts
    _reconnectAttempts++;

    final delay = _calculateExponentialBackoff(_reconnectAttempts - 1);
    Future.delayed(Duration(seconds: delay), () {
      print("Attempting to reconnect... Attempt: $_reconnectAttempts");
      connect(link);
    });
  }

  int _calculateExponentialBackoff(int attempt) {
    return (1 << attempt) * 2;
  }

  void connect(String link) async {
    final fullUrl = "$_wsBaseUrl$link";
    _wasClosedIntentionally = false;

    try {
      _webSocket = await WebSocket.connect(fullUrl);
      _reconnectAttempts = 0;

      _webSocket?.listen(
        (data) {
          if (_webSocket == null || _webSocket!.readyState != WebSocket.open) {
            return;
          }
          try {
            final decoded = json.decode(data);
            final tickersData = decoded['watchTickers'];

            if (tickersData is Map<String, dynamic>) {
              final markets = tickersData.entries.map((e) {
                return Market.fromJson(e.key, e.value);
              }).toList();
              _safeAddToController(markets);
            } else {
              print("Unexpected data structure received.");
            }
          } catch (e) {
            print("Error processing WebSocket data: $e");
          }
        },
        onError: (error) {
          print("WebSocket error: $error");
          _reconnect(link);
        },
        onDone: () {
          print("WebSocket closed for $link");
          if (!_wasClosedIntentionally) {
            _reconnect(link);
          }
        },
      );
    } catch (e) {
      print("Error connecting to WebSocket: $e");
      _reconnect(link);
    }
  }

  void _safeAddToController(List<Market> markets) {
    if (!_controller.isClosed) {
      _controller.add(markets);
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

        String requestUrl =
            '${baseUrl}/api/exchange/chart/historical?symbol=$symbol&interval=$interval&from=$sinceTimestamp&to=$toTimestamp&duration=$since';
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

  Future<List<Market>> fetchExchangeMarkets() async {
    final url = Uri.parse('${baseUrl}/api/exchange/markets');
    final response = await http.get(url, headers: {
      'accept': 'application/json',
      // Include any necessary headers such as authorization tokens
    });

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        List<Market> markets = (jsonResponse['data']['result'] as List)
            .map((marketData) =>
                Market.fromJson(marketData['symbol'], marketData))
            .toList();
        // markets.forEach((market) {
        //   print(
        //       "Fetched Market: Symbol: ${market.symbol}, Taker: ${market.metadata.taker}, Maker: ${market.metadata.maker}");
        // });

        return markets;
      } else {
        throw Exception('Failed to load exchange markets');
      }
    } else {
      throw Exception(
          'Failed to fetch exchange markets: ${response.statusCode}');
    }
  }

  Future<String> createOrder(String symbol, String type, String side,
      String amount, String price) async {
    final url = Uri.parse('${baseUrl}/api/exchange/orders');

    await loadTokens(); // Load tokens

    final response = await http.post(
      url,
      headers: headers, // Use consistent headers
      body: json.encode({
        'symbol': symbol,
        'type': type,
        'side': side,
        'amount': amount,
        'price': price,
      }),
    );

    Map<String, dynamic> responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      if (responseBody['status'] == 'fail') {
        // The order was not created successfully, return the error message
        return responseBody['error']['message'];
      } else {
        // The order was created successfully, return a success message
        return 'Order created successfully';
      }
    } else {
      throw Exception(
          'Failed to create order: ${response.statusCode}, ${response.body}');
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
      metadata: MarketMetadata.fromJson(json['metadata'] ?? {}),

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
