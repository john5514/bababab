import 'package:bicrypto/Controllers/wallets/spot%20wallet/spotDeposit_controller.dart';
import 'package:bicrypto/services/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class SpotDepositView extends StatelessWidget {
  final SpotDepositController controller =
      Get.put(SpotDepositController(Get.find<WalletService>()));

  SpotDepositView({super.key});

  @override
  Widget build(BuildContext context) {
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

        // If chains are loaded, show the DropdownButton2
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Chain",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white), // For dark theme
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2F33), // Color of the dropdown
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Colors.black26, // Border color
                  ),
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
                        color: const Color(
                            0xFF2C2F33), // Color of the dropdown button
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
                        color: const Color(
                            0xFF2C2F33), // Color of the dropdown menu
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                  ),
                ),
              ),
              // ... Other UI elements
            ],
          ),
        );
      }),
    );
  }
}
