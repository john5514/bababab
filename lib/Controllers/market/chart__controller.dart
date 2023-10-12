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
    _startTimer();
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
      if (candles.isNotEmpty) {
        volume24hUSDT.value = candles.last.close * candles.last.volume;
      } else {
        throw Exception('No data available for the past 24 hours');
      }
    } catch (e) {
      print("Error fetching 24h volume: $e");
      // Handle the error accordingly, maybe update the UI to show an error state
    }
  }

  void updateChartData(String timeframe) {
    currentTimeFrame.value = timeframe;
    _loadHistoricalData(timeframe);
  }

  Future<void> _loadHistoricalData([String timeframe = '1d']) async {
    try {
      final historicalData =
          await _marketService.fetchHistoricalData(pair, timeframe);
      if (historicalData.isEmpty) {
        print("Received empty historical data for $pair");
      } else {
        candleData.clear(); // Clear existing data
        candleData.addAll(historicalData);

        // Calculate and set the 24-hour high and low from the fetched data.
        high24h.value =
            historicalData.map((e) => e.high).reduce((a, b) => a > b ? a : b);
        low24h.value =
            historicalData.map((e) => e.low).reduce((a, b) => a < b ? a : b);

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
  final double volume;

  CandleData({
    required this.x,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });
}
