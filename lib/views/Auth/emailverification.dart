import 'package:bicrypto/Controllers/Auth/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class EmailVerificationScreen extends StatelessWidget {
  final LoginController loginController = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    // Start the auto-check process
    loginController.autoCheckEmailVerification();

    return Scaffold(
      backgroundColor:
          const Color.fromARGB(136, 0, 0, 0), // A not-so-dark background
      appBar: AppBar(
        title: const Text('Email Verification',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Lottie.asset(
            'assets/animations/emailverify.json',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.4,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Please verify your email address to continue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: loginController.isEmailSent.isFalse
                            ? Color.fromARGB(165, 92, 194, 201)
                            : Color.fromARGB(164, 50, 205,
                                50), // Grey if not sent, green if sent
                        onPrimary: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        minimumSize:
                            const Size(double.infinity, 50), // Wider button
                      ),
                      onPressed: loginController.isLoading.isFalse &&
                              loginController.isEmailSent.isFalse
                          ? () => loginController.sendEmailVerification()
                          : null, // Disable if loading or email is already sent
                      child: loginController.isLoading.isTrue
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white))
                          : const Text('Send Verification Email',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 40.0),
                  child: Obx(() => TextButton(
                        onPressed: loginController.isLoading.isFalse &&
                                loginController.isEmailSent.isTrue
                            ? () => loginController.resendEmailVerification()
                            : null, // Enable only if not loading and email has been sent
                        child: Text(
                          'Resend Verification Email',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: loginController.isEmailSent.isTrue
                                ? Color.fromARGB(165, 92, 194, 201)
                                : Colors.grey, // Green if sent, grey otherwise
                            fontSize: 16,
                          ),
                        ),
                      )),
                ),
                Obx(() => loginController.isEmailVerified.isTrue
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text('Email verified. Redirecting...',
                            style: TextStyle(
                                color:
                                    const Color.fromARGB(210, 129, 199, 132))),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
