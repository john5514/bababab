import 'package:bitcuit/Controllers/home_controller.dart';
import 'package:bitcuit/services/profile_service.dart';
import 'package:bitcuit/views/Auth/profile/tabbar.dart';
import 'package:bitcuit/views/home_screen.dart';
import 'package:get/get.dart';

class TwoStepVerificationController extends GetxController {
  var isLoading = false.obs;
  var phoneNumber = ''.obs;
  var otpSecret = ''.obs; // Variable to store OTP secret
  var isTwoFactorAuthEnabled =
      false.obs; // Reactive state for two-factor authentication status

  final ProfileService profileService; // Inject your service

  TwoStepVerificationController(this.profileService);

  void sendOTP() async {
    if (phoneNumber.value.isEmpty) {
      Get.snackbar('Error', 'Please enter your phone number');
      return;
    }

    isLoading.value = true;
    try {
      var response = await profileService.generateOTPSecret('SMS',
          phoneNumber: phoneNumber.value);
      isLoading.value = false;

      if (response != null && response['status'] == 'success') {
        otpSecret.value =
            response['data']['result']['secret']; // Store the OTP secret
        Get.toNamed('/otp-verification'); // Navigate to OTP verification screen
      } else {
        // Handle error
        print('Error Response: $response'); // Debug print
        Get.snackbar('Error', 'Failed to send OTP');
      }
    } catch (e) {
      isLoading.value = false;
      print('Exception: $e'); // Debug print for exceptions
      Get.snackbar('Error', 'An error occurred');
    }
  }

  void verifyOTP(String otp) async {
    if (otp.isEmpty) {
      Get.snackbar('Error', 'Please enter the OTP');
      return;
    }

    isLoading.value = true;
    try {
      var response =
          await profileService.verifyOTP(otp, otpSecret.value, 'SMS');
      isLoading.value = false;

      if (response != null && response['status'] == 'success') {
        // Assuming the Two-Step Verification tab is the last in the list
        int settingsTabIndex = 4; // This index might be different in your app

        // Update the reactive state to reflect that two-factor is enabled
        isTwoFactorAuthEnabled.value = true;

        Get.snackbar('Success', 'OTP verified successfully');

        // Use Get.find<HomeController>() to find the controller and set the correct tab index
        HomeController homeController = Get.find<HomeController>();
        homeController.changeTabIndex(settingsTabIndex);

        // Navigate to the HomeView
        Get.offAll(() => HomeView());
      } else {
        // Handle error
        print('Error Response: $response'); // Debug print
        Get.snackbar('Error', 'Failed to verify OTP');
      }
    } catch (e) {
      isLoading.value = false;
      print('Exception: $e'); // Debug print for exceptions
      Get.snackbar('Error', 'An error occurred');
    }
  }

  void resendOTP() async {
    if (phoneNumber.value.isEmpty) {
      Get.snackbar('Error', 'Please enter your phone number');
      return;
    }

    isLoading.value = true;
    try {
      var response = await profileService.generateOTPSecret('SMS',
          phoneNumber: phoneNumber.value);
      isLoading.value = false;

      if (response != null && response['status'] == 'success') {
        otpSecret.value =
            response['data']['result']['secret']; // Store the OTP secret
        Get.snackbar('Success', 'OTP resent successfully');
      } else {
        print('Error Response: $response'); // Debug print
        Get.snackbar('Error', 'Failed to resend OTP');
      }
    } catch (e) {
      isLoading.value = false;
      print('Exception: $e'); // Debug print for exceptions
      Get.snackbar('Error', 'An error occurred');
    }
  }
}
