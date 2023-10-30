import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicrypto/Controllers/market/chart__controller.dart'; // Import the ChartController

class TradeController extends GetxController {
  var tradeName = "".obs;
  var change24h = 0.0.obs;
  final ChartController _chartController = Get.find<ChartController>();
  var activeAction = "Buy".obs;
  var selectedOrderType = "Limit".obs;
  var sliderValue = 0.0.obs;
  var takerFees = 0.0.obs; // Defined takerFees
  var totalExclFees = 0.0.obs; // Defined total excluding fees
  var cost = 0.0.obs; // Defined cost

  final TextEditingController amountController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String get firstPairName => tradeName.value.split('/').first;
  String get secondPairName => tradeName.value.split('/').last;

  @override
  void onInit() {
    super.onInit();

    // Fetching initial trade name from the passed arguments
    final Map<String, dynamic> arguments = Get.arguments;
    tradeName.value = arguments['pair'];

    // Listening for changes on the currentMarket
    _chartController.currentMarket.listen((market) {
      if (market != null) {
        change24h.value = market.change;
      }
    });

    // Example logic to calculate fees and cost (You might want to adjust this)
    // This is a basic example and might not cover your actual use-case.
    _calculateValues();
  }

  void _calculateValues() {
    // Example logic for calculations:
    double amount = double.tryParse(amountController.text) ?? 0.0;
    double price = double.tryParse(priceController.text) ?? 0.0;

    takerFees.value = 0.001 * amount * price; // 0.1% taker fee
    totalExclFees.value = amount - takerFees.value;
    cost.value = amount * price;
  }

  void buy() {
    // Your logic to perform the buying action goes here.
    // For now, let's just print a message:
    print("Buying ${amountController.text} of ${tradeName.value}");
  }

  void sell() {
    // Your logic to perform the selling action goes here.
    // For now, let's just print a message:
    print("Selling ${amountController.text} of ${tradeName.value}");
  }
}
