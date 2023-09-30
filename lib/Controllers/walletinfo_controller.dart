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
  var walletInfo = <String, dynamic>{}.obs;
  final customFieldInputs = <String, dynamic>{}.obs;

  final WalletService walletService = Get.find();
  void setWalletInfo(String name, double balance, Map<String, dynamic> info,
      Map<String, dynamic> method) {
    walletName.value = name;
    walletBalance.value = balance;
    walletInfo.value = info; // set walletInfo
    selectedMethod.value = method; // set selectedMethod

    // Debugging: Print walletInfo and selectedMethod
    print("Debugging: walletInfo = $info");
    print("Debugging: selectedMethod = $method");

    fetchAllDepositOptions(); // Call the modified method here
  }

// Method to initialize wallet information
  void initializeWalletInfo(
      Map<String, dynamic> walletInfo, Map<String, dynamic> selectedMethod) {
    String walletName = walletInfo['currency'] ?? '';
    double walletBalance = (walletInfo['balance'] is int)
        ? walletInfo['balance'].toDouble()
        : (walletInfo['balance'] ?? 0.0);

    setWalletInfo(walletName, walletBalance, walletInfo, selectedMethod);
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

      // Validate input and retrieve necessary parameters
      String walletIdentifier = walletInfo.value['id']?.toString() ?? '';
      String methodId = selectedMethod.value?['id']?.toString() ?? '';

// Debugging: Print the values of walletIdentifier and methodId
      print("Debugging: walletIdentifier = $walletIdentifier");
      print("Debugging: methodId = $methodId");

      if (walletIdentifier.isEmpty || methodId.isEmpty) {
        throw Exception('Wallet identifier or method ID is missing');
      }

      // Construct and post the deposit payload
      constructAndPostDepositPayload(payload, walletIdentifier, methodId);
    } catch (e) {
      print("Failed to post fiat deposit method: $e");
      Get.snackbar('Error', 'Failed to perform deposit: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  void validateInput(Map<String, dynamic> payload) {
    if (payload['amount'] == null || payload['transactionId'] == null) {
      throw Exception('Invalid input: Amount and Transaction ID are required');
    }

    double amount = double.tryParse(payload['amount']) ?? 0;
    if (amount <= 0) {
      throw Exception('Invalid input: Amount should be a positive number');
    }
  }

  List<Map<String, dynamic>> formatCustomData() {
    List<Map<String, dynamic>> result = [];

    List<dynamic>? customFields = selectedMethod.value?['custom_fields'];

    if (customFields != null) {
      for (var field in customFields) {
        String type = field['type'];
        String title = field['title'];
        dynamic value = customFieldInputs[title];

        result.add({
          'type': type,
          'title': title,
          'value': value,
        });
      }
    }

    return result;
  }

  void constructAndPostDepositPayload(Map<String, dynamic> payload,
      String walletIdentifier, String methodId) async {
    payload['wallet'] = walletIdentifier.toString();
    payload['methodId'] = methodId.toString();
    payload['total'] = double.tryParse(payload['amount']) ?? 0;

    // Add formatted custom_data to the payload
    payload['custom_data'] = formatCustomData();
    print("Final Payload: $payload");

    await walletService.postFiatDepositMethod(payload);
    Get.snackbar('Success', 'Deposit successful',
        snackPosition: SnackPosition.BOTTOM);
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
