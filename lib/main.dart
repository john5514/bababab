import 'package:bitcuit/Controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:bitcuit/Controllers/Auth/profile/kyc_controller.dart';
import 'package:bitcuit/Controllers/Auth/profile/profile_controller.dart';
import 'package:bitcuit/Controllers/home_controller.dart';
import 'package:bitcuit/Controllers/wallets/spot%20wallet/spotWallet_controller.dart';
import 'package:bitcuit/Routing/app_routes.dart';
import 'package:bitcuit/maintainance.dart';
import 'package:bitcuit/services/api_service.dart';
import 'package:bitcuit/services/market_service.dart';
import 'package:bitcuit/services/profile_service.dart';
import 'package:bitcuit/services/wallet_service.dart';
import 'package:bitcuit/Controllers/Auth/login_controller.dart';
import 'Style/styles.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();

  // Initialize ApiService
  final ApiService apiService = ApiService();
  Get.put<ApiService>(apiService);

  // Fetch settings and check for maintenance mode
  try {
    var settings = await apiService.fetchSettings();
    if (settings['data']['result'].any((setting) =>
        setting['key'] == 'site_maintenance' &&
        setting['value'] == 'Enabled')) {
      runApp(const MaintenanceApp());
      return; // Stop further execution if in maintenance mode
    }
  } catch (e) {
    if (e is SocketException) {
      runApp(NetworkErrorApp()); // A custom app to handle network errors
    } else {
      runApp(const ErrorApp());
    }
    return;
  }
  // Initialize ProfileService
  final ProfileService profileService = ProfileService(apiService);
  Get.put<ProfileService>(profileService);

  // Initialize LoginController
  final LoginController loginController =
      Get.put(LoginController(profileService));

  // Initialize other services and controllers
  initializeApp(apiService, profileService, loginController);

  // Check for email verification and navigate accordingly
  try {
    if (loginController.isEmailVerificationEnabled.value &&
        !loginController.isEmailVerified.value) {
      Get.toNamed('/email-verification');
    } else {
      Get.offAllNamed('/home');
    }
  } catch (e) {
    print("Error during navigation: $e");
  }
}

Future<void> initializeApp(ApiService apiService, ProfileService profileService,
    LoginController loginController) async {
  // Create an instance of WalletService
  WalletService walletService = WalletService(apiService);

  // Register other services and controllers
  Get.put<WalletService>(walletService);
  Get.put<MarketService>(MarketService(apiService));
  Get.put<ProfileController>(ProfileController(profileService: profileService));
  Get.put<KYCController>(KYCController(profileService: profileService));
  Get.put<HomeController>(HomeController(), permanent: true);
  Get.put<WalletController>(WalletController(walletService));
  Get.put<WalletSpotController>(
      WalletSpotController(walletService: Get.find()));

  // Check login status
  await loginController.init();

  Stripe.publishableKey = const String.fromEnvironment('STRIPE_PUBLISHABLE_KEY',
      defaultValue:
          'pk_test_51LPVEfLFyngRnuDVzYJ2cb5yF2BsE4fELcGumnvgjuLCCPWjHpEeDMVz6DOSilTNc2FihuK91zbNurhhyRZT0qTI000Zc1hT5Bb');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.find();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'bitcuit',
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

class NetworkErrorApp extends StatelessWidget {
  const NetworkErrorApp({super.key});

  // Define how this app should look like
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
            child: Text(
                'Network error occurred. Please check your connection and try again.')),
      ),
    );
  }
}
