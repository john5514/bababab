import 'package:get/get.dart';
import 'package:bicrypto/services/wallet_service.dart'; // Import your WalletService

class WalletController extends GetxController {
  final WalletService walletService = WalletService();
  var fiatDepositMethods = [].obs;
  var fiatWithdrawMethods = [].obs;
  var fiatDepositGateways = [].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFiatDepositMethods();
    fetchFiatWithdrawMethods();
    fetchFiatDepositGateways();
  }

  void fetchFiatDepositMethods() async {
    try {
      isLoading(true);
      var response = await walletService.getFiatDepositMethods();
      if (response != null && response is Map && response.containsKey('data')) {
        fiatDepositMethods.assignAll(response['data']);
      }
    } finally {
      isLoading(false);
    }
  }

  void fetchFiatWithdrawMethods() async {
    try {
      isLoading(true);
      var response = await walletService.getFiatWithdrawMethods();
      if (response != null && response is Map && response.containsKey('data')) {
        fiatWithdrawMethods.assignAll(response['data']);
      }
    } finally {
      isLoading(false);
    }
  }

  void fetchFiatDepositGateways() async {
    try {
      isLoading(true);
      var response = await walletService.getFiatDepositGateways();
      if (response != null && response is Map && response.containsKey('data')) {
        fiatDepositGateways.assignAll(response['data']);
      }
    } finally {
      isLoading(false);
    }
  }
  // Add more methods to handle other functionalities
}
