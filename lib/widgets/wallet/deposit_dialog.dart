import 'package:bicrypto/Controllers/wallets/spot%20wallet/spotDeposit_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Dialog content with timer and cancel option
// Helper function to format remaining time
String formatTime(int seconds) {
  int minutes = seconds ~/ 60;
  int remainingSeconds = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}

// Dialog content with timer and cancel option
class DepositInstructionsDialog extends StatelessWidget {
  final Map<String, dynamic> walletDetails;
  final SpotDepositController controller = Get.find();

  DepositInstructionsDialog({Key? key, required this.walletDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[850],
      title: const Text(
        "DEPOSIT INSTRUCTIONS",
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Your transaction is currently pending and is waiting to be verified. Please refrain from closing the modal or refreshing the page until the verification process is complete. This may take a few moments, but rest assured that we are working diligently to ensure that your transaction is processed as quickly and securely as possible. Thank you for your patience and cooperation.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[300]),
              ),
              const SizedBox(height: 20),
              Text(
                "Remaining time: ${formatTime(controller.remainingTime.value)}",
                style: TextStyle(color: Colors.orange[300]),
              ),
            ],
          )),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            // Cancel the deposit
            controller.cancelDeposit();
            Navigator.of(context).pop();
          },
          child: Text('Cancel Deposit'),
        ),
      ],
    );
  }
}
