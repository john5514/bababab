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

  final RxString currentTimeFrame = '1h'.obs;
  double _previous24hVolume = 0; // To store the previous 24-hour volume

  ChartController(this.pair);
  bool _isInitialLoad = true;

  List<String> fallbackTimeFrames = [
    '1h',
    '15m',
    '1d',
    '4h'
  ]; // Add or remove as per your requirements
  int currentFallbackIndex = 0;
  final RxBool isLoading = true.obs; // <-- Added to track loading status
  final RxString errorMsg = ''.obs; // <-- Added to track error messages

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
          await _marketService.fetchHistoricalData(pair, '1h', numCandles: 1);

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
    print("Called updateChartData with timeframe: $timeframe");

    errorMsg.value = ''; // Reset the error message on user-initiated update
    _isInitialLoad = false; // Set to false as this is a manual update by user
    currentTimeFrame.value = timeframe;
    _loadHistoricalData(timeframe);

    if (_timer != null) {
      _timer!.cancel();
      _startTimer(_getUpdateInterval(timeframe));
    }
  }

  void _loadHistoricalData([String timeframe = '1h']) async {
    // If timeframe is 1s, clear the kLineData, add an initial entry, and refresh the chart.
    if (timeframe == '1s') {
      print(
          "Timeframe is 1s. Clearing kLineData, adding initial entry, and refreshing chart.");

      // Clear the kLineData
      kLineData.clear();

      // Add an initial entry if currentMarket has data
      if (currentMarket.value != null) {
        CustomKLineEntity initialEntity = CustomKLineEntity(
          time: DateTime.now().toUtc().millisecondsSinceEpoch,
          open: currentMarket.value!.price,
          high: currentMarket.value!.price,
          low: currentMarket.value!.price,
          close: currentMarket.value!.price,
          vol: 0, // You can adjust this as necessary
        );
        kLineData.add(initialEntity);
      }

      // Refresh the chart
      refreshChart();

      isLoading.value = false; // Stop the loading indicator
      return;
    }

    errorMsg.value = ''; // Reset the error message at the start
    isLoading.value = true; // Start the loading indicator
    print("Called _loadHistoricalData with timeframe: $timeframe");

    try {
      final historicalData = await _marketService
          .fetchHistoricalData(pair, timeframe, numCandles: 500);

      kLineData.clear();
      kLineData.addAll(historicalData);

      if (historicalData.isNotEmpty) {
        print("Last historical candle: ${historicalData.last}");

        high24h.value =
            historicalData.map((e) => e.high).reduce((a, b) => a > b ? a : b);
        low24h.value =
            historicalData.map((e) => e.low).reduce((a, b) => a < b ? a : b);
      }

      isLoading.value = false; // Stop the loading indicator
    } catch (e) {
      print("Error loading historical data: $e");

      if (_isInitialLoad) {
        currentFallbackIndex++;
        if (currentFallbackIndex < fallbackTimeFrames.length) {
          await Future.delayed(Duration(seconds: 2)); // Delay for 2 seconds
          currentTimeFrame.value = fallbackTimeFrames[currentFallbackIndex];
          _loadHistoricalData(currentTimeFrame.value);
        } else {
          print("All timeframes failed!");
          errorMsg.value = "Failed to fetch data for all timeframes.";
          isLoading.value = false; // Stop the loading indicator
        }
      } else {
        errorMsg.value = "Failed to fetch data for selected timeframe.";
        isLoading.value = false; // Stop the loading indicator
      }
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
        // Remove this block to not limit kLineData to 500
        // if (kLineData.length >= 500) {
        //   kLineData.removeAt(0);
        // }

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

      if (kLineData.isEmpty) {
        print("kLineData is empty! Cannot access last element.");
        return; // exit the function if the list is empty
      }

      double previousClose = kLineData.last.close;
      double adjustedVolume = specificMarket.volume - _previous24hVolume;
      _previous24hVolume = specificMarket
          .volume; // Store the current 24h volume for the next update

      CustomKLineEntity newEntry = CustomKLineEntity(
        time: DateTime.now().toUtc().millisecondsSinceEpoch, // Convert to UTC
        open: previousClose,
        high: specificMarket.price,
        low: specificMarket.price,
        close: specificMarket.price,
        vol: adjustedVolume,
      );
      print("New WebSocket candle: $newEntry"); // Add this line

      if (kLineData.isEmpty) {
        kLineData.add(newEntry);
      } else {
        bool isCurrentInterval = _isWithinCurrentInterval(kLineData.last.time);

        if (isCurrentInterval) {
          CustomKLineEntity lastEntry = kLineData.last;
          lastEntry.high = max(lastEntry.high, specificMarket.price);
          lastEntry.low = min(lastEntry.low, specificMarket.price);
          lastEntry.close = specificMarket.price;
          lastEntry.vol +=
              adjustedVolume; // Accumulate volume for the current interval
        } else {
          kLineData.add(newEntry);
        }
      }

      update();
      refreshChart();
    }
  }

  bool _isWithinCurrentInterval(int timestamp) {
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);

    DateTime now = DateTime.now().toUtc();

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
  @override
  String toString() {
    return '=================------==========Time: $time, Open: $open, High: $high, Low: $low, Close: $close, Vol: $vol';
  }
}
