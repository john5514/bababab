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

  var address = ''.obs;
  var city = ''.obs;
  var country = ''.obs;
  var zip = ''.obs;
  var role = ''.obs;
  var bio = ''.obs;

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
        var result = profileData['data']['result'];
        firstName(result['first_name']);
        lastName(result['last_name']);
        avatarUrl('https://v3.mash3div.com${result['avatar']}');

        // Assuming metadata and its fields are always present, otherwise add null checks.
        var metadata = result['metadata'];
        var location = metadata['location'];
        address(location['address']);
        city(location['city']);
        country(location['country']);
        zip(location['zip']);
        role(metadata['role']);
        bio(metadata['bio']);
        // Set other metadata fields as needed.
      }
    } catch (e) {
      // Handle any errors here
      print('Error fetching profile data: $e');
    } finally {
      isLoading(false); // Stop loading
    }
  }

  void updateProfileData() async {
    isLoading(true); // Start loading
    try {
      // Construct the profile data in the format the API expects.
      var profileData = {
        'first_name': firstName.value,
        'last_name': lastName.value,
        'metadata': {
          'location': {
            'address': address.value,
            'city': city.value,
            'country': country.value,
            'zip': zip.value
          },
          'role': role.value,
          'bio': bio.value,
          // Add other metadata fields as necessary
        }
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
      // Step 1: Upload the avatar and get the new URL
      var newAvatarUrl = await profileService.updateAvatar(image);
      if (newAvatarUrl != null) {
        // Step 2: Save the new avatar URL to the user's profile
        var saved = await profileService.saveAvatarUrl(newAvatarUrl);
        if (saved) {
          // Step 3: Fetch the updated profile data
          fetchProfileData();
          Get.snackbar('Success', 'Avatar updated successfully');
        } else {
          Get.snackbar('Error', 'Failed to save new avatar');
        }
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

      // Call the updateAvatar method in ProfileService, and check if the result is not null
      var newAvatarUrl = await profileService.updateAvatar(imageFile);
      if (newAvatarUrl != null) {
        // If the upload was successful, you may want to update the avatar image
        avatar.value = imageFile;
        // And update the avatarUrl with the returned string URL
        avatarUrl.value = newAvatarUrl;
        // Fetch the new profile data
        fetchProfileData();
        Get.snackbar('Success', 'Avatar updated successfully');
      } else {
        Get.snackbar('Error', 'Failed to update avatar');
      }
      isLoading(false); // Hide the loading indicator
    }
  }
}
