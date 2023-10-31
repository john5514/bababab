import 'package:bicrypto/Controllers/walletinfo_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicrypto/Controllers/wallet_controller.dart';
import 'package:bicrypto/Style/styles.dart';

class FiatWalletView extends StatelessWidget {
  final WalletController walletController = Get.find();

  FiatWalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fiat Wallet',
            style: TextStyle(color: appTheme.secondaryHeaderColor)),
        backgroundColor: appTheme.primaryColor,
      ),
      body: Obx(
        () {
          if (walletController.isLoading.value ||
              walletController.currencies.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: appTheme.hintColor,
              ),
            );
          } else if (walletController.fiatWalletInfo.isEmpty) {
            return Center(
              child: Text(
                'You do not have a fiat wallet. Please create one.',
                style: appTheme.textTheme.bodyLarge,
              ),
            );
          } else {
            return ListView.builder(
              itemCount: walletController.fiatWalletInfo.length,
              itemBuilder: (context, index) {
                var walletInfo = walletController.fiatWalletInfo[index];
                String currencySymbol =
                    walletController.getCurrencySymbol(walletInfo['currency']);

                // Define a list of gradients to be used for the cards
                List<LinearGradient> gradients = [
                  const LinearGradient(
                      colors: [Colors.blue, Colors.blueAccent]),
                  const LinearGradient(colors: [Colors.red, Colors.redAccent]),
                  const LinearGradient(
                      colors: [Colors.green, Colors.greenAccent]),
                  const LinearGradient(
                      colors: [Colors.purple, Colors.purpleAccent]),
                  // Add more gradients as needed
                ];

                // Select a gradient based on the index
                LinearGradient selectedGradient =
                    gradients[index % gradients.length];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: const EdgeInsets.all(12),
                  elevation: 8,
                  shadowColor: appTheme.hintColor.withOpacity(0.5),
                  child: InkWell(
                    onTap: () {
                      var walletName = walletInfo['currency'];
                      var walletBalance = (walletInfo['balance'] is int)
                          ? walletInfo['balance'].toDouble()
                          : walletInfo['balance'];

                      // Register the WalletInfoController instance
                      Get.put(WalletInfoController());

                      // Fetch selectedMethod from the WalletInfoController
                      var selectedMethod =
                          Get.find<WalletInfoController>().selectedMethod.value;

                      // Print the walletInfo for debugging
                      print(
                          "Debugging: walletInfo after setting in onTap = $walletInfo");

                      // Set wallet info and navigate to the wallet info view
                      Get.find<WalletInfoController>().setWalletInfo(walletName,
                          walletBalance, walletInfo, selectedMethod ?? {});

                      Get.toNamed('/wallet-info');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        gradient:
                            selectedGradient, // Apply the selected gradient
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$currencySymbol ${walletInfo['balance'].toStringAsFixed(1)}',
                            style: appTheme.textTheme.displayLarge?.copyWith(
                                color: appTheme.secondaryHeaderColor),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${walletInfo['currency']} Wallet',
                            style: appTheme.textTheme.bodyLarge?.copyWith(
                                color: appTheme.secondaryHeaderColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
                actions: [
                  TextButton(
                    onPressed: () {
                      walletController.selectedCurrency.value = '';
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
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
                    child: const Text('Create'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: appTheme.floatingActionButtonTheme.backgroundColor,
      ),
    );
  }
}
