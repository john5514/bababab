import 'package:bicrypto/services/profile_service.dart';
import 'package:get/get.dart';

class TwoStepVerificationController extends GetxController {
  var isLoading = false.obs;
  var phoneNumber = ''.obs;

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
        // Navigate to OTP verification screen or handle success
        Get.snackbar('Success', 'OTP sent successfully');
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
}
