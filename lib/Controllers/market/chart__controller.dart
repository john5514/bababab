import 'dart:async';
import 'dart:math';
import 'package:bicrypto/services/market_service.dart';
import 'package:get/get.dart';
import 'package:k_chart/flutter_k_chart.dart';

class ChartController extends GetxController {
  final Rx<Market?> currentMarket = Rx<Market?>(null);
  final Rx<Market?> lastMarket = Rx<Market?>(null);
  final RxDouble high24h = 0.0.obs;
  final RxDouble low24h = 0.0.obs;
  final RxDouble volume24h = 0.0.obs;
  final RxDouble volume24hUSDT = 0.0.obs;

  final String pair;
  final MarketService _marketService = MarketService();
  var kLineData = <CustomKLineEntity>[].obs;
  StreamSubscription? _marketSubscription;
  Timer? _timer;

  KLineEntity? _currentKLineEntity;

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
      final List<CustomKLineEntity> candles =
          await _marketService.fetchHistoricalData(pair, '1d', durationDays: 1);

      if (candles.isNotEmpty) {
        volume24hUSDT.value = candles.last.close * candles.last.vol;
      } else {
        throw Exception('No data available for the past 24 hours');
      }
    } catch (e) {
      print("Error fetching 24h volume: $e");
    }
  }

  void updateChartData(String timeframe) {
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
      kLineData.clear();
      // Commented out the next line as it might not work with the custom entity.
      // DataUtil.calculate(historicalData);
      kLineData.addAll(historicalData as Iterable<CustomKLineEntity>);

      if (historicalData.isNotEmpty) {
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
      if (_currentKLineEntity != null) {
        if (kLineData.length >= 500) {
          kLineData.removeAt(0);
        }
        kLineData.add(_currentKLineEntity! as CustomKLineEntity);
        _currentKLineEntity = null;
        update();
      }
    });
  }

  void _processMarketUpdate(List<Market> updatedMarkets) {
    final Market? specificMarket = updatedMarkets.firstWhereOrNull(
        (market) => '${market.symbol}/${market.pair}' == pair);

    if (specificMarket != null) {
      lastMarket.value = currentMarket.value;
      currentMarket.value = specificMarket;

      if (_currentKLineEntity == null) {
        _currentKLineEntity = KLineEntity.fromJson({
          'time': DateTime.now().millisecondsSinceEpoch,
          'open': specificMarket.price,
          'high': specificMarket.price,
          'low': specificMarket.price,
          'close': specificMarket.price,
          'vol': specificMarket.volume,
        });
      } else {
        _currentKLineEntity!.high =
            max(_currentKLineEntity!.high, specificMarket.price);
        _currentKLineEntity!.low =
            min(_currentKLineEntity!.low, specificMarket.price);
        _currentKLineEntity!.close = specificMarket.price;
      }
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

class CustomKLineEntity {
  final int time;
  final double open;
  double high; // Removed 'final'
  double low; // Removed 'final'
  double close; // Removed 'final'
  final double vol;

  CustomKLineEntity({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.vol,
  });
}
