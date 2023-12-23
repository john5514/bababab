import 'package:bicrypto/Controllers/walletinfo_controller.dart';
import 'package:bicrypto/services/api_service.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:bicrypto/services/wallet_service.dart';

class WeeklySummary {
  final String week;
  double income;
  double expense;

  WeeklySummary(this.week, this.income, this.expense);
}

class WalletController extends GetxController {
  final WalletService walletService;
  WalletController(this.walletService);
  int dayOfYear(DateTime date) {
    return date.difference(DateTime(date.year, 1, 1)).inDays + 1;
  }

  var isLoading = false.obs;
  var fiatBalance = 0.0.obs;
  var fiatTransactions = [].obs;
  var fiatWalletTransactions = <dynamic>[].obs;
  var fiatWalletsEnabled = false.obs;

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
    fetchFiatWalletTransactions();

    fetchWalletBalance();
    fetchCurrencies();
    fetchFiatWalletInfo();
    fetchWeeklySummary();
    fetchSettings();
  }

  String getCurrencySymbol(String currencyCode) {
    // Mapping of currency codes to correct symbols
    Map<String, String> correctSymbols = {
      'ANG': 'ƒ',
      'AWG': 'ƒ',
      'AFN': '؋',
      'AZN': '₼',
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'AUD': 'A',
      'BRL': 'R',
      'CAD': 'C',
      'CHF': 'CHF',
      'DKK': 'kr',
      'HKD': 'HK',
      'INR': '₹',
      'MXN': 'MX',
      'MYR': 'RM',
      'NOK': 'kr',
      'NZD': 'NZ',
      'PLN': 'zł',
      'SEK': 'kr',
      'SGD': 'S',
    };

    var currency = currencies.firstWhere((c) => c['code'] == currencyCode,
        orElse: () => null);

    // If the currency code is in the mapping, return the correct symbol, otherwise return the symbol from the API
    if (currency != null) {
      String apiSymbol = currency['symbol'];
      return correctSymbols.containsKey(currencyCode)
          ? correctSymbols[currencyCode]!
          : apiSymbol;
    } else {
      return currencyCode;
    }
  }

  Map<String, double> calculateBalanceForCurrency(String currency) {
    double income = fiatWalletTransactions
        .where((trx) =>
            trx['type'] == 'DEPOSIT' && trx['wallet']['currency'] == currency)
        .fold(0.0, (sum, trx) => sum + trx['amount']);

    List<dynamic> incomeTransactions = fiatWalletTransactions
        .where((trx) =>
            trx['type'] == 'DEPOSIT' && trx['wallet']['currency'] == currency)
        .toList();

    // Calculate expense and create the expenseTransactions list
    double expense = fiatWalletTransactions
        .where((trx) =>
            trx['type'] != 'DEPOSIT' && trx['wallet']['currency'] == currency)
        .fold(0.0, (sum, trx) => sum + trx['amount']);

    List<dynamic> expenseTransactions = fiatWalletTransactions
        .where((trx) =>
            trx['type'] != 'DEPOSIT' && trx['wallet']['currency'] == currency)
        .toList();

    return {
      'income': income,
      'expense': expense,
    };
  }

  List<String> extractUniqueCurrencies() {
    Set<String> currencies = Set<String>();
    for (var trx in fiatTransactions) {
      currencies.add(trx['wallet']['currency']);
    }
    return currencies.toList();
  }

  void calculateBalancesForAllCurrencies() {
    List<String> uniqueCurrencies = extractUniqueCurrencies();
    for (String currency in uniqueCurrencies) {
      Map<String, double> balance = calculateBalanceForCurrency(currency);
      // print(
      //     "Balance for $currency: ${balance['income']} - ${balance['expense']}");
    }
  }

  void fetchSettings() async {
    isLoading(true);
    try {
      // Call the fetchSettings method from the ApiService
      var settingsResponse = await walletService.apiService.fetchSettings();
      if (settingsResponse.containsKey('data') &&
          settingsResponse['data'].containsKey('result')) {
        List<dynamic> results = settingsResponse['data']['result'];
        var fiatWalletSetting = results.firstWhere(
          (setting) => setting['key'] == 'fiat_wallets',
          orElse: () => null,
        );

        if (fiatWalletSetting != null) {
          fiatWalletsEnabled(fiatWalletSetting['value'] == 'Enabled');
          print('Fiat Wallets setting is: ${fiatWalletSetting['value']}');
        } else {
          print('Fiat Wallets setting not found');
        }
      } else {
        print('Settings response format is not as expected');
      }
    } catch (e) {
      // Handle any errors here
      print('Error fetching settings: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchWeeklySummary({String? currency}) async {
    try {
      SchedulerBinding.instance?.addPostFrameCallback((_) {
        isLoading(true);
      });

      // Fetch the weekly summary from the service using the updated method
      List<WeeklySummary> weeklyData =
          await walletService.getWeeklySummary(currency: currency);

      // Clear the previous summaries
      weeklySummaries.clear();

      // Update the list with the fetched data
      weeklySummaries.addAll(weeklyData);
    } catch (e) {
      // Handle the error by printing it for now
      // print("Error in fetchWeeklySummary: $e");
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
        // print("Unexpected response format: $response");
      }
    } catch (e) {
      // print("Error fetching fiat wallet info: $e");
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

  Future<void> createWallet(String currency) async {
    // print(
    //     "Attempting to create wallet with currency: $currency"); // Debugging line
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
      // print("Wallet created successfully"); // Debugging line
    } catch (e) {
      // Handle error
      // print("Error creating wallet: $e"); // Debugging line
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
      // print("Fetched Wallet Balance: $balance");
    } catch (e) {
      // print("Error fetching wallet balance: $e");
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

  void fetchFiatTransactions() async {
    try {
      isLoading(true);
      // Assuming 'fiat' is the type for fiat transactions
      List<dynamic> transactionsList =
          await walletService.fetchTransactions('FIAT');
      fiatTransactions.assignAll(transactionsList);
    } catch (e) {
      print("Error fetching fiat transactions: $e");
      fiatTransactions.assignAll([]);
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchFiatWalletTransactions() async {
    try {
      isLoading(true);
      var transactions = await walletService.fetchFiatWalletTransactions();

      fiatWalletTransactions.value = transactions;
      // Printing fetched transactions
    } catch (e) {
      // Handle the exception
      print("Error fetching fiat wallet transactions: $e");
    } finally {
      isLoading(false);
    }
  }
}
