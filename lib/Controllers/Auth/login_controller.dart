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

  Future<void> login(
      String email, String password, BuildContext context) async {
    try {
      isLoading.value = true;
      emailErrorMessage.value = '';
      passwordErrorMessage.value = '';

      if (email.isEmpty) {
        emailErrorMessage.value = 'Please enter your email';
        showFlushbar("Error", 'Please enter your email', context);
        return;
      }

      if (password.isEmpty) {
        passwordErrorMessage.value = 'Please enter your password';
        showFlushbar("Error", 'Please enter your password', context);
        return;
      }

      if (!GetUtils.isEmail(email)) {
        emailErrorMessage.value = 'Invalid email format';
        showFlushbar("Error", 'Invalid email format', context);
        return;
      }

      final String? error = await apiService.login(email, password);

      if (error == null) {
        isLoggedIn.value = true;
        userEmail.value = email;
        Get.offAllNamed('/home');
        showFlushbar("Success", "Login successful!", context);
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

  void showFlushbar(String title, String message, BuildContext context) {
    Flushbar(
      title: title,
      message: message,
      duration: Duration(seconds: 3),
    )..show(context);
  }

  void logout() {
    isLoggedIn.value = false;
    userEmail.value = '';
  }
}
