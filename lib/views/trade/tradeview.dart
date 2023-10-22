import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicrypto/Controllers/tarde/trade_controller.dart';

class TradeView extends StatelessWidget {
  final TradeController _tradeController = Get.put(TradeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context)
          .scaffoldBackgroundColor, // Set the background color same as parent
      appBar: AppBar(
        backgroundColor: Theme.of(context)
            .scaffoldBackgroundColor, // Set the AppBar background color same as parent
        title: Row(
          children: [
            Obx(() => Text(_tradeController.tradeName.value)),
            const SizedBox(width: 8.0), // Add a small space between
            Obx(() => Text(
                  "${_tradeController.change24h.value}%",
                  style: TextStyle(
                    fontSize: 20, // Enlarge a bit
                    color: Colors.green, // Set color to green
                  ),
                )),
          ],
        ),
      ),
      body: Center(
        child: Text("Trade content will be here"),
      ),
    );
  }
}
