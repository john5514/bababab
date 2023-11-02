import 'package:bicrypto/Controllers/wallets/spot%20wallet/spotDetail_controller.dart';
import 'package:bicrypto/services/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SpotWalletDetailView extends StatelessWidget {
  final SpotWalletDetailController controller =
      Get.put(SpotWalletDetailController(Get.find<WalletService>()));

  SpotWalletDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<dynamic, dynamic> arguments = Get.arguments;
    final Map<String, dynamic> walletDetails =
        Map<String, dynamic>.from(arguments);
    controller.setWalletDetails(walletDetails);

    return Scaffold(
      appBar: AppBar(
        title: Text("Wallet Details"),
      ),
      body: Column(
        children: [
          Obx(() => Text(
                "Balance: ${controller.walletDetails['balance'].toStringAsFixed(4)}",
                style: TextStyle(fontSize: 20, color: Colors.white),
              )),
          Expanded(
            child: Obx(() {
              if (controller.transactions.isEmpty) {
                return Center(child: Text("No transactions found"));
              }
              return ListView.builder(
                itemCount: controller.transactions.length,
                itemBuilder: (context, index) {
                  var transaction = controller.transactions[index];
                  return ListTile(
                    title: Text(transaction['description'] ?? 'No description'),
                    subtitle:
                        Text("Amount: ${transaction['amount'].toString()}"),
                    // Add more details as needed
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
