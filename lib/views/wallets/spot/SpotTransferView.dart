import 'package:bicrypto/Controllers/wallets/spot%20wallet/spot_transfer_controller.dart.dart';
import 'package:bicrypto/Style/styles.dart';
import 'package:bicrypto/services/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SpotTransferView extends StatelessWidget {
  final SpotTransferController controller =
      Get.put(SpotTransferController(Get.find<WalletService>()));
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _uuidController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  SpotTransferView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Funds'),
        backgroundColor: appTheme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _uuidController,
                style: const TextStyle(
                  color: Colors.white, // Text color
                ),
                decoration: const InputDecoration(
                  labelText: 'Target User UUID',
                  labelStyle: TextStyle(
                    color: Colors.white, // Label text color for dark mode
                  ),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.white), // Border color for dark mode
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors
                            .white), // Border color when the field is focused
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter target user UUID';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  } else if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Only attempt the transfer if the form is valid
                  controller
                      .transferFunds(
                    'currency', // You would have to provide the actual currency
                    'SPOT',
                    _amountController.text,
                    _uuidController.text,
                  )
                      .then((_) {
                    // Here, you can show a snackbar with the results for debugging purposes
                    if (controller.transferResult['status'] == 'fail') {
                      Get.snackbar(
                        'Transfer Failed',
                        controller.transferResult['error']['message'],
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  });
                }
              },
              child: Obx(() => controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : const Text('Transfer')),
            ),
            Obx(() {
              if (controller.transferResult.isNotEmpty) {
                return Text(
                    'Transfer Status: ${controller.transferResult['status']}');
              }
              return const SizedBox
                  .shrink(); // Return an empty widget if no result
            }),
          ],
        ),
      ),
    );
  }
}
