import 'package:bicrypto/Controllers/wallets/spot%20wallet/spotWithdraw_controller.dart';
import 'package:bicrypto/Style/styles.dart';
import 'package:bicrypto/services/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class SpotWithdrawView extends StatelessWidget {
  final SpotWithdrawController controller =
      Get.put(SpotWithdrawController(Get.find<WalletService>()));

  SpotWithdrawView({super.key});

  @override
  Widget build(BuildContext context) {
    final addressController = TextEditingController();
    final amountController = TextEditingController();

    // Make sure to retrieve the currency from the arguments
    final currency = Get.arguments['currency'] as String;

    final textTheme = Theme.of(context).textTheme.apply(
          fontFamily: 'Inter',
          bodyColor: Colors.white, // Make text color white for dark mode
          displayColor:
              Colors.white, // Make display text color white for dark mode
        );

    return Scaffold(
      appBar: AppBar(
        title: Text('$currency Withdraw',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: appTheme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.isTrue) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select Chain:",
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              _buildChainDropdown(controller, textTheme),
              const SizedBox(height: 24),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                    labelText: 'Withdrawal Address',
                    labelStyle: textTheme.bodyText1),
                style: textTheme.bodyText1,
                onChanged: (value) =>
                    controller.withdrawalAddress.value = value,
              ),
              SizedBox(height: 20),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                    labelText: 'Amount', labelStyle: textTheme.bodyText1),
                style: textTheme.bodyText1,
                onChanged: (value) => controller.withdrawalAmount.value = value,
              ),
              SizedBox(height: 20),
              Obx(() => Text('Fee: ${controller.withdrawFee}',
                  style: textTheme.bodyText1)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.initiateWithdrawal,
                child: Text('Withdraw', style: textTheme.button),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildChainDropdown(
      SpotWithdrawController controller, TextTheme textTheme) {
    return Obx(() => Container(
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
                  color:
                      const Color(0xFF2C2F33), // Color of the dropdown button
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
        ));
  }
}
