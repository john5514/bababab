import 'package:bicrypto/Controllers/Auth/profile/two_step_verification_controller.dart';
import 'package:bicrypto/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class TwoStepVerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TwoStepVerificationController(
        Get.find<ProfileService>())); // Initialize your controller

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Obx(() {
              return InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  controller.phoneNumber.value = number.phoneNumber!;
                },
                onInputValidated: (bool value) {
                  // You can use this to take actions based on the validation
                },
                selectorConfig: SelectorConfig(
                  selectorType: PhoneInputSelectorType.DIALOG,
                ),
                ignoreBlank: false,
                autoValidateMode: AutovalidateMode.disabled,
                selectorTextStyle: TextStyle(color: Colors.white),
                textFieldController:
                    TextEditingController(text: controller.phoneNumber.value),
                formatInput: false,
                keyboardType: TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                inputBorder: OutlineInputBorder(),
                onSaved: (PhoneNumber number) {
                  controller.phoneNumber.value = number.phoneNumber!;
                },
              );
            }),
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
