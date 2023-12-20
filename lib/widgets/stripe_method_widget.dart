import 'package:bicrypto/Controllers/walletinfo_controller.dart';
import 'package:bicrypto/services/api_service.dart';
import 'package:bicrypto/services/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeMethodWidget extends StatefulWidget {
  const StripeMethodWidget({super.key});

  @override
  _StripeMethodWidgetState createState() => _StripeMethodWidgetState();
}

class _StripeMethodWidgetState extends State<StripeMethodWidget> {
  final TextEditingController _amountController = TextEditingController();
  final RxBool _isAgreedToTOS = false.obs;
  final WalletInfoController controller = Get.find<WalletInfoController>();

  final ApiService apiService = Get.find<ApiService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              style: const TextStyle(color: Colors.orange),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefix: Text('USD '),
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
                  activeColor: Colors.orange,
                  checkColor: Colors.black,
                )),
            const SizedBox(height: 20),
            Obx(() => ElevatedButton(
                  onPressed: _isAgreedToTOS.value
                      ? () async {
                          double amount = double.parse(_amountController.text);
                          await controller.initiateStripePayment(amount, "USD");
                        }
                      : null,
                  // ignore: sort_child_properties_last
                  child: _isAgreedToTOS.value
                      ? const Text('Pay with Stripe')
                      : const Text('Accept TOS to continue'),
                  style: ElevatedButton.styleFrom(
                    primary: _isAgreedToTOS.value ? Colors.orange : Colors.grey,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
