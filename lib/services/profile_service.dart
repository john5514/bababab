import 'dart:convert';
import 'package:bicrypto/services/api_service.dart';
import 'package:http/http.dart' as http;

class ProfileService {
  final String _baseUrl = "https://v3.mash3div.com/api/auth/profile";
  final ApiService apiService;

  ProfileService(this.apiService);

  Map<String, String> headers = {};

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

  Future<Map<String, dynamic>?> getProfile() async {
    await loadHeaders();
    final Uri url = Uri.parse(_baseUrl);
    final response = await http.get(url, headers: headers);

    print('GET Profile Request Headers: $headers'); // Debug print for headers
    print('GET Profile Request to URL: $url'); // Debug print for requested URL

    if (response.statusCode == 200) {
      print(
          'Profile Data Fetched Successfully: ${response.body}'); // Debug print for success response
      return jsonDecode(response.body);
    } else {
      print(
          'Failed to load profile. Status code: ${response.statusCode}'); // Debug print for status code on failure
      print(
          'Error Response Body: ${response.body}'); // Debug print for error response body
      return null; // or throw an exception based on your error handling policies
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    await loadHeaders();
    final Uri url = Uri.parse(_baseUrl);
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(profileData),
    );

    if (response.statusCode == 200) {
      return true; // Profile updated successfully
    } else {
      print('Failed to update profile. Status code: ${response.statusCode}');
      print('Error: ${response.body}');
      return false; // or throw an exception based on your error handling policies
    }
  }
}
