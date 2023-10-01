import 'package:bicrypto/Controllers/walletinfo_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

class SelectedMethodPage extends StatelessWidget {
  final Map<String, dynamic> selectedMethod;
  final String currencyName;
  final Map<String, dynamic> walletInfo;
  final WalletInfoController controller = Get.find();
  final RxBool isAgreedToTOS = false.obs; // Define isAgreedToTOS here

  SelectedMethodPage({
    Key? key,
    required this.selectedMethod,
    required this.currencyName,
    required this.walletInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController transactionIdController =
        TextEditingController();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      print("Debugging: walletInfo in SelectedMethodPage = $walletInfo");
      controller.initializeWalletInfo(walletInfo, selectedMethod);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedMethod['title'] ?? 'Selected Method',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${selectedMethod['title']}',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            SizedBox(height: 20),
            Text(
              'Instructions: ${selectedMethod['instructions'] ?? 'N/A'}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 20),
            TextField(
              controller: transactionIdController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Transaction ID',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.grey),
            SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Deposit Amount',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
            ),
            SizedBox(height: 20),
            buildInfoRow(
                'Flat Tax', '$currencyName ${selectedMethod['fixed_fee']}'),
            SizedBox(height: 10),
            buildInfoRow('Percentage Tax',
                '${(selectedMethod['percentage_fee'] as num).toDouble() / 100}%'), // Fixed percentage display
            SizedBox(height: 20),
            buildInfoRow(
              'To pay today ($currencyName)',
              '$currencyName ${calculateTotalAmount(amountController.text, selectedMethod)}',
            ),
            SizedBox(height: 20),
            SizedBox(height: 20),
            Obx(() => CheckboxListTile(
                  title: Text(
                    'I agree to the Terms Of Service',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  value: isAgreedToTOS.value,
                  onChanged: (value) {
                    isAgreedToTOS.value = value!;
                  },
                  activeColor: Colors.orange,
                  checkColor: Colors.black, // Fixed checkbox color
                )),
            SizedBox(height: 20),
            Obx(() => ElevatedButton(
                  onPressed: isAgreedToTOS.value
                      ? () async {
                          // Store the transactionIdController.text value in customFieldInputs
                          controller.customFieldInputs[transactionIdController
                              .text] = 'test@gmail.com'; // This line is changed

                          // Construct the payload with necessary parameters
                          final payload = {
                            'amount': amountController.text,
                            'wallet': walletInfo['id'].toString(),
                            'methodId': selectedMethod['id'],
                          };

                          // Call the controller method to post the deposit
                          await controller.postFiatDepositMethod(payload);
                        }
                      : null,
                  child: Text('Deposit'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.orange,
                    onPrimary: Colors.white,
                    elevation: 6.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white)),
        Text(value, style: TextStyle(color: Colors.white)),
      ],
    );
  }

  double calculateTotalAmount(String amount, Map<String, dynamic> method) {
    double depositAmount = double.tryParse(amount) ?? 0;
    double fixedFee = (method['fixed_fee'] as num).toDouble();
    double percentageFee = (method['percentage_fee'] as num).toDouble();
    return depositAmount + fixedFee + (depositAmount * (percentageFee / 100));
  }
}
