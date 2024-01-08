import 'package:bitcuit/Controllers/market/customizechart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:k_chart/k_chart_widget.dart';

class ChartCustomizationWidget extends StatelessWidget {
  final CustomizeChartController _customizeController =
      Get.put(CustomizeChartController());

  ChartCustomizationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    int numberOfButtons = 9;
    double buttonWidth = width / numberOfButtons - 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Row(
        children: <Widget>[
          _buildButton(
            onPressed: () => _customizeController.toggleVolumeVisibility(),
            child: Obx(() => Text(
                _customizeController.isVolumeVisible.value ? "H V" : "S V")),
            width: buttonWidth,
          ),
          _buildButton(
            onPressed: () => _customizeController.toggleChartMode(),
            child: Obx(() =>
                Text(_customizeController.isLineMode.value ? "K-L" : "T-M")),
            width: buttonWidth,
          ),
          _buildButton(
            onPressed: () => _customizeController.toggleCustomUI(),
            child: Obx(() =>
                Text(_customizeController.isCustomUI.value ? "D UI" : "C UI")),
            width: buttonWidth,
          ),
          _buildButton(
            onPressed: () => _customizeController.toggleGridVisibility(),
            child: Obx(() =>
                Text(_customizeController.isGridHidden.value ? "S G" : "H G")),
            width: buttonWidth,
          ),
          _buildButton(
            onPressed: () => _customizeController.toggleNowPriceVisibility(),
            child: Obx(() => Text(
                _customizeController.isNowPriceShown.value ? "H NP" : "S NP")),
            width: buttonWidth,
          ),
          _buildButton(
            onPressed: () => _customizeController.setMainState(MainState.MA),
            child: const Text("MA"),
            width: buttonWidth,
          ),
          _buildButton(
            onPressed: () => _customizeController.setMainState(MainState.BOLL),
            child: const Text("BOLL"),
            width: buttonWidth,
          ),
          _buildButton(
            onPressed: () => _customizeController.setMainState(MainState.NONE),
            child: const Text("H L"),
            width: buttonWidth,
          ),
          _buildChartIconDropdown(buttonWidth),
        ],
      ),
    );
    //
  }

  Widget _buildButton(
      {required Widget child, VoidCallback? onPressed, required double width}) {
    return SizedBox(
      width: width,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          textStyle: const TextStyle(fontSize: 12),
        ),
        child: child,
      ),
    );
  }

  Widget _buildChartIconDropdown(double width) {
    return SizedBox(
      width: width,
      child: PopupMenuButton<SecondaryState>(
        onSelected: (value) =>
            _customizeController.secondaryState.value = value,
        itemBuilder: (context) => SecondaryState.values.map((state) {
          return PopupMenuItem(
            value: state,
            child: Text(
              state.toString().split('.').last,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        color: Colors.grey[850],
        child: const IconButton(
          icon: Icon(Icons.show_chart, color: Colors.grey), // Chart Icon
          onPressed: null,
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        ),
      ),
    );
  }
}
