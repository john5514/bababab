import 'package:get/get.dart';
import 'package:bicrypto/services/profile_service.dart';

class KYCController extends GetxController {
  final ProfileService profileService;

  // Observables
  var kycData = Rxn<Map<String, dynamic>>(); // Holds the KYC data
  var isLoading = false.obs; // Tracks loading state
  var submitStatus = Rxn<String>(); // Tracks the status of KYC submission

  KYCController({required this.profileService});

  @override
  void onInit() {
    super.onInit();
    fetchKYCData(); // Fetch KYC data when the controller is initialized
  }

  // Fetch KYC data from the server
  Future<void> fetchKYCData() async {
    isLoading(true);
    try {
      var response = await profileService.getKYC();
      if (response != null) {
        kycData(response);
      } else {
        // Handle null response or error
      }
    } finally {
      isLoading(false);
    }
  }

  // Submit KYC data to the server
  Future<void> submitKYC(
      String templateId, String template, String level) async {
    isLoading(true);
    try {
      bool success =
          await profileService.submitKYC(templateId, template, level);
      if (success) {
        submitStatus('KYC submitted successfully');
      } else {
        // Handle submission failure
        submitStatus('Failed to submit KYC');
      }
    } finally {
      isLoading(false);
    }
  }
}
