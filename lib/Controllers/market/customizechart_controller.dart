import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:k_chart/flutter_k_chart.dart';

class CustomizeChartController extends GetxController {
  final RxBool isVolumeVisible = true.obs;
  final RxBool isLineMode = false.obs;
  var secondaryState = SecondaryState.MACD.obs;
  final RxBool isGridHidden = false.obs;
  final RxBool isNowPriceShown = true.obs;
  final RxBool isTrendLine = false.obs;
  final chartColors = ChartColors();
  final chartStyle = ChartStyle();
  var mainState = MainState.MA.obs;
  final isCustomUI = false.obs;
  final isDragging = false.obs;

  void handleDrag(bool dragState) {
    isDragging.value = dragState;
  }

  void cycleSecondaryState() {
    List<SecondaryState> states = SecondaryState.values;
    int currentIndex = states.indexOf(secondaryState.value);
    int nextIndex = (currentIndex + 1) % states.length;
    secondaryState.value = states[nextIndex];
  }

  void toggleCustomUI() {
    isCustomUI.value = !isCustomUI.value;
    if (isCustomUI.value) {
      chartColors.selectBorderColor = Colors.red;
      chartColors.selectFillColor = Colors.red;
      chartColors.lineFillColor = Colors.red;
      chartColors.kLineColor = Colors.yellow;
    } else {
      chartColors.selectBorderColor = Color(0xff6C7A86);
      chartColors.selectFillColor = Color(0xff0D1722);
      chartColors.lineFillColor = Color(0x554C86CD);
      chartColors.kLineColor = Color(0xff4C86CD);
    }
    update(); // Notify listeners to rebuild
  }

  void setMainState(MainState state) {
    mainState.value = state;
  }

  void toggleTrendLine() {
    isTrendLine.value = !isTrendLine.value;
  }

  void toggleVolumeVisibility() {
    isVolumeVisible.value = !isVolumeVisible.value;
  }

  void toggleChartMode() {
    isLineMode.value = !isLineMode.value;
  }

  void setSecondaryState(SecondaryState state) {
    secondaryState.value = state;
  }

  void toggleGridVisibility() {
    isGridHidden.value = !isGridHidden.value;
  }

  void toggleNowPriceVisibility() {
    isNowPriceShown.value = !isNowPriceShown.value;
  }
}
