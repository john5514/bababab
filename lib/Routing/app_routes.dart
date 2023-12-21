import 'package:bicrypto/Controllers/walletinfo_controller.dart';
import 'package:bicrypto/views/Auth/emailverification.dart';
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
import 'package:bicrypto/views/wallets/withdrawalview.dart';
import 'package:bicrypto/widgets/stripe_method_widget.dart';
import 'package:bicrypto/widgets/wallet/payoneer_withdrow.dart';
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
    GetPage(name: '/withdraw', page: () => const WithdrawalView()),
    GetPage(
        name: '/completeDeposit',
        page: () => CompleteDepositView(method: Get.arguments)),
    GetPage(
      name:
          '/payoneer_withdraw', // Add the correct path for Payoneer withdrawal page
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        final selectedMethod = arguments['method'] as Map<String, dynamic>;
        final currencyName = arguments['currencyName'] as String;
        final walletInfo = arguments['walletInfo'] as Map<String, dynamic>;

        return PayoneerWithdrawalPage(
          selectedMethod: selectedMethod,
          currencyName: currencyName,
          walletInfo: walletInfo,
        );
      },
    ), // Replace with the correct widget

    GetPage(
      name: '/selected-method',
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        final selectedMethod = arguments['method'] as Map<String, dynamic>;
        final currencyName = arguments['currencyName'] as String;
        final walletInfo = arguments['walletInfo'] as Map<String, dynamic>;

        return PayoneerSelectedMethodPage(
          selectedMethod: selectedMethod,
          currencyName: currencyName,
          walletInfo: walletInfo,
        );
      },
    ),

    GetPage(
      name: '/stripe_method',
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>?;
        if (arguments != null) {
          final method = arguments['method'] as Map<String, dynamic>;
          final controller = Get.find<WalletInfoController>();
          controller.selectedMethod.value = method;
        }
        return StripeMethodWidget();
      },
    ),

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
    GetPage(
      name: '/email-verification',
      page: () => EmailVerificationScreen(),
    ),
  ];
}
