import 'package:bicrypto/Controllers/Auth/profile/two_step_verification_controller.dart';
import 'package:bicrypto/Style/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPVerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<
        TwoStepVerificationController>(); // Use the existing controller
    final ThemeData theme = Theme.of(context);

    // Assuming you have these colors defined for the dark mode theme
    Color backgroundColor =
        theme.scaffoldBackgroundColor; // Dark background color
    Color buttonColor =
        Colors.deepPurple; // Same as the phone number page button color
    Color textColor = Colors.white; // White text for dark mode

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Two-Step Verification'),
        backgroundColor: appTheme.scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize:
                  MainAxisSize.min, // To center the content vertically
              children: <Widget>[
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: textColor,
                ),
                SizedBox(height: 24.0),
                Text(
                  'Enter your code',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Enter the pin code we\'ve just sent you',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 24.0),
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor, // Button background color
                    onPrimary: textColor, // Button text color
                    minimumSize: Size(double.infinity,
                        50), // Full-width button with fixed height
                  ),
                  onPressed: () {
                    controller.verifyOTP(
                        controller.otpSecret.value); // Manually verify OTP
                  },
                  child: Text(
                    'Verify',
                    style: TextStyle(color: textColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextButton(
                    onPressed: () {
                      controller.resendOTP(); // Resend OTP
                    },
                    child: Text(
                      'Didn\'t receive the code? ',
                      style: TextStyle(
                        color: textColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    controller.resendOTP(); // Resend OTP
                  },
                  child: Text(
                    'Send it again',
                    style: TextStyle(
                      color: textColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
