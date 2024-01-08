import 'package:bitcuit/Controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For date formatting

class TransactionItem extends StatelessWidget {
  final dynamic transaction;

  const TransactionItem({Key? key, required this.transaction})
      : super(key: key);

  // Helper function to format dates
  String formatDate(String dateString) {
    final dateTime = DateTime.parse(dateString);
    final formatter = DateFormat('MMM d, y');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final WalletController walletController = Get.find<WalletController>();

    String currencySymbol =
        walletController.getCurrencySymbol(transaction['wallet']['currency']);
    String formattedAmount = '$currencySymbol ${transaction['amount']}';

    return Padding(
      padding: const EdgeInsets.only(
          bottom:
              1), // This will ensure items are visually distinct but still share the same background
      child: Container(
        // Remove margin as the spacing is now handled by padding above
        padding: const EdgeInsets.all(8.0),
        // Remove decoration if you don't want individual background for items
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
            const Spacer(),
            Text(
              formattedAmount,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.right,
            ),
            const SizedBox(width: 8),
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
      ),
    );
  }
}
