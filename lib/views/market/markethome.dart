import 'package:bitcuit/Controllers/market/market_controller.dart';
import 'package:bitcuit/Style/styles.dart';
import 'package:bitcuit/services/market_service.dart';
import 'package:bitcuit/widgets/market/pairs_list.dart';
import 'package:bitcuit/widgets/market/search_pairs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class MarketScreen extends StatelessWidget {
  final MarketController _marketController = Get.put(MarketController());

  MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Update the length for the added tabs
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
              Tab(text: 'Gainers'),
              Tab(text: 'Losers'),
              Tab(text: 'Trending'), // New Tab for Trending
              Tab(text: 'Hot'), // New Tab for Hot
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
            _buildMarketTab('gainers'),
            _buildMarketTab('losers'),
            _buildMarketTab('trending'),
            _buildMarketTab('hot'),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketTab(String category) {
    return Obx(() {
      return RefreshIndicator(
        onRefresh: () => _marketController.refreshMarkets(),
        child: _marketController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : PairsListView(
                markets: _filterAndLimitMarkets(
                    _marketController.markets.value, category)),
      );
    });
  }

  List<Market> _filterAndLimitMarkets(List<Market> markets, String category) {
    List<Market> sortedMarkets = List.from(markets);

    switch (category) {
      case 'gainers':
        sortedMarkets.sort((a, b) => b.change.compareTo(a.change));
        break;
      case 'losers':
        sortedMarkets.sort((a, b) => a.change.compareTo(b.change));
        break;
      case 'trending':
        sortedMarkets.sort((a, b) => b.change.abs().compareTo(a.change.abs()));
        break;
      case 'hot':
        sortedMarkets.sort((a, b) => b.volume.compareTo(a.volume));
        break;
      default:
        break;
    }

    // Limit the list to 20 items
    return sortedMarkets.take(20).toList();
  }
}
