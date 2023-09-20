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
  final ApiService apiService = ApiService();

  Future<void> init() async {
    await apiService
        .loadCookie(); // Load the cookie when the controller is initialized
    if (apiService.cookie != null) {
      isLoggedIn.value = true; // Update isLoggedIn based on the cookie status
    }
  }

  Future<void> login(
      String email, String password, BuildContext context) async {
    try {
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

      final String? error = await apiService.login(email, password);

      if (error == null) {
        isLoggedIn.value = true;
        userEmail.value = email;
        Get.offAllNamed('/home');
        showFlushbar("Success", "Login successful!", context, Colors.blue);
      } else {
        if (error.toLowerCase().contains("password")) {
          passwordErrorMessage.value = error;
        } else {
          emailErrorMessage.value = error;
        }
        showFlushbar("Error", error, context);
      }
    } catch (e) {
      emailErrorMessage.value = e.toString();
      showFlushbar("Error", e.toString(), context);
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
    )..show(context);
  }

  void logout() {
    isLoggedIn.value = false;
    userEmail.value = '';
    apiService.logout(); // Clear the cookie
  }
}
