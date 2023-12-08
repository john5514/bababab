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
        avatarUrl(result['avatar']);

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
  void updateAvatar(File image, String oldAvatarPath) async {
    isLoading(true);
    // print('Begin updateAvatar');

    try {
      // Pass the old avatar path to the updateAvatar function
      var newAvatarUrl =
          await profileService.updateAvatar(image, oldAvatarPath);
      // print('New avatar URL after upload: $newAvatarUrl');

      if (newAvatarUrl != null) {
        var saved = await profileService.saveAvatarUrl(newAvatarUrl);
        print('Save avatar URL result: $saved');

        if (saved) {
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

  Future<void> pickAndUpdateAvatar() async {
    final ImagePicker _picker = ImagePicker();
    // Retrieve the current avatar path from the user's profile
    final currentAvatarPath = avatarUrl
        .value; // Adjust this line to get the actual current avatar path

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      isLoading(true);
      print('Picked image path: ${image.path}');

      File imageFile = File(image.path);
      // Pass the current avatar path to the updateAvatar function
      updateAvatar(imageFile, currentAvatarPath);
      isLoading(false);
    }
  }
}
