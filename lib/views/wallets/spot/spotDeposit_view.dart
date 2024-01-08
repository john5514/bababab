import 'package:bitcuit/Controllers/wallets/spot%20wallet/spotDeposit_controller.dart';
import 'package:bitcuit/Style/styles.dart';
import 'package:bitcuit/services/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart'; // For Clipboard

class SpotDepositView extends StatelessWidget {
  final SpotDepositController controller =
      Get.put(SpotDepositController(Get.find<WalletService>()));

  SpotDepositView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController txHashController = TextEditingController();

    final textTheme = Theme.of(context)
        .textTheme
        .apply(
          fontFamily: 'Inter',
          bodyColor: Colors.white, // Make text color white for dark mode
          displayColor:
              Colors.white, // Make display text color white for dark mode
        )
        .copyWith(
          displayLarge: const TextStyle(
            fontSize: 26, // Increase font size
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: const TextStyle(
            fontSize: 16, // Increase font size
            color: Colors.white,
          ),
          titleMedium: const TextStyle(
            fontSize: 14, // Increase font size
            color: Color.fromRGBO(214, 214, 214, 1),
          ),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text('${Get.arguments['currency']} Deposit',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: appTheme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.isTrue) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Select Chain:",
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    _buildChainDropdown(controller, textTheme),
                    const SizedBox(height: 24),
                    if (controller.selectedChain.isNotEmpty) ...[
                      Text(
                        "Send Transaction:",
                        style: textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Deposit to the address:",
                        style: textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white54),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: SelectableText(
                                controller.depositAddress.value,
                                style: textTheme.bodyLarge,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.copy, color: appTheme.hintColor),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text: controller.depositAddress.value));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Address copied to clipboard!')),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Submit Transaction:",
                        style: textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      Text(
                          'After you have sent the transaction, please enter the transaction hash below.',
                          style: textTheme.titleMedium),
                      const SizedBox(height: 15),
                      TextField(
                        style: TextStyle(color: Colors.white),
                        controller: txHashController,
                        decoration: InputDecoration(
                          labelText: 'Transaction Hash',
                          labelStyle: textTheme.titleMedium,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      Lottie.asset(
                        'assets/animations/safe-deposit.json',
                        fit: BoxFit.cover,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 36), // Make button wide
                ),
                onPressed: () {
                  if (txHashController.text.isNotEmpty) {
                    // Prepare the deposit data with dynamic values
                    Map<String, dynamic> depositData = {
                      "wallet_id":
                          controller.selectedWallet.value['id'].toString(),
                      "trx": txHashController
                          .text, // transaction hash input by the user
                      "chain": controller.selectedChain.value,
                    };

                    // Call the validateAndShowDialog method with the dynamic data
                    controller.validateAndShowDialog(depositData);
                  } else {
                    // If the transaction hash is empty, notify the user to enter it
                    Get.snackbar('Error', 'Please enter the transaction hash.');
                  }
                },
                child: const Text("Submit",
                    style: TextStyle(fontSize: 18)), // Increased font size
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildChainDropdown(
      SpotDepositController controller, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F33),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.black26),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          value: controller.selectedChain.value.isNotEmpty
              ? controller.selectedChain.value
              : null,
          items: controller.chains
              .map((String chain) => DropdownMenuItem<String>(
                    value: chain,
                    child: Text(
                      chain,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Text color
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (newValue) {
            controller.setChain(newValue!);
          },
          buttonStyleData: ButtonStyleData(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: const Color(0xFF2C2F33), // Color of the dropdown button
            ),
          ),
          iconStyleData: const IconStyleData(
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.white, // Icon color
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            width: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: const Color(0xFF2C2F33), // Color of the dropdown menu
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 8.0),
          ),
        ),
      ),
    );
  }
}
