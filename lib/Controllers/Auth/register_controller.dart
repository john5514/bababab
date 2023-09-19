import 'package:another_flushbar/flushbar.dart';
import 'package:bicrypto/models/user_model.dart';
import 'package:bicrypto/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  var userModel = UserModel.empty().obs; // Initialize with empty UserModel
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  final ApiService apiService = ApiService();
  var firstNameErrorMessage = ''.obs;
  var lastNameErrorMessage = ''.obs;
  var emailErrorMessage = ''.obs;
  var passwordErrorMessage = ''.obs;
  var confirmPasswordErrorMessage = ''.obs;

  Future<void> registerUser(
    String firstName,
    String lastName,
    String email,
    String password,
    String confirmPassword,
    BuildContext context,
  ) async {
    try {
      isLoading.value = true;
      firstNameErrorMessage.value = '';
      lastNameErrorMessage.value = '';
      emailErrorMessage.value = '';
      passwordErrorMessage.value = '';
      confirmPasswordErrorMessage.value = '';

      bool hasError = false;

      if (firstName.isEmpty) {
        firstNameErrorMessage.value = 'Please enter your first name';
        hasError = true;
      }

      if (lastName.isEmpty) {
        lastNameErrorMessage.value = 'Please enter your last name';
        hasError = true;
      }

      if (email.isEmpty) {
        emailErrorMessage.value = 'Please enter your email';
        hasError = true;
      }

      if (!GetUtils.isEmail(email)) {
        emailErrorMessage.value = 'Invalid email format';
        hasError = true;
      }

      if (password.isEmpty) {
        passwordErrorMessage.value = 'Please enter your password';
        hasError = true;
      }

      if (confirmPassword.isEmpty) {
        confirmPasswordErrorMessage.value = 'Please confirm your password';
        hasError = true;
      }

      if (password != confirmPassword) {
        confirmPasswordErrorMessage.value = 'Passwords do not match';
        hasError = true;
      }

      if (hasError) {
        showFlushbar("Error", "Please correct the errors", context, Colors.red);
        return;
      }

      final success =
          await apiService.register(email, password, firstName, lastName);

      if (success) {
        showFlushbar(
            "Success", "Registration successful!", context, Colors.blue);
        Get.offNamed('/'); // Navigate to Login screen
      } else {
        errorMessage.value = 'Registration failed';
        showFlushbar("Error", "Registration failed", context, Colors.red);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      showFlushbar("Error", e.toString(), context, Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  void showFlushbar(
      String title, String message, BuildContext context, Color color) {
    Flushbar(
      title: title,
      message: message,
      duration: Duration(seconds: 3),
      backgroundColor: color,
    )..show(context);
  }
}
