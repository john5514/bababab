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
    // Access the app's theme data
    final ThemeData themeData = appTheme;

    // Define the border colors for each tab using the theme's color scheme
    final List<Color> tabBorderColors = [
      themeData.colorScheme.secondary, // Green shade for 'Top Gainers'
      themeData.colorScheme.error, // Red shade for 'Top Losers'
      themeData.colorScheme.primary, // Orange shade for 'Trending'
      Colors.orange, // Additional color for 'Hot', update as needed
    ];

    return Column(
      children: <Widget>[
        Obx(() {
          // Use Obx to listen to tabIndex changes and rebuild the ButtonsTabBar
          return ButtonsTabBar(
            controller: _marketController.tabController,
            backgroundColor: themeData
                .scaffoldBackgroundColor, // Use the scaffold background color
            unselectedBackgroundColor: themeData
                .scaffoldBackgroundColor, // Use the scaffold background color
            labelStyle: themeData.textTheme.bodyLarge!.copyWith(
                color:
                    themeData.colorScheme.onSurface), // Use the onSurface color
            unselectedLabelStyle: themeData.textTheme.bodyLarge!
                .copyWith(color: Colors.white.withOpacity(0.6)),
            borderWidth: 2,
            borderColor: tabBorderColors[_marketController.tabIndex.value],

            unselectedBorderColor:
                appTheme.colorScheme.onSurface.withOpacity(0.1),
            radius: 8,
            contentPadding: const EdgeInsets.symmetric(horizontal: 11),
            buttonMargin: const EdgeInsets.symmetric(horizontal: 4),
            physics: const BouncingScrollPhysics(),
            tabs: const [
              Tab(icon: Icon(Icons.trending_up), text: 'Top Gainers'),
              Tab(icon: Icon(Icons.trending_down), text: 'Top Losers'),
              Tab(icon: Icon(Icons.trending_flat), text: 'Trending'),
              Tab(icon: Icon(Icons.whatshot), text: 'Hot'),
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
