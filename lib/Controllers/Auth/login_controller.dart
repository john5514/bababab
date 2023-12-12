import 'package:another_flushbar/flushbar.dart';
import 'package:bicrypto/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  var isLoggedIn = false.obs;
  var userEmail = ''.obs;
  var isLoading = false.obs;
  var emailErrorMessage = ''.obs; // Specific to email
  var passwordErrorMessage = ''.obs; // Specific to password
  var trustFor14Days = false.obs; // New property for "Trust for 14 days"

  final ApiService apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future<void> init() async {
    await apiService.loadTokens();
    // First, check if we should auto-logout the user due to the 12-day inactivity
    if (await apiService.shouldAutoLogout()) {
      logout();
    } else {
      // Next, check if all required tokens are present and valid
      if (apiService.tokens.isNotEmpty &&
          apiService.tokens['access-token'] != null &&
          apiService.tokens['access-token']!.isNotEmpty &&
          apiService.tokens['session-id'] != null &&
          apiService.tokens['session-id']!.isNotEmpty &&
          apiService.tokens['csrf-token'] != null &&
          apiService.tokens['csrf-token']!.isNotEmpty &&
          apiService.tokens['refresh-token'] != null &&
          apiService.tokens['refresh-token']!.isNotEmpty) {
        isLoggedIn.value = true; // Update isLoggedIn based on the token status
      } else {
        isLoggedIn.value =
            false; // If any token is missing or invalid, set isLoggedIn to false
      }
    }
  }

  Future<void> login(String email, String password, bool trustFor14Days,
      BuildContext context) async {
    isLoading.value = true;
    emailErrorMessage.value = '';
    passwordErrorMessage.value = '';

    bool hasError = false;

    if (email.isEmpty) {
      emailErrorMessage.value = 'Please enter your email';
      hasError = true;
    }

    if (password.isEmpty) {
      passwordErrorMessage.value = 'Please enter your password';
      hasError = true;
    }

    if (!GetUtils.isEmail(email)) {
      emailErrorMessage.value = 'Invalid email format';
      hasError = true;
    }

    if (hasError) {
      showFlushbar("Error", 'Please correct the errors', context);
      return;
    }

    try {
      final String? error =
          await apiService.login(email, password, trustDevice: trustFor14Days);

      if (error == null) {
        await apiService.saveLoginTimestamp(); // Save the login timestamp
        isLoggedIn.value = true;
        userEmail.value = email;
        Get.offAllNamed('/home');
        showFlushbar("Success", "Login successful!", context, Colors.blue);
      } else {
        handleLoginError(error, context);
      }
    } catch (e) {
      handleLoginError(e.toString(), context);
    } finally {
      isLoading.value = false;
    }
  }

  void showFlushbar(String title, String message, BuildContext context,
      [Color? color]) {
    Flushbar(
      title: title,
      message: message,
      duration: Duration(seconds: 3),
      backgroundColor:
          color ?? Colors.red, // Default to red if color is not provided
    ).show(context);
  }

  void handleLoginError(String error, BuildContext context) {
    if (error.toLowerCase().contains("password")) {
      passwordErrorMessage.value = error;
    } else {
      emailErrorMessage.value = error;
    }
    showFlushbar("Error", error, context);
  }

  Future<void> logout() async {
    isLoggedIn.value = false;
    userEmail.value = '';
    await apiService.logout(); // Call logout from the ApiService
    Get.offAllNamed('/login'); // Navigate to the login screen
  }
}
