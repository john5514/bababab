import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:bicrypto/Controllers/Auth/profile/kyc_controller.dart';
import 'package:bicrypto/Controllers/Auth/profile/profile_controller.dart';
import 'package:bicrypto/Controllers/home_controller.dart';

import 'package:bicrypto/Controllers/wallets/spot%20wallet/spotWallet_controller.dart';
import 'package:bicrypto/Routing/app_routes.dart';
import 'package:bicrypto/maintainance.dart';
import 'package:bicrypto/services/api_service.dart';
import 'package:bicrypto/services/market_service.dart';
import 'package:bicrypto/services/profile_service.dart';
import 'package:bicrypto/services/wallet_service.dart';
import 'package:bicrypto/Controllers/Auth/login_controller.dart';
import 'Style/styles.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();

  // Initialize ApiService
  final ApiService apiService = ApiService();
  Get.put<ApiService>(apiService);

  // Perform domain check using ApiService
  try {
    final response = await http.get(Uri.parse(apiService.baseDomainUrl));
    if (response.statusCode == 200) {
      initializeApp(apiService);
    } else {
      runApp(const MaintenanceApp());
    }
  } catch (e) {
    runApp(const MaintenanceApp());
  }
}

Future<void> initializeApp(ApiService apiService) async {
  // Register other services and controllers
  Get.put<WalletService>(WalletService(apiService));
  Get.put<MarketService>(MarketService(apiService));
  Get.put<ProfileService>(ProfileService(apiService));

  // Register controllers
  Get.put<WalletSpotController>(
      WalletSpotController(walletService: Get.find()));
  Get.put<ProfileController>(ProfileController(profileService: Get.find()));
  Get.put<KYCController>(KYCController(profileService: Get.find()));
  Get.put<HomeController>(HomeController(), permanent: true);

  // Initialize LoginController and check login status
  final LoginController loginController = Get.put(LoginController());
  await loginController.init();
  Stripe.publishableKey =
      'pk_test_51LPVEfLFyngRnuDVzYJ2cb5yF2BsE4fELcGumnvgjuLCCPWjHpEeDMVz6DOSilTNc2FihuK91zbNurhhyRZT0qTI000Zc1hT5B';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.find();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BiCrypto',
      theme: appTheme,
      themeMode: ThemeMode.dark,
      initialRoute: loginController.isLoggedIn.value ? '/home' : '/',
      getPages: AppRoutes.routes,
    );
  }
}

class MaintenanceApp extends StatelessWidget {
  const MaintenanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: MaintenancePage(),
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: Text('An error occurred during initialization')),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
