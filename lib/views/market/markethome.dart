import 'package:bicrypto/Controllers/market/market_controller.dart';
import 'package:bicrypto/Style/styles.dart';
import 'package:bicrypto/services/market_service.dart';
import 'package:bicrypto/widgets/market/pairs_list.dart';
import 'package:bicrypto/widgets/market/search_pairs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class MarketScreen extends StatelessWidget {
  final MarketController _marketController = Get.put(MarketController());

  MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () {
                Get.to(() => SearchScreen()); // Navigate to the search screen
              },
              child: AbsorbPointer(
                child: CupertinoSearchTextField(
                  placeholder: 'Search Coin Pairs',
                  style: const TextStyle(color: Colors.white),
                  placeholderStyle: TextStyle(color: Colors.grey[400]),
                ),
              ),
            ),
          ),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Top Gainers'),
              Tab(text: 'Top Losers'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[400],
            indicator: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(
              color: Colors.yellow,
              width: 2.0,
            ))),
          ),
          backgroundColor: appTheme.scaffoldBackgroundColor,
          elevation: 0,
        ),
        body: TabBarView(
          children: [
            Obx(() => _buildMarketList(showGainers: true)),
            Obx(() => _buildMarketList(showGainers: false)),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketList({required bool showGainers}) {
    List<Market> sortedMarkets = List.from(_marketController.markets.value);
    if (showGainers) {
      sortedMarkets.sort((a, b) => b.change.compareTo(a.change));
    } else {
      sortedMarkets.sort((a, b) => a.change.compareTo(b.change));
    }

    return _marketController.isLoading.value
        ? const Center(child: CircularProgressIndicator())
        : pairs_listview(markets: sortedMarkets);
  }
}
