import 'dart:ui';

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
      body: Obx(
        () {
          if (walletController.isLoading.value ||
              walletController.currencies.isEmpty) {
            return Center(
                child: CircularProgressIndicator(color: appTheme.hintColor));
          } else if (walletController.fiatWalletInfo.isEmpty) {
            return Center(
              child: Text('You do not have a fiat wallet. Please create one.',
                  style: appTheme.textTheme.bodyLarge),
            );
          } else {
            return ListView.builder(
              itemCount: walletController.fiatWalletInfo.length,
              itemBuilder: (context, index) {
                var walletInfo = walletController.fiatWalletInfo[index];
                String currencySymbol =
                    walletController.getCurrencySymbol(walletInfo['currency']);
                LinearGradient selectedGradient =
                    _getProfessionalGradient(index);

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: AspectRatio(
                    aspectRatio: 1.586, // Credit card aspect ratio
                    child: InkWell(
                      onTap: () => _onCardTap(walletInfo, context),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 8,
                        shadowColor: appTheme.hintColor.withOpacity(0.5),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: selectedGradient,
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildChipIcon(),
                                const SizedBox(height: 10),
                                Text(
                                  '${walletInfo['currency']} Wallet',
                                  style: appTheme.textTheme.bodyLarge?.copyWith(
                                    color: appTheme.secondaryHeaderColor,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  '$currencySymbol ${walletInfo['balance'].toStringAsFixed(2)}',
                                  style:
                                      appTheme.textTheme.displayLarge?.copyWith(
                                    color: appTheme.secondaryHeaderColor,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
            bottom: 30.0), // Increase bottom padding to move the button up
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              width: 56.0, // Standard FAB size, adjust if needed
              height: 56.0, // Standard FAB size, adjust if needed
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: FloatingActionButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Create Wallet'),
                        content: Obx(
                          () => DropdownButton<String>(
                            value:
                                walletController.selectedCurrency.value.isEmpty
                                    ? null
                                    : walletController.selectedCurrency.value,
                            hint: const Text('Select Currency'),
                            onChanged: (String? newValue) {
                              walletController.selectedCurrency.value =
                                  newValue!;
                            },
                            items: walletController.currencies
                                .where((currency) =>
                                    currency is Map &&
                                    currency.containsKey('code'))
                                .map<DropdownMenuItem<String>>((currency) {
                              return DropdownMenuItem<String>(
                                value: (currency['code'] ?? '').toString(),
                                child:
                                    Text((currency['code'] ?? '').toString()),
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
                              if (walletController
                                  .selectedCurrency.value.isNotEmpty) {
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
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(
                  Icons.add,
                  color: Colors.orange,
                  size: 40.0, // Increase the size of the icon
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _getProfessionalGradient(int index) {
    List<LinearGradient> gradients = [
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color.fromARGB(255, 7, 7, 7)!,
          const Color.fromARGB(255, 105, 104, 104)!
        ], // Subtle gray gradient
      ),
      // More subtle gradients...
    ];
    return gradients[index % gradients.length];
  }

  Widget _buildChipIcon() {
    // Build a small widget that looks like a credit card chip
    return Container(
      width: 40,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Icon(Icons.credit_card, size: 24, color: Colors.grey[600]),
    );
  }

  void _onCardTap(Map<String, dynamic> walletInfo, BuildContext context) {
    var walletName = walletInfo['currency'];
    var walletBalance = (walletInfo['balance'] is int)
        ? walletInfo['balance'].toDouble()
        : walletInfo['balance'];

    Get.put(
        WalletInfoController()); // Register the WalletInfoController instance
    var selectedMethod = Get.find<WalletInfoController>().selectedMethod.value;

    // Set wallet info and navigate to the wallet info view
    Get.find<WalletInfoController>().setWalletInfo(
        walletName, walletBalance, walletInfo, selectedMethod ?? {});
    Get.toNamed('/wallet-info');
  }
}
