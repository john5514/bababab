import 'package:bicrypto/Style/styles.dart';
import 'package:bicrypto/services/market_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bicrypto/Controllers/market/market_controller.dart';
import 'package:bicrypto/widgets/market/pairs_list.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final MarketController _marketController =
      Get.find(); // Get the controller instance
  String query = '';
  List<Market> filteredMarkets = [];

  void _filterMarkets() {
    filteredMarkets = _marketController.markets.where((market) {
      return market.symbol.toLowerCase().contains(query.toLowerCase()) ||
          market.pair.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CupertinoSearchTextField(
          placeholder: 'Search Coin Pairs',
          style: const TextStyle(color: Colors.white),
          onChanged: (text) {
            setState(() {
              query = text;
              _filterMarkets();
            });
          },
        ),
        backgroundColor: appTheme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: PairsListView(markets: filteredMarkets),
    );
  }
}
