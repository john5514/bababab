// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicrypto/Controllers/walletinfo_controller.dart';

class DepositView extends StatelessWidget {
  const DepositView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final WalletInfoController controller = Get.find();
    // ignore: unused_local_variable
    final Map<String, dynamic> walletInfo = Get.arguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.fiatDepositMethods.isEmpty) {
          return const Center(
              child: Text('No deposit methods available',
                  style: TextStyle(color: Colors.white)));
        } else {
          return ListView.builder(
            itemCount: controller.fiatDepositMethods.length,
            itemBuilder: (context, index) {
              var method = controller.fiatDepositMethods[index];
              return ListTile(
                title: Text(
                  method['title'] ?? 'N/A',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  print(
                      "Debugging: selectedMethod in DepositView before navigation = $method");

                  if (method.isNotEmpty) {
                    if (method['name'] == 'Stripe') {
                      // Navigate to Stripe page
                      Get.toNamed('/stripe_method', arguments: {
                        'method': method,
                        'currencyName': controller.walletName.value,
                        'walletInfo': controller.walletInfo.value,
                      });
                    } else {
                      // Navigate to the selected method page for other methods
                      Get.toNamed('/selected-method', arguments: {
                        'method': method,
                        'currencyName': controller.walletName.value,
                        'walletInfo': controller.walletInfo.value,
                      });
                    }
                  } else {
                    print("Error: selectedMethod is empty before navigation");
                    // Optionally, show an error message to the user.
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
