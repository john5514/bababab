import 'dart:convert';
import 'package:bicrypto/Controllers/wallet_controller.dart';
import 'package:bicrypto/services/api_service.dart';
import 'package:http_client_helper/http_client_helper.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class WalletService {
  final String baseUrl = "https://v3.mash3div.com/api/wallets";
  final ApiService apiService;

  WalletService(this.apiService);

  Future<void> loadHeaders() async {
    await apiService.loadTokens(); // Load tokens from ApiService
    headers = {
      'access-token': apiService.tokens['access-token'] ?? "",
      'session-id': apiService.tokens['session-id'] ?? "",
      'csrf-token': apiService.tokens['csrf-token'] ?? "",
      'refresh-token': apiService.tokens['refresh-token'] ?? "",
      'Content-Type': 'application/json',
      'Client-Platform': 'app',
    };
  }

  Map<String, String> headers = {};

  Future<dynamic> callStripeIpnEndpoint(
      double amount, String currency, double taxAmount) async {
    try {
      await loadHeaders();

      final Uri url = Uri.parse('https://v3.mash3div.com/api/ipn/stripe/');
      final response = await HttpClientHelper.post(
        url,
        headers: headers,
        body: jsonEncode({
          'amount': (amount * 100)
              .toInt(), // Convert to integer since Stripe expects amount in smallest currency unit
          'currency': currency.toLowerCase(),
          'taxAmount': (taxAmount * 100).toInt(), // Convert to integer
        }),
      );
      print('Loaded Headers: $headers');

      print(
          'Response Status Code from Stripe IPN============: ${response?.statusCode}');
      print('Response Body from Stripe IPN===============: ${response?.body}');

      if (response?.statusCode == 200) {
        return jsonDecode(response!.body);
      } else {
        throw Exception('Failed to call Stripe IPN endpoint');
      }
    } catch (e) {
      print('Error in callStripeIpnEndpoint: $e');
      throw e; // Re-throwing the error so that any external caller can handle it if needed.
    }
  }

  Future<void> createWallet(String currency) async {
    await loadHeaders();

    // print("Headers before API call: $headers");
    // print("Attempting to create wallet with currency: $currency");

    final payload = jsonEncode({'currency': currency, 'type': 'FIAT'});
    // print("Payload: $payload");

    final response = await HttpClientHelper.post(
      Uri.parse('${baseUrl}'),
      headers: headers,
      body: payload,
    );

    // print("Response Status Code: ${response?.statusCode}");
    // print("Response Headers: ${response?.headers}");
    // print("Response Body: ${response?.body}");

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      var responseBody = jsonDecode(response!.body);
      if (responseBody['status'] == 'success') {
        // print("Wallet created successfully");
      } else {
        // print("Failed to create wallet: ${responseBody['error']['message']}");
        throw Exception('Failed to create wallet');
      }
    } else if (response?.statusCode == 400) {
      // print("Bad Request - Session issue");
      // Handle session issue here
    } else if (response?.statusCode == 401) {
      // print("Unauthorized - Invalid refresh token");
      // Handle reauthentication or token refresh here
    } else {
      // print(
      //     "Failed to create wallet with status code: ${response?.statusCode}");
      // print("Failure response: ${response?.body}");
      throw Exception('Failed to create wallet');
    }
  }

  Future<dynamic> getCurrencies() async {
    await loadHeaders();
    final response = await HttpClientHelper.get(
      Uri.parse('https://v3.mash3div.com/api/currencies'),
      headers: headers,
    );
    // print(
    //     "API Response for Currencies: ${response?.body}"); // Log the API response
    if (response?.statusCode == 200) {
      return jsonDecode(response!.body);
    } else {
      // print(
      //     "Error fetching currencies: ${response?.statusCode}, ${response?.body}");
      throw Exception('Failed to load currencies');
    }
  }

  Future<dynamic> getExchangeCurrencies() async {
    await loadHeaders();
    final response = await HttpClientHelper.get(
      Uri.parse(
          'https://v3.mash3div.com/api/exchange/currencies'), // Updated URL
      headers: headers,
    );

    if (response?.statusCode == 200) {
      return jsonDecode(response!.body);
    } else {
      throw Exception('Failed to load currencies');
    }
  }

  Future<double> fetchWalletBalance() async {
    await loadHeaders();
    final response = await HttpClientHelper.get(
      Uri.parse('${baseUrl}/balance'),
      headers: headers,
    );
    if (response?.statusCode == 200) {
      var responseBody = jsonDecode(response!.body);
      double balance = responseBody['balance'] ?? 0.0;
      // print("WalletService - Fetched Wallet Balance: $balance");
      return balance;
    } else {
      // print(
      //     "Failed to fetch wallet balance with status code: ${response?.statusCode}");
      // print("Failure response: ${response?.body}");
      throw Exception('Failed to fetch wallet balance');
    }
  }

  Future<List<dynamic>> fetchSpotWallets() async {
    await loadHeaders();
    final response = await HttpClientHelper.get(
      Uri.parse('${baseUrl}/user'),
      headers: headers,
    );
    if (response?.statusCode == 200) {
      var responseBody = jsonDecode(response!.body);
      print(
          'Wallet Service Response: $responseBody'); // Add this line to print response

      List<dynamic> allWallets = responseBody['data']['result'];
      List<dynamic> spotWallets =
          allWallets.where((wallet) => wallet['type'] == 'SPOT').toList();
      // Uncomment the line below to print the SPOT wallets
      // print("WalletService - Fetched SPOT Wallets: $spotWallets");
      return spotWallets;
    } else {
      // Uncomment the lines below to print the error details
      // print("Failed to fetch wallets with status code: ${response?.statusCode}");
      // print("Failure response: ${response?.body}");
      throw Exception('Failed to fetch wallets');
    }
  }

  Future<Map<String, dynamic>> verifySpotDeposit(String transactionId) async {
    await loadHeaders();
    final response = await HttpClientHelper.get(
      Uri.parse('${baseUrl}/spot/deposit/verify/$transactionId'),
      headers: headers,
    );
    if (response?.statusCode == 200) {
      return jsonDecode(response!.body);
    } else {
      throw Exception(
          'Failed to verify deposit. Status code: ${response?.statusCode}');
    }
  }

  Future<Map<String, dynamic>> cancelSpotDeposit(String transactionId) async {
    await loadHeaders();
    final response = await HttpClientHelper.delete(
      Uri.parse('${baseUrl}/spot/deposit/cancel/$transactionId'),
      headers: headers,
    );
    if (response?.statusCode == 200) {
      return jsonDecode(response!.body);
    } else {
      throw Exception(
          'Failed to cancel deposit. Status code: ${response?.statusCode}');
    }
  }

  Future<Map<String, dynamic>> transfer({
    required String currency,
    required String type,
    required String amount,
    required String to,
  }) async {
    await loadHeaders(); // Make sure headers are loaded with tokens

    final Uri transferUri = Uri.parse('${baseUrl}/transfer');
    final response = await http.post(
      transferUri,
      headers: headers,
      body: jsonEncode({
        'currency': currency,
        'type': type,
        'amount': amount,
        'to': to,
      }),
    );

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      return json.decode(response.body);
    } else {
      // If the call to the server was not successful, handle errors
      var responseBody = json.decode(response.body);
      var errorMessage = 'Failed to transfer funds.';
      if (responseBody is Map<String, dynamic> &&
          responseBody['error'] != null) {
        errorMessage = responseBody['error']['message'] ?? errorMessage;
      }
      throw Exception(errorMessage);
    }
  }

////////////////////////// Fiat Wallet /////////////////////////
  Future<List<dynamic>> fetchFiatDepositMethods() async {
    await loadHeaders();
    final response = await HttpClientHelper.get(
      Uri.parse('${baseUrl}/fiat/deposit/methods'),
      headers: headers,
    );
    if (response?.statusCode == 200) {
      // print(
      //     "Fetched Deposit Methods: ${response?.body}"); // Print the fetched data
      var decodedResponse = jsonDecode(response!.body);
      if (decodedResponse['status'] == 'success') {
        return decodedResponse['data']
            ['result']; // Return the list of deposit methods
      } else {
        throw Exception('Failed to fetch fiat deposit methods');
      }
    } else {
      // print(
      //     "Failed to fetch deposit methods. Status Code: ${response?.statusCode}"); // Print the status code
      throw Exception('Failed to fetch fiat deposit methods');
    }
  }

  Future<Map<String, dynamic>> fetchFiatDepositMethodById(String id) async {
    await loadHeaders();
    final response = await HttpClientHelper.get(
      Uri.parse('${baseUrl}/fiat/deposit/methods/$id'),
      headers: headers,
    );
    if (response?.statusCode == 200) {
      return jsonDecode(response!.body);
    } else {
      throw Exception('Failed to fetch fiat deposit method by id');
    }
  }

  Future<List<dynamic>> fetchFiatDepositGateways() async {
    await loadHeaders();
    final response = await HttpClientHelper.get(
      Uri.parse('${baseUrl}/fiat/deposit/gateways'),
      headers: headers,
    );
    if (response?.statusCode == 200) {
      // print("Fetched Deposit Gateways: ${response?.body}");
      var decodedResponse = jsonDecode(response!.body);
      if (decodedResponse['status'] == 'success') {
        return decodedResponse['data']
            ['result']; // Extract the list of gateways
      } else {
        throw Exception('Failed to fetch fiat deposit gateways');
      }
    } else {
      // print(
      //     "Failed to fetch deposit gateways. Status Code: ${response?.statusCode}");
      throw Exception('Failed to fetch fiat deposit gateways');
    }
  }

  Future<List<dynamic>> fetchFiatWithdrawMethods() async {
    await loadHeaders();
    final response = await HttpClientHelper.get(
      Uri.parse('${baseUrl}/fiat/withdraw/methods'),
      headers: headers,
    );
    if (response?.statusCode == 200) {
      // print("Fetched Withdraw Methods: ${response?.body}");
      var decodedResponse = jsonDecode(response!.body);
      if (decodedResponse['status'] == 'success') {
        return decodedResponse['data']['result'];
      } else {
        throw Exception('Failed to fetch fiat withdraw methods');
      }
    } else {
      // print(
      //     "Failed to fetch withdraw methods. Status Code: ${response?.statusCode}");
      throw Exception('Failed to fetch fiat withdraw methods');
    }
  }

  Future<Map<String, dynamic>> fetchFiatWithdrawMethodById(String id) async {
    await loadHeaders();
    final response = await HttpClientHelper.get(
      Uri.parse('${baseUrl}/fiat/withdraw/methods/$id'),
      headers: headers,
    );
    if (response?.statusCode == 200) {
      return jsonDecode(response!.body);
    } else {
      throw Exception('Failed to fetch fiat withdraw method by id');
    }
  }

  Future<void> postFiatDeposit(Map<String, dynamic> payload) async {
    await loadHeaders();
    final response = await HttpClientHelper.post(
      Uri.parse('${baseUrl}/fiat/deposit'),
      headers: headers,
      body: jsonEncode(payload),
    );
    if (response?.statusCode != 200 && response?.statusCode != 201) {
      throw Exception('Failed to post fiat deposit');
    }
  }

  Future<void> postFiatWithdraw(Map<String, dynamic> payload) async {
    await loadHeaders();
    final response = await HttpClientHelper.post(
      Uri.parse('${baseUrl}/fiat/withdraw'),
      headers: headers,
      body: jsonEncode(payload),
    );
    if (response?.statusCode != 200 && response?.statusCode != 201) {
      throw Exception('Failed to post fiat withdraw');
    }
  }

  Future<void> postFiatDepositMethod(Map<String, dynamic> payload) async {
    try {
      await loadHeaders();

      // Print the payload for debugging
      // print("Debugging: Sending payload = $payload");

      final response = await HttpClientHelper.post(
        Uri.parse('${baseUrl}/fiat/deposit/method'),
        headers: headers,
        body: jsonEncode(payload),
      );
      if (response?.statusCode != 200 && response?.statusCode != 201) {
        // print('Response Body: ${response?.body}');
        throw Exception('Failed to post fiat deposit method');
      } else {
        // print('Deposit Method Successful. Response Body: ${response?.body}');
      }
    } catch (e) {
      // print("Error in postFiatDepositMethod: $e");
      rethrow;
    }
  }

///////////////////////// Spot Wallet /////////////////////////
  Future<Map<String, dynamic>> fetchSpotWallet(String currency) async {
    await loadHeaders();
    final response = await HttpClientHelper.get(
      Uri.parse('${baseUrl}/spot/$currency'),
      headers: headers,
    );
    if (response?.statusCode == 200) {
      return jsonDecode(response!.body);
    } else {
      throw Exception('Failed to fetch spot wallet');
    }
  }

  Future<void> postSpotWallet(String currency) async {
    await loadHeaders();
    final response = await HttpClientHelper.post(
      Uri.parse('${baseUrl}/spot/$currency'),
      headers: headers,
      body: jsonEncode({'currency': currency}), // Assuming the API needs this
    );
    if (response?.statusCode != 200 && response?.statusCode != 201) {
      throw Exception('Failed to post spot wallet');
    }
  }

  Future<List<dynamic>> fetchSpotTransactions(String trx) async {
    await loadHeaders();
    final response = await HttpClientHelper.get(
      Uri.parse('${baseUrl}/spot/transactions/$trx'),
      headers: headers,
    );
    if (response?.statusCode == 200) {
      return jsonDecode(response!.body);
    } else {
      throw Exception('Failed to fetch spot transactions');
    }
  }

  Future<void> postSpotDeposit(Map<String, dynamic> payload) async {
    await loadHeaders();
    final response = await HttpClientHelper.post(
      Uri.parse('${baseUrl}/spot/deposit'),
      headers: headers,
      body: jsonEncode(payload),
    );
    if (response?.statusCode != 200 && response?.statusCode != 201) {
      throw Exception('Failed to post spot deposit');
    }
  }

  Future<void> postSpotDepositVerify(String trx) async {
    await loadHeaders();
    final response = await HttpClientHelper.post(
      Uri.parse('${baseUrl}/spot/deposit/verify/$trx'),
      headers: headers,
    );
    if (response?.statusCode != 200 && response?.statusCode != 201) {
      throw Exception('Failed to verify spot deposit');
    }
  }

  Future<void> postSpotWithdraw(Map<String, dynamic> payload) async {
    await loadHeaders();
    final response = await HttpClientHelper.post(
      Uri.parse('${baseUrl}/spot/withdraw'),
      headers: headers,
      body: jsonEncode(payload),
    );
    if (response?.statusCode != 200 && response?.statusCode != 201) {
      throw Exception('Failed to post spot withdraw');
    }
  }

  Future<List<dynamic>> fetchAllWallets() async {
    await loadHeaders();
    final response = await HttpClientHelper.get(
      Uri.parse('${baseUrl}'),
      headers: headers,
    );
    if (response?.statusCode == 200) {
      return jsonDecode(response!.body);
    } else {
      throw Exception('Failed to fetch all wallets');
    }
  }

  Future<void> createStoreWallet(Map<String, dynamic> payload) async {
    await loadHeaders();
    final response = await HttpClientHelper.post(
      Uri.parse('${baseUrl}'),
      headers: headers,
      body: jsonEncode(payload),
    );
    if (response?.statusCode != 200 && response?.statusCode != 201) {
      throw Exception('Failed to create store wallet');
    }
  }

  Future<List<dynamic>> fetchUserWallets() async {
    await loadHeaders();
    final response = await HttpClientHelper.get(
      Uri.parse('${baseUrl}/user'),
      headers: headers,
    );
    if (response?.statusCode == 200) {
      var responseBody = jsonDecode(response!.body);

      if (responseBody is Map) {
        var data = responseBody['data'];
        if (data is Map) {
          var result = data['result'];
          if (result is List) {
            return result;
          }
        }
      }
      throw Exception('Unexpected response format');
    } else {
      throw Exception('Failed to fetch user wallets');
    }
  }

  // Future<double> fetchWalletBalance() async {
  //   await loadHeaders();
  //   final response = await HttpClientHelper.get(
  //     Uri.parse('${baseUrl}/balance'),
  //     headers: headers,
  //   );
  //   if (response?.statusCode == 200) {
  //     var responseBody = jsonDecode(response!.body);
  //     double balance = responseBody['balance'] ?? 0.0;
  //     return balance;
  //   } else {
  //     throw Exception('Failed to fetch wallet balance');
  //   }
  // }

  Future<Map<String, dynamic>> fetchWalletTransactionById(
      String referenceId) async {
    await loadHeaders();
    final response = await HttpClientHelper.get(
      Uri.parse('${baseUrl}/transactions/$referenceId'),
      headers: headers,
    );
    if (response?.statusCode == 200) {
      return jsonDecode(response!.body);
    } else {
      throw Exception('Failed to fetch wallet transaction by id');
    }
  }

  Future<List<dynamic>> fetchTransactions(String walletType) async {
    await loadHeaders();
    final response = await HttpClientHelper.get(
      Uri.parse('${baseUrl}/transactions?walletType=$walletType'),
      headers: headers,
    );

    if (response?.statusCode == 200) {
      var decodedResponse = jsonDecode(response!.body);
      if (decodedResponse['status'] == 'success') {
        return decodedResponse['data'][
            'result']; // Assuming the structure is similar to your previous method
      } else {
        throw Exception(
            'Failed to fetch transactions: ${decodedResponse['message']}');
      }
    } else {
      throw Exception(
          'Failed to fetch transactions. Status Code: ${response?.statusCode}');
    }
  }

  Future<List<dynamic>> fetchWalletTransactionsForUserID35() async {
    await loadHeaders();
    final response = await HttpClientHelper.get(
      Uri.parse('${baseUrl}/transactions'),
      headers: headers,
    );

    if (response?.statusCode == 200) {
      var decodedResponse = jsonDecode(response!.body);

      // Extract the result field from the decoded response and filter for User ID 35
      List<dynamic> transactions = decodedResponse['data']['result'];
      List<dynamic> userTransactions = transactions
          .where((transaction) => transaction['user_id'] == 35)
          .toList();

      // Debug: Print each transaction's user ID to confirm
      for (var transaction in userTransactions) {
        // print("Filtered Transaction User ID: ${transaction['user_id']}");
      }

      return userTransactions;
    } else {
      throw Exception('Failed to fetch wallet transactions');
    }
  }

  Future<List<WeeklySummary>> getWeeklySummary({String? currency}) async {
    final List<dynamic> allTransactions =
        await fetchWalletTransactionsForUserID35();

    // Filter transactions for the specified currency if provided
    final List<dynamic> transactions = (currency == null)
        ? allTransactions
        : allTransactions
            .where((trx) => trx['wallet']['currency'] == currency)
            .toList();

    // Initialize a list to store the summaries
    List<WeeklySummary> weeklyData = [];

    for (int i = 6; i >= 0; i--) {
      DateTime targetDate = DateTime.now().subtract(Duration(days: i));
      List<dynamic> dailyTransactions = transactions.where((transaction) {
        String? createdAt = transaction['created_at'];
        if (createdAt != null) {
          DateTime transactionDate =
              DateFormat('yyyy-MM-ddTHH:mm:ss').parse(createdAt);
          return transactionDate.year == targetDate.year &&
              transactionDate.month == targetDate.month &&
              transactionDate.day == targetDate.day;
        }
        return false;
      }).toList();

      List<dynamic> deposits = dailyTransactions
          .where((transaction) => transaction['type'] == 'DEPOSIT')
          .toList();
      List<dynamic> withdrawals = dailyTransactions
          .where((transaction) => transaction['type'] == 'WITHDRAWAL')
          .toList();

      double totalDeposits = deposits.fold(
          0, (sum, transaction) => sum + (transaction['amount'] ?? 0.0));
      double totalWithdrawals = withdrawals.fold(
          0, (sum, transaction) => sum + (transaction['amount'] ?? 0.0));

      // Add the day's summary to the list
      weeklyData.add(WeeklySummary(
          DateFormat('E').format(targetDate), totalDeposits, totalWithdrawals));
    }

    return weeklyData;
  }
}
