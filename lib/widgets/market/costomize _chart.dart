import 'package:bicrypto/Controllers/market/customizechart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:k_chart/k_chart_widget.dart';

class ChartCustomizationWidget extends StatelessWidget {
  final CustomizeChartController _customizeController =
      Get.put(CustomizeChartController());

  ChartCustomizationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Wrap(
        spacing: 4.0, // space between buttons
        runSpacing: 2.0, // space between lines

        alignment: WrapAlignment.center,

        children: <Widget>[
          _buildButton(
            onPressed: () => _customizeController.toggleVolumeVisibility(),
            child: Obx(() => Text(
                _customizeController.isVolumeVisible.value ? "H V" : "S V")),
          ),
          _buildButton(
            onPressed: () => _customizeController.toggleChartMode(),
            child: Obx(() =>
                Text(_customizeController.isLineMode.value ? "K-L" : "T-M")),
          ),
          _buildButton(
            onPressed: () => _customizeController.toggleCustomUI(),
            child: Obx(() =>
                Text(_customizeController.isCustomUI.value ? "D UI" : "C UI")),
          ),
          _buildButton(
            onPressed: () => _customizeController.toggleGridVisibility(),
            child: Obx(() =>
                Text(_customizeController.isGridHidden.value ? "S G" : "H G")),
          ),
          _buildButton(
            onPressed: () => _customizeController.toggleNowPriceVisibility(),
            child: Obx(() => Text(
                _customizeController.isNowPriceShown.value ? "H NP" : "S NP")),
          ),
          _buildButton(
            onPressed: () => _customizeController.setMainState(MainState.MA),
            child: Text("MA"),
          ),
          _buildButton(
            onPressed: () => _customizeController.setMainState(MainState.BOLL),
            child: Text("BOLL"),
          ),
          _buildButton(
            onPressed: () => _customizeController.setMainState(MainState.NONE),
            child: Text("H L"),
          ),
          _buildDropDown(),
        ],
      ),
    );
  }

  Widget _buildButton({required Widget child, VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Colors.grey[850], // button color
        onPrimary: Colors.white, // button text color
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: TextStyle(fontSize: 12), // font size
      ),
      child: child,
    );
  }

  Widget _buildDropDown() {
    return Obx(() => DropdownButton<SecondaryState>(
          value: _customizeController.secondaryState.value,
          onChanged: (value) =>
              _customizeController.secondaryState.value = value!,
          items: SecondaryState.values.map((state) {
            return DropdownMenuItem(
              value: state,
              child: Text(
                state.toString().split('.').last,
                style: TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          dropdownColor: Colors.grey[850],
        ));
  }
}
