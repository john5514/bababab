import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:bicrypto/Controllers/market/chart__controller.dart';

class ChartPage extends StatelessWidget {
  final String pair;
  final ChartController _chartController;

  // Dummy data for testing
  final List<CandleData> dummyData = [
    CandleData(
        x: DateTime.now().subtract(Duration(days: 5)),
        open: 10,
        high: 15,
        low: 7,
        close: 13),
    CandleData(
        x: DateTime.now().subtract(Duration(days: 4)),
        open: 13,
        high: 17,
        low: 11,
        close: 15),
    CandleData(
        x: DateTime.now().subtract(Duration(days: 3)),
        open: 15,
        high: 18,
        low: 14,
        close: 16),
    CandleData(
        x: DateTime.now().subtract(Duration(days: 2)),
        open: 16,
        high: 19,
        low: 15,
        close: 18),
    CandleData(
        x: DateTime.now().subtract(Duration(days: 1)),
        open: 18,
        high: 20,
        low: 17,
        close: 19),
  ];

  ChartPage({required this.pair})
      : _chartController = Get.put(ChartController(pair));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Chart for $pair")),
      body: SfCartesianChart(
        plotAreaBorderColor: Colors.white,
        plotAreaBackgroundColor: Colors.black,
        borderWidth: 0.5,
        title: ChartTitle(
            text: '$pair Chart',
            textStyle: TextStyle(color: Colors.white, fontSize: 20)),
        legend: Legend(isVisible: false),
        series: <ChartSeries>[
          CandleSeries<CandleData, DateTime>(
            dataSource: dummyData, // Use the dummy data
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
    );
  }
}
