import 'package:bicrypto/services/wallet_service.dart';
import 'package:get/get.dart';

class WalletSpotController extends GetxController {
  final WalletService walletService;
  var currencies = <dynamic>[].obs;
  var balance = 0.0.obs; // Observable balance
  var isLoading = true.obs;

  WalletSpotController({required this.walletService});

  @override
  void onInit() {
    super.onInit();
    fetchCurrencies();
    fetchBalance(); // Fetch balance on initialization
  }

  void fetchCurrencies() async {
    isLoading(true);
    try {
      var response = await walletService.getCurrencies();
      if (response['status'] == 'success') {
        currencies.value = response['data']['result'];
      }
    } catch (e) {
      print('Error fetching currencies: $e');
    } finally {
      isLoading(false);
    }
  }

  void fetchBalance() async {
    try {
      balance.value = await walletService.fetchWalletBalance();
      // print("Fetched balance: ${balance.value}");
    } catch (e) {
      print('Error fetching wallet balance: $e');
    }
  }
}
