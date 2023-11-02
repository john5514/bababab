import 'package:bicrypto/services/wallet_service.dart';
import 'package:get/get.dart';

class WalletSpotController extends GetxController {
  final WalletService walletService;
  var currencies = <dynamic>[].obs;
  var totalEstimatedBalance = 0.0.obs;
  var isLoading = true.obs;
  var isSearching = false.obs;
  var filteredCurrencies = <dynamic>[].obs;
  var hideZeroBalances = false.obs;

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
    var listToFilter = isSearching.isTrue ? filteredCurrencies : currencies;
    var filteredList = listToFilter.where((currency) {
      var balance = currency['balance'] ?? 0.0;
      return !hideZeroBalances.isTrue || balance > 0.0;
    }).toList();
    if (isSearching.isTrue) {
      filteredCurrencies.assignAll(filteredList);
    } else {
      currencies.assignAll(filteredList);
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

  void fetchCurrencies() async {
    isLoading(true);
    try {
      var response = await walletService.getExchangeCurrencies();
      if (response['status'] == 'success') {
        currencies.value = response['data']['result'];
        await fetchBalancesForCurrencies(); // New method to fetch balances
      }
    } catch (e) {
      print('Error fetching currencies: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchBalancesForCurrencies() async {
    var fetchTasks = <Future>[];

    for (var currency in currencies) {
      var task = walletService
          .fetchSpotWallet(currency['currency'])
          .then((walletInfo) {
        if (walletInfo['status'] == 'success' &&
            walletInfo['data']['result'] != null) {
          updateCurrencyWithWalletDetails(
              currency['currency'], walletInfo['data']['result']);
        }
      }).catchError((e) {
        print('Error fetching wallet for currency ${currency['currency']}: $e');
      });

      fetchTasks.add(task);
    }

    // Wait for all the fetch tasks to complete
    await Future.wait(fetchTasks);
  }

  void calculateTotalEstimatedBalance() {
    double total = 0.0;
    for (var currency in currencies) {
      // Ensuring that price is a double
      var priceValue = currency['price'];
      double price =
          (priceValue is int) ? priceValue.toDouble() : (priceValue ?? 0.0);

      // Ensuring that balance is a double
      var balanceValue = currency['balance'];
      double amount = (balanceValue is int)
          ? balanceValue.toDouble()
          : (balanceValue ?? 0.0);

      total += price * amount;
    }
    totalEstimatedBalance.value = total;
    print("Calculated total balance: $total");
  }

  void handleCurrencyTap(String currencyCode) async {
    isLoading(true);
    try {
      Map<String, dynamic> walletInfo =
          await walletService.fetchSpotWallet(currencyCode);

      if (walletInfo['status'] == 'success') {
        if (walletInfo['data']['result'] != null) {
          updateCurrencyWithWalletDetails(
              currencyCode, walletInfo['data']['result']);
        } else {
          await walletService.postSpotWallet(currencyCode);
          await Future.delayed(Duration(seconds: 2));
          walletInfo = await walletService.fetchSpotWallet(currencyCode);
          if (walletInfo['status'] == 'success') {
            updateCurrencyWithWalletDetails(
                currencyCode, walletInfo['data']['result']);
          } else {
            print("Failed to create or fetch wallet for $currencyCode");
          }
        }
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
      currencies[index]['uuid'] = walletDetails['uuid'];
      currencies[index]['balance'] = walletDetails['balance'];
      // Recalculate total balance whenever a wallet's details are updated
      calculateTotalEstimatedBalance();
    }
    print("Updated currency: ${currencies[index]}");
  }
}
