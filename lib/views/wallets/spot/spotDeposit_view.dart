import 'package:bicrypto/Controllers/wallets/spot%20wallet/spotDeposit_controller.dart';
import 'package:bicrypto/services/wallet_service.dart';
import 'package:bicrypto/widgets/wallet/deposit_instructions_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/services.dart'; // For Clipboard

class SpotDepositView extends StatelessWidget {
  final SpotDepositController controller =
      Get.put(SpotDepositController(Get.find<WalletService>()));

  SpotDepositView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController txHashController = TextEditingController();

    // Safely access 'currency' from arguments
    final walletName =
        (Get.arguments as Map<String, dynamic>?)?['currency'] ?? 'Wallet';

    return Scaffold(
      appBar: AppBar(
        title: Text('$walletName Deposit'),
      ),
      body: Obx(() {
        if (controller.isLoading.isTrue) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown to select chain
              _buildChainDropdown(controller),
              if (controller.selectedChain.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  "Send Transaction:",
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(height: 8),
                Text("Deposit to the address:"),
                SelectableText(
                  controller.depositAddress.value,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: controller.depositAddress.value));
                    // Show a snackbar or toast message after copying
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Address copied to clipboard!')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text("Copy"),
                ),
                const SizedBox(height: 16),
                Text(
                  "Submit Transaction:",
                  style: Theme.of(context).textTheme.headline6,
                ),
                TextField(
                  controller: txHashController,
                  decoration: const InputDecoration(
                    labelText: 'Transaction Hash',
                    helperText:
                        'After you have sent the transaction, please enter the transaction hash below.',
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
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
                      Get.snackbar(
                          'Error', 'Please enter the transaction hash.');
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildChainDropdown(SpotDepositController controller) {
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
