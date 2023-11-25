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
  var currentPrice = 0.0.obs; // Observable for the current price
  var availableBalance = 0.0.obs; // Observable for the available balance

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

    amountController.addListener(() {
      double enteredAmount = double.tryParse(amountController.text) ?? 0.0;
      if (availableBalance.value <= 0) {
        sliderValue.value = 0;
        if (enteredAmount > 0) {
          amountController.text = '0';
        }
      } else {
        sliderValue.value =
            (enteredAmount / availableBalance.value).clamp(0.0, 1.0);
      }
    });

    _currentMarket.listen((_) {
      if (_currentMarket.value != null) {
        _calculateValues();
      }
    });
  }

  Future<void> _fetchMarketData() async {
    try {
      List<Market> marketList = await _marketService.fetchExchangeMarkets();

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
    double fee = activeAction.value == "Buy"
        ? _currentMarket.value?.metadata.taker ?? 0.001
        : _currentMarket.value?.metadata.maker ?? 0.001;

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

    // Calculate the fee rate and taker fees
    double feeRate = currentFee;
    takerFees.value = calculateFee(amount, price, feeRate);

    // Calculate cost based on the action type

    cost.value = calculateCost(amount, price, feeRate, activeAction.value);

    update();
  }

  double calculateFee(double amount, double price, double feeRate) {
    return (amount * price * feeRate) / 100;
  }

  double calculateCost(
      double amount, double price, double feeRate, String side) {
    if (side == 'Buy') {
      return (amount * price) + calculateFee(amount, price, feeRate);
    } else {
      // For sell, cost doesn't include the fee since the fee is subtracted from the received amount
      return amount;
    }
  }

  void buy() async {
    if (amountController.text.isEmpty || priceController.text.isEmpty) {
      print("Error: Amount or Price is empty");
      return;
    }
    try {
      await _marketService.createOrder(
        firstPairName, // symbol
        selectedOrderType.value, // type (e.g., "Limit")
        'buy', // side
        amountController.text, // amount
        priceController.text, // price
      );
      print("Buying ${amountController.text} of ${tradeName.value}");
    } catch (e) {
      print('Error creating buy order: $e');
    }
  }

  void sell() async {
    if (amountController.text.isEmpty || priceController.text.isEmpty) {
      print("Error: Amount or Price is empty");
      return;
    }
    try {
      await _marketService.createOrder(
        firstPairName, // symbol
        selectedOrderType.value, // type (e.g., "Limit")
        'sell', // side
        amountController.text, // amount
        priceController.text, // price
      );
      print("Selling ${amountController.text} of ${tradeName.value}");
    } catch (e) {
      print('Error creating sell order: $e');
    }
  }

  // In TradeController
  void updateAmountFromSlider() {
    if (availableBalance.value <= 0) {
      sliderValue.value = 0;
      amountController.text = '0';
      return;
    }

    double amount = availableBalance.value * sliderValue.value;
    amountController.text =
        amount.toStringAsFixed(2); // Set the calculated amount
  }

  void updateMarketPrice(double newPrice) {
    currentPrice.value = newPrice;
  }

  void updateAvailableBalance(double newBalance) {
    availableBalance.value = newBalance;
  }
}
