import 'package:bicrypto/Controllers/home_controller.dart';
import 'package:bicrypto/Style/styles.dart';
import 'package:bicrypto/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:bicrypto/services/wallet_service.dart';
import 'package:url_launcher/url_launcher.dart';

class WalletInfoController extends GetxController {
  var walletName = ''.obs;
  var walletBalance = 0.0.obs;
  var fiatDepositMethods = [].obs;
  var fiatWithdrawMethods = [].obs;
  var fiatDepositGateways = [].obs;
  var depositAmount = 0.0.obs;
  var withdrawAmount = 0.0.obs;
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

    // Clear existing custom field inputs
    customFieldInputs.clear();

    // Store custom field data
    if (method.containsKey('custom_fields')) {
      for (var field in method['custom_fields']) {
        if (field['type'] == 'input' && field['required']) {
          customFieldInputs[field['title']] =
              ''; // Initialize with empty string
        }
      }
    }
  }

  void refreshDepositOptions() {
    fetchAllDepositOptions();
  }

// Method to initialize wallet information
  void initializeWalletInfo(
      Map<String, dynamic> walletInfo, Map<String, dynamic> selectedMethod) {
    String walletName = walletInfo['currency'] ?? '';
    double walletBalance = (walletInfo['balance'] is int)
        ? walletInfo['balance'].toDouble()
        : (walletInfo['balance'] ?? 0.0);

    // Set new wallet info
    setWalletInfo(walletName, walletBalance, walletInfo, selectedMethod);

    // Fetch new deposit options for the selected wallet
    fetchAllDepositOptions();
  }

  @override
  void onInit() {
    super.onInit();

    fetchAllDepositOptions(); // Call the new method to fetch and combine deposit options
    fetchFiatWithdrawMethods();
  }

  Future<void> initiateStripePayment(double amount, String currency) async {
    print(
        'initiateStripePayment called with amount: $amount, currency: $currency');

    try {
      if (selectedMethod.value == null) {
        throw 'No payment method selected';
      }
      print('Selected method details: ${selectedMethod.value}');

      double flatTax = selectedMethod.value?['fixed_fee']?.toDouble() ?? 0.0;
      double percentageTaxRate =
          (selectedMethod.value?['percentage_fee'] ?? 0) / 100;
      double percentageTax = amount * percentageTaxRate;

      // Now you're sending the original amount and tax separately
      final response = await WalletService(ApiService())
          .callStripeIpnEndpoint(amount, currency, flatTax + percentageTax);

      print('Response from callStripeIpnEndpoint: $response');

      if (response != null && response['clientSecret'] != null) {
        print('Received clientSecret: ${response['clientSecret']}');

        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: response['clientSecret'],
            merchantDisplayName: 'Your Business Name',
            style: ThemeMode.dark,
          ),
        );

        await Stripe.instance.presentPaymentSheet();
        print('Payment is successful');
        Get.snackbar('Success', 'Payment done successfully',
            snackPosition: SnackPosition.BOTTOM);
        Get.offAllNamed('/home');
        print('Navigating to Home Screen');
      } else {
        print('Failed to receive a valid response or clientSecret');
        Get.snackbar('Error', 'Failed to initialize Stripe Payment Sheet',
            snackPosition: SnackPosition.BOTTOM);
        throw 'Failed to initialize Stripe Payment Sheet';
      }
    } on StripeException catch (e) {
      print('Payment failed: ${e.error.localizedMessage}');
      Get.snackbar(
          'Error', 'Stripe payment failed: ${e.error.localizedMessage}',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      print('Error in initiateStripePayment: $e');
      Get.snackbar('Error', 'Stripe payment initiation failed: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> fetchAllDepositOptions() async {
    print(
        "Fetching deposit options for wallet: ${walletInfo.value['currency']}");

    try {
      isLoading(true);

      // Clear existing methods
      fiatDepositMethods.clear();

      // Fetch deposit methods and gateways
      var methods = await walletService.fetchFiatDepositMethods();
      var gateways = await walletService.fetchFiatDepositGateways();

      // Get the wallet's currency
      String walletCurrency = walletInfo.value['currency'] ?? '';

      // Filter out PayPal and gateways that do not support the wallet's currency
      var supportedGateways = gateways.where((gateway) {
        bool isNotPayPal = gateway['name'] != 'PayPal';
        bool supportsWalletCurrency =
            gateway['currencies']?.containsKey(walletCurrency) ?? false;
        return isNotPayPal && supportsWalletCurrency;
      }).toList();

      // Combine methods and supported gateways into a single list
      var allOptions = [...methods, ...supportedGateways];

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
      // print("Error fetching fiat withdraw methods: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchFiatDepositGateways() async {
    try {
      isLoading(true);
      var gateways = await walletService.fetchFiatDepositGateways();

      // Filtering out PayPal
      var filteredGateways =
          gateways.where((gateway) => gateway['name'] != 'PayPal').toList();

      fiatDepositGateways.assignAll(filteredGateways);
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

  Future<void> postFiatWithdrawalMethod(
      Map<String, dynamic> payload, String methodId) async {
    try {
      isLoading(true);

      String walletIdentifier = walletInfo.value['id']?.toString() ?? '';
      if (walletIdentifier.isEmpty || methodId.isEmpty) {
        throw Exception('Wallet identifier or method ID is missing');
      }

      // Construct and post the withdrawal payload
      constructAndPostWithdrawalPayload(payload, walletIdentifier, methodId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to perform withdrawal: $e',
          backgroundColor: Colors.grey[850],
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  Future<void> postFiatDepositMethod(
      Map<String, dynamic> payload, String methodId) async {
    try {
      isLoading(true);

      // Validate input and retrieve necessary parameters
      String walletIdentifier = walletInfo.value['id']?.toString() ?? '';

      if (walletIdentifier.isEmpty || methodId.isEmpty) {
        throw Exception('Wallet identifier or method ID is missing');
      }

      // Construct and post the deposit payload
      constructAndPostDepositPayload(payload, walletIdentifier, methodId);
    } catch (e) {
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
        String title = customFieldInputs.keys.first; // This line is changed
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
    // Use the 'uuid' from the walletInfo
    payload['wallet'] = walletInfo.value['uuid'].toString();

    // Parse the methodId as an integer
    payload['methodId'] = int.parse(methodId);

    double amount = double.tryParse(payload['amount']) ?? 0;
    double fixedFee =
        (selectedMethod.value?['fixed_fee'] as num?)?.toDouble() ?? 0;
    double percentageFee =
        (selectedMethod.value?['percentage_fee'] as num?)?.toDouble() ?? 0;

    // Correctly calculate the total
    payload['total'] = amount + fixedFee + (amount * (percentageFee / 100));

    // Add formatted custom_data to the payload
    payload['custom_data'] = formatCustomData();

    await walletService.postFiatDepositMethod(payload);
    Get.back();
//style snakbar for darktheme

    Get.snackbar(
      'Success',
      'Deposit request sent successfully.',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void constructAndPostWithdrawalPayload(Map<String, dynamic> payload,
      String walletIdentifier, String methodId) async {
    // Use the 'uuid' from the walletInfo
    payload['wallet'] = walletInfo.value['uuid'].toString();

    // Parse the methodId as an integer
    payload['methodId'] = int.parse(methodId);

    double amount = double.tryParse(payload['amount']) ?? 0;
    double fixedFee =
        (selectedMethod.value?['fixed_fee'] as num?)?.toDouble() ?? 0;
    double percentageFee =
        (selectedMethod.value?['percentage_fee'] as num?)?.toDouble() ?? 0;

    // Correctly calculate the total amount including fees
    double total = amount + fixedFee + (amount * (percentageFee / 100));

    // Check if the user's balance is sufficient
    if (walletBalance.value < total) {
      Get.snackbar(
        'Insufficient Balance',
        'You do not have enough balance to complete this withdrawal. Please check your balance and try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return; // Stop the execution if balance is insufficient
    }

    // Add formatted custom_data to the payload
    payload['custom_data'] = formatCustomData();

    try {
      await walletService.postFiatWithdraw(payload);
      Get.back();

      // Display success message
      Get.snackbar(
        'Success',
        'Withdrawal request sent successfully.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // Handle any errors during the withdrawal process
      Get.snackbar(
        'Error',
        'Failed to process withdrawal: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<Map<String, dynamic>> fetchFiatDepositMethodById(String id) async {
    try {
      isLoading(true);
      var method = await walletService.fetchFiatDepositMethodById(id);
      if (method != null) {
        setWalletInfo(
            walletName.value, walletBalance.value, walletInfo.value, method);
      }
      return method;
    } catch (e) {
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
      // print("Failed to fetch fiat withdraw method by id: $e");
      rethrow;
    } finally {
      isLoading(false);
    }
  }
}
