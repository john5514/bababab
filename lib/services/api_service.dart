import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = "https://v3.mash3div.com/api/auth/";
  String? cookie;

  Future<void> updateCookie(http.Response response) async {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      cookie = (index == -1) ? rawCookie : rawCookie.substring(0, index);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('cookie', cookie!);
    }
  }

  Future<void> loadCookie() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cookie = prefs.getString('cookie');
  }

  Future<String?> login(String email, String password) async {
    await loadCookie();
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}login'),
        headers: {'Content-Type': 'application/json', 'Cookie': cookie ?? ""},
        body: jsonEncode({'email': email, 'password': password}),
      );

      await updateCookie(response);

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

  Future<void> logout() async {
    cookie = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('cookie');
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
      print('Error occurred: $e');
      return false;
    }
  }
}
