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
      body: Row(
        children: [
          // Buy and Sell Buttons
          Expanded(
            flex: 7, // 7 parts out of 10
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment
                    .start, // Aligns children to the start (top) of the column
                children: [
                  Row(
                    children: [
                      _buildActionButton(context, 'Buy',
                          Colors.amber), // Buy button with amber color
                      _buildActionButton(
                          context,
                          'Sell',
                          Colors
                              .white10), // Sell button with the color from the example
                    ],
                  ),
                ],
              ),
            ),
          ),
          // OrderBook
          Expanded(
            flex: 3, // 3 parts out of 10
            child: TradeOrderBookWidget(pair: arguments['pair']),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String title, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        color: color,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.0,
            color: color == Colors.white10 ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
