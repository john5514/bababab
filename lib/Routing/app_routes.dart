import 'package:bicrypto/views/Auth/login_view.dart';
import 'package:bicrypto/views/Auth/register_view.dart';
import 'package:bicrypto/views/Auth/resetpassword_view.dart';
import 'package:bicrypto/views/home_screen.dart';
import 'package:get/get.dart';

class AppRoutes {
  static final routes = [
    GetPage(name: '/', page: () => LoginView()), // Login Screen
    GetPage(
        name: '/register', page: () => RegisterView()), // Registration Screen
    GetPage(
        name: '/reset-password',
        page: () => ForgotPasswordView()), // Password Reset Screen
    GetPage(name: '/home', page: () => HomeView()), // Home Screen
  ];
}
