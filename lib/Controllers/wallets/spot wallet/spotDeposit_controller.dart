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
  var transactionHashForCancellation = ''.obs;

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

  String? findTransactionToCancel() {
    for (var transaction in selectedWallet.value['transactions'] ?? []) {
      if (transaction['type'] == 'DEPOSIT' &&
          transaction['status'] == 'PENDING') {
        return transaction['uuid']; // Assuming 'uuid' is the transaction ID
      }
    }
    return null;
  }

  Future<void> cancelDeposit() async {
    isLoading.value = true;
    String transactionHashToCancel = transactionHashForCancellation.value;
    if (transactionHashToCancel.isEmpty) {
      print('No transaction hash stored for cancellation.');
      isLoading.value = false;
      return; // No transaction hash stored, so return early
    }

    try {
      print(
          'Attempting to cancel deposit with transaction hash: $transactionHashToCancel');
      var response =
          await walletService.cancelSpotDeposit(transactionHashToCancel);
      print('Cancellation response: $response');
      // Clear the stored transaction hash after attempting cancellation
      transactionHashForCancellation.value = '';
      // Handle the successful cancellation here
      // Depending on the response, you might want to update the UI or user state here
    } catch (e) {
      print('An error occurred during cancellation: $e');
      // Handle the error here
      // Display an error message or update the UI accordingly
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

  void validateAndShowDialog(Map<String, dynamic> depositData) async {
    isLoading.value = true;
    // Ensure wallet_id is an integer
    depositData['wallet_id'] = int.tryParse(depositData['wallet_id']) ?? 0;
    print('Sending deposit data: $depositData');

    try {
      var response = await walletService.postSpotDeposit(depositData);
      print('Received response: $response');

      if (response['status'] == 'success') {
        // Save the transaction hash for later use in cancellation
        transactionHashForCancellation.value = depositData['trx'];
        showDialog();
      } else if (response['status'] == 'fail') {
        String errorMessage = response['error']['message'];
        print('Validation failed with message: $errorMessage');
        Get.snackbar('Error', 'Validation failed: $errorMessage');
      } else {
        print('Validation failed with an unknown error');
        Get.snackbar('Error', 'Validation failed with an unknown error');
      }
    } catch (e) {
      print('An error occurred during validation: $e');
      Get.snackbar('Error', 'An error occurred during validation: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
