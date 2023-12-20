import 'package:bicrypto/Controllers/market/market_controller.dart';
import 'package:bicrypto/Style/styles.dart';
import 'package:bicrypto/services/market_service.dart';
import 'package:bicrypto/widgets/market/simple_pairlist.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';

class SimpleMarketScreen extends StatelessWidget {
  final MarketController _marketController = Get.put(MarketController());

  SimpleMarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = appTheme;

    // Define the border colors for each tab using the theme's color scheme
    final List<Color> tabIndicatorColors = [
      themeData.colorScheme.secondary, // Green shade for 'Top Gainers'
      themeData.colorScheme.error, // Red shade for 'Top Losers'
      themeData.colorScheme.primary, // Orange shade for 'Trending'
      Colors.orange, // Additional color for 'Hot', update as needed
    ];

    return Column(
      children: <Widget>[
        Obx(() {
          int tabIndex = _marketController.tabIndex.value;
          return TabBar(
            controller: _marketController.tabController,
            labelStyle: themeData.textTheme.bodyLarge!
                .copyWith(color: themeData.colorScheme.onSurface),
            unselectedLabelStyle: themeData.textTheme.bodyLarge!
                .copyWith(color: Colors.white.withOpacity(0.6)),
            indicator: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: tabIndicatorColors[
                      tabIndex], // Selected tab's border color
                  width: 2.0, // Width of the border
                ),
              ),
            ),
            tabs: const [
              Tab(text: 'Gainers'),
              Tab(text: 'Losers'),
              Tab(text: 'Trending'),
              Tab(text: 'Hot'),
            ],
          );
        }),
        Expanded(
          child: TabBarView(
            controller: _marketController.tabController,
            children: [
              Obx(() => _buildMarketList(category: 'gainers')),
              Obx(() => _buildMarketList(category: 'losers')),
              Obx(() => _buildMarketList(category: 'trending')),
              Obx(() => _buildMarketList(category: 'hot')),
            ],
          ),
        ),
      ],
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
