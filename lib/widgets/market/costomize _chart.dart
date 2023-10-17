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
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => _customizeController.toggleVolumeVisibility(),
            child: Obx(() => Text(_customizeController.isVolumeVisible.value
                ? "Hide Volume"
                : "Show Volume")),
          ),
          ElevatedButton(
            onPressed: () => _customizeController.toggleChartMode(),
            child: Obx(() => Text(_customizeController.isLineMode.value
                ? "Switch to K-Line Mode"
                : "Switch to Time Mode")),
          ),
          ElevatedButton(
            onPressed: () => _customizeController.toggleCustomUI(),
            child: Obx(() => Text(_customizeController.isCustomUI.value
                ? "Default UI"
                : "Customize UI")),
          ),
          Obx(() => DropdownButton<SecondaryState>(
                value: _customizeController.secondaryState.value,
                onChanged: (value) =>
                    _customizeController.secondaryState.value = value!,
                items: SecondaryState.values.map((state) {
                  return DropdownMenuItem(
                    value: state,
                    child: Text(state.toString().split('.').last),
                  );
                }).toList(),
              )),
          ElevatedButton(
            onPressed: () => _customizeController.toggleGridVisibility(),
            child: Obx(() => Text(_customizeController.isGridHidden.value
                ? "Show Grid"
                : "Hide Grid")),
          ),
          ElevatedButton(
            onPressed: () => _customizeController.toggleNowPriceVisibility(),
            child: Obx(() => Text(_customizeController.isNowPriceShown.value
                ? "Hide Now Price"
                : "Show Now Price")),
          ),
          ElevatedButton(
            onPressed: () => _customizeController.setMainState(MainState.MA),
            child: Text("Line:MA"),
          ),
          ElevatedButton(
            onPressed: () => _customizeController.setMainState(MainState.BOLL),
            child: Text("Line:BOLL"),
          ),
          ElevatedButton(
            onPressed: () => _customizeController.setMainState(MainState.NONE),
            child: Text("Hide Line"),
          ),
        ],
      ),
    );
  }
}
