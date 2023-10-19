import 'package:bicrypto/Controllers/market/customizechart_controller.dart';
import 'package:bicrypto/widgets/market/chart_header.dart';
import 'package:bicrypto/widgets/market/costomize%20_chart.dart';
import 'package:bicrypto/widgets/market/orderbook.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:k_chart/flutter_k_chart.dart';
import 'package:bicrypto/Controllers/market/chart__controller.dart';

class ChartPage extends StatelessWidget {
  final String pair;
  final ChartController _chartController;
  final CustomizeChartController _customizeChartController =
      Get.put(CustomizeChartController());

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
                height: MediaQuery.of(context).size.height * 0.6,
                child: tryRenderChart(),
              ),
              const Divider(color: Colors.grey),

              Container(
                height: 25,
                child: buildControlButtons(),
              ),
              //gray devider
              const Divider(color: Colors.grey),

              OrderBookWidget(pair: pair),
            ],
          );
        },
      ),
    );
  }

  // New control buttons widget
  Widget buildControlButtons() {
    return ChartCustomizationWidget();
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

      // Process the data using DataUtil
      DataUtil.calculate(kChartData);

      return KeyedSubtree(
        key: _chartController.chartKey.value,
        child: KChartWidget(
          kChartData,
          _customizeChartController.chartStyle,
          _customizeChartController.chartColors,
          isLine: _customizeChartController.isLineMode.value,
          isTrendLine: _customizeChartController.isTrendLine.value,
          mainState: _customizeChartController.mainState.value,
          secondaryState: _customizeChartController.secondaryState.value,
          fixedLength: 2,
          timeFormat: TimeFormat.YEAR_MONTH_DAY,
          onLoadMore: (bool isRight) {},
          maDayList: [5, 10, 20],
          volHidden: !_customizeChartController.isVolumeVisible.value,
          hideGrid: _customizeChartController.isGridHidden.value,
          showNowPrice: _customizeChartController.isNowPriceShown.value,
          isOnDrag: _customizeChartController.handleDrag,
          onSecondaryTap: _customizeChartController.cycleSecondaryState,
          xFrontPadding: 100,
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
