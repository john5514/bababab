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
    double? currentPrice = _chartController.currentMarket.value?.price;
    double? last24hPrice = _chartController.lastMarket.value?.price;
    double percentageChange = 0;
    if (currentPrice != null && last24hPrice != null && last24hPrice != 0) {
      percentageChange = ((currentPrice - last24hPrice) / last24hPrice) * 100;
    }

    String formatVolume(double volume) {
      return 'Vol ${(volume / 1000000).toStringAsFixed(2)} M';
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          children: [
            Icon(Icons.sync), // The arrow icons
            SizedBox(width: 8),
            Text(pair),
          ],
        ),
      ),
      body: Obx(
        () => ListView(
          children: [
            // Timeframe selector
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // This line will align the left column to the top
                    children: [
                      // Left content: Current price and 24h change
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${_chartController.currentMarket.value?.price ?? 0.0}",
                            style: TextStyle(
                              fontSize: 32,
                              color:
                                  (_chartController.lastMarket.value?.price ??
                                              0) <
                                          (_chartController
                                                  .currentMarket.value?.price ??
                                              1)
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                    text:
                                        "≈ ${_chartController.currentMarket.value?.price ?? 0.0}  ",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white)),
                                TextSpan(
                                    text:
                                        "${_chartController.currentMarket.value?.change.toStringAsFixed(2) ?? '+0.00'}%",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: (_chartController.currentMarket
                                                        .value?.change ??
                                                    0) >
                                                0
                                            ? Colors.green
                                            : (_chartController.currentMarket
                                                            .value?.change ??
                                                        0) <
                                                    0
                                                ? Colors.red
                                                : Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Right content: 24h High, 24h Low, and 24h Vol
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "24h High",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  Text(
                                    "${_chartController.currentMarket.value?.high24h ?? 0.0}",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  width:
                                      20), // Added spacing between the columns
                              Column(
                                children: [
                                  Text(
                                    "24h Low",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  Text(
                                    "${_chartController.currentMarket.value?.low24h ?? 0.0}",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                              height: 10), // Existing spacing between the rows
                          Column(
                            children: [
                              Text(
                                "24h Vol(USDT)",
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              Text(
                                "${formatVolume(_chartController.currentMarket.value?.volume ?? 0)}",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  DropdownButtonHideUnderline(
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
                ],
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
