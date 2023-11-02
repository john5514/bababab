import 'package:bicrypto/Controllers/wallets/spot%20wallet/spotWallet_controller.dart';
import 'package:bicrypto/services/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalletSpotView extends StatelessWidget {
  final WalletSpotController controller =
      Get.put(WalletSpotController(walletService: Get.find<WalletService>()));

  WalletSpotView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Obx(() => controller.isSearching.value
            ? TextField(
                onChanged: (value) => controller.filterCurrencies(value),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.white),
                  hintText: "Search Currencies",
                  hintStyle: TextStyle(color: Colors.white),
                ),
              )
            : Text(
                'Total Balance: \$${controller.totalEstimatedBalance.value.toStringAsFixed(2)}')),
        actions: <Widget>[
          Obx(() => controller.isSearching.value
              ? IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    controller.clearSearch();
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    controller.enableSearch();
                  },
                )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: controller.isSearching.isTrue
              ? controller.filteredCurrencies.length
              : controller.currencies.length,
          itemBuilder: (context, index) {
            var currency = controller.isSearching.isTrue
                ? controller.filteredCurrencies[index]
                : controller.currencies[index];
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
              trailing: Text(
                "${currency['balance']?.toStringAsFixed(1) ?? '0.0'}",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
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
