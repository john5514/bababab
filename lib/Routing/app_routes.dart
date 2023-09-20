import 'package:bicrypto/views/Auth/login_view.dart';
import 'package:bicrypto/views/Auth/register_view.dart';
import 'package:bicrypto/views/Auth/resetpassword_view.dart';
import 'package:bicrypto/views/home_screen.dart';
import 'package:bicrypto/views/wallet_view.dart';
import 'package:get/get.dart';

class AppRoutes {
  static final routes = [
    GetPage(name: '/', page: () => LoginView()),
    GetPage(name: '/register', page: () => RegisterView()),
    GetPage(name: '/reset-password', page: () => ForgotPasswordView()),
    GetPage(name: '/home', page: () => HomeView()),
    GetPage(name: '/wallet', page: () => WalletView()),
  ];
}
