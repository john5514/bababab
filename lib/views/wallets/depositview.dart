import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicrypto/Controllers/walletinfo_controller.dart';

class DepositView extends StatelessWidget {
  const DepositView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final WalletInfoController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Text('Deposit', style: TextStyle(color: Colors.white)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (controller.fiatDepositMethods.isEmpty) {
          return Center(
              child: Text('No deposit methods available',
                  style: TextStyle(color: Colors.white)));
        } else {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: controller.fiatDepositMethods.length,
                  itemBuilder: (context, index) {
                    var method = controller.fiatDepositMethods[index];
                    return ListTile(
                      title: Text(
                        method['title'] ??
                            'N/A', // Use 'title' key instead of 'name'
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        controller.selectedMethod.value = method;
                      },
                    );
                  },
                ),
              ),
              if (controller.selectedMethod.value != null)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Method: ${controller.selectedMethod.value!['title']}',
                          style: TextStyle(fontSize: 18),
                        ),

                        SizedBox(height: 10),
                        Text(
                            'Details and instructions for the selected method...'),
                        // Add form elements, checkboxes, and buttons here
                        // ...
                      ],
                    ),
                  ),
                ),
            ],
          );
        }
      }),
    );
  }
}
