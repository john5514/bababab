import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bicrypto/services/profile_service.dart';
import 'package:bicrypto/services/api_service.dart'; // Adjust the import path as necessary

class ProfileController extends GetxController {
  final ProfileService profileService;
  var firstName = ''.obs;
  var lastName = ''.obs;
  Rx<File?> avatar = Rx<File?>(null);
  var avatarUrl = ''.obs;
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
        // Set the complete URL for the avatar image
        avatarUrl(
            'https://v3.mash3div.com${profileData['data']['result']['avatar']}');
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

  // This method in ProfileController needs to be corrected
  void updateAvatar(File image) async {
    isLoading(true);
    try {
      // Call the updateAvatar method from the profile service
      bool success = await profileService.updateAvatar(image);
      if (success) {
        // If the upload was successful, update the avatar file
        avatar.value = image;
        // Optionally, you might want to fetch and update the avatarUrl observable
        // with the new URL returned by the server after a successful upload
        fetchProfileData();
        Get.snackbar('Success', 'Avatar updated successfully');
      } else {
        Get.snackbar('Error', 'Failed to update avatar');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading(false);
    }
  }

  // In ProfileController
  Future<void> pickAndUpdateAvatar() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      isLoading(true); // Display a loading indicator
      File imageFile = File(image.path);

      // This should call the updateAvatar method in ProfileService, not a local method.
      bool success = await profileService.updateAvatar(imageFile);
      if (success) {
        // If the upload was successful, you may want to update the avatar image
        avatar.value = imageFile;
        // And possibly fetch the new avatar URL
        fetchProfileData();
        Get.snackbar('Success', 'Avatar updated successfully');
      } else {
        Get.snackbar('Error', 'Failed to update avatar');
      }
      isLoading(false); // Hide the loading indicator
    }
  }
}
