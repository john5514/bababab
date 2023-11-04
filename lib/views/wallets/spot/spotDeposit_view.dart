import 'package:bicrypto/Controllers/wallets/spot%20wallet/spotDeposit_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SpotDepositView extends StatelessWidget {
  final SpotDepositController controller = Get.put(SpotDepositController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spot Deposit'),
        // ... other appBar configurations
      ),
      body: Obx(() {
        if (controller.chains.isNotEmpty) {
          return DropdownButton<String>(
            value: controller.selectedChain.value,
            onChanged: (String? newValue) {
              controller.setChain(newValue!);
            },
            items:
                controller.chains.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          );
        } else {
          return CircularProgressIndicator(); // Or some placeholder
        }
      }),
    );
  }
}
