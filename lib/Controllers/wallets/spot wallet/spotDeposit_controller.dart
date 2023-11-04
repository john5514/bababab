import 'package:bicrypto/services/wallet_service.dart';
import 'package:get/get.dart';

class SpotDepositController extends GetxController {
  var chains = <String>[].obs;

  var selectedChain = ''.obs;
  var depositAddress = ''.obs;
  var depositQRCode = ''.obs;
  var transactionHash = ''.obs;
  var isVerified = false.obs;
  var remainingTime = 30.minutes.obs;

  void startDepositCountdown() {
    // Assuming you want to start a countdown when the deposit process begins
    remainingTime.value = 30.minutes;
    ever(remainingTime, (_) {
      if (remainingTime.value.inSeconds > 0) {
        remainingTime.value = remainingTime.value - 1.seconds;
      } else {
        // Handle times up
      }
    });
  }

  Future<void> fetchChains() async {
    try {
      var wallets = await Get.find<WalletService>().fetchSpotWallets();
      var chains = wallets
          .map((wallet) => wallet['addresses'].keys.toList())
          .expand((i) => i)
          .toSet()
          .toList();
      // Now you have the list of chains. You can store it in a variable or do something with it.
    } catch (e) {
      // Handle the error
    }
  }

  // Call this when the user selects a chain
  void setChain(String chain) {
    selectedChain.value = chain;
    // Fetch the deposit address and QR code for the selected chain
  }

  // Call this when the user submits the transaction hash
  void setTransactionHash(String hash) {
    transactionHash.value = hash;
    // Verify the transaction hash
  }

  // Add other necessary methods and logic for deposit verification, fetching addresses, etc.
}
