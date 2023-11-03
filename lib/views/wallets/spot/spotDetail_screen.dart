import 'package:bicrypto/Controllers/wallets/spot%20wallet/spotDetail_controller.dart';
import 'package:bicrypto/Style/styles.dart';
import 'package:bicrypto/services/wallet_service.dart';
import 'package:bicrypto/views/wallets/spot/SpotTransferView.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SpotWalletDetailView extends StatelessWidget {
  final SpotWalletDetailController controller =
      Get.put(SpotWalletDetailController(Get.find<WalletService>()));

  SpotWalletDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure arguments are not null before using them
    final Map<dynamic, dynamic>? arguments = Get.arguments;
    if (arguments == null) {
      // Handle the case where arguments are null
      // You could show an error or redirect the user back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Error',
          'No wallet details provided.',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.back(); // Go back to the previous screen if no arguments are passed
      });
      return Scaffold(
          body:
              Container()); // Return an empty container to avoid rendering errors
    }

    final Map<String, dynamic> walletDetails =
        Map<String, dynamic>.from(arguments);
    controller.setWalletDetails(walletDetails);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet Details"),
        backgroundColor: appTheme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Obx(() => Text(
                "Balance: ${controller.walletDetails['balance'].toStringAsFixed(4)}",
                style: const TextStyle(fontSize: 20, color: Colors.white),
              )),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: Icon(Icons.swap_horiz), // Replace with your transfer icon
            label: Text("Transfer"),
            onPressed: () {
              Get.to(() => SpotTransferView()); // Navigate to the transfer page
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.blue, // Button color
              onPrimary: Colors.white, // Text color
            ),
          ),
          const SizedBox(height: 20),
          Expanded(child: _buildTransactions(controller.transactions)),
        ],
      ),
    );
  }

  Widget _buildTransactions(List<dynamic> transactions) {
    return Container(
      constraints: const BoxConstraints(
          maxHeight:
              300), // Ensuring the container takes up only half the screen
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(101, 75, 75, 75),
            Color.fromARGB(101, 95, 95, 95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transactions',
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildTransactionHeaders(),
          const Divider(color: Colors.white38),
          const SizedBox(height: 10),
          Expanded(
            child: transactions.isEmpty
                ? const Text(
                    'No transactions yet.',
                    style: TextStyle(
                        color: Colors.white, fontStyle: FontStyle.italic),
                  )
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      var transaction = transactions[index];
                      return _buildTransactionRow(transaction);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHeaders() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Date',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            child: Text(
              'Amount',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Status',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(Map<String, dynamic> transaction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Text(
              DateFormat('MMM d, yyyy')
                  .format(DateTime.parse(transaction['created_at'])),
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            child: Text(
              "${transaction['amount'].toString()}",
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              transaction['status'] ?? 'Unknown',
              style: TextStyle(
                color: transaction['status'] == 'COMPLETED'
                    ? Colors.green
                    : Colors.red,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
