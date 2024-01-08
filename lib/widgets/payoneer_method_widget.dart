import 'package:bitcuit/Style/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bitcuit/Controllers/walletinfo_controller.dart';

class PayoneerSelectedMethodPage extends StatelessWidget {
  final Map<String, dynamic> selectedMethod;
  final String currencyName;
  final Map<String, dynamic> walletInfo;
  final WalletInfoController controller = Get.find();
  final RxBool isAgreedToTOS = false.obs;

  PayoneerSelectedMethodPage({
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
              color: appTheme.colorScheme.surface, // Dark card background
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // The Payoneer logo as an asset
                    Container(
                      height: 100, // Adjust the height as needed
                      decoration: BoxDecoration(
                        // Load the image from the network
                        image: selectedMethod['image'] != null
                            ? DecorationImage(
                                // ignore: prefer_interpolation_to_compose_strings
                                image: NetworkImage("https://v3.mash3div.com" +
                                    selectedMethod['image']),
                                fit: BoxFit.contain,
                              )
                            : const DecorationImage(
                                // Fallback image if the URL is not available
                                image: AssetImage('assets/images/PAYO.png'),
                                fit: BoxFit.fitHeight,
                              ),
                      ),
                    ),

                    const SizedBox(height: 20), // Space between image and text
                    Text(
                      'Deposit with Payoneer',
                      style: theme.textTheme.headline6
                          ?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(
                        height: 10), // Space between title and subtitle
                    Text(
                      'After clicking on "Deposit", your deposit will be sent to our team for verification. You will receive an email notification once your deposit has been approved.',
                      style: theme.textTheme.subtitle1
                          ?.copyWith(color: Colors.grey[400]),
                    ),
                    const SizedBox(
                        height: 20), // Space at the bottom of the card
                    // You can add more widgets here, such as buttons or icons, if needed
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: appTheme.colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deposit Instructions',
                      style: theme.textTheme.subtitle1
                          ?.copyWith(color: Colors.orange),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      selectedMethod['instructions'] ??
                          'No instructions provided.',
                      style: theme.textTheme.bodyText2
                          ?.copyWith(color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Minimum Deposit: ${selectedMethod['min_amount']} $currencyName\nMaximum Deposit: ${selectedMethod['max_amount']} $currencyName',
                      style: theme.textTheme.bodyText2
                          ?.copyWith(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            buildTextField(
              label: 'Deposit Amount',
              hint: 'Enter amount',
              prefixIcon: Icons.attach_money,
              onChanged: (value) =>
                  controller.depositAmount.value = double.tryParse(value) ?? 0,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ...buildCustomFields(),
            const SizedBox(height: 20),
            buildInfoRow('Flat Tax',
                '${selectedMethod['fixed_fee']} $currencyName', theme),
            buildInfoRow('Percentage Tax',
                '${selectedMethod['percentage_fee']}%', theme),
            Obx(() => buildInfoRow(
                  'To pay today ($currencyName)',
                  '${calculateTotalAmount(controller.depositAmount.value.toString(), selectedMethod)}',
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
                    primary: Colors.orange, // Your brand color for the button
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  onPressed: isAgreedToTOS.value
                      ? () async {
                          // Call the controller method to post the deposit
                          await controller.postFiatDepositMethod(
                            {
                              'amount':
                                  controller.depositAmount.value.toString(),
                              'wallet': walletInfo['id'].toString(),
                            },
                            selectedMethod['id'].toString(),
                          );
                        }
                      : null,
                  child: Center(
                    child: Text(
                      'Deposit',
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
    double depositAmount = double.tryParse(amount) ?? 0;
    double fixedFee = (method['fixed_fee'] as num).toDouble();
    double percentageFee = (method['percentage_fee'] as num).toDouble();
    double total =
        depositAmount + fixedFee + (depositAmount * (percentageFee / 100));
    return total.toStringAsFixed(2); // Formats the total to 2 decimal places
  }

  List<Widget> buildCustomFields() {
    List<Widget> customFieldWidgets = [];

    List<dynamic> customFields = selectedMethod['custom_fields'] ?? [];

    for (var field in customFields) {
      customFieldWidgets.add(
        buildTextField(
          label: field['title'],
          hint: 'Enter ${field['title']}',
          prefixIcon: Icons.input, // Change as needed
          onChanged: (value) {
            // Update the value in the controller
            controller.customFieldInputs[field['title']] = value;
          },
        ),
      );

      // Add spacing between fields
      customFieldWidgets.add(SizedBox(height: 10));
    }

    return customFieldWidgets;
  }
}
