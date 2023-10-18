import 'dart:async';
import 'package:bicrypto/services/orderbook_service.dart';
import 'package:get/get.dart';

class OrderBookController extends GetxController {
  final OrderBookService _orderBookService = OrderBookService();
  final Rx<OrderBook?> currentOrderBook = Rx<OrderBook?>(null);
  StreamSubscription? _orderBookSubscription;
  final String pair;

  OrderBookController(this.pair);

  @override
  void onInit() {
    super.onInit();
    _initializeOrderBookWebSocket();
  }

  void _initializeOrderBookWebSocket() {
    _orderBookService.connect();
    _orderBookSubscription =
        _orderBookService.orderBookUpdates.listen(_processOrderBookUpdate);

    // Add a delay before subscribing
    Future.delayed(Duration(seconds: 1), () {
      // Subscribe to the order book updates for the current pair
      _orderBookService.subscribeToOrderBook(pair);
    });
  }

  void _processOrderBookUpdate(OrderBook updatedOrderBook) {
    currentOrderBook.value = updatedOrderBook;
    print(
        "Received OrderBook Update: Bids: ${updatedOrderBook.bids.length}, Asks: ${updatedOrderBook.asks.length}");
    update();
  }

  @override
  void onClose() {
    _orderBookSubscription?.cancel();
    _orderBookService.dispose();
    super.onClose();
  }
}
