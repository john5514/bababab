import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicrypto/Controllers/walletinfo_controller.dart';

class PayoneerWithdrawalPage extends StatelessWidget {
  final Map<String, dynamic> selectedMethod;
  final String currencyName;
  final Map<String, dynamic> walletInfo;
  final WalletInfoController controller = Get.find();
  final RxBool isAgreedToTOS = false.obs;

  PayoneerWithdrawalPage({
    Key? key,
    required this.selectedMethod,
    required this.currencyName,
    required this.walletInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedMethod['title'] ?? 'Selected Method'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.grey[850],
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 56,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/PAYO.png'),
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Withdraw with Payoneer',
                      style: theme.textTheme.headline6
                          ?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      selectedMethod['instructions'] ??
                          'No instructions provided.',
                      style: theme.textTheme.subtitle1
                          ?.copyWith(color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            buildTextField(
              label: 'Withdrawal Amount',
              hint: 'Enter amount',
              prefixIcon: Icons.attach_money,
              onChanged: (value) =>
                  controller.withdrawAmount.value = double.tryParse(value) ?? 0,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            buildTextField(
              label: 'Payoneer Email',
              hint: 'Enter your Payoneer email',
              prefixIcon: Icons.email,
              onChanged: (value) =>
                  controller.customFieldInputs['Email'] = value,
            ),
            const SizedBox(height: 20),
            buildInfoRow('Flat Fee',
                '${selectedMethod['fixed_fee']} $currencyName', theme),
            buildInfoRow('Percentage Fee',
                '${selectedMethod['percentage_fee']}%', theme),
            Obx(() => buildInfoRow(
                  'Total Cost ($currencyName)',
                  '${calculateTotalAmount(controller.withdrawAmount.value.toString(), selectedMethod)}',
                  theme,
                )),
            const SizedBox(height: 20),
            Obx(
              () => CheckboxListTile(
                title: Text(
                  'I agree to the Terms Of Service',
                  style: theme.textTheme.bodyText1
                      ?.copyWith(color: Colors.grey[400]),
                ),
                value: isAgreedToTOS.value,
                onChanged: (bool? value) {
                  if (value != null) {
                    isAgreedToTOS.value = value;
                  }
                },
                activeColor: Colors.orange,
                checkColor: Colors.black,
                tileColor: Colors.grey[850],
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  onPressed: isAgreedToTOS.value
                      ? () async {
                          await controller.postFiatWithdrawalMethod(
                            {
                              'amount':
                                  controller.withdrawAmount.value.toString(),
                              'wallet': walletInfo['id'].toString(),
                              'email': controller.customFieldInputs['Email'],
                            },
                            selectedMethod['id'].toString(),
                          );
                        }
                      : null,
                  child: Center(
                    child: Text(
                      'Withdraw',
                      style: theme.textTheme.headline6
                          ?.copyWith(color: Colors.white),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required String hint,
    required IconData prefixIcon,
    required void Function(String) onChanged,
    TextInputType? keyboardType,
  }) {
    return TextField(
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(prefixIcon, color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orange),
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  theme.textTheme.bodyText2?.copyWith(color: Colors.grey[400])),
          Text(value,
              style: theme.textTheme.bodyText2?.copyWith(color: Colors.white)),
        ],
      ),
    );
  }

  String calculateTotalAmount(String amount, Map<String, dynamic> method) {
    double withdrawalAmount = double.tryParse(amount) ?? 0;
    double fixedFee = (method['fixed_fee'] as num).toDouble();
    double percentageFee = (method['percentage_fee'] as num).toDouble();
    double total = withdrawalAmount +
        fixedFee +
        (withdrawalAmount * (percentageFee / 100));
    return total.toStringAsFixed(2); // Formats the total to 2 decimal places
  }
}
