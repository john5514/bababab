import 'package:bicrypto/services/market_service.dart';
import 'package:get/get.dart';

class MarketController extends GetxController {
  final MarketService _marketService = MarketService();
  var markets = <Market>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadMarkets();
  }

  void loadMarkets() async {
    try {
      isLoading.value = true;
      markets.value = await _marketService.getMarkets();
      print(
          "Markets loaded: ${markets.value.length}"); // This will print the number of markets loaded
    } catch (e) {
      print("Failed to load markets: $e");
      // Handle error e.g. show a message to the user
    } finally {
      isLoading.value = false;
    }
  }
}
