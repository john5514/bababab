import 'dart:async';
import 'dart:math';
import 'package:bicrypto/services/market_service.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';

class ChartController extends GetxController {
  final String pair;
  final MarketService _marketService = MarketService();
  var candleData = <CandleData>[].obs;
  StreamSubscription? _marketSubscription;
  Timer? _timer;

  CandleData? _currentCandle;

  ChartController(this.pair);

  @override
  void onInit() {
    super.onInit();
    _loadHistoricalData();
    _initializeWebSocket();
    _startTimer();
  }

  @override
  void onClose() {
    _marketSubscription?.cancel();
    _marketService.dispose();
    _timer?.cancel();
    super.onClose();
  }

  Future<void> _loadHistoricalData() async {
    try {
      final historicalData = await _marketService.fetchHistoricalData(
          pair, "1d"); // "1d" is used as an example interval
      if (historicalData.isEmpty) {
        print("Received empty historical data for $pair");
      } else {
        candleData.addAll(historicalData);
        print("Received historical data: $historicalData");
      }
    } catch (e) {
      print("Error loading historical data: $e");
      // Handle the error accordingly
    }
  }

  void _initializeWebSocket() {
    _marketService.connect('tickers');
    _marketSubscription =
        _marketService.marketUpdates.listen(_processMarketUpdate);
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (_currentCandle != null) {
        candleData.add(_currentCandle!);
        _currentCandle = null;
      }
    });
  }

  void _processMarketUpdate(List<Market> updatedMarkets) {
    final Market? specificMarket = updatedMarkets.firstWhereOrNull(
      (market) => '${market.symbol}/${market.pair}' == pair,
    );

    if (specificMarket != null) {
      if (_currentCandle == null) {
        _currentCandle = CandleData(
          x: DateTime.now(),
          open: specificMarket.price,
          high: specificMarket.price,
          low: specificMarket.price,
          close: specificMarket.price,
        );
      } else {
        _currentCandle!.high = max(_currentCandle!.high, specificMarket.price);
        _currentCandle!.low = min(_currentCandle!.low, specificMarket.price);
        _currentCandle!.close = specificMarket.price;
      }
      update();
    }
  }
}

class CandleData {
  final DateTime x;
  final double open;
  double high;
  double low;
  double close;

  CandleData({
    required this.x,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });
}
