import 'package:flutter/material.dart';

class MarketScreen extends StatefulWidget {
  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  bool showGainers = true; // to toggle between gainers and losers

  final Map<String, Map<String, String>> topGainers = {
    'BTCUSDT': {'baseVolume': '3000000', 'last': '50000', 'change': '2.5'},
    'ETHUSDT': {'baseVolume': '2000000', 'last': '3400', 'change': '1.5'},
    'XRPUSDT': {'baseVolume': '1000000', 'last': '1.1', 'change': '1.8'},
    'DOTUSDT': {'baseVolume': '500000', 'last': '25', 'change': '5.5'}
  };

  final Map<String, Map<String, String>> topLosers = {
    'LTCUSDT': {'baseVolume': '1800000', 'last': '120', 'change': '-2.5'},
    'BCHUSDT': {'baseVolume': '1500000', 'last': '480', 'change': '-3.1'},
    'LINKUSDT': {'baseVolume': '900000', 'last': '20', 'change': '-1.9'},
    'ADAUSDT': {'baseVolume': '700000', 'last': '1.4', 'change': '-4.2'}
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  showGainers = true;
                });
              },
              child: Text(
                'Top Gainers',
                style: TextStyle(
                  fontSize: showGainers ? 20 : 16,
                  color: showGainers ? Colors.white : Colors.grey[400],
                ),
              ),
            ),
            SizedBox(width: 20),
            GestureDetector(
              onTap: () {
                setState(() {
                  showGainers = false;
                });
              },
              child: Text(
                'Top Losers',
                style: TextStyle(
                  fontSize: showGainers ? 16 : 20,
                  color: showGainers ? Colors.grey[400] : Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black87,
      ),
      body: showGainers
          ? _buildMarketListView(topGainers)
          : _buildMarketListView(topLosers),
    );
  }

  Widget _buildMarketListView(Map<String, Map<String, String>> data) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.black87,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Name / Vol',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              Text('Last Price',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              Text('24h Change',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        // List
        Expanded(
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              var symbol = data.keys.elementAt(index);
              var entry = data[symbol];
              var volume = double.tryParse(entry?['baseVolume'] ?? '0') ?? 0;
              var volumeM = (volume / 1000000).toStringAsFixed(2);
              var lastPrice =
                  double.tryParse(entry?['last'] ?? '0')?.toStringAsFixed(2) ??
                      'N/A';
              var change = double.tryParse(entry?['change'] ?? '0') ?? 0;

              return ListTile(
                tileColor: index.isEven ? Colors.grey[850] : Colors.grey[900],
                onTap: () {
                  // Navigate to pair details
                },
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Name and Pair
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: symbol.substring(0, 3),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: '/${symbol.substring(3)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Vol $volumeM M',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    // Last Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$$lastPrice',
                          style: TextStyle(
                            fontSize: 16,
                            color: change > 0
                                ? Colors.green
                                : change < 0
                                    ? Colors.red
                                    : Colors.white,
                          ),
                        ),
                        Text(
                          '\$$lastPrice',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    // 24h Change
                    Chip(
                        label: Text('${change.toStringAsFixed(2)}%',
                            style: TextStyle(color: Colors.white)),
                        backgroundColor: change > 0
                            ? Colors.green
                            : change < 0
                                ? Colors.red
                                : Colors.grey,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
