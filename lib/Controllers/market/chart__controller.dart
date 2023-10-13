import 'dart:async';
import 'dart:math';
import 'package:bicrypto/services/market_service.dart';
import 'package:get/get.dart';

class ChartController extends GetxController {
  final Rx<Market?> currentMarket = Rx<Market?>(null);
  final Rx<Market?> lastMarket = Rx<Market?>(null);
  final RxDouble high24h = 0.0.obs;
  final RxDouble low24h = 0.0.obs;
  final RxDouble volume24h = 0.0.obs;
  final RxDouble volume24hUSDT = 0.0.obs;

  final String pair;
  final MarketService _marketService = MarketService();
  var candleData = <CandleData>[].obs;
  StreamSubscription? _marketSubscription;
  Timer? _timer;

  CandleData? _currentCandle;

  final RxString currentTimeFrame = '1d'.obs;

  ChartController(this.pair);

  @override
  void onInit() {
    super.onInit();
    _loadHistoricalData(currentTimeFrame.value);
    fetch24hVolume();
    _initializeWebSocket();
    _startTimer(_getUpdateInterval(currentTimeFrame.value));
  }

  @override
  void onClose() {
    _marketSubscription?.cancel();
    _marketService.dispose();
    _timer?.cancel();
    super.onClose();
  }

  Future<void> fetch24hVolume() async {
    try {
      final List<CandleData> candles =
          await _marketService.fetchHistoricalData(pair, '1d', durationDays: 1);
      print("Fetched 24h volume data: $candles"); // Enhanced Debugging
      if (candles.isNotEmpty) {
        volume24hUSDT.value = candles.last.close * candles.last.volume;
      } else {
        throw Exception('No data available for the past 24 hours');
      }
    } catch (e) {
      print("Error fetching 24h volume: $e");
    }
  }

  void updateChartData(String timeframe) {
    print("Switching to timeframe: $timeframe"); // Enhanced Debugging
    print(
        "Candle data before switching: ${candleData.toList()}"); // Enhanced Debugging
    currentTimeFrame.value = timeframe;
    _loadHistoricalData(timeframe);

    if (_timer != null) {
      _timer!.cancel();
      _startTimer(_getUpdateInterval(timeframe));
    }
  }

  void _loadHistoricalData([String timeframe = '1d']) async {
    try {
      final historicalData =
          await _marketService.fetchHistoricalData(pair, timeframe);
      print(
          "Received historical data for $timeframe: $historicalData"); // Enhanced Debugging
      if (historicalData.isEmpty) {
        print("Received empty historical data for $pair");
      } else {
        print(
            "Clearing existing candles. Previous data: ${candleData.toList()}"); // Enhanced Debugging
        candleData.clear();
        print(
            "Adding new historical data: $historicalData"); // Enhanced Debugging
        candleData
            .addAll(historicalData.skip(max(0, historicalData.length - 500)));

        high24h.value =
            historicalData.map((e) => e.high).reduce((a, b) => a > b ? a : b);
        low24h.value =
            historicalData.map((e) => e.low).reduce((a, b) => a < b ? a : b);
      }
    } catch (e) {
      print("Error loading historical data: $e");
    }
  }

  void _initializeWebSocket() {
    _marketService.connect('tickers');
    _marketSubscription =
        _marketService.marketUpdates.listen(_processMarketUpdate);
  }

  void _startTimer(Duration duration) {
    _timer = Timer.periodic(duration, (timer) {
      print(
          "=====Timer triggered with duration: $duration"); // Enhanced Debugging
      if (_currentCandle != null) {
        if (candleData.length >= 500) {
          print("Removing the oldest candle to accommodate the new one.");
          candleData.removeAt(0);
        }
        print("Appending current candle to candleData.");
        candleData.add(_currentCandle!);
        _currentCandle = null; // Reset the current candle after appending
        update();
      }
    });
  }

  void _processMarketUpdate(List<Market> updatedMarkets) {
    print("========Processing WebSocket update..."); // Debugging
    final Market? specificMarket = updatedMarkets.firstWhereOrNull(
        (market) => '${market.symbol}/${market.pair}' == pair);

    if (specificMarket != null) {
      print("Received market update: $specificMarket"); // Enhanced Debugging
      lastMarket.value = currentMarket.value;
      currentMarket.value = specificMarket;

      if (_currentCandle == null) {
        _currentCandle = CandleData(
          x: DateTime.now(),
          open: specificMarket.price,
          high: specificMarket.price,
          low: specificMarket.price,
          close: specificMarket.price,
          volume: specificMarket.volume,
        );
      } else {
        _currentCandle!.high = max(_currentCandle!.high, specificMarket.price);
        _currentCandle!.low = min(_currentCandle!.low, specificMarket.price);
        _currentCandle!.close = specificMarket.price;
      }
      print("Updated current candle: $_currentCandle"); // Enhanced Debugging
    }
  }

  Duration _getUpdateInterval(String timeframe) {
    switch (timeframe) {
      case '1s':
        return Duration(seconds: 1);
      case '1m':
        return Duration(minutes: 1);
      case '3m':
        return Duration(minutes: 3);
      case '15m':
        return Duration(minutes: 15);
      case '30m':
        return Duration(minutes: 30);
      case '1h':
        return Duration(hours: 1);
      case '2h':
        return Duration(hours: 2);
      case '4h':
        return Duration(hours: 4);
      case '6h':
        return Duration(hours: 6);
      case '8h':
        return Duration(hours: 8);
      case '12h':
        return Duration(hours: 12);
      case '1d':
        return Duration(days: 1);
      case '3d':
        return Duration(days: 3);
      default:
        return Duration(minutes: 1); // Default to 1 minute if none matches
    }
  }
}

class CandleData {
  final DateTime x;
  final double open;
  double high;
  double low;
  double close;
  final double volume;

  CandleData({
    required this.x,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  // @override
  // String toString() {
  //   return '================CandleData(x: $x, open: $open, high: $high, low: $low, close: $close, volume: $volume)';
  // }
}
