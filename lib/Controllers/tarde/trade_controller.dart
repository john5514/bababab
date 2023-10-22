import 'package:get/get.dart';
import 'package:bicrypto/Controllers/market/chart__controller.dart'; // Import the ChartController

class TradeController extends GetxController {
  var tradeName = "".obs;
  var change24h = 0.0.obs;
  final ChartController _chartController = Get.find<ChartController>();

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
  }
}
