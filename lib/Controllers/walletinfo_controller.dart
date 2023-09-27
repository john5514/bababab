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

      // Combine them into a single list
      var allOptions = [...methods, ...gateways];

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
      await walletService.postFiatDepositMethod(payload);
    } catch (e) {
      print("Failed to post fiat deposit method: $e");
    } finally {
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
