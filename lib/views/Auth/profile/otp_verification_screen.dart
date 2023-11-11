import 'package:bicrypto/Controllers/Auth/profile/two_step_verification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPVerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<
        TwoStepVerificationController>(); // Use the existing controller

    return Scaffold(
      appBar: AppBar(
        title: Text('OTP Verification'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            PinCodeTextField(
              appContext: context,
              length: 6,
              backgroundColor: Colors.transparent, // For dark mode
              keyboardType: TextInputType.number,
              textStyle: TextStyle(color: Colors.white), // Text color
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor:
                    Theme.of(context).inputDecorationTheme.fillColor ??
                        Colors.white,
              ),
              onChanged: (value) {
                // Handle change
              },
              onCompleted: (value) {
                controller.verifyOTP(value);
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    controller.verifyOTP(
                        controller.otpSecret.value); // Manually verify OTP
                  },
                  child: Text('Verify OTP'),
                ),
                TextButton(
                  onPressed: () {
                    controller.resendOTP(); // Resend OTP
                  },
                  child: Text('Resend OTP'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
