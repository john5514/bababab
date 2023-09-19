import 'package:bicrypto/Controllers/Auth/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterView extends StatelessWidget {
  final RegisterController authController =
      Get.put(RegisterController()); // <-- Use RegisterController
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

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
                Text(
                  'Register',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge, // Adjust as needed
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: firstNameController,
                  keyboardAppearance: Brightness.dark,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    labelStyle: inputDecoration.labelStyle,
                    focusedBorder: inputDecoration.focusedBorder,
                    enabledBorder: inputDecoration.enabledBorder,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: lastNameController,
                  keyboardAppearance: Brightness.dark,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    labelStyle: inputDecoration.labelStyle,
                    focusedBorder: inputDecoration.focusedBorder,
                    enabledBorder: inputDecoration.enabledBorder,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  keyboardAppearance: Brightness.dark,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: inputDecoration.labelStyle,
                    focusedBorder: inputDecoration.focusedBorder,
                    enabledBorder: inputDecoration.enabledBorder,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  keyboardAppearance: Brightness.dark,
                  style: const TextStyle(color: Colors.white),
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: inputDecoration.labelStyle,
                    focusedBorder: inputDecoration.focusedBorder,
                    enabledBorder: inputDecoration.enabledBorder,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: confirmPasswordController,
                  keyboardAppearance: Brightness.dark,
                  style: const TextStyle(color: Colors.white),
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: inputDecoration.labelStyle,
                    focusedBorder: inputDecoration.focusedBorder,
                    enabledBorder: inputDecoration.enabledBorder,
                  ),
                ),
                const SizedBox(height: 20),
                Obx(
                  () => ElevatedButton(
                    onPressed: authController.isLoading.value
                        ? null
                        : () {
                            authController.registerUser(
                              firstNameController.text,
                              lastNameController.text,
                              emailController.text,
                              passwordController.text,
                              confirmPasswordController.text,
                            );
                          },
                    child: authController.isLoading.value
                        ? const CircularProgressIndicator()
                        : const Text('Register'),
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
