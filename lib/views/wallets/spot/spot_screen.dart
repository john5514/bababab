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
                style: TextStyle(color: Theme.of(context).primaryColor),
                decoration: InputDecoration(
                  icon:
                      Icon(Icons.search, color: Theme.of(context).primaryColor),
                  hintText: "Search Currencies",
                  hintStyle: TextStyle(color: Theme.of(context).hintColor),
                ),
              )
            : Text(
                'Total Balance: \$${controller.totalEstimatedBalance.value.toStringAsFixed(2)}',
                style: TextStyle(
                    color: Theme.of(context).textTheme.headline6?.color),
              )),
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
      body: Column(
        children: [
          Obx(() => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: controller.hideZeroBalances.value,
                      onChanged: (bool? value) =>
                          controller.setHideZeroBalances(value ?? false),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      side: BorderSide(color: Theme.of(context).dividerColor),
                      activeColor: Theme.of(context).hintColor,
                    ),
                    Text(
                      'Hide Zero Balances',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.subtitle1?.color,
                          fontSize: 14),
                    ),
                  ],
                ),
              )),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return RefreshIndicator(
                onRefresh: controller.refreshCurrencies,
                child: ListView.builder(
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
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0),
                      ),
                      subtitle: Text(
                        currency['name'], // Adjusted key
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyText2?.color,
                            fontSize: 14.0),
                      ),
                      trailing: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            // Default text style
                            color: Theme.of(context).textTheme.bodyText1?.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 16, // Normal text size
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: currency['balance']?.floor().toString() ??
                                  '0', // Whole number part
                            ),
                            const TextSpan(
                              text: ".",
                              style: TextStyle(
                                fontSize:
                                    16, // Size for the decimal point, keep it consistent with the whole number part
                              ),
                            ),
                            TextSpan(
                              text: ((currency['balance'] ?? 0) * 10 % 10)
                                  .toInt()
                                  .toString(), // Decimal part
                              style: const TextStyle(
                                fontSize:
                                    22, // Larger text size for the decimal part
                              ),
                            ),
                          ],
                        ),
                      ),

                      onTap: () => controller.handleCurrencyTap(
                          currency['currency']), // Adjusted key
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
