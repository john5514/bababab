import 'dart:convert';
import 'package:bicrypto/services/api_service.dart';
import 'package:http_client_helper/http_client_helper.dart';

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

  Future<void> createWallet(String currency) async {
    await loadHeaders();

    print("Headers before API call: $headers");
    print("Attempting to create wallet with currency: $currency");

    final payload = jsonEncode({'currency': currency, 'type': 'FIAT'});
    print("Payload: $payload");

    final response = await HttpClientHelper.post(
      Uri.parse('${baseUrl}'),
      headers: headers,
      body: payload,
    );

    print("Response Status Code: ${response?.statusCode}");
    print("Response Headers: ${response?.headers}");
    print("Response Body: ${response?.body}");

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      var responseBody = jsonDecode(response!.body);
      if (responseBody['status'] == 'success') {
        print("Wallet created successfully");
      } else {
        print("Failed to create wallet: ${responseBody['error']['message']}");
        throw Exception('Failed to create wallet');
      }
    } else if (response?.statusCode == 400) {
      print("Bad Request - Session issue");
      // Handle session issue here
    } else if (response?.statusCode == 401) {
      print("Unauthorized - Invalid refresh token");
      // Handle reauthentication or token refresh here
    } else {
      print(
          "Failed to create wallet with status code: ${response?.statusCode}");
      print("Failure response: ${response?.body}");
      throw Exception('Failed to create wallet');
    }
  }

  Future<dynamic> getCurrencies() async {
    await loadHeaders();
    final response = await HttpClientHelper.get(
      Uri.parse('https://v3.mash3div.com/api/currencies'),
      headers: headers,
    );
    //print("API Response for Currencies: ${response?.body}");
    if (response?.statusCode == 200) {
      return jsonDecode(response!.body);
    } else {
      print(
          "Error fetching currencies: ${response?.statusCode}, ${response?.body}");
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
      print("WalletService - Fetched Wallet Balance: $balance");
      return balance;
    } else {
      print(
          "Failed to fetch wallet balance with status code: ${response?.statusCode}");
      print("Failure response: ${response?.body}");
      throw Exception('Failed to fetch wallet balance');
    }
  }

  Future<List<dynamic>> fetchFiatDepositMethods() async {
    await loadHeaders();
    final response = await HttpClientHelper.get(
      Uri.parse('${baseUrl}/fiat/deposit/methods'),
      headers: headers,
    );
    if (response?.statusCode == 200) {
      return jsonDecode(response!.body);
    } else {
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
      return jsonDecode(response!.body);
    } else {
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
      return jsonDecode(response!.body);
    } else {
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
    await loadHeaders();
    final response = await HttpClientHelper.post(
      Uri.parse('${baseUrl}/fiat/deposit/method'),
      headers: headers,
      body: jsonEncode(payload),
    );
    if (response?.statusCode != 200 && response?.statusCode != 201) {
      throw Exception('Failed to post fiat deposit method');
    }
  }

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

  Future<List<dynamic>> fetchWalletTransactions() async {
    await loadHeaders();
    final response = await HttpClientHelper.get(
      Uri.parse('${baseUrl}/transactions'),
      headers: headers,
    );
    if (response?.statusCode == 200) {
      return jsonDecode(response!.body);
    } else {
      throw Exception('Failed to fetch wallet transactions');
    }
  }

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
}
