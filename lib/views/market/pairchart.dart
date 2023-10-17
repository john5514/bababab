import 'package:bicrypto/widgets/market/chart_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:k_chart/flutter_k_chart.dart';
import 'package:bicrypto/Controllers/market/chart__controller.dart';

class ChartPage extends StatelessWidget {
  final String pair;
  final ChartController _chartController;

  ChartPage({required this.pair})
      : _chartController = Get.put(ChartController(pair));
  String formatVolume(double volume) {
    if (volume >= 1e9) {
      return '${(volume / 1e9).toStringAsFixed(2)} B';
    } else if (volume >= 1e6) {
      return '${(volume / 1e6).toStringAsFixed(2)} M';
    } else if (volume >= 1e3) {
      return '${(volume / 1e3).toStringAsFixed(2)} K';
    } else {
      return volume.toStringAsFixed(2);
    }
  }

  String getPrimarySymbol(String pair) {
    return pair.split('/').first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          children: [
            const Icon(Icons.sync),
            const SizedBox(width: 8),
            Text(pair),
          ],
        ),
      ),
      body: Obx(
        () {
          return ListView(
            children: [
              ChartHeader(_chartController, pair),
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: tryRenderChart(),
              ),
              buildControlButtons(),
            ],
          );
        },
      ),
    );
  }

  // New control buttons widget
  Widget buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => _chartController.toggleVolumeVisibility(),
            child: Text(_chartController.isVolumeVisible.value
                ? "Hide Volume"
                : "Show Volume"),
          ),
          ElevatedButton(
            onPressed: () => _chartController.toggleChartMode(),
            child: Text(_chartController.isLineMode.value
                ? "Switch to K-Line Mode"
                : "Switch to Time Mode"),
          ),
          DropdownButton<SecondaryChartState>(
            value: _chartController.secondaryState.value,
            onChanged: (value) => _chartController.setSecondaryState(value!),
            items: SecondaryChartState.values.map((state) {
              return DropdownMenuItem(
                value: state,
                child: Text(state.toString().split('.').last),
              );
            }).toList(),
          ),
          ElevatedButton(
            onPressed: () => _chartController.toggleGridVisibility(),
            child: Text(_chartController.isGridHidden.value
                ? "Show Grid"
                : "Hide Grid"),
          ),
          ElevatedButton(
            onPressed: () => _chartController.toggleNowPriceVisibility(),
            child: Text(_chartController.isNowPriceShown.value
                ? "Hide Now Price"
                : "Show Now Price"),
          ),
        ],
      ),
    );
  }

  Widget tryRenderChart() {
    if (_chartController.isLoading.value) {
      return Center(
          child: CircularProgressIndicator()); // Display a loading spinner
    } else if (_chartController.errorMsg.value.isNotEmpty) {
      return Center(
          child: Text(_chartController.errorMsg.value,
              style: TextStyle(color: Colors.red)));
    }

    try {
      List<KLineEntity> kChartData = _chartController.kLineData.map((e) {
        return KLineEntity.fromJson({
          'id': e.time,
          'open': e.open,
          'high': e.high,
          'low': e.low,
          'close': e.close,
          'vol': e.vol,
          'amount': 0,
          'count': 0,
        });
      }).toList();

      // Initialize your chartStyle and chartColors here if they are not already.
      ChartStyle chartStyle = ChartStyle();
      ChartColors chartColors = ChartColors();

      return KeyedSubtree(
        key: _chartController.chartKey.value, // <-- Added this line
        child: KChartWidget(
          kChartData, // This is the datas parameter
          chartStyle, // This is the chartStyle parameter
          chartColors, // This is the chartColors parameter
          isLine:
              _chartController.isLineMode.value, // Control Line or K-Line mode
          isTrendLine: _chartController.isTrendLine.value, // Control Trend Line
          mainState: MainState.MA, // This remains unchanged for now
          secondaryState: _chartController
              .mapToSecondaryState(_chartController.secondaryState.value),

          onLoadMore: (bool isRight) {
            // Handle load more data if needed
          },
          volHidden: !_chartController
              .isVolumeVisible.value, // Control volume visibility
          hideGrid:
              _chartController.isGridHidden.value, // Control grid visibility
          showNowPrice: _chartController
              .isNowPriceShown.value, // Control now price visibility
        ),
      );
    } catch (e) {
      print("Error rendering the chart: $e");
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text("Error rendering chart", style: TextStyle(color: Colors.red)),
            Text("$e"),
          ],
        ),
      );
    }
  }
}
