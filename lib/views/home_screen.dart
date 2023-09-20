import 'package:bicrypto/Controllers/Auth/login_controller.dart';
import 'package:bicrypto/Controllers/home_controller.dart'; // <-- Import HomeController
import 'package:bicrypto/views/wallet_view.dart'; // <-- Import WalletView
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicrypto/Style/styles.dart';

class HomeView extends StatelessWidget {
  final LoginController loginController = Get.find();
  final HomeController homeController =
      Get.put(HomeController()); // <-- Initialize HomeController

  final List<Widget> _children = [
    Center(child: Text('Home')),
    Center(child: Text('Markets')),
    Center(child: Text('Trade')),
    Center(child: Text('Futures')),
    WalletView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: homeController.currentTabIndex.value, // <-- Use HomeController
          children: _children,
        ),
      ),
      bottomNavigationBar: Obx(
        () => CurvedNavigationBar(
          height: 50.0,
          animationDuration: Duration(milliseconds: 300),
          animationCurve: Curves.easeInOut,
          index: homeController.currentTabIndex.value, // <-- Use HomeController
          backgroundColor: appTheme.scaffoldBackgroundColor,
          items: <Widget>[
            Icon(Icons.home, size: 30, color: appTheme.secondaryHeaderColor),
            Icon(Icons.pie_chart,
                size: 30, color: appTheme.secondaryHeaderColor),
            Icon(Icons.swap_horiz,
                size: 30, color: appTheme.secondaryHeaderColor),
            Icon(Icons.show_chart,
                size: 30, color: appTheme.secondaryHeaderColor),
            Icon(Icons.account_balance_wallet,
                size: 30, color: appTheme.secondaryHeaderColor),
          ],
          onTap: (index) {
            homeController.changeTabIndex(index); // <-- Use HomeController
          },
          color: appTheme.hintColor,
          buttonBackgroundColor: appTheme.hintColor,
          letIndexChange: (index) => true,
        ),
      ),
    );
  }
}
