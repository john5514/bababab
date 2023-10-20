import 'package:bicrypto/Controllers/market/market_controller.dart';
import 'package:bicrypto/Style/styles.dart';
import 'package:bicrypto/services/market_service.dart';
import 'package:bicrypto/widgets/market/pairs_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // import cupertino package
import 'package:get/get.dart';

class MarketScreen extends StatelessWidget {
  final MarketController _marketController = Get.put(MarketController());

  MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: CupertinoSearchTextField(
            placeholder: 'Search coin pairs',
            style: TextStyle(color: Colors.white),
            placeholderStyle: TextStyle(color: Colors.grey[400]),
          ),
        ),
        backgroundColor: appTheme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Obx(() => Row(
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
                        fontSize:
                            !_marketController.showGainers.value ? 20 : 16,
                        color: !_marketController.showGainers.value
                            ? Colors.white
                            : Colors.grey[400],
                      ),
                    ),
                  ),
                ],
              )),
          SizedBox(height: 10),
          Expanded(
            child: Obx(() {
              List<Market> sortedMarkets =
                  List.from(_marketController.markets.value);
              if (_marketController.showGainers.value) {
                sortedMarkets.sort((a, b) => b.change.compareTo(a.change));
              } else {
                sortedMarkets.sort((a, b) => a.change.compareTo(b.change));
              }
              return _marketController.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : pairs_listview(markets: sortedMarkets);
            }),
          ),
        ],
      ),
    );
  }
}
