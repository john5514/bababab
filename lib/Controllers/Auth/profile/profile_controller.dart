import 'dart:convert';
import 'package:bicrypto/services/profile_service.dart';
import 'package:get/get.dart';
import 'package:bicrypto/services/api_service.dart'; // Adjust the import path as necessary

class ProfileController extends GetxController {
  final ProfileService profileService;

  ProfileController({required this.profileService});

  // Reactive profile fields
  final Rx<String> firstName = ''.obs;
  final Rx<String> lastName = ''.obs;
  final Rx<String> email = ''.obs;
  final Rx<String> bio = ''.obs;
  final Rx<String> jobTitle = ''.obs;
  final Rx<String> address = ''.obs;
  final Rx<String> city = ''.obs;
  final Rx<String> country = ''.obs;
  final Rx<String> zip = ''.obs;
  final Rx<String> experience = ''.obs;
  final Rx<bool> firstJob = false.obs;
  final Rx<bool> flexible = false.obs;
  final Rx<bool> remote = false.obs;

  // Reactive social links fields
  final Rx<String> facebookUrl = ''.obs;
  final Rx<String> twitterUrl = ''.obs;
  final Rx<String> dribbbleUrl = ''.obs;
  final Rx<String> instagramUrl = ''.obs;
  final Rx<String> githubUrl = ''.obs;
  final Rx<String> gitlabUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
  }

  void fetchProfileData() async {
    try {
      var response = await profileService.getProfile();

      if (response == null || response['result'] == null) {
        Get.snackbar('Error', 'No profile data available');
        return;
      }

      var profile = response['data']['result'];
      // Assign the simple fields first
      firstName.value = profile['first_name'];
      lastName.value = profile['last_name'];
      email.value = profile['email'];

      // Check if metadata is not null and parse it if it's available
      if (profile['metadata'] != null) {
        var metadata = json.decode(profile['metadata']);

        bio.value = metadata['bio'] ?? '';
        jobTitle.value = metadata['role'] ?? '';
        address.value = metadata['location']['address'] ?? '';
        city.value = metadata['location']['city'] ?? '';
        country.value = metadata['location']['country'] ?? '';
        zip.value = metadata['location']['zip'] ?? '';
        experience.value = metadata['info']['experience'] ?? '';
        firstJob.value = metadata['info']['firstJob']['value'] ?? false;
        flexible.value = metadata['info']['flexible']['value'] ?? false;
        remote.value = metadata['info']['remote']['value'] ?? false;

        // Social links
        facebookUrl.value = metadata['social']['facebook'] ?? '';
        twitterUrl.value = metadata['social']['twitter'] ?? '';
        dribbbleUrl.value = metadata['social']['dribbble'] ?? '';
        instagramUrl.value = metadata['social']['instagram'] ?? '';
        githubUrl.value = metadata['social']['github'] ?? '';
        gitlabUrl.value = metadata['social']['gitlab'] ?? '';
      } else {
        // If metadata is null, reset all values or set them to defaults
        bio.value = '';
        jobTitle.value = '';
        address.value = '';
        city.value = '';
        country.value = '';
        zip.value = '';
        experience.value = '';
        firstJob.value = false;
        flexible.value = false;
        remote.value = false;

        // Social links
        facebookUrl.value = '';
        twitterUrl.value = '';
        dribbbleUrl.value = '';
        instagramUrl.value = '';
        githubUrl.value = '';
        gitlabUrl.value = '';
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch profile data: $e');
      print('Error occurred: $e');
    }
  }

  void updateProfileData() async {
    var profileData = {
      'first_name': firstName.value,
      'last_name': lastName.value,
      'email': email.value,
      'metadata': json.encode({
        'location': {
          'address': address.value,
          'city': city.value,
          'country': country.value,
          'zip': zip.value,
        },
        'role': jobTitle.value,
        'bio': bio.value,
        'info': {
          'experience': experience.value,
          'firstJob': {
            'label': firstJob.value ? 'Yes' : 'No',
            'value': firstJob.value,
          },
          'flexible': {
            'label': flexible.value ? 'Yes' : 'No',
            'value': flexible.value,
          },
          'remote': {
            'label': remote.value ? 'Yes' : 'No',
            'value': remote.value,
          },
        },
        'social': {
          'facebook': facebookUrl.value,
          'twitter': twitterUrl.value,
          'dribbble': dribbbleUrl.value,
          'instagram': instagramUrl.value,
          'github': githubUrl.value,
          'gitlab': gitlabUrl.value,
        },
      }),
    };

    bool success = await profileService.updateProfile(profileData);
    if (success) {
      Get.snackbar('Success', 'Profile updated successfully');
    } else {
      Get.snackbar('Error', 'Failed to update profile');
    }
  }
}
