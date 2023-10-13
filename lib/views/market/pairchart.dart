import 'package:bicrypto/widgets/market/chart_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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
        () => ListView(
          children: [
            ChartHeader(_chartController, pair),
            Container(
              height: MediaQuery.of(context).size.height * 0.7,
              child: SfCartesianChart(
                plotAreaBorderColor: Colors.white,
                plotAreaBackgroundColor: Colors.black,
                borderWidth: 0.5,
                zoomPanBehavior: ZoomPanBehavior(
                  enablePanning: true,
                  enablePinching: true,
                  zoomMode: ZoomMode.x,
                  enableDoubleTapZooming: true,
                ),
                title: ChartTitle(
                  text: '$pair Chart',
                  textStyle: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                legend: const Legend(isVisible: false),
                series: <ChartSeries>[
                  CandleSeries<CandleData, DateTime>(
                    dataSource: _chartController.candleData.toList(),
                    xValueMapper: (datum, _) => datum.x,
                    lowValueMapper: (datum, _) => datum.low,
                    highValueMapper: (datum, _) => datum.high,
                    openValueMapper: (datum, _) => datum.open,
                    closeValueMapper: (datum, _) => datum.close,
                    bearColor: Colors.red,
                    bullColor: Colors.green,
                    enableTooltip: true,
                  ),
                ],
                primaryXAxis: DateTimeAxis(
                  majorGridLines: MajorGridLines(color: Colors.grey[800]!),
                  minorGridLines: MinorGridLines(color: Colors.grey[800]!),
                  axisLine: AxisLine(color: Colors.grey[700]!),
                  labelStyle: const TextStyle(color: Colors.white),
                  visibleMinimum: _chartController.candleData.length > 30
                      ? _chartController
                          .candleData[_chartController.candleData.length - 30].x
                      : null,
                  visibleMaximum: _chartController.candleData.isNotEmpty
                      ? _chartController.candleData.last.x
                      : null,
                ),
                primaryYAxis: NumericAxis(
                  numberFormat: NumberFormat.simpleCurrency(),
                  opposedPosition: true,
                  majorTickLines:
                      const MajorTickLines(color: Colors.transparent),
                  minorTickLines:
                      const MinorTickLines(color: Colors.transparent),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: const TextStyle(color: Colors.white),
                  majorGridLines: MajorGridLines(color: Colors.grey[800]!),
                  minorGridLines: MinorGridLines(color: Colors.grey[800]!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
