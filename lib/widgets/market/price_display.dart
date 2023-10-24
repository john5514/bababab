import 'package:flutter/material.dart';
import 'package:bicrypto/Controllers/market/chart__controller.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class PriceDisplay extends StatelessWidget {
  final ChartController chartController;

  const PriceDisplay({super.key, required this.chartController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          Text(
            "${chartController.currentMarket.value?.price ?? 0.0}",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              color: (chartController.lastMarket.value?.price ?? 0) <
                      (chartController.currentMarket.value?.price ?? 1)
                  ? Colors.green
                  : Colors.red,
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text:
                      "≈ \$ ${chartController.currentMarket.value?.price ?? 0.0}  ",
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                TextSpan(
                  text:
                      "${chartController.currentMarket.value?.change.toStringAsFixed(2) ?? '+0.00'}%",
                  style: TextStyle(
                    fontSize: 14,
                    color: (chartController.currentMarket.value?.change ?? 0) >
                            0
                        ? Colors.green
                        : (chartController.currentMarket.value?.change ?? 0) < 0
                            ? Colors.red
                            : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
