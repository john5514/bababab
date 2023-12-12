import 'package:bicrypto/Controllers/Auth/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginView extends StatelessWidget {
  final LoginController authController = Get.put(LoginController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool passwordVisible = false.obs;

  @override
  Widget build(BuildContext context) {
    InputDecorationTheme inputDecoration =
        Theme.of(context).inputDecorationTheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            // Ensure the content fits when the keyboard appears
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Login',
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
                      errorText: authController.emailErrorMessage.value.isEmpty
                          ? null
                          : authController.emailErrorMessage.value,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Obx(() => TextField(
                      controller: passwordController,
                      keyboardAppearance: Brightness.dark,
                      style: const TextStyle(color: Colors.white),
                      obscureText: !passwordVisible
                          .value, // Toggle this based on the passwordVisible state
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: inputDecoration.labelStyle,
                        focusedBorder: inputDecoration.focusedBorder,
                        enabledBorder: inputDecoration.enabledBorder,
                        errorText:
                            authController.passwordErrorMessage.value.isEmpty
                                ? null
                                : authController.passwordErrorMessage.value,
                        // Add an eye icon to toggle password visibility
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Change the icon based on the password visibility
                            passwordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // Update the passwordVisible state
                            passwordVisible.value = !passwordVisible.value;
                          },
                        ),
                      ),
                    )),
                const SizedBox(height: 20),
                Obx(() => CheckboxListTile(
                      title: const Text("Trust for 14 days",
                          style: TextStyle(color: Colors.white)),
                      value: authController.trustFor14Days.value,
                      onChanged: (newValue) {
                        authController.trustFor14Days.value = newValue ?? false;
                      },
                      activeColor: Theme.of(context)
                          .primaryColor, // Use the primary color for the check
                      checkColor: Colors.white, // White check mark
                      contentPadding:
                          EdgeInsets.zero, // Align with the text fields
                    )),
                const SizedBox(height: 20),
                Obx(
                  () => ElevatedButton(
                    onPressed: authController.isLoading.value
                        ? null
                        : () {
                            authController.login(
                              emailController.text,
                              passwordController.text,
                              authController.trustFor14Days
                                  .value, // Pass the trust for 14 days value
                              context,
                            );
                          },
                    child: authController.isLoading.value
                        ? CircularProgressIndicator(
                            color: Theme.of(context)
                                .primaryColor) // Match the primary theme color
                        : const Text('Login',
                            style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context)
                          .primaryColor, // Use the primary color for the button
                      onPrimary:
                          Colors.white, // Use white for the button text color
                      minimumSize: const Size(double.infinity,
                          50), // Make the button full width and 50px high
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.toNamed('/reset-password');
                      },
                      child: const Text('Forgot Password?',
                          style: TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.toNamed('/register');
                      },
                      child: const Text('Register',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
