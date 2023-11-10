import 'package:bicrypto/Controllers/Auth/profile/changepassword_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordScreen extends StatelessWidget {
  final ChangePasswordController controller =
      Get.put(ChangePasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Dark background
      appBar: AppBar(
        title: Text('Change Password'),
        backgroundColor: Colors.grey[850],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (controller.successMessage.isNotEmpty)
                  Text(
                    controller.successMessage.value,
                    style: TextStyle(color: Colors.green),
                  ),
                if (controller.errorMessage.isNotEmpty)
                  Text(
                    controller.errorMessage.value,
                    style: TextStyle(color: Colors.red),
                  ),
                TextField(
                  onChanged: (value) => controller.oldPassword.value = value,
                  decoration: InputDecoration(
                    labelText: 'Old Password',
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                TextField(
                  onChanged: (value) => controller.newPassword.value = value,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                TextField(
                  onChanged: (value) =>
                      controller.repeatNewPassword.value = value,
                  decoration: InputDecoration(
                    labelText: 'Repeat New Password',
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.changePassword,
                  child: Text(controller.isLoading.value
                      ? 'Changing...'
                      : 'Change Password'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.deepPurple,
                    minimumSize: Size(double.infinity, 50), // Full width button
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
