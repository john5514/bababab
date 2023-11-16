// ignore_for_file: invalid_use_of_protected_member

import 'package:bicrypto/Style/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicrypto/Controllers/walletinfo_controller.dart';

class WithdrawalView extends StatelessWidget {
  const WithdrawalView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final WalletInfoController controller = Get.find();
    // Use walletInfo if needed
    final Map<String, dynamic> walletInfo = Get.arguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw', style: TextStyle(color: Colors.white)),
        backgroundColor: appTheme.scaffoldBackgroundColor,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.fiatWithdrawMethods.isEmpty) {
          return const Center(
              child: Text('No withdrawal methods available',
                  style: TextStyle(color: Colors.white)));
        } else {
          return ListView.builder(
            itemCount: controller.fiatWithdrawMethods.length,
            itemBuilder: (context, index) {
              var method = controller.fiatWithdrawMethods[index];
              return ListTile(
                title: Text(
                  method['title'] ?? 'N/A',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  if (method.isNotEmpty) {
                    if (method['title'].toString().trim() == 'Payoneer') {
                      // Navigate to Payoneer page for withdrawal
                      Get.toNamed('/payoneer_withdraw', arguments: {
                        'method': method,
                        'currencyName': controller.walletName.value,
                        'walletInfo': controller.walletInfo.value,
                      });
                    } else {
                      // Implement other withdrawal methods when available
                      print("Other withdrawal methods not implemented yet");
                    }
                  } else {
                    print("Error: selectedMethod is empty");
                    // Optionally, show an error message to the user
                  }
                },
              );
            },
          );
        }
      }),
    );
  }
}
