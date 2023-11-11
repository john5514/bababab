import 'package:bicrypto/Controllers/Auth/profile/two_step_verification_controller.dart';
import 'package:bicrypto/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TwoStepVerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TwoStepVerificationController(
        Get.find<ProfileService>())); // Initialize your controller

    return Scaffold(
      appBar: AppBar(
        title: Text('Two-Step Verification'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Obx(() => TextField(
                  onChanged: (value) => controller.phoneNumber.value = value,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    suffixIcon: controller.isLoading.value
                        ? CircularProgressIndicator()
                        : null,
                  ),
                  keyboardType: TextInputType.phone,
                )),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.sendOTP,
              child: Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
