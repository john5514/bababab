import 'dart:async';
import 'package:bicrypto/services/api_service.dart';
import 'package:bicrypto/services/market_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarketController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final MarketService _marketService;
  late TabController tabController; // Declare the TabController

  // Observable variables
  var markets = <Market>[].obs;
  var isLoading = true.obs;
  var tabIndex = 0.obs; // Add an observable for the active tab index

  StreamSubscription? _marketSubscription;

  MarketController() {
    _marketService = MarketService(Get.find<ApiService>());
  }

  @override
  void onInit() {
    super.onInit();
    tabController =
        TabController(length: 4, vsync: this); // Initialize the TabController

    // Listen to tab index changes
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        tabIndex.value = tabController.index; // Update the tabIndex observable
      }
    });

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

      // Update existing markets or add new ones
      for (var updatedMarket in updatedMarkets) {
        var index = markets.value.indexWhere((m) =>
            m.symbol == updatedMarket.symbol && m.pair == updatedMarket.pair);

        if (index != -1) {
          // Update existing market
          markets.value[index].updateWith(updatedMarket);
        } else {
          // Add new market
          markets.value.add(updatedMarket);
        }
      }
      markets.refresh(); // Notify listeners about the update
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
    tabController.dispose(); // Dispose the TabController
    super.onClose();
  }
}
