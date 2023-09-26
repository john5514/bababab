import 'package:bicrypto/Controllers/walletinfo_controller.dart';
import 'package:bicrypto/Controllers/wallet_controller.dart'; // Import WalletController
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicrypto/Style/styles.dart'; // Import your theme

class WalletInfoView extends StatelessWidget {
  final WalletInfoController walletInfoController =
      Get.put(WalletInfoController());
  final WalletController walletController =
      Get.find(); // Get the WalletController instance

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wallet Info',
          style: TextStyle(color: appTheme.secondaryHeaderColor),
        ),
        backgroundColor: appTheme.primaryColor,
      ),
      body: Obx(
        () => Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Text(
                  'Wallet Name: ${walletInfoController.walletName.value}',
                  style: appTheme.textTheme.bodyLarge,
                ),
                SizedBox(height: 20),
                Text(
                  'Wallet Balance: ${walletInfoController.walletBalance.value}',
                  style: appTheme.textTheme.bodyLarge,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_upward,
                        color: Colors.green), // Income Icon
                    Text(
                      '+${walletController.calculateIncome()}', // Display calculated income
                      style: appTheme.textTheme.bodyLarge
                          ?.copyWith(color: Colors.green),
                    ),
                    SizedBox(width: 20),
                    Icon(Icons.arrow_downward,
                        color: Colors.red), // Expense Icon
                    Text(
                      '-${walletController.calculateExpense()}', // Display calculated expense
                      style: appTheme.textTheme.bodyLarge
                          ?.copyWith(color: Colors.red),
                    ),
                  ],
                ),
                SizedBox(height: 40),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Handle deposit
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red),
                        padding: EdgeInsets.all(15),
                      ),
                      child: Text(
                        'Deposit',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Handle withdrawal
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green),
                        padding: EdgeInsets.all(15),
                      ),
                      child: Text(
                        'Withdraw',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: appTheme.scaffoldBackgroundColor,
    );
  }
}
