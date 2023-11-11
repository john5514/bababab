import 'dart:ui';
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
      body: buildWalletListView(),
      floatingActionButton: buildAddWalletButton(context),
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
          return ListView.builder(
            itemCount: walletController.fiatWalletInfo.length,
            itemBuilder: (context, index) => buildWalletCard(context, index),
          );
        }
      },
    );
  }

  Widget buildWalletCard(BuildContext context, int index) {
    var walletInfo = walletController.fiatWalletInfo[index];
    String currencySymbol =
        walletController.getCurrencySymbol(walletInfo['currency']);
    LinearGradient selectedGradient = getProfessionalGradient(index);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: AspectRatio(
        aspectRatio: 1.586, // Credit card aspect ratio
        child: InkWell(
          onTap: () => onCardTap(walletInfo, context),
          child: buildCard(walletInfo, currencySymbol, selectedGradient),
        ),
      ),
    );
  }

  Card buildCard(Map<String, dynamic> walletInfo, String currencySymbol,
      LinearGradient gradient) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 8,
      shadowColor: appTheme.hintColor.withOpacity(0.5),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildChipIcon(),
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
                style: appTheme.textTheme.displayLarge?.copyWith(
                  color: appTheme.secondaryHeaderColor,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient getProfessionalGradient(int index) {
    List<LinearGradient> gradients = [
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF2B2B2B), // Dark grey
          Color(0xFF383838), // Slightly lighter grey
        ],
      ),
      // You can add more subtle gradients here if you have other card styles
    ];
    return gradients[index % gradients.length];
  }

  Widget buildChipIcon() {
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
