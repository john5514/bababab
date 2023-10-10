import 'dart:async'; // <-- Added for StreamSubscription
import 'package:bicrypto/services/market_service.dart';
import 'package:get/get.dart';

class MarketController extends GetxController {
  final MarketService _marketService = MarketService();
  var markets = <Market>[].obs;
  var isLoading = true.obs;
  var showGainers = true.obs;

  StreamSubscription? _marketSubscription; // <-- Subscription variable

  @override
  void onInit() {
    super.onInit();
    _initializeWebSocket(); // Start the WebSocket connection when the controller is initialized
  }

  void startWebSocket() {
    _initializeWebSocket();
  }

  void stopWebSocket() {
    _marketSubscription?.cancel(); // Cancel the subscription before disposing
    _marketService.dispose();
  }

  void _initializeWebSocket() {
    isLoading.value = true;

    // Update the link to match the endpoint
    _marketService.connect('tickers');

    _marketSubscription = _marketService.marketUpdates.listen((updatedMarkets) {
      if (_marketService.isControllerClosed) {
        // Check if the StreamController is closed
        print("StreamController is closed. Cannot add new data.");
        return;
      }
      markets.value = updatedMarkets;
      isLoading.value = false;
      // print("Markets updated: ${markets.value.length}");
    }, onError: (error) {
      isLoading.value = false;
      print("Failed to load markets: $error");
      // Handle error e.g. show a message to the user
    });

    // You might want to adjust this based on the actual data you want to subscribe to.
    // For now, I'm commenting it out.
    // _marketService.subscribeToTradeData('BTCUSDT', 'watchOrderBook', limit: 10);
  }

  @override
  void onClose() {
    _marketSubscription?.cancel(); // Cancel the subscription
    _marketService.dispose(); // Close the WebSocket
    super.onClose();
  }

  // Toggle between gainers and losers
  void toggleGainers() {
    showGainers.value = !showGainers.value;
  }
}
