import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicrypto/Controllers/wallet_controller.dart'; // Import your WalletController
import 'package:bicrypto/Style/styles.dart'; // Import your custom theme

class FiatWalletView extends StatelessWidget {
  final WalletController walletController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (walletController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: appTheme.hintColor, // Use your custom theme color
            ),
          );
        } else if (walletController.fiatDepositMethods.isEmpty) {
          return Center(
            child: ElevatedButton(
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
                                  currency is Map &&
                                  currency.containsKey('code'))
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
                            walletController.selectedCurrency.value =
                                ''; // Reset selection
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            if (walletController
                                .selectedCurrency.value.isNotEmpty) {
                              walletController.createWallet(
                                  walletController.selectedCurrency.value);
                            }
                            walletController.selectedCurrency.value =
                                ''; // Reset selection
                            Navigator.pop(context);
                          },
                          child: Text('Create'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Create Wallet'),
            ),
          );
        } else {
          return ListView(
            children: [
              // Your wallet information and monthly summary charts go here
            ],
          );
        }
      },
    );
  }
}
