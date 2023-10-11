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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Chart for $pair")),
      body: Obx(
        () => ListView(
          // <-- Added for vertical scrolling
          children: [
            Container(
              // <-- Wrap chart with a container to give a fixed height
              height:
                  MediaQuery.of(context).size.height * 0.7, // Example height
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
                  textStyle: TextStyle(color: Colors.white, fontSize: 20),
                ),
                legend: Legend(isVisible: false),
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
                  labelStyle: TextStyle(color: Colors.white),
                ),
                primaryYAxis: NumericAxis(
                  numberFormat: NumberFormat.simpleCurrency(),
                  opposedPosition: true,
                  majorTickLines: MajorTickLines(color: Colors.transparent),
                  minorTickLines: MinorTickLines(color: Colors.transparent),
                  axisLine: AxisLine(width: 0),
                  labelStyle: TextStyle(color: Colors.white),
                  majorGridLines: MajorGridLines(color: Colors.grey[800]!),
                  minorGridLines: MinorGridLines(color: Colors.grey[800]!),
                ),
              ),
            ),
            // You can add more widgets below the chart here if required.
          ],
        ),
      ),
    );
  }
}
