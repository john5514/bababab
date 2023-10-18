import 'package:bicrypto/Controllers/market/orederbook_controller.dart';
import 'package:bicrypto/services/orderbook_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Order {
  final double price;
  final double quantity;

  Order(this.price, this.quantity);
}

class OrderBookWidget extends StatelessWidget {
  final String pair;
  final OrderBookController _orderBookController;

  OrderBookWidget({super.key, required this.pair})
      : _orderBookController = Get.put(OrderBookController(pair));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text("Order Book", style: TextStyle(color: Colors.white)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: buildOrderBookSide("Bids", Colors.green, true)),
            Expanded(child: buildOrderBookSide("Asks", Colors.red, false)),
          ],
        ),
      ],
    );
  }

  Widget buildOrderBookSide(String title, Color color, bool isBids) {
    final OrderBook? orderBook = _orderBookController.currentOrderBook.value;
    final List<Order> orders = (isBids ? orderBook?.bids : orderBook?.asks)
            ?.map((e) => Order(e[0], e[1]))
            .toList() ??
        [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: color)),
        const SizedBox(height: 10),
        ...orders.map((order) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.price.toString(), style: TextStyle(color: color)),
                Text(order.quantity.toString(),
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
