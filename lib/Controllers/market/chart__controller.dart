import 'dart:async';
import 'package:bicrypto/services/market_service.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';

class ChartController extends GetxController {
  final String pair;
  final MarketService _marketService = MarketService();
  var candleData = <CandleData>[].obs;
  StreamSubscription? _marketSubscription;

  ChartController(this.pair);

  @override
  void onInit() {
    super.onInit();
    _initializeWebSocket();
  }

  @override
  void onClose() {
    _marketSubscription?.cancel();
    _marketService.dispose();
    super.onClose();
  }

  void _initializeWebSocket() {
    _marketService.connect('tickers');
    _marketSubscription =
        _marketService.marketUpdates.listen(_processMarketUpdate);
  }

  void _processMarketUpdate(List<Market> updatedMarkets) {
    final Market? specificMarket = updatedMarkets.firstWhereOrNull(
      (market) => '${market.symbol}/${market.pair}' == pair,
    );

    if (specificMarket != null) {
      final newData = CandleData(
        x: DateTime.now(),
        open: specificMarket.price,
        high: specificMarket.price + specificMarket.change,
        low: specificMarket.price - specificMarket.change,
        close: specificMarket.price,
      );

      candleData.add(newData);
    }
  }
}

class CandleData {
  final DateTime x;
  final double open;
  final double high;
  final double low;
  final double close;

  CandleData({
    required this.x,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });
}
