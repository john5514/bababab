import 'dart:convert';
import 'dart:async';
import 'dart:io';

class OrderBookService {
  // Extract the domain part from the environment variable
  final String domain = const String.fromEnvironment('BASE_DOMAIN',
      defaultValue: 'v3.mash3div.com');

  // Build the WebSocket URL by prepending 'wss://'
  String get _wsBaseUrl => 'wss://$domain/exchange/trade';

  WebSocket? _webSocket;
  final _controller = StreamController<OrderBook>.broadcast();

  bool get isControllerClosed => _controller.isClosed;
  bool _wasClosedIntentionally = false;

  Stream<OrderBook> get orderBookUpdates => _controller.stream;

  void dispose() {
    _wasClosedIntentionally = true;
    _webSocket?.close();
    _controller.close();
  }

  void connect() async {
    // print("Attempting to connect to WebSocket at $_wsBaseUrl...");

    try {
      _webSocket = await WebSocket.connect(_wsBaseUrl);
      // print("++++++++++++WebSocket connected successfully!");

      _webSocket!.listen(
        (data) {
          // print(
          //     '==================+++++++++=========WebSocket data received: $data');
          _handleWebSocketData(data);
        },
        onError: (error) {
          // print("WebSocket error received: $error");
          _reconnect();
        },
        onDone: () {
          // print("WebSocket connection closed");
          if (!_wasClosedIntentionally) {
            _reconnect();
          }
        },
        cancelOnError:
            true, // This will close the subscription on the first error
      );
    } catch (e) {
      // print("Error while trying to connect to WebSocket: $e");
      _reconnect();
    }
  }

  void _reconnect() {
    Future.delayed(Duration(seconds: 5), () {
      // print("Attempting to reconnect...");
      connect();
    });
  }

  void _handleWebSocketData(String data) {
    try {
      final decoded = json.decode(data);
      final orderBookData = decoded['watchOrderBook'];
      if (orderBookData != null) {
        _controller.add(OrderBook.fromJson(orderBookData));
      } else {
        // print("Unexpected data structure received.");
      }
    } catch (e) {
      // print("Error processing WebSocket data: $e");
    }
  }

  void subscribeToOrderBook(String symbol, {int limit = 20}) {
    if (_webSocket != null && _webSocket!.readyState == WebSocket.open) {
      final data = {
        "method": "SUBSCRIBE",
        "params": {"symbol": symbol, "type": "watchOrderBook", "limit": limit}
      };
      _webSocket!.add(json.encode(data));
    } else {
      print("WebSocket not initialized or not open.");
    }
  }

  void unsubscribeFromOrderBook(String symbol) {
    if (_webSocket != null && _webSocket!.readyState == WebSocket.open) {
      final data = {
        "method": "UNSUBSCRIBE",
        "params": {"symbol": symbol, "type": "watchOrderBook"}
      };
      _webSocket!.add(json.encode(data));
    } else {
      print("WebSocket not initialized or not open.");
    }
  }
}

class OrderBook {
  final List<List<double>> bids;
  final List<List<double>> asks;

  OrderBook({required this.bids, required this.asks});

  factory OrderBook.fromJson(Map<String, dynamic> json) {
    var bidsList = (json['bids'] as List)
        .map((e) => [
              double.tryParse(e[0].toString()) ?? 0.0,
              double.tryParse(e[1].toString()) ?? 0.0
            ])
        .toList();
    var asksList = (json['asks'] as List)
        .map((e) => [
              double.tryParse(e[0].toString()) ?? 0.0,
              double.tryParse(e[1].toString()) ?? 0.0
            ])
        .toList();

    // Sort bids descending (highest price first)
    bidsList.sort((a, b) => b[0].compareTo(a[0]));
    // Sort asks ascending (lowest price first)
    asksList.sort((a, b) => a[0].compareTo(b[0]));

    return OrderBook(
      bids: bidsList,
      asks: asksList,
    );
  }

  // Best bid is the first element after sorting, which has the highest price
  double get bestBid => bids.isNotEmpty ? bids.first[0] : 0.0;

  // Best ask is the first element after sorting, which has the lowest price
  double get bestAsk => asks.isNotEmpty ? asks.first[0] : 0.0;
}
