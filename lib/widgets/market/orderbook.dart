import 'dart:math';
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

  OrderBookWidget({Key? key, required this.pair})
      : _orderBookController = Get.put(OrderBookController(pair)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text("Order Book", style: TextStyle(color: Colors.white)),
        const SizedBox(height: 10),
        Obx(
          () => _orderBookController.currentOrderBook.value == null
              ? const Center(
                  child:
                      CircularProgressIndicator()) // Show loading indicator when data is null
              : Row(
                  children: [
                    Expanded(child: buildOrderBookSide(Colors.green, true)),
                    Expanded(child: buildOrderBookSide(Colors.red, false)),
                  ],
                ),
        ),
      ],
    );
  }

  Widget buildOrderBookSide(Color color, bool isBids) {
    final OrderBook? orderBook = _orderBookController.currentOrderBook.value;
    List<Order> orders = (isBids ? orderBook?.bids : orderBook?.asks)
            ?.map((e) => Order(e[0], e[1]))
            .toList() ??
        [];

    if (isBids) {
      orders = orders.reversed.toList();
    }

    final double maxPrice =
        orders.isEmpty ? 1 : orders.map((o) => o.price).reduce(max);
    final double minPrice =
        orders.isEmpty ? 1 : orders.map((o) => o.price).reduce(min);

    const double orderHeight = 20.0; // The height of each order
    const double containerHeight =
        20 * orderHeight; // Assuming maximum of 20 orders

    return Container(
      height: containerHeight,
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          double widthFactor = (order.price - minPrice) / (maxPrice - minPrice);

          return Stack(
            alignment: isBids ? Alignment.centerRight : Alignment.centerLeft,
            children: [
              FractionallySizedBox(
                alignment:
                    isBids ? Alignment.centerRight : Alignment.centerLeft,
                widthFactor: widthFactor,
                child: Opacity(
                  opacity: 0.2, // Adjust the opacity as per your requirements
                  child: Container(color: color, height: orderHeight),
                ),
              ),
              Positioned(
                left: isBids ? 8 : null,
                right: isBids ? null : 8,
                child: Text(
                  order.quantity.toStringAsFixed(2),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
              Positioned(
                left: isBids ? null : 8,
                right: isBids ? 8 : null,
                child: Text(
                  order.price.toStringAsFixed(2),
                  style: TextStyle(
                    color: isBids ? Colors.green : Colors.red,
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
