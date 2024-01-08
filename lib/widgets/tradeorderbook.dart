import 'dart:math';
import 'package:bitcuit/Controllers/market/orederbook_controller.dart';
import 'package:bitcuit/services/orderbook_service.dart';
import 'package:bitcuit/widgets/market/orderbook.dart';
import 'package:bitcuit/widgets/market/price_display.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TradeOrderBookWidget extends StatelessWidget {
  final String pair;

  const TradeOrderBookWidget({super.key, required this.pair});

  @override
  Widget build(BuildContext context) {
    final OrderBookController orderBookController =
        Get.find<OrderBookController>();

    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 8.0), // Left padding for Amount
              child: Text("Amount", style: TextStyle(color: Colors.grey)),
            ),
            Padding(
              padding: EdgeInsets.only(right: 8.0), // Right padding for Price
              child: Text("Price", style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Obx(
          () => orderBookController.currentOrderBook.value == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    buildOrderBookSide(Colors.red, false),
                    const SizedBox(height: 10),

                    // Add the PriceDisplay widget here
                    PriceDisplay(chartController: Get.find()),

                    const SizedBox(
                        height: 10), // Add some padding after the PriceDisplay
                    buildOrderBookSide(Colors.green, true),
                  ],
                ),
        ),
      ],
    );
  }

  Widget buildOrderBookSide(Color color, bool isBids) {
    final OrderBookController orderBookController =
        Get.find<OrderBookController>();
    final OrderBook? orderBook = orderBookController.currentOrderBook.value;
    List<Order> orders = (isBids ? orderBook?.bids : orderBook?.asks)
            ?.map((e) => Order(e[0], e[1]))
            .toList() ??
        [];

    // Limit to 7 orders
    orders = orders.take(9).toList();

    final double maxPrice =
        orders.isEmpty ? 1 : orders.map((o) => o.price).reduce(max);
    final double minPrice =
        orders.isEmpty ? 1 : orders.map((o) => o.price).reduce(min);

    const double orderHeight = 20.0;

    return SizedBox(
      height: orderHeight * 9, // Height for 7 orders
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
