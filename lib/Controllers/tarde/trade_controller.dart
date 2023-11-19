import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicrypto/Controllers/market/chart__controller.dart'; // Import the ChartController

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

  String get firstPairName => tradeName.value.split('/').first;
  String get secondPairName => tradeName.value.split('/').last;

  @override
  void onInit() {
    super.onInit();

    final Map<String, dynamic> arguments = Get.arguments;
    tradeName.value = arguments['pair'];

    _chartController.currentMarket.listen((market) {
      if (market != null) {
        change24h.value = market.change;
      }
    });

    amountController.addListener(_calculateValues);
    priceController.addListener(_calculateValues);

    _calculateValues();
  }

  @override
  void onClose() {
    amountController.dispose();
    priceController.dispose();
    super.onClose();
  }

  void _calculateValues() {
    double amount = double.tryParse(amountController.text) ?? 0.0;
    double price = double.tryParse(priceController.text) ?? 0.0;

    // Backend logic replicated
    double feeRate =
        activeAction.value == 'Buy' ? 0.1 : 0.2; // Example fee rates
    takerFees.value = calculateFee(amount, price, feeRate);
    cost.value = calculateCost(amount, price, feeRate, activeAction.value);
    totalExclFees.value = cost.value - takerFees.value;

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
      // Sell
      return amount; // For sell, the cost is just the amount
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
