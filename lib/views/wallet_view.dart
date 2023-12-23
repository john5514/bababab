// WalletView.dart

import 'package:bicrypto/views/wallets/FiatWalletView.dart';
import 'package:bicrypto/views/wallets/spot/spot_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicrypto/Controllers/wallet_controller.dart'; // Import your WalletController
import 'package:bicrypto/Style/styles.dart'; // Import your custom theme

class WalletView extends StatelessWidget {
  final WalletController walletController = Get.find<WalletController>();

  WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (walletController.fiatWalletsEnabled.value) {
        return _buildTabbedView();
      } else {
        return _buildSpotOnlyView();
      }
    });
  }

  Widget _buildTabbedView() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Wallet'),
          backgroundColor: appTheme.scaffoldBackgroundColor,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Fiat Wallets'),
              Tab(text: 'Spot Wallets'),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            FiatWalletView(),
            WalletSpotView(),
          ],
        ),
      ),
    );
  }

  Widget _buildSpotOnlyView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        backgroundColor: appTheme.scaffoldBackgroundColor,
      ),
      body: WalletSpotView(),
    );
  }
}
