import 'package:bicrypto/Controllers/Auth/reset_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class ForgotPasswordView extends StatelessWidget {
  final ForgotPasswordController forgotPasswordController =
      Get.put(ForgotPasswordController());
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    InputDecorationTheme inputDecoration =
        Theme.of(context).inputDecorationTheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/forgetpass.json',
                ),
                Text(
                  'Forgot Password',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 20),
                Obx(
                  () => TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    keyboardAppearance: Brightness.dark,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: inputDecoration.labelStyle,
                      focusedBorder: inputDecoration.focusedBorder,
                      enabledBorder: inputDecoration.enabledBorder,
                      errorText:
                          forgotPasswordController.errorMessage.value.isEmpty
                              ? null
                              : forgotPasswordController.errorMessage.value,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Obx(
                  () => ElevatedButton(
                    onPressed: forgotPasswordController.isLoading.value
                        ? null
                        : () {
                            forgotPasswordController.sendResetLink(
                              emailController.text,
                            );
                          },
                    child: forgotPasswordController.isLoading.value
                        ? const CircularProgressIndicator()
                        : const Text('Send Reset Link'),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Get.back(); // Navigate back to the previous screen
                  },
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
