import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://v3.mash3div.com/api/auth/";

  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

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

  Future<bool> register(
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

      print("API Response: ${response.body}"); // Debugging line

      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseBody['status'] == 'success') {
          return true;
        } else {
          print(
              "Failed to register, Message: ${responseBody['error']['message']}"); // Debugging line
          return false;
        }
      } else {
        print(
            "Failed to register, Status code: ${response.statusCode}"); // Debugging line
        return false;
      }
    } catch (e) {
      print('Error occurred: $e');
      return false;
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
