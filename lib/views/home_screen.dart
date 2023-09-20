import 'package:bicrypto/Controllers/Auth/login_controller.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicrypto/Style/styles.dart'; // <-- Import your custom theme

class HomeView extends StatelessWidget {
  final LoginController loginController = Get.find();

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: appTheme.primaryColor,
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
                style: appTheme.textTheme.bodyLarge,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                loginController.logout();
                Get.offAllNamed('/login');
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 50.0, // New height
        animationDuration: Duration(milliseconds: 300), // New duration
        animationCurve: Curves.easeInOut, // New curve
        index: 2, // New initial index
        backgroundColor: appTheme.scaffoldBackgroundColor,
        items: <Widget>[
          Icon(Icons.home, size: 30, color: appTheme.secondaryHeaderColor),
          Icon(Icons.pie_chart, size: 30, color: appTheme.secondaryHeaderColor),
          Icon(Icons.swap_horiz,
              size: 30, color: appTheme.secondaryHeaderColor),
          Icon(Icons.show_chart,
              size: 30, color: appTheme.secondaryHeaderColor),
          Icon(Icons.account_balance_wallet,
              size: 30, color: appTheme.secondaryHeaderColor),
        ],
        onTap: (index) {
          // Handle your button tap here
        },
        color: appTheme.hintColor,
        buttonBackgroundColor: appTheme.hintColor,
        letIndexChange: (index) => true, // New touch area
      ),
    );
  }
}
