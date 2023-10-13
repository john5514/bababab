import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicrypto/Controllers/market/chart__controller.dart';

class TimeFrameSelector extends GetView<ChartController> {
  final List<String> _mainTimeframes = ['15m', '1h', '4h', '1d', 'More'];
  final List<String> _moreTimeframes = [
    '1s',
    '1m',
    '3m',
    '30m',
    '2h',
    '6h',
    '8h',
    '12h',
    '3d'
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        width: MediaQuery.of(context).size.width * 0.6,
        padding: const EdgeInsets.only(left: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _mainTimeframes.map((tf) {
            return Container(
              height: 50,
              child: GestureDetector(
                onTap: () {
                  if (tf == 'More') {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return Container(
                          color: Colors.grey[800],
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: _moreTimeframes.map((timeframe) {
                              return GestureDetector(
                                onTap: () {
                                  controller.updateChartData(timeframe);
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    timeframe,
                                    style: TextStyle(
                                      color:
                                          controller.currentTimeFrame.value ==
                                                  timeframe
                                              ? Colors.white
                                              : Colors.grey,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    );
                  } else {
                    controller.updateChartData(tf);
                  }
                },
                child: Row(
                  children: [
                    Text(
                      tf,
                      style: TextStyle(
                        color: controller.currentTimeFrame.value == tf
                            ? Colors.white
                            : Colors.grey,
                      ),
                    ),
                    if (tf == 'More')
                      Icon(Icons.arrow_drop_down, color: Colors.grey)
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}
