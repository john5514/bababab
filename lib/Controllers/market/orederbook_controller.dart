import 'package:bicrypto/services/orderbook_service.dart';
import 'package:get/get.dart';

class OrderBookController extends GetxController {
  final OrderBookService _orderBookService = OrderBookService();

  // Reactive variables
  final RxList<List<double>> bids = <List<double>>[].obs;
  final RxList<List<double>> asks = <List<double>>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Connect to the WebSocket
    _orderBookService.connect();

    // Listen to order book updates
    _orderBookService.orderBookUpdates.listen((orderBook) {
      bids.value = orderBook.bids;
      asks.value = orderBook.asks;
    });
  }

  // Subscribe to order book updates for a symbol
  void subscribeToOrderBook(String symbol, {int limit = 20}) {
    _orderBookService.subscribeToOrderBook(symbol, limit: limit);
  }

  // Unsubscribe from order book updates for a symbol
  void unsubscribeFromOrderBook(String symbol) {
    _orderBookService.unsubscribeFromOrderBook(symbol);
  }

  @override
  void onClose() {
    // Dispose the order book service when the controller is closed
    _orderBookService.dispose();
    super.onClose();
  }
}
