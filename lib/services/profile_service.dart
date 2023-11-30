import 'dart:convert';
import 'dart:io';
import 'package:bicrypto/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

class ProfileService {
  final String baseUrl = const String.fromEnvironment('BASE_DOMAIN',
      defaultValue: 'https://v3.mash3div.com');
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
    final Uri url = Uri.parse('${baseUrl}/api/auth/profile');
    final response = await http.get(url, headers: headers);

    // print('GET Profile Request Headers: $headers'); // Debug print for headers
    // print('GET Profile Request to URL: $url'); // Debug print for requested URL

    if (response.statusCode == 200) {
      // print(
      //     'Profile Data Fetched Successfully: ${response.body}'); // Debug print for success response
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
    final Uri url = Uri.parse('${baseUrl}/api/auth/profile');

    Map<String, dynamic> wrappedProfileData = {"user": profileData};

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(wrappedProfileData),
    );

    print('PUT Profile Request Headers: $headers');
    print('PUT Profile Request to URL: $url');
    print('PUT Profile Request Body: ${jsonEncode(wrappedProfileData)}');

    if (response.statusCode == 200) {
      print('Profile Updated Successfully: ${response.body}');
      return true; // Profile updated successfully
    } else {
      print('Failed to update profile. Status code: ${response.statusCode}');
      print('Error: ${response.body}');
      return false; // or throw an exception based on your error handling policies
    }
  }

  Future<String?> updateAvatar(File image, String oldAvatarPath) async {
    await loadHeaders();
    final Uri uploadUrl = Uri.parse('${baseUrl}/api/upload');
    print('Updating avatar with image path: ${image.path}');

    var request = http.MultipartRequest('POST', uploadUrl)
      ..headers.addAll(headers)
      // Add the old avatar path and the type if necessary
      ..fields['oldImagePath'] = oldAvatarPath
      ..fields['type'] = 'avatar'
      ..files.add(
        http.MultipartFile(
          'files', // The field name must match the server's expected field name
          image.readAsBytes().asStream(),
          image.lengthSync(),
          filename: basename(image.path),
          contentType:
              MediaType('image', 'jpeg'), // Adjust if your image is not a JPEG
        ),
      );

    print('Sending avatar update request...');
    try {
      var streamedResponse = await request.send();
      print('Avatar update request sent. Awaiting response...');

      var response = await http.Response.fromStream(streamedResponse);
      print('Avatar update response status code: ${response.statusCode}');
      print('Avatar update response body: ${response.body}');

      if (response.statusCode == 200) {
        // Directly return the response body if it's not JSON.
        print('New avatar path: ${response.body}');
        return '${baseUrl}' + response.body;
      } else {
        print(
            'Avatar update request failed with status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception during avatar update: $e');
      return null;
    }
  }

  Future<bool> saveAvatarUrl(String newAvatarUrl) async {
    // Use the URL as returned by the server without any alteration
    Map<String, dynamic> profileData = {
      'avatar': newAvatarUrl,
    };
    print('Attempting to save new avatar URL: $newAvatarUrl');

    bool result = await updateProfile(profileData);
    if (!result) {
      print('Failed to save the new avatar URL to the profile.');
    }
    return result;
  }

  Future<Map<String, dynamic>> changePassword(
      String currentPassword, String newPassword, String uuid) async {
    await loadHeaders();
    final Uri url = Uri.parse('${baseUrl}/api/auth/profile');

    Map<String, dynamic> profileData = {
      'user': {
        'uuid': uuid,
        'current_password': currentPassword,
        'password': newPassword,
      },
    };

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(profileData),
    );

    print('PUT Change Password Request to URL: $url');

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200 && responseBody['status'] != 'fail') {
      print('Password Changed Successfully: ${response.body}');
      return {'success': true, 'message': 'Password changed successfully'};
    } else {
      print('Failed to change password. Response: ${response.body}');
      // Extract the error message from response and return it
      return {'success': false, 'message': responseBody['error']['message']};
    }
  }

  Future<Map<String, dynamic>?> generateOTPSecret(String type,
      {String? email, String? phoneNumber}) async {
    await loadHeaders();
    final Uri url = Uri.parse('${baseUrl}/api/profile/generateOTPSecret');

    Map<String, dynamic> requestBody = {
      "type": type,
    };

    // Add email and phoneNumber to requestBody if they are not null
    if (email != null) {
      requestBody["email"] = email;
    }
    if (phoneNumber != null) {
      requestBody["phoneNumber"] = phoneNumber; // Changed from "?phoneNumber"
    }

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Handle error
      return null;
    }
  }

  Future<Map<String, dynamic>?> verifyOTP(
      String otp, String secret, String type) async {
    await loadHeaders();
    final Uri url = Uri.parse('${baseUrl}/api/profile/verifyOTP');
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        "otp": otp,
        "secret": secret,
        "type": type,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Handle error
      return null;
    }
  }

  Future<Map<String, dynamic>?> saveOTP(String secret, String type) async {
    await loadHeaders();
    final Uri url = Uri.parse('${baseUrl}/api/profile/toggleOtp');
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        "secret": secret,
        "type": type,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Handle error
      return null;
    }
  }

  Future<Map<String, dynamic>?> toggleOtp(String status) async {
    await loadHeaders();
    final Uri url = Uri.parse('${baseUrl}/api/kyc');
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({"status": status}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Handle error
      return null;
    }
  }

  Future<Map<String, dynamic>?> checkKYCStatus() async {
    await loadHeaders();
    final Uri url = Uri.parse('${baseUrl}/api/kyc');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to check KYC status. Status code: ${response.statusCode}');
      return null;
    }
  }

  Future<bool> submitKYCDetails(String templateId, Map<String, dynamic> payload,
      Map<String, dynamic> template, String level) async {
    await loadHeaders();
    final Uri url = Uri.parse('${baseUrl}/api/kyc');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        "templateId":
            int.parse(templateId), // Convert the templateId to an integer
        "template": template, // Include the template structure
        "level": int.parse(level), // Include the level as an integer
        ...payload, // Spread the payload fields directly into the body
      }),
    );

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      print('KYC details submitted successfully: $responseJson');
      return responseJson['status'] == 'success';
    } else {
      print(
          'Failed to submit KYC details. Status code: ${response.statusCode}');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getKYC() async {
    await loadHeaders();
    // Set your KYC URL to the provided endpoint
    final Uri url = Uri.parse('${baseUrl}/api/kyc-template');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to load KYC data. Status code: ${response.statusCode}');
      return null;
    }
  }
}
