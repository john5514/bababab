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
          children: [
            // Timeframe selector
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _chartController.currentTimeFrame.value,
                  dropdownColor: Colors.grey[800],
                  style: TextStyle(color: Colors.white),
                  items: ['1m', '5m', '15m', '1h', '4h', '8h', '12h', '1d']
                      .map((String timeframe) {
                    return DropdownMenuItem<String>(
                      value: timeframe,
                      child: Text(timeframe),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _chartController.updateChartData(newValue);
                    }
                  },
                ),
              ),
            ),
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
                  majorTickLines: MajorTickLines(color: Colors.transparent),
                  minorTickLines: MinorTickLines(color: Colors.transparent),
                  axisLine: AxisLine(width: 0),
                  labelStyle: TextStyle(color: Colors.white),
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
