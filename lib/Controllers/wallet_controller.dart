import 'package:bicrypto/services/api_service.dart';
import 'package:get/get.dart';
import 'package:bicrypto/services/wallet_service.dart'; // Import your WalletService

class WalletController extends GetxController {
  final WalletService walletService = WalletService(ApiService());

  var fiatDepositMethods = [].obs;
  var fiatWithdrawMethods = [].obs;
  var fiatDepositGateways = [].obs;
  var isLoading = false.obs;
  var fiatBalance = 0.0.obs;
  var fiatTransactions = [].obs;
  var currencies = [].obs;
  var selectedCurrency = ''.obs;
  var walletBalance = 0.0.obs;
  var fiatWalletInfo = <dynamic>[].obs; // Updated to List<dynamic>

  @override
  void onInit() {
    super.onInit();
    fetchFiatBalance();
    fetchFiatTransactions();
    fetchWalletBalance();
    fetchCurrencies();
    fetchFiatWalletInfo();
  }

  Future<void> fetchFiatWalletInfo() async {
    try {
      isLoading(true);
      var response =
          await walletService.fetchUserWallets(); // Keep the type as var

      if (response is List<dynamic>) {
        fiatWalletInfo.assignAll(response);
      } else {
        print("Unexpected response format: $response");
      }
    } catch (e) {
      print("Error fetching fiat wallet info: $e");
    } finally {
      isLoading(false);
    }
  }

// Fetch balance
  Future<void> fetchFiatBalance() async {
    try {
      isLoading(true);
      // Fetch balance from API (replace with actual API call)
      fiatBalance.value = 1000.0; // Example balance
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchFiatTransactions() async {
    try {
      isLoading(true);
      // Fetch transactions from API (replace with actual API call)
      fiatTransactions.assignAll([
        {"date": "2023-09-01", "amount": 100},
        {"date": "2023-09-02", "amount": 200},
        // ... (more transactions)
      ]);
    } finally {
      isLoading(false);
    }
  }

  Future<void> createWallet(String currency) async {
    print(
        "Attempting to create wallet with currency: $currency"); // Debugging line
    try {
      isLoading(true);
      await walletService.createWallet(currency);
      // Refresh the wallet data after creating a new wallet
      fetchFiatBalance();
      fetchFiatTransactions();
      // Show a success message
      Get.snackbar('Success', 'Wallet created successfully',
          snackPosition: SnackPosition.BOTTOM);
      print("Wallet created successfully"); // Debugging line
    } catch (e) {
      // Handle error
      print("Error creating wallet: $e"); // Debugging line
      // Show an error message
      Get.snackbar('Error', 'Failed to create wallet',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchWalletBalance() async {
    try {
      isLoading(true);
      double balance = await walletService.fetchWalletBalance();
      walletBalance.value = balance;
      print("Fetched Wallet Balance: $balance");
    } catch (e) {
      print("Error fetching wallet balance: $e");
    } finally {
      isLoading(false);
    }
  }

  void fetchCurrencies() async {
    try {
      isLoading(true);
      var response = await walletService.getCurrencies();
      print("Fetched Currencies: $response"); // Add this line
      if (response != null && response is Map && response.containsKey('data')) {
        var data = response['data'];
        if (data is Map && data.containsKey('result')) {
          var result = data['result'];
          if (result is List) {
            currencies.assignAll(result);
          }
        }
      }
    } finally {
      isLoading(false);
    }
  }
}
