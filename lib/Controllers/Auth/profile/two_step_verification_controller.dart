import 'package:bicrypto/services/profile_service.dart';
import 'package:get/get.dart';

class TwoStepVerificationController extends GetxController {
  var isLoading = false.obs;
  var phoneNumber = ''.obs;
  var otpSecret = ''.obs; // Variable to store OTP secret

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
        Get.snackbar('Success', 'OTP verified successfully');
        // Handle successful verification
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
