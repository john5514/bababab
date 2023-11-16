import 'package:bicrypto/Controllers/wallets/spot%20wallet/spotDetail_controller.dart';
import 'package:bicrypto/Style/styles.dart';
import 'package:bicrypto/services/wallet_service.dart';
import 'package:bicrypto/views/wallets/spot/SpotTransferView.dart';
import 'package:bicrypto/views/wallets/spot/spotWithdraw_screen.dart';
import 'package:bicrypto/widgets/wallet/build_transactions.dart';
import 'package:bicrypto/widgets/wallet/defaultDialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SpotWalletDetailView extends StatelessWidget {
  final SpotWalletDetailController controller =
      Get.put(SpotWalletDetailController(Get.find<WalletService>()));

  SpotWalletDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure arguments are not null before using them
    final Map<dynamic, dynamic>? arguments = Get.arguments;
    if (arguments == null) {
      // Handle the case where arguments are null
      // You could show an error or redirect the user back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Error',
          'No wallet details provided.',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.back(); // Go back to the previous screen if no arguments are passed
      });
      return Scaffold(
          body:
              Container()); // Return an empty container to avoid rendering errors
    }

    final Map<String, dynamic> walletDetails =
        Map<String, dynamic>.from(arguments);
    controller.setWalletDetails(walletDetails);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet Details"),
        backgroundColor: appTheme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Obx(() => Text(
                "Balance: ${controller.walletDetails['balance']?.toStringAsFixed(2) ?? '0.00'}",
                style: const TextStyle(fontSize: 20, color: Colors.white),
              )),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(
                        Icons.swap_horiz), // Replace with your transfer icon
                    label: const Text("Transfer"),
                    onPressed: () {
                      Get.to(() =>
                          SpotTransferView()); // Navigate to the transfer page
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.all(4), // Reduced padding
                      minimumSize: const Size(88, 36), // Reduced minimum size
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons
                        .account_balance_wallet), // Replace with your deposit icon
                    label: const Text("Deposit"),
                    onPressed: () {
                      showDepositInstructions(
                          context, controller.walletDetails.value);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.all(4), // Reduced padding
                      minimumSize: const Size(88, 36), // Reduced minimum size
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons
                    .remove_circle_outline), // Use an appropriate icon for withdrawal
                label: const Text("Withdraw"),
                onPressed: () {
                  // Navigate to WithdrawView and pass the currency as an argument
                  Get.to(
                    () => SpotWithdrawView(),
                    arguments: {
                      'currency': walletDetails[
                          'currency'], // Make sure walletDetails has a 'currency' key
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.all(4), // Reduced padding
                  minimumSize: const Size(88, 36), // Reduced minimum size
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
              child: TransactionDisplay(transactions: controller.transactions)),
        ],
      ),
    );
  }
}
