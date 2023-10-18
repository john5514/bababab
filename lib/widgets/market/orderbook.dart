import 'package:bicrypto/Controllers/market/orederbook_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderBookView extends StatelessWidget {
  final OrderBookController _controller = Get.put(OrderBookController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Book')),
      body: Row(
        children: [
          // Bids (Buy orders)
          Expanded(
            child: Container(
              color: Colors.green[100], // Light green background for bids
              child: Obx(
                () => ListView.builder(
                  itemCount: _controller.bids.length,
                  itemBuilder: (context, index) {
                    final bid = _controller.bids[index];
                    return ListTile(
                      title: Text('${bid[0]}'), // Price
                      trailing: Text('${bid[1]}'), // Quantity
                    );
                  },
                ),
              ),
            ),
          ),

          // Asks (Sell orders)
          Expanded(
            child: Container(
              color: Colors.red[100], // Light red background for asks
              child: Obx(
                () => ListView.builder(
                  itemCount: _controller.asks.length,
                  itemBuilder: (context, index) {
                    final ask = _controller.asks[index];
                    return ListTile(
                      title: Text('${ask[0]}'), // Price
                      trailing: Text('${ask[1]}'), // Quantity
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
