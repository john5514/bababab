import 'package:bitcuit/Controllers/wallets/spot%20wallet/spotDetail_controller.dart';
import 'package:bitcuit/Style/styles.dart';
import 'package:bitcuit/services/wallet_service.dart';
import 'package:bitcuit/views/wallets/spot/SpotTransferView.dart';
import 'package:bitcuit/views/wallets/spot/spotWithdraw_screen.dart';
import 'package:bitcuit/widgets/wallet/build_transactions.dart';
import 'package:bitcuit/widgets/wallet/defaultDialog.dart';
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
          Obx(() => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Balance: ${controller.walletDetails['balance']?.toStringAsFixed(2) ?? '0.00'}",
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              )),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.swap_horiz,
                  label: "Transfer",
                  onPressed: () => Get.to(() => SpotTransferView()),
                  borderColor: Colors.blueAccent, // Use Binance Pro's color
                  textColor: Colors.blueAccent, // Use Binance Pro's color
                ),
                _buildActionButton(
                  context,
                  icon: Icons.account_balance_wallet,
                  label: "Deposit",
                  onPressed: () => showDepositInstructions(
                      context, controller.walletDetails.value),
                  borderColor: Colors.green, // Use Binance Pro's color
                  textColor: Colors.green, // Use Binance Pro's color
                ),
                _buildActionButton(
                  context,
                  icon: Icons.remove_circle_outline,
                  label: "Withdraw",
                  onPressed: () => Get.to(
                    () => SpotWithdrawView(),
                    arguments: {'currency': walletDetails['currency']},
                  ),
                  borderColor: Colors.redAccent, // Use Binance Pro's color
                  textColor: Colors.redAccent, // Use Binance Pro's color
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
              child: TransactionDisplay(transactions: controller.transactions)),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed,
      required Color borderColor, // Add a border color parameter
      required Color textColor}) {
    // Add a text color parameter
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: OutlinedButton.icon(
          icon: Icon(icon, size: 24, color: textColor), // Set icon color
          label:
              Text(label, style: TextStyle(color: textColor)), // Set text color
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: borderColor), // Add border color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12.0),
          ),
        ),
      ),
    );
  }
}
