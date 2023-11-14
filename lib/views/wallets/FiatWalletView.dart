import 'dart:ui';
import 'package:bicrypto/widgets/wallet/TransactionItem.dart';
import 'package:bicrypto/widgets/wallet/build_transactions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicrypto/Controllers/wallet_controller.dart';
import 'package:bicrypto/Controllers/walletinfo_controller.dart';
import 'package:bicrypto/Style/styles.dart';

class FiatWalletView extends StatelessWidget {
  final WalletController walletController = Get.find();

  FiatWalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Use two-thirds of the space for the wallet list
          Flexible(
            flex: 4,
            child: Obx(() {
              if (walletController.isLoading.value) {
                return Center(
                    child:
                        CircularProgressIndicator(color: appTheme.hintColor));
              }
              if (walletController.fiatWalletInfo.isEmpty) {
                return Center(
                  child: Text(
                    'You do not have a fiat wallet. Please create one.',
                    style: appTheme.textTheme.bodyLarge,
                  ),
                );
              }
              return ListView.separated(
                itemCount: walletController.fiatWalletInfo.length,
                itemBuilder: (context, index) =>
                    buildWalletListItem(context, index),
                separatorBuilder: (context, index) =>
                    const Divider(color: Colors.grey),
              );
            }),
          ),
          // Use one-third of the space for the transactions list
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: const BoxDecoration(
              color: Colors
                  .black54, // Change this to match the background color in the image
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            width: double
                .infinity, // This will make the container stretch to the full width of the screen
            child: const Text(
              'Transactions',
              style: TextStyle(
                color: Colors.white, // Adjust text color to match your design
                fontWeight: FontWeight.bold,
                fontSize: 18, // Adjust font size as needed
              ),
            ),
          ),

          // Line under the header

          Expanded(
            flex: 3,
            child: Obx(() {
              if (walletController.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: appTheme.hintColor),
                );
              }
              if (walletController.fiatWalletTransactions.isEmpty) {
                return Center(
                  child: Text(
                    'No transactions found.',
                    style: appTheme.textTheme.bodyLarge,
                  ),
                );
              }
              return Container(
                decoration: const BoxDecoration(
                  color: Colors
                      .black54, // Common background color for transactions
                ),
                child: ListView.builder(
                  itemCount: walletController.fiatWalletTransactions.length,
                  itemBuilder: (context, index) {
                    var transaction =
                        walletController.fiatWalletTransactions[index];
                    return TransactionItem(
                      transaction: transaction,
                      // Remove margin to avoid space between items
                    ); // Use the TransactionItem widget here
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton:
          buildAddWalletButton(context), // Make sure this method is defined
    );
  }

  Widget buildWalletListView() {
    return Obx(
      () {
        if (walletController.isLoading.value ||
            walletController.currencies.isEmpty) {
          return Center(
              child: CircularProgressIndicator(color: appTheme.hintColor));
        } else if (walletController.fiatWalletInfo.isEmpty) {
          return Center(
            child: Text(
              'You do not have a fiat wallet. Please create one.',
              style: appTheme.textTheme.bodyLarge,
            ),
          );
        } else {
          // Use ListView.builder directly without wrapping it in Expanded
          return ListView.separated(
            itemCount: walletController.fiatWalletInfo.length,
            itemBuilder: (context, index) =>
                buildWalletListItem(context, index),
            separatorBuilder: (context, index) => const Divider(
                color: Colors.grey, endIndent: 20.0, indent: 20.0),
          );
        }
      },
    );
  }

  Widget buildWalletListItem(BuildContext context, int index) {
    var walletInfo = walletController.fiatWalletInfo[index];
    String currencySymbol =
        walletController.getCurrencySymbol(walletInfo['currency']);

    return ListTile(
      title: Text(
        '${walletInfo['currency']} ',
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      trailing: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$currencySymbol ',
              style: const TextStyle(
                // Gray and not bold
                color: Colors.orange,
                fontWeight: FontWeight.normal,
                fontFamily: 'Inter',
              ),
            ),
            TextSpan(
              text: '${walletInfo['balance'].toStringAsFixed(2)}',
              style: const TextStyle(
                // White and bold
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
      onTap: () => onCardTap(walletInfo, context),
    );
  }

  void onCardTap(Map<String, dynamic> walletInfo, BuildContext context) {
    var walletName = walletInfo['currency'];
    var walletBalance = (walletInfo['balance'] is int)
        ? walletInfo['balance'].toDouble()
        : walletInfo['balance'];

    // Ensure that WalletInfoController is registered
    if (!Get.isRegistered<WalletInfoController>()) {
      Get.put(WalletInfoController());
    }

    // Retrieve the WalletInfoController instance
    WalletInfoController walletInfoController =
        Get.find<WalletInfoController>();

    // Retrieve the selected method, if any
    var selectedMethod = walletInfoController.selectedMethod.value;

    // Set the wallet info in the controller
    walletInfoController.setWalletInfo(
        walletName, walletBalance, walletInfo, selectedMethod ?? {});

    // Navigate to the wallet info view
    Get.toNamed('/wallet-info');
  }

  Widget buildAddWalletButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: buildFloatingActionButton(context),
        ),
      ),
    );
  }

  FloatingActionButton buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => showCreateWalletDialog(context),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: const Icon(Icons.add, color: Colors.orange, size: 40.0),
    );
  }

  void showCreateWalletDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Wallet'),
          content: Obx(
            () => DropdownButton<String>(
              value: walletController.selectedCurrency.value.isEmpty
                  ? null
                  : walletController.selectedCurrency.value,
              hint: const Text('Select Currency'),
              onChanged: (String? newValue) {
                walletController.selectedCurrency.value = newValue!;
              },
              items: walletController.currencies
                  .where((currency) =>
                      currency is Map && currency.containsKey('code'))
                  .map<DropdownMenuItem<String>>((currency) {
                return DropdownMenuItem<String>(
                  value: (currency['code'] ?? '').toString(),
                  child: Text((currency['code'] ?? '').toString()),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                walletController.selectedCurrency.value = '';
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (walletController.selectedCurrency.value.isNotEmpty) {
                  walletController
                      .createWallet(walletController.selectedCurrency.value);
                }
                walletController.selectedCurrency.value = '';
                Navigator.of(context).pop();
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
