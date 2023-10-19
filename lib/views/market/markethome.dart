import 'package:bicrypto/Controllers/market/market_controller.dart';
import 'package:bicrypto/Style/styles.dart';
import 'package:bicrypto/services/market_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarketScreen extends StatelessWidget {
  final MarketController _marketController = Get.put(MarketController());

  MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    _marketController.showGainers.value = true;
                  },
                  child: Text(
                    'Top Gainers',
                    style: TextStyle(
                      fontSize: _marketController.showGainers.value ? 20 : 16,
                      color: _marketController.showGainers.value
                          ? Colors.white
                          : Colors.grey[400],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    _marketController.showGainers.value = false;
                  },
                  child: Text(
                    'Top Losers',
                    style: TextStyle(
                      fontSize: !_marketController.showGainers.value ? 20 : 16,
                      color: !_marketController.showGainers.value
                          ? Colors.white
                          : Colors.grey[400],
                    ),
                  ),
                ),
              ],
            )),
        backgroundColor: appTheme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Obx(() {
        List<Market> sortedMarkets = List.from(_marketController.markets.value);
        if (_marketController.showGainers.value) {
          sortedMarkets.sort((a, b) => b.change
              .compareTo(a.change)); // For gainers: Highest change at the top
        } else {
          sortedMarkets.sort((a, b) => a.change
              .compareTo(b.change)); // For losers: Lowest change at the top
        }
        return _marketController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : _buildMarketListView(sortedMarkets);
      }),
    );
  }

  Widget _buildMarketListView(List<Market> markets) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: appTheme.scaffoldBackgroundColor,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Name / Vol',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              Text('Last Price',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              Text('24h Change',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
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
