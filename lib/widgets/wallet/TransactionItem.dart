import 'package:bicrypto/Controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For date formatting

class TransactionItem extends StatelessWidget {
  final dynamic transaction;

  TransactionItem({Key? key, required this.transaction}) : super(key: key);

  // Helper function to format dates
  String formatDate(String dateString) {
    final dateTime = DateTime.parse(dateString);
    final formatter = DateFormat('MMM d, y');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    // Ensure that WalletController is available and get it
    final WalletController walletController = Get.find<WalletController>();

    // Use getCurrencySymbol from WalletController
    String currencySymbol =
        walletController.getCurrencySymbol(transaction['wallet']['currency']);
    String formattedAmount = '$currencySymbol ${transaction['amount']}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black54, // Change as per your color theme
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.account_balance_wallet, color: Colors.teal),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction[
                      'type'], // Directly using the type from transaction data
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  formatDate(transaction['created_at']),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Spacer(), // Use a spacer to push the following text to the right
          Text(
            formattedAmount,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.right,
          ),
          const SizedBox(width: 8), // Give some space before the status
          Text(
            transaction['status'],
            style: TextStyle(
              color: transaction['status'] == 'PENDING'
                  ? Colors.orange
                  : Colors.green,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.visibility, color: Colors.white),
            onPressed: () {
              // Implement view details functionality
            },
          ),
        ],
      ),
    );
  }
}
