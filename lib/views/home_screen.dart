import 'package:bicrypto/Controllers/Auth/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  final LoginController loginController = Get.find(); // <-- Use LoginController

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
              () => Text(
                loginController.isLoggedIn.value
                    ? 'Welcome, ${loginController.userEmail.value}'
                    : 'Not logged in',
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Perform logout operation here
                loginController.logout();
                Get.offAllNamed('/login'); // Navigate to login screen
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
