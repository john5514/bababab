import 'package:bitcuit/Controllers/wallet_controller.dart';
import 'package:bitcuit/Controllers/walletinfo_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class StripeMethodWidget extends StatefulWidget {
  const StripeMethodWidget({super.key});

  @override
  _StripeMethodWidgetState createState() => _StripeMethodWidgetState();
}

class _StripeMethodWidgetState extends State<StripeMethodWidget> {
  final TextEditingController _amountController = TextEditingController();
  final RxBool _isAgreedToTOS = false.obs;
  final WalletInfoController controller = Get.find<WalletInfoController>();

  @override
  @override
  Widget build(BuildContext context) {
    final WalletController walletController = Get.find<WalletController>();
    String currencyCode = controller.walletInfo.value['currency'] ?? "USD";
    String currencySymbol = walletController.getCurrencySymbol(currencyCode);
    return Scaffold(
      appBar: AppBar(
        title: Text('$currencyCode Payment',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent, // Stripe-like blue color
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _amountController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: const TextStyle(color: Colors.white),
                  // Use the currencySymbol and currencyCode dynamically
                  prefix: Text('$currencySymbol ',
                      style: TextStyle(color: Colors.white)),
                  prefixIcon: const Icon(Icons.money, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Obx(() => CheckboxListTile(
                    title: const Text(
                      'I agree to the Terms Of Service',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    value: _isAgreedToTOS.value,
                    onChanged: (value) => _isAgreedToTOS.value = value!,
                    activeColor: Colors.blueAccent, // Stripe-like blue color
                    checkColor: Colors.white,
                  )),
              const SizedBox(height: 20),
              Obx(() => ElevatedButton.icon(
                    onPressed: _isAgreedToTOS.value
                        ? () async {
                            double amount =
                                double.parse(_amountController.text);
                            String currency =
                                controller.walletInfo.value['currency'] ??
                                    "USD"; // Correctly accessing currency
                            await controller.initiateStripePayment(
                                amount, currency);
                          }
                        : null,
                    icon: const Icon(Icons.account_balance_wallet,
                        color: Colors.white), // Wallet icon
                    label: _isAgreedToTOS.value
                        ? const Text('Pay with Stripe')
                        : const Text('Accept TOS to continue'),
                    style: ElevatedButton.styleFrom(
                      primary: _isAgreedToTOS.value
                          ? Colors.blueAccent
                          : Colors.grey, // Stripe-like blue color
                      onPrimary: Colors.white, // Text color
                      shape: RoundedRectangleBorder(
                        // Rounded corners
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 30),
                    ),
                  )),
              Lottie.asset(
                'assets/animations/stripe.json',
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
