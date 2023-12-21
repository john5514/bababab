import 'package:bicrypto/Controllers/wallets/spot%20wallet/spot_transfer_controller.dart.dart';
import 'package:bicrypto/style/styles.dart';
import 'package:bicrypto/services/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SpotTransferView extends StatelessWidget {
  final SpotTransferController controller =
      Get.put(SpotTransferController(Get.find<WalletService>()));
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _uuidController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  SpotTransferView({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Theme data to adjust colors for dark mode
    ThemeData theme = Theme.of(context);
    var inputTextColor = theme.textTheme.bodyText1?.color ?? Colors.white;
    var borderColor = theme.hintColor;
    var focusedBorderColor = theme.colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Funds'),
        backgroundColor: appTheme
            .scaffoldBackgroundColor, // Make sure this is set for dark mode
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Lottie.asset(
                'assets/animations/online-banking.json',
                fit: BoxFit.fitHeight,
              ),
              TextFormField(
                controller: _uuidController,
                style: TextStyle(color: inputTextColor),
                decoration: InputDecoration(
                  labelText: 'Target User UUID',
                  labelStyle: TextStyle(color: inputTextColor),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: focusedBorderColor),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter target user UUID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: inputTextColor),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: inputTextColor),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: focusedBorderColor),
                  ),
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
              SizedBox(height: 24.0),
              ElevatedButton.icon(
                icon: Icon(Icons.send),
                label: Obx(() => controller.isLoading.value
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(inputTextColor),
                        ),
                      )
                    : Text('Transfer')),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    FocusScope.of(context).unfocus(); // Hide the keyboard
                    controller.transferFunds(
                      'currency', // Actual currency value should be provided here
                      'SPOT',
                      _amountController.text,
                      _uuidController.text,
                    );
                  }
                },
              ),
              Obx(() {
                if (controller.transferResult.isNotEmpty) {
                  return Text(
                    'Transfer Status: ${controller.transferResult['status']}',
                    style: TextStyle(color: inputTextColor),
                  );
                }
                return SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }
}
