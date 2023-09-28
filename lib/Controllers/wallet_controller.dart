import 'package:bicrypto/services/api_service.dart';
import 'package:get/get.dart';
import 'package:bicrypto/services/wallet_service.dart';

class WeeklySummary {
  final String week;
  double income;
  double expense;

  WeeklySummary(this.week, this.income, this.expense);
}

class WalletController extends GetxController {
  final WalletService walletService = WalletService(ApiService());
  int dayOfYear(DateTime date) {
    return date.difference(DateTime(date.year, 1, 1)).inDays + 1;
  }

  var isLoading = false.obs;
  var fiatBalance = 0.0.obs;
  var fiatTransactions = [].obs;
  var currencies = [].obs;
  var selectedCurrency = ''.obs;
  var walletBalance = 0.0.obs;
  var fiatWalletInfo = <dynamic>[].obs;
  var weeklySummaries = <WeeklySummary>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchFiatBalance();
    fetchFiatTransactions();
    fetchWalletBalance();
    fetchCurrencies();
    fetchFiatWalletInfo();
    fetchWeeklySummary();
  }

  double calculateIncome() {
    // Calculate and return the total income based on the transaction data
    //print("Fiat Transactions: $fiatTransactions");
    return fiatTransactions
        .where((trx) => trx['amount'] > 0)
        .fold(0.0, (sum, trx) => sum + trx['amount']);
  }

  double calculateExpense() {
    // Calculate and return the total expense based on the transaction data
    return fiatTransactions
        .where((trx) => trx['amount'] < 0)
        .fold(0.0, (sum, trx) => sum + trx['amount']);
  }

  Future<void> fetchWeeklySummary() async {
    try {
      isLoading(true);
      Map<String, dynamic> weeklySummary =
          await walletService.getWeeklySummary();

      // Create a WeeklySummary object from the obtained summary
      WeeklySummary lastWeekSummary = WeeklySummary(
        'Last 7 Days',
        weeklySummary['totalAmount'] > 0 ? weeklySummary['totalAmount'] : 0,
        weeklySummary['totalAmount'] < 0
            ? weeklySummary['totalAmount'].abs()
            : 0,
      );

      // Clear the previous summaries and add the new summary
      weeklySummaries.clear();
      weeklySummaries.add(lastWeekSummary);
      // print("Weekly Summaries: $weeklySummaries");
    } catch (e) {
      // print("Error fetching weekly summary: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchFiatWalletInfo() async {
    try {
      isLoading(true);
      var response =
          await walletService.fetchUserWallets(); // Keep the type as var

      if (response is List<dynamic>) {
        // Filter out only fiat wallets
        var fiatWallets =
            response.where((wallet) => wallet['type'] == 'FIAT').toList();
        fiatWalletInfo.assignAll(fiatWallets);
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
      // Fetch transactions from API
      List<dynamic> transactions =
          await walletService.fetchWalletTransactions();
      fiatTransactions.assignAll(transactions);
    } catch (e) {
      print("Error fetching fiat transactions: $e");
      // Handle the error appropriately, e.g., show an error message to the user
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
      await fetchFiatWalletInfo(); // Refresh the list of wallets
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
