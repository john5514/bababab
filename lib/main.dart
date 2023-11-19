import 'package:bicrypto/Controllers/Auth/profile/kyc_controller.dart';
import 'package:bicrypto/Controllers/Auth/profile/profile_controller.dart';
import 'package:bicrypto/Controllers/wallets/spot%20wallet/spotWallet_controller.dart';
import 'package:bicrypto/Routing/app_routes.dart';
import 'package:bicrypto/services/CoinGeckoService.dart';
import 'package:bicrypto/services/api_service.dart';
import 'package:bicrypto/services/profile_service.dart';
import 'package:bicrypto/services/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Style/styles.dart';
import 'package:bicrypto/Controllers/Auth/login_controller.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  // Create an instance of ApiService
  final ApiService apiService = ApiService();

  // Pass the ApiService instance when creating WalletService
  Get.put(WalletService(apiService));
  Get.put(ApiService());
  Get.put<ProfileService>(ProfileService(apiService));

  // Now put WalletSpotController in GetX
  Get.put(WalletSpotController(walletService: Get.find()));
  Get.put<ProfileController>(ProfileController(profileService: Get.find()));
  Get.put(KYCController(profileService: Get.find()));

  final LoginController loginController = Get.put(LoginController());
  await loginController.init(); // Wait for initialization to complete

  Stripe.publishableKey =
      'pk_test_51LPVEfLFyngRnuDVzYJ2cb5yF2BsE4fELcGumnvgjuLCCPWjHpEeDMVz6DOSilTNc2FihuK91zbNurhhyRZT0qTI000Zc1hT5B';

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
