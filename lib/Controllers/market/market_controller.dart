import 'dart:async';
import 'package:bicrypto/services/market_service.dart';
import 'package:get/get.dart';

class MarketController extends GetxController {
  final MarketService _marketService = MarketService();
  var markets = <Market>[].obs;
  var isLoading = true.obs;

  StreamSubscription? _marketSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeWebSocket();
  }

  void startWebSocket() {
    _initializeWebSocket();
  }

  void stopWebSocket() {
    _marketSubscription?.cancel();
    _marketService.dispose();
  }

  void _initializeWebSocket() {
    isLoading.value = true;

    _marketService.connect('tickers');

    _marketSubscription = _marketService.marketUpdates.listen((updatedMarkets) {
      if (_marketService.isControllerClosed) {
        print("StreamController is closed. Cannot add new data.");
        return;
      }
      markets.value = updatedMarkets;
      isLoading.value = false;
    }, onError: (error) {
      isLoading.value = false;
      print("Failed to load markets: $error");
    });
  }

  @override
  void onClose() {
    _marketSubscription?.cancel();
    _marketService.dispose();
    super.onClose();
  }
}
