import 'dart:convert';
import 'package:get/get.dart';
import 'package:bicrypto/services/profile_service.dart';
import 'package:bicrypto/services/api_service.dart'; // Adjust the import path as necessary

class ProfileController extends GetxController {
  final ProfileService profileService;
  var firstName = ''.obs;
  var lastName = ''.obs;
  var isLoading = false.obs;

  ProfileController({required this.profileService});

  @override
  void onInit() {
    super.onInit();
    fetchProfileData(); // Fetch profile data when the controller is initialized
  }

  void fetchProfileData() async {
    isLoading(true); // Start loading
    try {
      var profileData = await profileService.getProfile();
      if (profileData != null) {
        firstName(profileData['data']['result']['first_name']);
        lastName(profileData['data']['result']['last_name']);
      }
    } finally {
      isLoading(false); // Stop loading
    }
  }

  void updateProfileData(String newFirstName, String newLastName) async {
    isLoading(true); // Start loading
    try {
      // Construct the profile data in the format the API expects.
      var profileData = {
        'first_name': newFirstName,
        'last_name': newLastName,
      };

      var success = await profileService.updateProfile(profileData);
      if (success) {
        // After a successful update, fetch the profile data again
        fetchProfileData();
        Get.snackbar('Success', 'Profile updated successfully');
      } else {
        Get.snackbar('Error', 'Failed to update profile');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading(false); // Stop loading
    }
  }
}
