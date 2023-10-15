import 'dart:async';
import 'dart:math';
import 'package:bicrypto/services/market_service.dart';
import 'package:get/get.dart';
import 'package:k_chart/flutter_k_chart.dart';
import 'package:flutter/material.dart'; // <-- Added this line for UniqueKey

class ChartController extends GetxController {
  final Rx<Market?> currentMarket = Rx<Market?>(null);
  final Rx<Market?> lastMarket = Rx<Market?>(null);
  final RxDouble high24h = 0.0.obs;
  final RxDouble low24h = 0.0.obs;
  final RxDouble volume24h = 0.0.obs;
  final RxDouble volume24hUSDT = 0.0.obs;

  final Rx<UniqueKey> chartKey = UniqueKey().obs; // <-- Added this line

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
      print(
          "===Loaded ${historicalData.length} historical data entries for $timeframe");

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
    print("WebSocket initialized");
    _marketService.connect('tickers');
    _marketSubscription =
        _marketService.marketUpdates.listen(_processMarketUpdate);
  }

  void _startTimer(Duration duration) {
    print("Starting timer with duration: $duration");
    _timer = Timer.periodic(duration, (timer) {
      if (_currentKLineEntity != null) {
        if (kLineData.length >= 500) {
          kLineData.removeAt(0);
        }

        CustomKLineEntity customEntity = CustomKLineEntity(
          time: _currentKLineEntity?.time ?? 0,
          open: _currentKLineEntity!.open,
          high: _currentKLineEntity!.high,
          low: _currentKLineEntity!.low,
          close: _currentKLineEntity!.close,
          vol: _currentKLineEntity!.vol,
        );

        kLineData.add(customEntity);
        _currentKLineEntity = null;
        update();
      }
    });
  }

  void refreshChart() {
    chartKey.value = UniqueKey();
  }

  void _processMarketUpdate(List<Market> updatedMarkets) {
    final Market? specificMarket = updatedMarkets.firstWhereOrNull(
        (market) => '${market.symbol}/${market.pair}' == pair);

    if (specificMarket != null) {
      lastMarket.value = currentMarket.value;
      currentMarket.value = specificMarket;

      CustomKLineEntity newEntry = CustomKLineEntity(
        time: DateTime.now().millisecondsSinceEpoch,
        open: specificMarket.price,
        high: specificMarket.price,
        low: specificMarket.price,
        close: specificMarket.price,
        vol: specificMarket.volume,
      );

      // If there's no data, create a new entry
      if (kLineData.isEmpty) {
        kLineData.add(newEntry);
      } else {
        // Check if the WebSocket data is for the current interval
        bool isCurrentInterval = _isWithinCurrentInterval(kLineData.last.time);
        print("Is current interval? $isCurrentInterval");

        if (isCurrentInterval) {
          // Update the last entry by replacing it with a new entry
          CustomKLineEntity lastEntry = kLineData.last;
          kLineData.last = CustomKLineEntity(
            time: lastEntry.time,
            open: lastEntry.open,
            high: max(lastEntry.high, specificMarket.price),
            low: min(lastEntry.low, specificMarket.price),
            close: specificMarket.price,
            vol: lastEntry.vol + specificMarket.volume,
          );
        } else {
          // Add the new entry for the new interval
          kLineData.add(newEntry);
        }
      }

      // Notify listeners of the change
      update();
      refreshChart(); // <-- Added this line
    }
  }

  bool _isWithinCurrentInterval(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateTime now = DateTime.now();
    switch (currentTimeFrame.value) {
      case '1d':
        return dateTime.day == now.day;
      case '1h':
        return dateTime.hour == now.hour;
      case '15m':
        DateTime roundedNow = now.subtract(Duration(minutes: now.minute % 15));
        return dateTime.isAfter(roundedNow);
      //add the other cases.
      case '1m':
        return dateTime.minute == now.minute;
      case '3m':
        return dateTime.minute % 3 == now.minute % 3;
      case '30m':
        return dateTime.minute % 30 == now.minute % 30;
      case '2h':
        return dateTime.hour % 2 == now.hour % 2;
      case '4h':
        return dateTime.hour % 4 == now.hour % 4;
      case '6h':
        return dateTime.hour % 6 == now.hour % 6;
      case '8h':
        return dateTime.hour % 8 == now.hour % 8;
      case '12h':
        return dateTime.hour % 12 == now.hour % 12;
      case '3d':
        return dateTime.day % 3 == now.day % 3;

      default:
        // Default to 1 minute if none matches
        Duration interval = Duration(minutes: 1);

        return false; // Default to false or handle other timeframes accordingly
    }
  }

  Duration _getUpdateInterval(String timeframe) {
    print("Timeframe selected: $timeframe");
    switch (timeframe) {
      case '1s':
        print("Timeframe selected: $timeframe");

        return Duration(seconds: 1);
      case '1m':
        print("Timeframe selected: $timeframe");

        return Duration(minutes: 1);
      case '3m':
        print("Timeframe selected: $timeframe");

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
  double vol;

  CustomKLineEntity({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.vol,
  });
}
