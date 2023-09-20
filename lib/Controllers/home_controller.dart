import 'package:get/get.dart';

class HomeController extends GetxController {
  var currentTabIndex = 0.obs;

  void changeTabIndex(int index) {
    currentTabIndex.value = index;
  }
}
