import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WalletService {
  final String baseUrl = "https://v3.mash3div.com/api/wallets/";
  String? cookie;

  Map<String, String> headers = {};

  Future<void> loadHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cookie = prefs.getString('cookie');
    // Load other tokens
    String? sessionId = prefs.getString('session-id');
    String? csrfToken = prefs.getString('csrf-token');
    String? accessToken = prefs.getString('access-token');
    String? refreshToken = prefs.getString('refresh-token');

    // Construct headers
    headers = {
      'Authorization': 'Bearer ' + (accessToken ?? ""),
      'Cookie': cookie ?? "",
      'session-id': sessionId ?? "",
      'csrf-token': csrfToken ?? "",
      'refresh-token': refreshToken ?? "",
      'Content-Type': 'application/json',
      'sid': sessionId ?? "", // Add this line
    };
  }

  Future<dynamic> getFiatDepositMethods() async {
    await loadHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}fiat/deposit/methods'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load fiat deposit methods');
    }
  }

  Future<dynamic> getFiatDepositMethodById(String id) async {
    await loadHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}fiat/deposit/methods/$id'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  Future<dynamic> getFiatDepositGateways() async {
    await loadHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}fiat/deposit/gateways'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  Future<dynamic> getFiatDepositGatewayById(String id) async {
    await loadHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}fiat/deposit/gateways/$id'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  Future<dynamic> getFiatWithdrawMethods() async {
    await loadHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}fiat/withdraw/methods'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load fiat withdraw methods');
    }
  }

  Future<dynamic> getFiatWithdrawMethodById(String id) async {
    await loadHeaders();
    final response = await http.get(
      Uri.parse('${baseUrl}fiat/withdraw/methods/$id'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  Future<void> createWallet(String currency) async {
    await loadHeaders();

    // Place the print statement here
    print("Headers before API call: $headers");

    print("Cookie: $cookie");
    print("Attempting to create wallet with currency: $currency");

    final payload = jsonEncode({
      'currency': currency,
      'type': 'someType' // Replace with the actual type
    });
    print("Payload: $payload");

    final response = await http.post(
      Uri.parse('https://v3.mash3div.com/api/wallets'),
      headers: {
        'Cookie': cookie ?? "",
        'Content-Type': 'application/json',
      },
      body: payload,
    );

    print("Response Status Code: ${response.statusCode}");
    print("Response Headers: ${response.headers}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      var responseBody = jsonDecode(response.body);
      if (responseBody['status'] == 'success') {
        print("Wallet created successfully");
      } else {
        print("Failed to create wallet: ${responseBody['error']['message']}");
        throw Exception('Failed to create wallet');
      }
    } else if (response.statusCode == 400) {
      print("Bad Request - Session issue");
      // Handle session issue here
    } else if (response.statusCode == 401) {
      print("Unauthorized - Invalid refresh token");
      // Handle reauthentication or token refresh here
    } else {
      print("Failed to create wallet with status code: ${response.statusCode}");
      print("Failure response: ${response.body}");
      throw Exception('Failed to create wallet');
    }
  }

  Future<dynamic> getCurrencies() async {
    await loadHeaders();
    final response = await http.get(
      Uri.parse('https://v3.mash3div.com/api/currencies'), // Updated endpoint
      headers: headers,
    );
    print("API Response for Currencies: ${response.body}"); // Add this line
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print(
          "Error fetching currencies: ${response.statusCode}, ${response.body}");
      throw Exception('Failed to load currencies');
    }
  }

  // Add more methods for other API endpoints here
  // For example, for POST requests, you can add methods like postFiatDeposit, postFiatWithdraw, etc.
}
