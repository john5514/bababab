import 'package:bicrypto/Style/styles.dart';
import 'package:bicrypto/services/market_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PairsListView extends StatelessWidget {
  final List<Market> markets;

  PairsListView({Key? key, required this.markets}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        _buildHeader(),
        // List
        Expanded(
          child: ListView.builder(
            itemCount: markets.length,
            itemBuilder: (context, index) => _buildListItem(markets[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: appTheme.scaffoldBackgroundColor,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              flex: 6,
              child: Text('Name / Vol',
                  style: TextStyle(
                      color: Colors.grey, fontFamily: 'Inter', fontSize: 12))),
          Expanded(
              flex: 3,
              child: Text('Last Price',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      color: Colors.grey, fontFamily: 'Inter', fontSize: 12))),
          Expanded(
              flex: 3,
              child: Text('24h Change',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      color: Colors.grey, fontFamily: 'Inter', fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildListItem(Market market) {
    return ListTile(
      tileColor: appTheme.scaffoldBackgroundColor,
      onTap: () {
        Get.toNamed('/chart', arguments: '${market.symbol}/${market.pair}');
      },
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNameAndVolume(market),
          Container(
              child: _buildLastPrice(
                  market)), // Changed from Expanded to Container
          _buildChange(market),
        ],
      ),
    );
  }

  Widget _buildNameAndVolume(Market market) {
    return Expanded(
      flex: 6,
      child: Column(
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
    );
  }

  Widget _buildLastPrice(Market market) {
    return Expanded(
      flex: 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${market.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
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
    );
  }

  Widget _buildChange(Market market) {
    return Expanded(
      flex: 3,
      child: Container(
        alignment: Alignment.centerRight,
        child: Chip(
          label: Text(
            '${market.change.toStringAsFixed(2)}%',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          backgroundColor: market.change > 0
              ? Colors.green
              : market.change < 0
                  ? Colors.red
                  : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }
}
