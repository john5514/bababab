import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bitcuit/services/profile_service.dart';

class KYCController extends GetxController {
  final ProfileService profileService;

  // Observables
  var kycData = Rxn<Map<String, dynamic>>(); // Holds the KYC data
  var isLoading = false.obs; // Tracks loading state
  var submitStatus = Rxn<String>(); // Tracks the status of KYC submission

  // Text editing controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();
  final zipController = TextEditingController();
  final dobController = TextEditingController();
  final extraInfoController = TextEditingController();

  KYCController({required this.profileService});

  @override
  void onInit() {
    super.onInit();
    fetchKYCData(); // Fetch KYC data when the controller is initialized
  }

  @override
  void onClose() {
    // Dispose controllers when the controller is removed from memory
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    zipController.dispose();
    dobController.dispose();
    extraInfoController.dispose();
    super.onClose();
  }

  // Fetch KYC data from the server
  Future<void> fetchKYCData() async {
    isLoading(true);
    try {
      var response = await profileService.getKYC();
      if (response != null) {
        kycData(response);
      } else {
        submitStatus('Failed to fetch KYC data');
      }
    } finally {
      isLoading(false);
    }
  }

  // Submit KYC data to the server
  Future<void> submitKYCData() async {
    isLoading(true);
    try {
      // Construct the data payload for submission
      final payload = {
        "first_name": firstNameController.text,
        "last_name": lastNameController.text,
        "email": emailController.text,
        "phone": phoneController.text,
        "address": addressController.text,
        "city": cityController.text,
        "state": stateController.text,
        "country": countryController.text,
        "zip": zipController.text,
        "dob": dobController.text,
        "extra_info":
            extraInfoController.text, // Assuming 'test' is 'extra_info'
        // Add other fields as necessary
      };

      // The templateId should be an integer. Since we've already set it as a String "1",
      // we will parse it to integer in the submitKYCDetails method.
      String templateId = "1"; // The actual template ID retrieved from your API
      // Assuming the level is a property of the template, you would retrieve it like this:
      String level = kycData.value?['result']['options']['first_name']
              ['level'] ??
          "1"; // default to "1" if not found

      // The template might be the entire 'options' object or just a part of it
      // This depends on how your backend expects the template to be structured
      Map<String, dynamic> template = kycData.value?['result']['options'];

      bool success = await profileService.submitKYCDetails(
        templateId, // This is passed as a String and will be parsed inside the method
        payload, // This is the payload constructed from the form fields
        template, // Include the template structure
        level, // Include the level
      );

      if (success) {
        submitStatus('KYC submitted successfully');
        // Optionally clear the text fields after successful submission
      } else {
        submitStatus('Failed to submit KYC');
      }
    } catch (e) {
      // If there's an error, handle it here
      submitStatus('Error submitting KYC: $e');
    } finally {
      isLoading(false);
    }
  }
}
