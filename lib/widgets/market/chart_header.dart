import 'package:bicrypto/widgets/market/timeframe.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicrypto/Controllers/market/chart__controller.dart';

class ChartHeader extends StatelessWidget {
  final ChartController _chartController;
  final String pair;

  // ignore: prefer_const_constructors_in_immutables
  ChartHeader(this._chartController, this.pair, {super.key});

  String formatVolume(double volume) {
    return ' ${(volume / 1000000).toStringAsFixed(2)} M';
  }

  String getPrimarySymbol(String pair) {
    return pair.split('/').first;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${_chartController.currentMarket.value?.price ?? 0.0}",
                        style: TextStyle(
                          fontSize: 32,
                          color:
                              (_chartController.lastMarket.value?.price ?? 0) <
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
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white),
                            ),
                            TextSpan(
                              text:
                                  "${_chartController.currentMarket.value?.change.toStringAsFixed(2) ?? '+0.00'}%",
                              style: TextStyle(
                                fontSize: 14,
                                color: (_chartController
                                                .currentMarket.value?.change ??
                                            0) >
                                        0
                                    ? Colors.green
                                    : (_chartController.currentMarket.value
                                                    ?.change ??
                                                0) <
                                            0
                                        ? Colors.red
                                        : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text("24h High",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              Obx(() => Text(
                                  "${_chartController.high24h.value.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.white))),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Column(
                            children: [
                              Text("24h Vol(${getPrimarySymbol(pair)})",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              Text(
                                  "${formatVolume(_chartController.currentMarket.value?.volume ?? 0)}",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text("24h Low",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              Obx(() => Text(
                                  "${_chartController.low24h.value.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.white))),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Column(
                            children: [
                              const Text("24h Vol(USDT)",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              Obx(() => Text(
                                  "${formatVolume(_chartController.volume24hUSDT.value)}",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.white))),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TimeFrameSelector(),
              const Divider(
                color: Colors.grey,
                height: 1,
              ),
            ],
          ),
        ));
  }
}
