import 'package:bitcuit/services/wallet_service.dart';
import 'package:get/get.dart';

class WalletSpotController extends GetxController {
  final WalletService walletService;
  var currencies = <dynamic>[].obs;
  var totalEstimatedBalance = 0.0.obs;
  var isLoading = true.obs;
  var isSearching = false.obs;
  var filteredCurrencies = <dynamic>[].obs;
  var hideZeroBalances = false.obs;
  var originalCurrencies = <dynamic>[].obs;

  WalletSpotController({required this.walletService});

  @override
  void onInit() {
    super.onInit();
    fetchCurrencies();
  }

  void setHideZeroBalances(bool value) {
    hideZeroBalances(value);
    updateFilteredCurrencies();
  }

  void updateFilteredCurrencies() {
    if (hideZeroBalances.isTrue) {
      var filteredList = originalCurrencies.where((currency) {
        var balance = currency['balance'] ?? 0.0;
        return balance > 0.0;
      }).toList();
      currencies.assignAll(filteredList);
    } else {
      currencies.assignAll(originalCurrencies);
    }
  }

  void filterCurrencies(String query) {
    var filteredList = currencies.where((currency) {
      var currencyName = currency['currency'].toLowerCase();
      var balance = currency['balance'] ?? 0.0;
      return currencyName.contains(query.toLowerCase()) &&
          (!hideZeroBalances.isTrue || balance > 0.0);
    }).toList();
    filteredCurrencies.assignAll(filteredList);
  }

  void enableSearch() {
    isSearching(true);
    filteredCurrencies.assignAll(currencies);
  }

  void clearSearch() {
    isSearching(false);
    filteredCurrencies.clear();
  }

  Future<void> refreshCurrencies() async {
    fetchCurrencies();
    // Any additional logic if needed during refresh
  }

  void fetchCurrencies() async {
    isLoading(true);
    try {
      var response = await walletService.getExchangeCurrencies();
      if (response['status'] == 'success') {
        var fetchedCurrencies = response['data']['result'];
        originalCurrencies.assignAll(fetchedCurrencies);
        updateFilteredCurrencies(); // To respect the hide zero balances setting
        await fetchBalancesForCurrencies();
      }
    } catch (e) {
      print('Error fetching currencies: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchBalancesForCurrencies() async {
    isLoading(true);
    try {
      List<dynamic> spotWallets = await walletService.fetchSpotWallets();
      Map<String, dynamic> spotWalletsMap = {
        for (var wallet in spotWallets) wallet['currency']: wallet['balance']
      };

      for (var currency in currencies) {
        var balance = spotWalletsMap[currency['currency']];
        currency['balance'] =
            balance is int ? balance.toDouble() : (balance ?? 0.0);
      }
      calculateTotalEstimatedBalance();
    } catch (e) {
      print('Error fetching spot wallets: $e');
    } finally {
      isLoading(false);
    }
  }

  void calculateTotalEstimatedBalance() {
    double total = 0.0;
    for (var currency in currencies) {
      var priceValue = currency['price'];
      double price =
          (priceValue is int) ? priceValue.toDouble() : (priceValue ?? 0.0);
      double amount = currency['balance'];

      total += price * amount;
    }
    totalEstimatedBalance.value = total;
    // print("Calculated total balance: $total");
  }

  void handleCurrencyTap(String currencyCode) async {
    isLoading(true);
    try {
      Map<String, dynamic> walletInfo =
          await walletService.fetchSpotWallet(currencyCode);
      print(walletInfo); // Add this to debug the structure of walletInfo

      if (walletInfo['status'] == 'success') {
        if (walletInfo['data']['result'] != null) {
          updateCurrencyWithWalletDetails(
              currencyCode, walletInfo['data']['result']);
        } else {
          // Attempt to create the wallet if it does not exist
          await walletService.postSpotWallet(currencyCode);
          // Wait for a couple of seconds to simulate delay (if necessary)
          // await Future.delayed(Duration(seconds: 2));
          // Try to fetch the wallet again after creation
          walletInfo = await walletService.fetchSpotWallet(currencyCode);
          if (walletInfo['status'] == 'success' &&
              walletInfo['data']['result'] != null) {
            updateCurrencyWithWalletDetails(
                currencyCode, walletInfo['data']['result']);
          } else {
            print("Failed to create or fetch wallet for $currencyCode");
            return; // Early return if failed to create or fetch
          }
        }
        // Navigate to the details page with the fetched wallet info
        Get.toNamed('/spot-wallet-detail',
            arguments: {...walletInfo['data']['result'], 'walletType': 'SPOT'});
      }
    } catch (e) {
      print('Error handling currency tap: $e');
    } finally {
      isLoading(false);
    }
  }

  void updateCurrencyWithWalletDetails(
      String currencyCode, dynamic walletDetails) {
    int index = currencies
        .indexWhere((currency) => currency['currency'] == currencyCode);
    if (index != -1) {
      // Ensure that the balance is cast to a double and is not null
      double balance = 0.0; // Default to 0.0 if balance is null
      if (walletDetails['balance'] != null) {
        balance = (walletDetails['balance'] is int)
            ? walletDetails['balance'].toDouble()
            : walletDetails['balance'];
      }
      currencies[index]['balance'] = balance;
      calculateTotalEstimatedBalance();
    }
    print("Updated currency: ${currencies[index]}");
  }
}
