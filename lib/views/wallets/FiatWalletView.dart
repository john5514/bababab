import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicrypto/Controllers/wallet_controller.dart'; // Import your WalletController
import 'package:bicrypto/Style/styles.dart'; // Import your custom theme

class FiatWalletView extends StatelessWidget {
  final WalletController walletController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () {
          if (walletController.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                color: appTheme.hintColor, // Use your custom theme color
              ),
            );
          } else if (walletController.fiatWalletInfo.isEmpty) {
            return Center(
              child: Text(
                'You do not have a fiat wallet. Please create one.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      appTheme.secondaryHeaderColor, // Set the text color here
                ),
              ),
            );
          } else {
            return ListView(
              children:
                  walletController.fiatWalletInfo.map<Widget>((walletInfo) {
                return ListTile(
                  title: Text(
                    '${walletInfo['currency']} Wallet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: appTheme.secondaryHeaderColor,
                    ),
                  ),
                  subtitle: Text(
                    'Balance: ${walletInfo['balance']}\nAddress: ${walletInfo['addresses']?.values?.first['address']}',
                    style: TextStyle(
                      fontSize: 16,
                      color: appTheme.secondaryHeaderColor,
                    ),
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Create Wallet'),
                content: Obx(
                  () => DropdownButton<String>(
                    value: walletController.selectedCurrency.value.isEmpty
                        ? null
                        : walletController.selectedCurrency.value,
                    hint: Text('Select Currency'),
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
                actions: [
                  TextButton(
                    onPressed: () {
                      walletController.selectedCurrency.value = '';
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (walletController.selectedCurrency.value.isNotEmpty) {
                        walletController.createWallet(
                            walletController.selectedCurrency.value);
                      }
                      walletController.selectedCurrency.value = '';
                      Navigator.pop(context);
                    },
                    child: Text('Create'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
