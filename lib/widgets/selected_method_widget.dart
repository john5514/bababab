import 'package:bicrypto/Controllers/walletinfo_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectedMethodPage extends StatelessWidget {
  final Map<String, dynamic> selectedMethod;
  final String currencyName;
  final Map<String, dynamic> walletInfo;
  final WalletInfoController controller = Get.find();
  final RxBool isAgreedToTOS = false.obs;

  SelectedMethodPage({
    Key? key,
    required this.selectedMethod,
    required this.currencyName,
    required this.walletInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedMethod['title'] ?? 'Selected Method',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        shadowColor: Colors.red,
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
            const SizedBox(height: 20),
            Text(
              'Instructions: ${selectedMethod['instructions'] ?? 'N/A'}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) =>
                  controller.depositAmount.value = double.tryParse(value) ?? 0,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.orange),
              decoration: const InputDecoration(
                labelText: 'Deposit Amount',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Min Amount: ${selectedMethod['min_amount']} $currencyName, Max Amount: ${selectedMethod['max_amount']} $currencyName',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            const TextField(
              style: TextStyle(color: Colors.orange),
              decoration: InputDecoration(
                labelText: 'Transaction ID',
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.grey),
            const SizedBox(height: 20),
            buildInfoRow(
                'Flat Tax', '$currencyName ${selectedMethod['fixed_fee']}'),
            const SizedBox(height: 10),
            buildInfoRow(
                'Percentage Tax', '${selectedMethod['percentage_fee']}%'),
            const SizedBox(height: 20),
            Obx(() => buildInfoRow(
                  'To pay today ($currencyName)',
                  '$currencyName ${calculateTotalAmount(controller.depositAmount.value.toString(), selectedMethod)}',
                )),
            const SizedBox(height: 20),
            Container(
              color: Colors.grey[800],
              child: Obx(() => CheckboxListTile(
                    title: const Text(
                      'I agree to the Terms Of Service',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    value: isAgreedToTOS.value,
                    onChanged: (value) => isAgreedToTOS.value = value!,
                    activeColor: Colors.orange,
                    checkColor: Colors.black,
                  )),
            ),
            const SizedBox(height: 20),
            Obx(() => ElevatedButton(
                  onPressed: isAgreedToTOS.value
                      ? () async {
                          // Call the controller method to post the deposit
                          await controller.postFiatDepositMethod({
                            'amount': controller.depositAmount.value.toString(),
                            'wallet': walletInfo['id'].toString(),
                            'methodId': selectedMethod['id'],
                          });
                        }
                      : null,
                  child: const Text('Deposit'),
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
        Text(label, style: const TextStyle(color: Colors.white)),
        Text(value, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  String calculateTotalAmount(String amount, Map<String, dynamic> method) {
    double depositAmount = double.tryParse(amount) ?? 0;
    double fixedFee = (method['fixed_fee'] as num).toDouble();
    double percentageFee = (method['percentage_fee'] as num).toDouble();
    double total =
        depositAmount + fixedFee + (depositAmount * (percentageFee / 100));
    return total.toStringAsFixed(2);
  }
}
