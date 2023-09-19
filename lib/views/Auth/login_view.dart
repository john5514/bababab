import 'package:bicrypto/Controllers/Auth/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginView extends StatelessWidget {
  final LoginController authController = Get.put(LoginController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    InputDecorationTheme inputDecoration =
        Theme.of(context).inputDecorationTheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            Obx(
              () => TextField(
                controller: passwordController,
                keyboardAppearance: Brightness.dark,
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: inputDecoration.labelStyle,
                  focusedBorder: inputDecoration.focusedBorder,
                  enabledBorder: inputDecoration.enabledBorder,
                  errorText: authController.passwordErrorMessage.value.isEmpty
                      ? null
                      : authController.passwordErrorMessage.value,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () => ElevatedButton(
                onPressed: authController.isLoading.value
                    ? null
                    : () {
                        authController.login(
                          emailController.text,
                          passwordController.text,
                          context,
                        );
                      },
                child: authController.isLoading.value
                    ? CircularProgressIndicator()
                    : Text('Login'),
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
                  child: const Text('Forgot Password?'),
                ),
                TextButton(
                  onPressed: () {
                    Get.toNamed('/register');
                  },
                  child: const Text('Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
