import 'package:get/get.dart';
import 'package:bicrypto/services/wallet_service.dart';

class SpotDepositController extends GetxController {
  var isLoading = false.obs;
  var selectedChain = ''.obs;
  var chains = <String>[].obs;
  final WalletService walletService;

  SpotDepositController(this.walletService);

  @override
  void onInit() {
    super.onInit();
    // Extract the currency from the arguments passed to this view
    // Ensure you handle the case where Get.arguments is null
    var arguments = Get.arguments as Map<String, dynamic>?;
    String currency = arguments?['currency'] ?? 'default_currency_value';
    // Now fetch chains for the selected currency
    fetchChains(currency);
  }

  void fetchChains(String currency) async {
    try {
      isLoading(true);
      var spotWallets = await walletService.fetchSpotWallets();
      // Find the wallet that matches the selected currency
      var selectedWallet = spotWallets.firstWhere(
        (wallet) => wallet['currency'] == currency,
        orElse: () => null,
      );

      if (selectedWallet != null && selectedWallet['addresses'] != null) {
        chains.value = selectedWallet['addresses'].keys.cast<String>().toList();
      } else {
        // Handle the case where no chains are found or the addresses are null
        chains.value = [];
      }
    } catch (e) {
      // Handle exception by showing error message or empty list
      chains.value = [];
      print('Error fetching chains for $currency: $e');
    } finally {
      isLoading(false);
    }
  }

  void setChain(String chain) {
    selectedChain.value = chain;
    print('Selected Chain: $chain'); // Print the selected chain

    // Fetch the deposit address and QR code for the selected chain
    // You would need to implement this in the walletService
  }

  // ... Other methods for handling deposit logic
}
