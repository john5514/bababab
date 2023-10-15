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
    return ' ${(volume / 1000000).toStringAsFixed(2)} M';
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
            ],
          );
        },
      ),
    );
  }

  Widget tryRenderChart() {
    try {
      List<KLineEntity> kChartData = _chartController.kLineData.map((e) {
        return KLineEntity.fromJson({
          'id': e.time,
          'open': e.open,
          'high': e.high,
          'low': e.low,
          'close': e.close,
          'vol': e.vol,
          'amount': 0, // You might need to adjust this value
          'count': 0, // You might need to adjust this value
        });
      }).toList();

      // Initialize your chartStyle and chartColors here if they are not already.
      ChartStyle chartStyle = ChartStyle();
      ChartColors chartColors = ChartColors();

      return KChartWidget(
        kChartData, // This is the datas parameter
        chartStyle, // This is the chartStyle parameter
        chartColors, // This is the chartColors parameter
        isLine: false,
        isTrendLine: false,
        mainState: MainState.MA,
        secondaryState: SecondaryState.MACD,
        onLoadMore: (bool isRight) {
          // Handle load more data if needed
        },
      );
    } catch (e) {
      print("Error rendering the chart: $e");
      return Center(child: Text("Error rendering chart: $e"));
    }
  }
}
