import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String domain = const String.fromEnvironment('BASE_DOMAIN',
      defaultValue: 'v3.mash3div.com');

  // Build the full URL by prepending 'https://'
  String get baseDomainUrl => 'https://$domain/';

  String get baseUrl => 'https://$domain/api/auth/';
  Map<String, String?> tokens = {
    'access-token': null,
    'refresh-token': null,
    'csrf-token': null,
    'session-id': null,
  };
  Future<void> saveLoginTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('login_timestamp', timestamp);
  }

  Future<bool> shouldAutoLogout() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTimestamp = prefs.getInt('login_timestamp');
    if (loginTimestamp != null) {
      final loginDate = DateTime.fromMillisecondsSinceEpoch(loginTimestamp);
      final currentDate = DateTime.now();
      if (currentDate.difference(loginDate).inDays >= 12) {
        return true;
      }
    }
    return false;
  }

  Future<void> checkAndPerformAutoLogout() async {
    if (await shouldAutoLogout()) {
      await logout();
    }
  }

  Future<void> updateTokensFromHeaders(Map<String, String> headers) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var key in tokens.keys) {
      if (headers.containsKey(key)) {
        tokens[key] = headers[key];
        prefs.setString(key, headers[key]!);
      }
    }
  }

  Future<void> loadTokens() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var key in tokens.keys) {
      tokens[key] = prefs.getString(key);
    }
  }

  Future<String?> login(String email, String password,
      {bool trustDevice = false}) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}login'),
        headers: {
          'Content-Type': 'application/json',
          'client-platform': 'app',
          // Optionally, if your backend uses a header:
          // 'Trust-Device': trustDevice ? 'true' : 'false',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          // Assuming the backend expects a boolean flag within the body:
          'trust_device': trustDevice,
        }),
      );

      await updateTokensFromHeaders(response.headers);

      final Map<String, dynamic> responseJson = json.decode(response.body);

      if (response.statusCode == 200 && responseJson['status'] == 'success') {
        return null; // No error, login successful
      } else {
        return responseJson['error']['message'] ?? 'Unknown error';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<Map<String, dynamic>> register(
      String email, String password, String firstName, String lastName) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
        }),
      );

      await updateTokensFromHeaders(response.headers);

      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseBody['status'] == 'success') {
          return {'success': true};
        } else {
          return {
            'success': false,
            'message': responseBody['error']['message']
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Status code: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error occurred: $e'};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('login_timestamp'); // Clear the login timestamp
    // Clear all tokens
    for (var key in tokens.keys) {
      prefs.remove(key);
      tokens[key] = null;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}reset'),
        headers: {
          'Content-Type': 'application/json',
          // Add other headers if needed
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return true; // Successfully sent reset link
      } else {
        // You can throw an exception or return false
        throw Exception('Failed to send reset link');
      }
    } catch (e) {
      // print('Error occurred: $e');
      return false;
    }
  }
}
