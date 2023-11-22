import 'package:bicrypto/Controllers/market/chart__controller.dart';
import 'package:bicrypto/Controllers/market/orederbook_controller.dart';
import 'package:bicrypto/services/market_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TradeController extends GetxController {
  var tradeName = "".obs;
  var change24h = 0.0.obs;
  final ChartController _chartController = Get.find<ChartController>();
  var activeAction = "Buy".obs; // 'Buy' or 'Sell'
  var selectedOrderType = "Limit".obs;
  var sliderValue = 0.0.obs;
  var takerFees = 0.0.obs;
  var totalExclFees = 0.0.obs;
  var cost = 0.0.obs;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final OrderBookController _orderBookController =
      Get.find<OrderBookController>();
  final MarketService _marketService =
      MarketService(); // Instance of MarketService

  final Rx<Market?> _currentMarket = Rx<Market?>(null); // Made observable
  Market? get currentMarket => _currentMarket.value;

  String get firstPairName => tradeName.value.split('/').first;
  String get secondPairName => tradeName.value.split('/').last;

  @override
  void onInit() async {
    super.onInit();

    final Map<String, dynamic> arguments = Get.arguments;
    tradeName.value = arguments['pair'];

    // Await the fetching of market data
    await _fetchMarketData();

    // Rest of your initialization logic
    _chartController.currentMarket.listen((market) {
      if (market != null) {
        change24h.value = market.change;
      }
    });

    amountController.addListener(_calculateValues);
    priceController.addListener(_calculateValues);
    _orderBookController.currentOrderBook.listen((_) {
      if (selectedOrderType.value == "Market") {
        _calculateValues();
      }
    });

    _currentMarket.listen((_) {
      if (_currentMarket.value != null) {
        _calculateValues();
      }
    });
  }

  Future<void> _fetchMarketData() async {
    print("Fetching market data...");
    try {
      List<Market> marketList = await _marketService.fetchExchangeMarkets();
      print("Trade Name: ${tradeName.value}"); // Debug print

      // Split tradeName.value to match the format used in Market
      String baseSymbol = tradeName.value.split('/').first;

      _currentMarket.value =
          marketList.firstWhereOrNull((market) => market.symbol == baseSymbol);

      if (_currentMarket.value != null) {
      } else {}
    } catch (e) {
      print('Error fetching market data: $e');
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    priceController.dispose();
    super.onClose();
  }

  double get currentFee {
    print(
        "Retrieving fee for ${activeAction.value} action. Current Market: ${_currentMarket.value?.symbol}");
    double fee = activeAction.value == "Buy"
        ? _currentMarket.value?.metadata.taker ?? 0.002
        : _currentMarket.value?.metadata.maker ?? 0.002;

    print("Current Fee: $fee");
    return fee;
  }

  void _calculateValues() {
    double amount = double.tryParse(amountController.text) ?? 0.0;
    double price;

    if (selectedOrderType.value == "Market") {
      if (activeAction.value == 'Buy') {
        price = _orderBookController.bestAskPrice;
      } else {
        price = _orderBookController.bestBidPrice;
      }
    } else {
      price = double.tryParse(priceController.text) ?? 0.0;
    }

    double feeRate = currentFee;
    takerFees.value = calculateFee(amount, price, feeRate);

    if (activeAction.value == 'Buy') {
      cost.value = amount * price * (1 + feeRate);
    } else {
      cost.value = amount * price;
    }

    totalExclFees.value = cost.value - takerFees.value;
    update();
  }

  double calculateFee(double amount, double price, double feeRate) {
    return (amount * price * feeRate);
  }

  double calculateCost(
      double amount, double price, double feeRate, String side) {
    if (side == 'Buy') {
      return (amount * price) + calculateFee(amount, price, feeRate);
    } else {
      // For sell, cost doesn't include the fee since the fee is subtracted from the received amount
      return amount * price;
    }
  }

  void buy() {
    // Add your buying logic here
    print("Buying ${amountController.text} of ${tradeName.value}");
  }

  void sell() {
    // Add your selling logic here
    print("Selling ${amountController.text} of ${tradeName.value}");
  }
}
