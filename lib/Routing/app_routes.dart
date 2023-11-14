import 'package:bicrypto/views/Auth/login_view.dart';
import 'package:bicrypto/views/Auth/profile/otp_verification_screen.dart';
import 'package:bicrypto/views/Auth/register_view.dart';
import 'package:bicrypto/views/Auth/resetpassword_view.dart';
import 'package:bicrypto/views/home_screen.dart';
import 'package:bicrypto/views/market/markethome.dart';
import 'package:bicrypto/views/market/pairchart.dart';
import 'package:bicrypto/views/trade/tradeview.dart';
import 'package:bicrypto/views/wallet_view.dart';
import 'package:bicrypto/views/wallets/completedepositview.dart';
import 'package:bicrypto/views/wallets/depositview.dart';
import 'package:bicrypto/views/wallets/spot/SpotTransferView.dart';
import 'package:bicrypto/views/wallets/spot/spotDeposit_view.dart';
import 'package:bicrypto/views/wallets/spot/spotDetail_screen.dart';
import 'package:bicrypto/views/wallets/spot/spotWithdraw_screen.dart';
import 'package:bicrypto/views/wallets/walletinfo_view.dart';
import 'package:bicrypto/views/wallets/withdrowview.dart';
import 'package:bicrypto/widgets/stripe_method_widget.dart';
import 'package:get/get.dart';

import '../widgets/payoneer_method_widget.dart';

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
    GetPage(
      name: '/selected-method',
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        final selectedMethod = arguments['method'] as Map<String, dynamic>;
        final currencyName = arguments['currencyName'] as String;
        final walletInfo = arguments['walletInfo'] as Map<String, dynamic>;

        // Add debug statements here
        print("Debugging: selectedMethod in route = $selectedMethod");
        print("Debugging: currencyName in route = $currencyName");
        print("Debugging: walletInfo in route = $walletInfo");

        return PayoneerSelectedMethodPage(
          selectedMethod: selectedMethod,
          currencyName: currencyName,
          walletInfo: walletInfo,
        );
      },
    ),

    GetPage(name: '/stripe_method', page: () => StripeMethodWidget()),
    GetPage(
      name: '/chart',
      page: () => ChartPage(pair: Get.arguments as String),
    ),
    GetPage(name: '/trade', page: () => TradeView()),
    GetPage(name: '/market', page: () => MarketScreen()),
    GetPage(
      name: '/withdraw',
      page: () => SpotWithdrawView(),
    ),
    GetPage(name: '/spot-wallet-detail', page: () => SpotWalletDetailView()),
    GetPage(name: '/spot-transfer', page: () => SpotTransferView()),
    GetPage(name: '/spot-deposit', page: () => SpotDepositView()),
    GetPage(
        name: '/otp-verification',
        page: () => OTPVerificationScreen()), // Add this line
  ];
}
