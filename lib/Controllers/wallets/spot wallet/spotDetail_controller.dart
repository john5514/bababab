import 'package:bitcuit/services/wallet_service.dart';
import 'package:get/get.dart';

class SpotWalletDetailController extends GetxController {
  // Explicitly declare walletDetails as Map<String, dynamic>
  var walletDetails = <String, dynamic>{}.obs;
  var transactions = <dynamic>[].obs;
  final WalletService walletService;

  SpotWalletDetailController(this.walletService);

  void setWalletDetails(Map<String, dynamic> details) {
    walletDetails.assignAll(details);
    if (details.containsKey('transactions') &&
        details['transactions'] is List) {
      transactions.assignAll(details['transactions']);
    } else {
      // print("No transactions found in the wallet details");
    }
  }

  void fetchTransactions() async {
    String? walletType = walletDetails[
        'type']; // It should be 'type' instead of 'walletType' based on your service response
    if (walletType != null) {
      try {
        transactions.value = await walletService.fetchTransactions(walletType);
      } catch (e) {
        // Handle exception
        print("Error fetching transactions: $e");
      }
    } else {
      print("Wallet type is null");
      // Handle case when walletType is null
    }
  }
}
