import 'package:bicrypto/Controllers/Auth/profile/changepassword_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class ChangePasswordScreen extends StatelessWidget {
  final ChangePasswordController controller =
      Get.put(ChangePasswordController());

  ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 150,
                  child: Lottie.asset('assets/animations/passwordreset.json'),
                ),
                // Old Password TextField
                _buildPasswordInputField(
                  label: 'Old Password',
                  onChanged: (value) => controller.oldPassword.value = value,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                // New Password TextField
                _buildPasswordInputField(
                  label: 'New Password',
                  onChanged: (value) {
                    controller.newPassword.value = value;
                    controller.validateNewPassword(value); // Validate on change
                  },
                  obscureText: true,
                  suffixIcon: Obx(() => IconButton(
                        icon: Icon(
                          Icons.info_outline,
                          // Change color based on the overall validity
                          color: controller.allCriteriaMet
                              ? Colors.green
                              : Colors.red,
                        ),
                        onPressed: () {
                          // Show the criteria in a dialog or modal bottom sheet
                          _showPasswordCriteria(context);
                        },
                      )),
                ),
                const SizedBox(height: 16),
                // Repeat New Password TextField
                _buildPasswordInputField(
                  label: 'Repeat New Password',
                  onChanged: (value) =>
                      controller.repeatNewPassword.value = value,
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                // Change Password Button
                ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.deepPurple, // Theme color for buttons
                    minimumSize:
                        const Size(double.infinity, 50), // Full width button
                  ),
                  child: Text(controller.isLoading.value
                      ? 'Changing...'
                      : 'Change Password'),
                ),
                // Success and Error Messages
                // _buildSuccessAndErrorMessage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPasswordCriteria(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.black,
          child: Wrap(
            children: <Widget>[
              _buildPasswordCriteriaIndicator(
                  'Minimum 8 characters', controller.hasMinLength.value),
              _buildPasswordCriteriaIndicator('Contains uppercase characters',
                  controller.hasUpperCase.value),
              _buildPasswordCriteriaIndicator('Contains lowercase characters',
                  controller.hasLowerCase.value),
              _buildPasswordCriteriaIndicator(
                  'Contains numbers', controller.hasNumber.value),
              _buildPasswordCriteriaIndicator('Contains special characters',
                  controller.hasSpecialCharacters.value),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPasswordInputField({
    required String label,
    required Function(String) onChanged,
    required bool obscureText,
    Widget? suffixIcon, // Make this an optional parameter.
  }) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[800],
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon, // Pass the icon widget here.
      ),
      obscureText: obscureText,
    );
  }

  Widget _buildPasswordCriteriaIndicator(String criteria, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: isMet ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            criteria,
            style: TextStyle(
              color: isMet ? Colors.green : Colors.red,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildSuccessAndErrorMessage() {
  //   return Column(
  //     children: [
  //       Obx(() => controller.successMessage.isNotEmpty
  //          // ? Text(
  //               controller.successMessage.value,
  //               style: TextStyle(color: Colors.green),
  //             )
  //           : SizedBox.shrink()),
  //       Obx(() => controller.errorMessage.isNotEmpty
  // //           ? Text(
  //               controller.errorMessage.value,
  //               style: TextStyle(color: Colors.red),
  //             )
  //           : SizedBox.shrink()),
  //     ],
  //   );
  // }
}
