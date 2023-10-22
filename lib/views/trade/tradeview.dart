import 'package:bicrypto/Controllers/tarde/trade_controller.dart';
import 'package:bicrypto/widgets/market/orderbook.dart';
import 'package:bicrypto/widgets/tradeorderbook.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TradeView extends StatelessWidget {
  final TradeController _tradeController = Get.put(TradeController());

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments = Get.arguments;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Row(
          children: [
            Obx(() => Text(_tradeController.tradeName.value)),
            const SizedBox(width: 8.0),
            Obx(() => Text(
                  "${_tradeController.change24h.value}%",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.green,
                  ),
                )),
          ],
        ),
      ),
      body: Align(
        alignment: Alignment.topLeft, // Align to the beginning of the page
        child: FractionallySizedBox(
          widthFactor: 0.35, // Set the width to be 35% of the screen width
          child: TradeOrderBookWidget(pair: arguments['pair']),
        ),
      ),
    );
  }
}
