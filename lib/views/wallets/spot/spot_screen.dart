import 'package:bicrypto/Controllers/wallets/spot%20wallet/spotWallet_controller.dart';
import 'package:bicrypto/services/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalletSpotView extends StatelessWidget {
  final WalletSpotController controller =
      Get.put(WalletSpotController(walletService: Get.find<WalletService>()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
            'Total Balance: \$${controller.totalEstimatedBalance.value.toStringAsFixed(2)}')),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: controller.currencies.length,
          itemBuilder: (context, index) {
            var currency = controller.currencies[index];
            return ListTile(
              title: Text(
                currency['currency'], // Adjusted key
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ),
              subtitle: Text(
                currency['name'], // Adjusted key
                style: const TextStyle(color: Colors.white, fontSize: 14.0),
              ),
              onTap: () => controller
                  .handleCurrencyTap(currency['currency']), // Adjusted key
            );
          },
        );
      }),
    );
  }
}
