import 'package:get/get.dart';
import 'package:bicrypto/services/wallet_service.dart';

class SpotDepositController extends GetxController {
  var isLoading = RxBool(false);
  var selectedChain = RxString('');
  var chains = RxList<String>();
  var depositAddress = RxString('');
  final WalletService walletService;
  var selectedWallet = {}.obs; // To store the selected wallet details

  SpotDepositController(this.walletService);

  @override
  void onInit() {
    super.onInit();
    var arguments = Get.arguments as Map<String, dynamic>?;
    String currency = arguments?['currency'] ?? 'default_currency_value';
    fetchChains(currency);
  }

  void fetchChains(String currency) async {
    try {
      isLoading(true);
      var spotWallets = await walletService.fetchSpotWallets();
      var wallet = spotWallets.firstWhere(
        (wallet) => wallet['currency'] == currency,
        orElse: () => null,
      );

      if (wallet != null) {
        selectedWallet(wallet); // Store the wallet details
        chains(wallet['addresses'].keys.cast<String>().toList());
        if (selectedChain.isNotEmpty) {
          setChain(selectedChain
              .value); // Fetch deposit address if chain is already selected
        }
      } else {
        chains([]);
      }
    } catch (e) {
      chains([]);
      print('Error fetching chains for $currency: $e');
    } finally {
      isLoading(false);
    }
  }

  void setChain(String chain) {
    selectedChain(chain);
    // Get the deposit address for the selected chain from the stored wallet details
    var addressDetails = selectedWallet['addresses'][chain];
    if (addressDetails != null) {
      depositAddress(addressDetails['address']);
    } else {
      depositAddress('Address not available');
    }
  }

  // Add any additional methods you need for the rest of your logic, such as transaction submission

  // ... Other methods for handling deposit logic
}
