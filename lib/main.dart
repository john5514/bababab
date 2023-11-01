import 'package:bicrypto/Routing/app_routes.dart';
import 'package:bicrypto/services/CoinGeckoService.dart';
import 'package:bicrypto/services/api_service.dart'; // Make sure to import ApiService
import 'package:bicrypto/services/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Style/styles.dart'; // Your global styles
import 'package:bicrypto/Controllers/Auth/login_controller.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  // Create an instance of ApiService
  final ApiService apiService = ApiService();

  // Pass the ApiService instance when creating WalletService
  Get.put(WalletService(apiService));
  Get.put(ApiService());

  final LoginController loginController = Get.put(LoginController());
  await loginController.init(); // Wait for initialization to complete
  Stripe.publishableKey =
      'pk_test_51LzmB6LGS76IduW6INDwhlf4Y55MHvFL6ldhq51gUkbZPO5l7Itfz8w2vvdzSfXR628ls9eJC8M5IcbI2092oazU00OcA3sfeD';

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.find();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BiCrypto',
      theme: appTheme,
      initialRoute: loginController.isLoggedIn.value ? '/home' : '/',
      getPages: AppRoutes.routes,
    );
  }
}
