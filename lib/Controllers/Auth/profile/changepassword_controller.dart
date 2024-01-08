import 'package:bitcuit/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bitcuit/services/profile_service.dart';

class ChangePasswordController extends GetxController {
  var isLoading = false.obs;
  var successMessage = ''.obs;
  var errorMessage = ''.obs;
  var oldPassword = ''.obs;
  var newPassword = ''.obs;
  var repeatNewPassword = ''.obs;
  var uuid = ''.obs; // You need to set this value from the user data

  // Live validation variables
  var hasMinLength = false.obs;
  var hasUpperCase = false.obs;
  var hasLowerCase = false.obs;
  var hasNumber = false.obs;
  var hasSpecialCharacters = false.obs;

  final ProfileService profileService = ProfileService(Get.find<ApiService>());

  bool get allCriteriaMet =>
      hasMinLength.value &&
      hasUpperCase.value &&
      hasLowerCase.value &&
      hasNumber.value &&
      hasSpecialCharacters.value;

  @override
  void onInit() {
    super.onInit();
    // React to changes in newPassword with debounce to avoid too frequent checks
    debounce(newPassword, validateNewPassword,
        time: Duration(milliseconds: 500));
  }

  void validateNewPassword(String value) {
    hasMinLength(value.length >= 8);
    hasUpperCase(value.contains(RegExp(r'[A-Z]')));
    hasLowerCase(value.contains(RegExp(r'[a-z]')));
    hasNumber(value.contains(RegExp(r'[0-9]')));
    hasSpecialCharacters(value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')));
  }

  // Existing validation functions
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
      var result = await profileService.changePassword(
        oldPassword.value,
        newPassword.value,
        uuid.value,
      );

      if (result['success']) {
        successMessage('Password successfully changed');
        // Clear the fields
        oldPassword('');
        newPassword('');
        repeatNewPassword('');
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
        // Display the error message from the backend
        errorMessage(result['message']);
        // Show an error Snackbar
        Get.snackbar(
          'Error',
          result['message'],
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
