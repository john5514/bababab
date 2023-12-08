import 'package:bicrypto/services/wallet_service.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart'; // make sure to add this package for firstWhereOrNull

class SpotWithdrawController extends GetxController {
  final WalletService walletService;
  var isLoading = false.obs;
  var withdrawFee = ''.obs;
  var selectedChain = ''.obs;
  var withdrawalAddress = ''.obs;
  var withdrawalAmount = ''.obs;
  var chains = <String>[].obs;
  var selectedWallet = Map<String, dynamic>().obs;

  SpotWithdrawController(this.walletService);

  @override
  void onInit() {
    super.onInit();
    var arguments = Get.arguments as Map<String, dynamic>?;
    String currency = arguments?['currency'] ?? 'default_currency_value';
    // print('onInit - Currency: $currency'); // Print currency on init
    fetchChainsAndFees(currency);
  }

  void fetchChainsAndFees(String currency) async {
    isLoading(true);
    try {
      var response = await walletService.getExchangeCurrencies();
      var data = response['data']['result'] as List<dynamic>;
      var wallet =
          data.firstWhereOrNull((wallet) => wallet['currency'] == currency);

      if (wallet != null) {
        selectedWallet(wallet);
        // Extract the chain information directly from the 'chains' key in the wallet
        var chainInfos = wallet['chains'] as List<dynamic>;
        var chainNames = chainInfos.map((chain) => chain['network']).toList();
        chains(chainNames.cast<String>());
        // print('fetchChainsAndFees - Chains set: ${chains.value}');
        if (chainNames.isNotEmpty) {
          // If we have chain names, automatically select the first one
          setChain(chainNames.first);
        }
      }
    } catch (e) {
      chains.clear();
      // print('fetchChainsAndFees - Error fetching chains: $e');
      Get.snackbar('Error', 'Failed to fetch chains and fees: $e');
    } finally {
      isLoading(false);
    }
  }

  void setChain(String chain) {
    // print('setChain - Chain selected: $chain');
    selectedChain(chain);

    // Access the chain info for the fee from the 'chains' array within the selected wallet
    var chainInfos = selectedWallet.value['chains'] as List<dynamic>;
    var chainInfo = chainInfos
        .firstWhereOrNull((chainItem) => chainItem['network'] == chain);

    if (chainInfo != null) {
      withdrawFee(chainInfo['withdrawFee']?.toString() ?? 'Fee not available');
      // print('setChain - Withdraw fee: ${withdrawFee.value}');
    } else {
      // print('setChain - No chain info found for chain: $chain');
      withdrawFee('Fee not available');
    }
  }

  void initiateWithdrawal() async {
    if (withdrawalAddress.isEmpty || withdrawalAmount.isEmpty) {
      Get.snackbar('Error', 'Please enter address and amount.');
      return;
    }
    if (selectedChain.isEmpty) {
      Get.snackbar('Error', 'Please select a chain.');
      return;
    }

    isLoading(true);
    try {
      await walletService.withdraw(
        currency: selectedWallet
            .value['currency'], // Use the selected wallet's currency
        chain: selectedChain.value,
        amount: withdrawalAmount.value,
        address: withdrawalAddress.value,
        memo: '', // This should be dynamic or optional based on user input
      );
      Get.snackbar('Success', 'Withdrawal initiated successfully.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to initiate withdrawal: $e');
    } finally {
      isLoading(false);
    }
  }
}
