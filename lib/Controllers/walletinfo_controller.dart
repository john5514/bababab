import 'package:get/get.dart';
import 'package:bicrypto/services/wallet_service.dart';

class WalletInfoController extends GetxController {
  var walletName = ''.obs;
  var walletBalance = 0.0.obs;
  var fiatDepositMethods = [].obs;
  var fiatWithdrawMethods = [].obs;
  var fiatDepositGateways = [].obs;
  var isLoading = false.obs;
  var selectedMethod = Rx<Map<String, dynamic>?>(null);

  final WalletService walletService = Get.find();
  void setWalletInfo(String name, double balance) {
    walletName.value = name;
    walletBalance.value = balance;
    fetchAllDepositOptions(); // Call the modified method here
  }

  @override
  void onInit() {
    super.onInit();
    fetchAllDepositOptions(); // Call the new method to fetch and combine deposit options
    fetchFiatWithdrawMethods();
  }

  Future<void> fetchAllDepositOptions() async {
    try {
      isLoading(true);

      // Fetch deposit methods and gateways
      var methods = await walletService.fetchFiatDepositMethods();
      var gateways = await walletService.fetchFiatDepositGateways();

      // Since methods support all currencies, no need to filter them
      var filteredMethods = methods;

      // Filter gateways based on the selected wallet's currency
      var filteredGateways = gateways.where((gateway) {
        return gateway['currencies'] != null &&
            gateway['currencies'].containsKey(walletName.value);
      }).toList();

      // Combine them into a single list
      var allOptions = [...filteredMethods, ...filteredGateways];

      fiatDepositMethods.assignAll(allOptions);
    } catch (e) {
      print("Error fetching deposit options: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchFiatDepositMethods() async {
    try {
      isLoading(true);
      var methods = await walletService.fetchFiatDepositMethods();
      fiatDepositMethods.assignAll(methods);
    } catch (e) {
      print("Error fetching fiat deposit methods: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchFiatWithdrawMethods() async {
    try {
      isLoading(true);
      var methods = await walletService.fetchFiatWithdrawMethods();
      fiatWithdrawMethods.assignAll(methods);
    } catch (e) {
      print("Error fetching fiat withdraw methods: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchFiatDepositGateways() async {
    try {
      isLoading(true);
      var gateways = await walletService.fetchFiatDepositGateways();
      fiatDepositGateways.assignAll(gateways);
    } catch (e) {
      print("Error fetching fiat deposit gateways: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> postFiatDeposit(Map<String, dynamic> payload) async {
    try {
      isLoading(true);
      await walletService.postFiatDeposit(payload);
    } catch (e) {
      print("Failed to post fiat deposit: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> postFiatWithdraw(Map<String, dynamic> payload) async {
    try {
      isLoading(true);
      await walletService.postFiatWithdraw(payload);
    } catch (e) {
      print("Failed to post fiat withdraw: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> postFiatDepositMethod(Map<String, dynamic> payload) async {
    try {
      isLoading(true);

      // Validate and add necessary parameters to the payload
      if (payload['amount'] == null || payload['transactionId'] == null) {
        throw Exception(
            'Invalid input: Amount and Transaction ID are required');
      }

      double amount = double.tryParse(payload['amount']) ?? 0;
      if (amount <= 0) {
        throw Exception('Invalid input: Amount should be a positive number');
      }

      // Retrieve the wallet identifier and method ID from the passed arguments
      String walletIdentifier = walletInfo[
          'walletIdentifier']; // Replace with the actual key for the wallet identifier in the walletInfo map
      String methodId = selectedMethod[
          'methodId']; // Replace with the actual key for the method ID in the selectedMethod map

      // Add the missing parameters to the payload
      payload['wallet'] = walletIdentifier;
      payload['methodId'] = methodId;
      payload['total'] = amount; // Assuming 'total' is the total deposit amount

      // Call the service method to post the fiat deposit
      await walletService.postFiatDepositMethod(payload);

      // Show success message
      Get.snackbar('Success', 'Deposit successful',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      // Log and show error message
      print("Failed to post fiat deposit method: $e");
      Get.snackbar('Error', 'Failed to perform deposit: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      // Reset loading state
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>> fetchFiatDepositMethodById(String id) async {
    try {
      isLoading(true);
      var method = await walletService.fetchFiatDepositMethodById(id);
      return method;
    } catch (e) {
      print("Failed to fetch fiat deposit method by id: $e");
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>> fetchFiatWithdrawMethodById(String id) async {
    try {
      isLoading(true);
      var method = await walletService.fetchFiatWithdrawMethodById(id);
      return method;
    } catch (e) {
      print("Failed to fetch fiat withdraw method by id: $e");
      rethrow;
    } finally {
      isLoading(false);
    }
  }
}
