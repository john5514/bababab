import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicrypto/Controllers/walletinfo_controller.dart';

class WithdrawView extends StatelessWidget {
  const WithdrawView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final WalletInfoController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Text('Withdraw'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Prepare the payload as per your API requirements
            Map<String, dynamic> payload = {
              // Add necessary parameters for withdraw
            };
            controller.postFiatWithdraw(payload);
          },
          child: Text('Withdraw'),
        ),
      ),
    );
  }
}
