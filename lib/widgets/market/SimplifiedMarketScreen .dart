import 'package:bicrypto/Controllers/home_controller.dart';
import 'package:bicrypto/Controllers/market/market_controller.dart';
import 'package:bicrypto/services/market_service.dart';
import 'package:bicrypto/widgets/market/simple_pairlist.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SimpleMarketScreen extends StatelessWidget {
  final MarketController _marketController = Get.put(MarketController());

  SimpleMarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Stack(
        children: [
          Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: TabBar(
                  isScrollable: true,
                  tabs: const [
                    Tab(text: 'Top Gainers'),
                    Tab(text: 'Top Losers'),
                    Tab(text: 'Trending'),
                    Tab(text: 'Hot'),
                  ],
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[400],
                  indicator: BoxDecoration(
                    color: Colors.grey[800], // Dark gray filled color
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  indicatorPadding:
                      const EdgeInsets.all(6), // Padding around the text
                  indicatorSize: TabBarIndicatorSize.tab, // Indicator size
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Obx(() => _buildMarketList(category: 'gainers')),
                    Obx(() => _buildMarketList(category: 'losers')),
                    Obx(() => _buildMarketList(category: 'trending')),
                    Obx(() => _buildMarketList(category: 'hot')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketList({required String category}) {
    List<Market> filteredMarkets =
        _filterAndLimitMarkets(_marketController.markets.value, category);

    return _marketController.isLoading.value
        ? const Center(child: CircularProgressIndicator())
        : SimplePairsListView(markets: filteredMarkets);
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
    return sortedMarkets.take(6).toList();
  }
}
