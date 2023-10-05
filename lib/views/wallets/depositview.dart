import 'package:bicrypto/widgets/selected_method_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicrypto/Controllers/walletinfo_controller.dart';

class DepositView extends StatelessWidget {
  const DepositView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final WalletInfoController controller = Get.find();
    final Map<String, dynamic> walletInfo = Get.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text('Deposit', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (controller.fiatDepositMethods.isEmpty) {
          return Center(
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
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  if (method.isNotEmpty) {
                    // Check if method is non-empty
                    print(
                        "Debugging: selectedMethod in DepositView before navigation = $method");
                    Get.toNamed('/selected-method', arguments: {
                      'method': method,
                      'currencyName': controller.walletName.value,
                      'walletInfo': controller.walletInfo.value,
                    });
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
