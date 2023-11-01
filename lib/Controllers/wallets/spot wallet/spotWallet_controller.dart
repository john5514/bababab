import 'package:bicrypto/services/CoinGeckoService.dart';
import 'package:get/get.dart';

class CoinGeckoController extends GetxController {
  final CoinGeckoService coinGeckoService;
  var currencies = <dynamic>[].obs;
  var isLoading = true.obs;

  CoinGeckoController({required this.coinGeckoService});

  @override
  void onInit() {
    super.onInit();
    fetchCurrencies();
  }

  void fetchCurrencies() async {
    try {
      isLoading(true);
      var fetchedCurrencies = await coinGeckoService.getCurrencies();
      currencies.value = fetchedCurrencies;
    } catch (e) {
      print('Error fetching currencies: $e');
    } finally {
      isLoading(false);
    }
  }
}
