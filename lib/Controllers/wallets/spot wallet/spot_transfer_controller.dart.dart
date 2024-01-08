import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bitcuit/services/wallet_service.dart';

class SpotTransferController extends GetxController {
  final WalletService walletService;
  var isLoading = false.obs;
  var transferResult = {}.obs;

  SpotTransferController(this.walletService);

  Future<void> transferFunds(
      String currency, String type, String amount, String to) async {
    isLoading(true);
    try {
      var result = await walletService.transfer(
        currency: currency,
        type: type,
        amount: amount,
        to: to,
      );
      if (result['status'] == 'fail') {
        Get.snackbar(
          'Transfer Failed',
          result['error']['message'] ?? 'An unknown error occurred.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: Colors.black,
        );
      } else {
        Get.snackbar(
          'Transfer Successful',
          'The funds have been transferred successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: Colors.black,
        );
      }
    } catch (e) {
      // Assuming e is an Exception and has a meaningful message
      String errorMessage = e.toString();
      Get.snackbar(
        'Transfer Failed',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black, // For contrast against the white background
      );
      print("Error during transfer: $e");
    } finally {
      isLoading(false);
    }
  }
}
