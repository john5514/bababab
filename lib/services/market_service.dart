import 'dart:convert';
import 'dart:async';
import 'dart:io';

class MarketService {
  final String _wsBaseUrl = "wss://v3.mash3div.com/exchange/";
  WebSocket? _webSocket; // Made it nullable
  final _controller = StreamController<List<Market>>.broadcast();

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

            final tickersData = decoded.containsKey('watchTickers')
                ? decoded['watchTickers']
                : decoded;

            if (tickersData is Map<String, dynamic>) {
              final markets =
                  tickersData.values.map((m) => Market.fromJson(m)).toList();
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
      id: json['id'] ?? 0,
      symbol: json['symbol'] ?? '',
      pair: json['pair'] ?? '',
      isTrending: json['is_trending'] ?? false,
      isHot: json['is_hot'] ?? false,
      metadata: MarketMetadata.fromJson(json['metadata'] ?? {}),
      status: json['status'] ?? false,
      price: (json['price'] ?? 0.0).toDouble(),
      change: (json['change'] ?? 0.0).toDouble(),
      volume: (json['volume'] ?? 0.0).toDouble(),
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
