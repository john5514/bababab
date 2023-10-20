import 'package:bicrypto/Style/styles.dart';
import 'package:bicrypto/services/market_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class pairs_listview extends StatelessWidget {
  const pairs_listview({
    super.key,
    required this.markets,
  });

  final List<Market> markets;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: appTheme.scaffoldBackgroundColor,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Name / Vol', style: TextStyle(color: Colors.grey)),
              Text('Last Price', style: TextStyle(color: Colors.grey)),
              Text('24h Change', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        // List
        Expanded(
          child: ListView.builder(
            itemCount: markets.length,
            itemBuilder: (context, index) {
              var market = markets[index];
              return ListTile(
                tileColor: appTheme.scaffoldBackgroundColor,
                onTap: () {
                  Get.toNamed('/chart',
                      arguments: '${market.symbol}/${market.pair}');
                },
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Name and Pair
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: market.symbol,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: '/${market.pair}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Vol ${(market.volume / 1000000).toStringAsFixed(2)} M',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    // Last Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${market.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: market.change > 0
                                ? Colors.green
                                : market.change < 0
                                    ? Colors.red
                                    : Colors.white,
                          ),
                        ),
                        Text(
                          '\$${market.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    // 24h Change
                    Chip(
                        label: Text('${market.change.toStringAsFixed(2)}%',
                            style: const TextStyle(color: Colors.white)),
                        backgroundColor: market.change > 0
                            ? Colors.green
                            : market.change < 0
                                ? Colors.red
                                : Colors.grey,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
