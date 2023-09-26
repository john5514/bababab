import 'package:get/get.dart';

class WalletInfoController extends GetxController {
  var walletName = ''.obs;
  var walletBalance = 0.0.obs;

  void setWalletInfo(String name, double balance) {
    walletName.value = name;
    walletBalance.value = balance;
  }
}
