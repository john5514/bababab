import 'package:bicrypto/views/Auth/login_view.dart';
import 'package:bicrypto/views/Auth/register_view.dart';
import 'package:bicrypto/views/Auth/resetpassword_view.dart';
import 'package:bicrypto/views/home_screen.dart';
import 'package:bicrypto/views/wallet_view.dart';
import 'package:bicrypto/views/wallets/completedepositview.dart';
import 'package:bicrypto/views/wallets/depositview.dart';
import 'package:bicrypto/views/wallets/walletinfo_view.dart';
import 'package:bicrypto/views/wallets/withdrowview.dart';
import 'package:get/get.dart';

class AppRoutes {
  static final routes = [
    GetPage(name: '/', page: () => LoginView()),
    GetPage(name: '/register', page: () => RegisterView()),
    GetPage(name: '/reset-password', page: () => ForgotPasswordView()),
    GetPage(name: '/home', page: () => HomeView()),
    GetPage(name: '/wallet', page: () => WalletView()),
    GetPage(name: '/wallet-info', page: () => WalletInfoView()),
    GetPage(name: '/deposit', page: () => const DepositView()),
    GetPage(name: '/withdraw', page: () => const WithdrawView()),
    GetPage(
        name: '/completeDeposit',
        page: () => CompleteDepositView(method: Get.arguments)),
  ];
}
