import 'package:bitcuit/Controllers/Auth/profile/two_step_verification_controller.dart';
import 'package:bitcuit/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class TwoStepVerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      TwoStepVerificationController(Get.find<ProfileService>()),
    ); // Initialize your controller

    // Ensure the theme is appropriate for dark mode
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.phone_android, // Phone icon
                  size: 48,
                  color: colorScheme.onBackground, // Icon color for dark mode
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Enter your Phone Number',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onBackground, // Text color for dark mode
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Enter the required information to continue',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: colorScheme.onBackground, // Text color for dark mode
                  ),
                ),
                const SizedBox(height: 32.0),
                // Only wrap the widget that needs to update with Obx
                InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    controller.phoneNumber.value = number.phoneNumber!;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors
                        .deepPurple, // Use a color that matches your design
                    onPrimary: Colors.white,
                    minimumSize: const Size(double.infinity,
                        50), // Full-width button with fixed height
                  ),
                  onPressed: controller.sendOTP,
                  child: const Text('Send OTP'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
