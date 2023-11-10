import 'package:bicrypto/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicrypto/services/profile_service.dart';

class ChangePasswordController extends GetxController {
  var isLoading = false.obs;
  var successMessage = ''.obs;
  var errorMessage = ''.obs;
  var oldPassword = ''.obs;
  var newPassword = ''.obs;
  var repeatNewPassword = ''.obs;
  var uuid = ''.obs; // You need to set this value from the user data

  final ProfileService profileService = ProfileService(Get.find<ApiService>());

  String? validatePassword(String password) {
    if (password.isEmpty) return 'Password cannot be empty';
    if (password.length < 8) return 'Password must be at least 8 characters';
    return null; // null means no error
  }

  String? validateConfirmPassword(String confirmPassword) {
    if (confirmPassword != newPassword.value) return 'Passwords do not match';
    return null; // null means no error
  }

  Future<void> changePassword() async {
    // Perform validation checks
    final oldPasswordError = validatePassword(oldPassword.value);
    final newPasswordError = validatePassword(newPassword.value);
    final confirmPasswordError =
        validateConfirmPassword(repeatNewPassword.value);

    if (oldPasswordError != null ||
        newPasswordError != null ||
        confirmPasswordError != null) {
      // If there is an error, show it using a Snackbar and stop the password change process
      Get.snackbar(
        'Error',
        oldPasswordError ?? newPasswordError ?? confirmPasswordError!,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading(true);
    try {
      bool result = await profileService.changePassword(
        oldPassword.value,
        newPassword.value,
        uuid.value,
      );

      if (result) {
        successMessage('Password successfully changed');
        // Show a success Snackbar
        Get.snackbar(
          'Success',
          'Password changed successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        // Clear the fields
        oldPassword('');
        newPassword('');
        repeatNewPassword('');
      } else {
        // Assume we receive a detailed error message from the backend in the form of a string
        errorMessage('Failed to change password: Invalid password format');
        // Show an error Snackbar
        Get.snackbar(
          'Error',
          'Failed to change password: Invalid password format',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage('An error occurred while changing the password: $e');
      // Show an error Snackbar for the catch block
      Get.snackbar(
        'Error',
        'An error occurred while changing the password: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }
}
