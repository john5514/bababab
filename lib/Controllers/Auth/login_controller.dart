import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:bicrypto/services/api_service.dart';
import 'package:bicrypto/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  var isLoggedIn = false.obs;
  var userEmail = ''.obs;
  var isLoading = false.obs;
  var emailErrorMessage = ''.obs; // Specific to email
  var passwordErrorMessage = ''.obs; // Specific to password
  var trustFor14Days = false.obs; // New property for "Trust for 14 days"
  var isEmailVerificationEnabled = false.obs; // Observable property

  var isEmailVerified = false.obs;
  var isEmailSent = false.obs;
  final ApiService apiService = ApiService();
  final ProfileService profileService;
  LoginController(this.profileService); // Constructor injection

  @override
  void onInit() {
    super.onInit();
    init();
  }

  void autoCheckEmailVerification() {
    Timer.periodic(Duration(seconds: 30), (timer) async {
      await checkEmailVerification();
      if (isEmailVerified.value) {
        timer.cancel(); // Stop the timer if email is verified
        Get.offAllNamed('/home'); // Navigate to the home screen
      }
    });
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
        await apiService.saveLoginTimestamp();
        isLoggedIn.value = true;
        userEmail.value = email;

        // Fetch email verification setting
        await fetchAndSetEmailVerificationSetting();

        // After login, check email verification status
        await checkEmailVerification();
      } else {
        handleLoginError(error, context);
      }
    } catch (e) {
      handleLoginError(e.toString(), context);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> checkEmailVerification() async {
    try {
      final profileResponse = await profileService.getProfile();
      if (profileResponse != null && profileResponse['status'] == 'success') {
        final userProfile = profileResponse['data']['result'];
        isEmailVerified.value = userProfile['email_verified'];

        if (!isEmailVerified.value && isEmailVerificationEnabled.value) {
          Get.offNamed('/email-verification');
        } else if (!isEmailVerificationEnabled.value || isEmailVerified.value) {
          Get.offAllNamed('/home');
        }
      } else {
        throw Exception('Failed to fetch user profile');
      }
    } catch (e) {
      showFlushbar("Error", 'Failed to check email verification', Get.context!);
    }
  }

  Future<void> fetchAndSetEmailVerificationSetting() async {
    try {
      final settingsResponse = await apiService.fetchSettings();
      if (settingsResponse['status'] == 'success') {
        final settings = settingsResponse['data']['result'];
        final emailVerificationSetting = settings.firstWhere(
          (setting) => setting['key'] == 'email_verification',
          orElse: () => {'value': 'Disabled'},
        );
        isEmailVerificationEnabled.value =
            emailVerificationSetting['value'] == 'Enabled';
      } else {
        throw Exception('Failed to fetch settings');
      }
    } catch (e) {
      showFlushbar("Error", 'Failed to fetch email verification setting',
          Get.context!, Colors.red);
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

  Future<void> sendEmailVerification() async {
    isLoading.value = true;
    try {
      final response =
          await profileService.sendEmailVerification(userEmail.value);
      String message = response['message'] as String? ??
          'Verification email sent successfully';
      showFlushbar("Success", message, Get.context!, Colors.green);
      // Assume that if the email was sent successfully, the email is not verified yet.
      isEmailSent.value = true; // Indicate that an email has been sent
    } catch (e) {
      showFlushbar("Error", e.toString(), Get.context!, Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendEmailVerification() async {
    isLoading.value = true;
    try {
      final response =
          await profileService.resendEmailVerification(userEmail.value);
      String message = response['message'] as String? ??
          'Verification email resent successfully';
      showFlushbar("Success", message, Get.context!, Colors.green);
      // Assume that if the email was resent successfully, the email is not verified yet.
      isEmailSent.value = true; // Indicate that an email has been sent
    } catch (e) {
      showFlushbar("Error", e.toString(), Get.context!, Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyEmailToken(String token) async {
    isLoading.value = true;
    try {
      final response = await profileService.verifyEmailToken(token);
      isLoading.value = false;

      // Check the response and handle it
      if (response['status'] == 'success') {
        isEmailVerified.value = true;
        Get.offAllNamed('/home');
      } else {
        throw Exception('Failed to verify email token');
      }
    } catch (e) {
      isLoading.value = false;
      showFlushbar("Error", e.toString(), Get.context!, Colors.red);
    }
  }

  Future<void> logout() async {
    isLoggedIn.value = false;
    userEmail.value = '';
    await apiService.logout(); // Call logout from the ApiService
    Get.offAllNamed('/login'); // Navigate to the login screen
  }
}
