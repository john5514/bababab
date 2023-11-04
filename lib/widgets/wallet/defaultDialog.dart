import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

void showDepositInstructions(BuildContext context) {
  Alert(
    context: context,
    type: AlertType.none,
    title: "DEPOSIT INSTRUCTIONS",
    style: AlertStyle(
      backgroundColor: Colors.grey[850],
      titleStyle: const TextStyle(
        fontFamily: 'Inter',
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      descStyle: TextStyle(
        fontFamily: 'Inter',
        color: Colors.grey[300],
        fontSize: 14,
      ),
      alertPadding: const EdgeInsets.all(15),
      titleTextAlign: TextAlign.center,
    ),
    content: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Divider(color: Colors.grey[600]),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Time Limit",
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.orange[300],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            "You have 30 minutes to complete the deposit after selecting a chain.",
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Select Chain",
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.orange[300],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            "Choose the desired blockchain network for your deposit.",
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Send Funds",
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.orange[300],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            "You will receive a deposit address and a QR code. Send your funds to this address.",
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Enter Transaction Hash",
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.orange[300],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            "After sending the funds, enter the transaction hash for verification.",
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Verification",
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.orange[300],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            "The transaction will be verified within 30 minutes. Please do not refresh or leave the page.",
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.grey[300],
            ),
          ),
        ],
      ),
    ),
    buttons: [
      DialogButton(
        onPressed: () => Get.toNamed('/spot-deposit'),
        color: Colors.blueAccent,
        child: const Text(
          "NEXT",
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      )
    ],
  ).show();
}
