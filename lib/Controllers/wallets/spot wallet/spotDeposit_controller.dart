import 'package:bicrypto/widgets/wallet/deposit_instructions_dialog.dart';
import 'package:get/get.dart';
import 'package:bicrypto/services/wallet_service.dart';
import 'dart:async';

class SpotDepositController extends GetxController {
  var isLoading = false.obs;
  var selectedChain = ''.obs;
  var chains = <String>[].obs;
  var depositAddress = ''.obs;
  final WalletService walletService;
  var selectedWallet =
      Map<String, dynamic>().obs; // To store the selected wallet details
  var remainingTime = (30 * 60).obs; // 30 minutes countdown in seconds
  Timer? countdownTimer;

  SpotDepositController(this.walletService);

  @override
  void onInit() {
    super.onInit();
    var arguments = Get.arguments as Map<String, dynamic>?;
    String currency = arguments?['currency'] ?? 'default_currency_value';
    fetchChains(currency);
    startCountdown();
  }

  @override
  void onClose() {
    countdownTimer?.cancel();
    super.onClose();
  }

  void fetchChains(String currency) async {
    isLoading.value = true;
    try {
      var spotWallets = await walletService.fetchSpotWallets();
      var wallet = spotWallets
          .firstWhereOrNull((wallet) => wallet['currency'] == currency);

      if (wallet != null) {
        selectedWallet.value = wallet;
        chains.value = List<String>.from(wallet['addresses']?.keys ?? []);
        if (selectedChain.value.isNotEmpty) {
          setChain(selectedChain.value);
        }
      }
    } catch (e) {
      chains.clear();
      print('Error fetching chains for $currency: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setChain(String chain) {
    selectedChain.value = chain;
    var addressDetails = selectedWallet.value['addresses']?[chain];
    depositAddress.value = addressDetails != null
        ? addressDetails['address']
        : 'Address not available';
  }

  Future<void> verifyDeposit(String transactionId) async {
    isLoading.value = true;
    try {
      var response = await walletService.verifySpotDeposit(transactionId);
      // Handle the successful verification here
    } catch (e) {
      // Handle the error here
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelDeposit(String transactionId) async {
    isLoading.value = true;
    try {
      var response = await walletService.cancelSpotDeposit(transactionId);
      // Handle the successful cancellation here
    } catch (e) {
      // Handle the error here
    } finally {
      isLoading.value = false;
    }
  }

  void startCountdown() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingTime.value > 0) {
        remainingTime.value--;
      } else {
        countdownTimer?.cancel();
        // Handle the countdown completion here
      }
    });
  }

  void showDialog() {
    Get.dialog(
      DepositInstructionsDialog(walletDetails: selectedWallet.value),
      barrierDismissible: false, // User must tap button to close dialog
    );
  }

  // ... Other methods for handling deposit logic
}
