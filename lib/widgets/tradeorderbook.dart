import 'dart:math';
import 'package:bicrypto/Controllers/market/orederbook_controller.dart';
import 'package:bicrypto/services/orderbook_service.dart';
import 'package:bicrypto/widgets/market/orderbook.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TradeOrderBookWidget extends StatelessWidget {
  final String pair;

  TradeOrderBookWidget({required this.pair});

  @override
  Widget build(BuildContext context) {
    final OrderBookController _orderBookController =
        Get.find<OrderBookController>();

    return Column(
      children: [
        const SizedBox(height: 20),
        const Text("Order Book", style: TextStyle(color: Colors.white)),
        const SizedBox(height: 10),
        Obx(
          () => _orderBookController.currentOrderBook.value == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    buildOrderBookSide(Colors.red, false),
                    const SizedBox(
                        height: 10), // Added padding between the two sides
                    buildOrderBookSide(Colors.green, true),
                  ],
                ),
        ),
      ],
    );
  }

  Widget buildOrderBookSide(Color color, bool isBids) {
    final OrderBookController _orderBookController =
        Get.find<OrderBookController>();
    final OrderBook? orderBook = _orderBookController.currentOrderBook.value;
    List<Order> orders = (isBids ? orderBook?.bids : orderBook?.asks)
            ?.map((e) => Order(e[0], e[1]))
            .toList() ??
        [];

    // Limit to 7 orders
    orders = orders.take(7).toList();

    final double maxPrice =
        orders.isEmpty ? 1 : orders.map((o) => o.price).reduce(max);
    final double minPrice =
        orders.isEmpty ? 1 : orders.map((o) => o.price).reduce(min);

    const double orderHeight = 20.0;

    return Container(
      height: orderHeight * 7, // Height for 7 orders
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          double widthFactor = (order.price - minPrice) / (maxPrice - minPrice);
          return Stack(
            alignment: Alignment
                .centerLeft, // Set to same direction for both bids and asks
            children: [
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: widthFactor,
                child: Opacity(
                  opacity: 0.2,
                  child: Container(color: color, height: orderHeight),
                ),
              ),
              Positioned(
                left: 8,
                child: Text(
                  order.quantity.toStringAsFixed(2),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
              Positioned(
                right: 8,
                child: Text(
                  order.price.toStringAsFixed(2),
                  style: TextStyle(
                    color: isBids ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
