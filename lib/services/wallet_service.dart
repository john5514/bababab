import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WalletService {
  final String baseUrl = "https://v3.mash3div.com/api/wallets/";
  String? cookie;

  Future<void> loadCookie() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cookie = prefs.getString('cookie');
  }

  Future<dynamic> getFiatDepositMethods() async {
    await loadCookie();
    final response = await http.get(
      Uri.parse('${baseUrl}fiat/deposit/methods'),
      headers: {'Cookie': cookie ?? ""},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load fiat deposit methods');
    }
  }

  Future<dynamic> getFiatDepositMethodById(String id) async {
    await loadCookie();
    final response = await http.get(
      Uri.parse('${baseUrl}fiat/deposit/methods/$id'),
      headers: {'Cookie': cookie ?? ""},
    );
    return jsonDecode(response.body);
  }

  Future<dynamic> getFiatDepositGateways() async {
    await loadCookie();
    final response = await http.get(
      Uri.parse('${baseUrl}fiat/deposit/gateways'),
      headers: {'Cookie': cookie ?? ""},
    );
    return jsonDecode(response.body);
  }

  Future<dynamic> getFiatDepositGatewayById(String id) async {
    await loadCookie();
    final response = await http.get(
      Uri.parse('${baseUrl}fiat/deposit/gateways/$id'),
      headers: {'Cookie': cookie ?? ""},
    );
    return jsonDecode(response.body);
  }

  Future<dynamic> getFiatWithdrawMethods() async {
    await loadCookie();
    final response = await http.get(
      Uri.parse('${baseUrl}fiat/withdraw/methods'),
      headers: {'Cookie': cookie ?? ""},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load fiat withdraw methods');
    }
  }

  Future<dynamic> getFiatWithdrawMethodById(String id) async {
    await loadCookie();
    final response = await http.get(
      Uri.parse('${baseUrl}fiat/withdraw/methods/$id'),
      headers: {'Cookie': cookie ?? ""},
    );
    return jsonDecode(response.body);
  }

  // Add more methods for other API endpoints here
  // For example, for POST requests, you can add methods like postFiatDeposit, postFiatWithdraw, etc.
}
