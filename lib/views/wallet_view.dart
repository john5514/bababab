import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicrypto/Controllers/wallet_controller.dart'; // Import your WalletController
import 'package:bicrypto/Style/styles.dart'; // Import your custom theme

class WalletView extends StatelessWidget {
  final WalletController walletController = Get.put(WalletController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Wallet'),
          backgroundColor: appTheme.primaryColor, // Use your custom theme color
          bottom: TabBar(
            tabs: [
              Tab(text: 'Fiat Wallets'),
              Tab(text: 'Spot Wallets'),
            ],
          ),
        ),
        body: Obx(
          () {
            if (walletController.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  color: appTheme.hintColor, // Use your custom theme color
                ),
              );
            } else {
              return TabBarView(
                children: [
                  // Content for Fiat Wallets
                  Center(child: Text('Fiat Wallets Content')),
                  // Content for Spot Wallets
                  Center(child: Text('Spot Wallets Content')),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
