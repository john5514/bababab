import 'package:bicrypto/Controllers/tarde/trade_controller.dart';
import 'package:bicrypto/Controllers/wallets/spot%20wallet/spotWallet_controller.dart';
import 'package:bicrypto/Style/styles.dart';
import 'package:bicrypto/services/market_service.dart';
import 'package:bicrypto/services/wallet_service.dart';
import 'package:bicrypto/views/wallets/spot/spot_currency.dart';
import 'package:bicrypto/widgets/costomslider.dart';
import 'package:bicrypto/widgets/tradeorderbook.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'dart:ui';

import 'package:intl/intl.dart';

class SfSliderThemeData {}

class TradeView extends StatelessWidget {
  final TradeController _tradeController = Get.put(TradeController());
  final WalletSpotController _walletSpotController =
      Get.put(WalletSpotController(walletService: Get.find<WalletService>()));
  final MarketService _marketService = Get.find<MarketService>();

  TradeView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments = Get.arguments;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Row(
            children: [
              Obx(
                () => Text(
                  _tradeController.tradeName.value,
                  style: const TextStyle(
                      color: Colors.white), // Set text color to white
                ),
              ),
              const SizedBox(width: 8.0),
              Obx(() => Text(
                    "${_tradeController.change24h.value}%",
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                    ),
                  )),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => _tradeController.refreshTradeData(),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Buy and Sell Buttons and Dropdown
                        Expanded(
                          flex: 7, // 7 parts out of 10
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 25, 10, 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Obx(() => Row(
                                      children: [
                                        _buildActionButton(context, 'Buy'),
                                        _buildActionButton(context, 'Sell'),
                                      ],
                                    )),
                                const SizedBox(height: 10), // spacing
                                _buildDropdown(),
                                const SizedBox(height: 10), // spacing
                                Obx(() {
                                  if (_tradeController
                                          .selectedOrderType.value ==
                                      "Limit") {
                                    return Column(
                                      children: [
                                        TextFormField(
                                          controller:
                                              _tradeController.priceController,
                                          onChanged: (value) {
                                            // When the user changes the price, update it in the controller
                                            var price = double.tryParse(value);
                                            if (price != null) {
                                              _tradeController
                                                  .updateMarketPrice(price);
                                            }
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'Price',
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            labelStyle: const TextStyle(
                                                color: Colors.white),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              borderSide: BorderSide.none,
                                            ),
                                            filled: true,
                                            fillColor: const Color(
                                                0xFF2C2F33), // Specific fill color for dark mode

                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                    horizontal:
                                                        12), // Reduced padding
                                          ),
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize:
                                                  14), // Smaller font size
                                        ),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          controller:
                                              _tradeController.amountController,
                                          decoration: InputDecoration(
                                            labelText: 'Amount',
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            labelStyle: const TextStyle(
                                                color: Colors.white),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              borderSide: BorderSide.none,
                                            ),
                                            filled: true,
                                            fillColor: const Color(
                                                0xFF2C2F33), // Specific fill color for dark mode

                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                    horizontal:
                                                        12), // Reduced padding
                                          ),
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize:
                                                  14), // Smaller font size
                                        ),
                                      ],
                                    );
                                  } else if (_tradeController
                                          .selectedOrderType.value ==
                                      "Market") {
                                    return TextFormField(
                                      controller:
                                          _tradeController.amountController,
                                      decoration: InputDecoration(
                                        labelText: 'Amount',
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        labelStyle: const TextStyle(
                                            color: Colors.white),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: const Color(
                                            0xFF2C2F33), // Specific fill color for dark mode
                                        prefixIcon: const Icon(Icons.balance,
                                            color: Colors.white),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 8,
                                                horizontal:
                                                    12), // Reduced padding
                                      ),
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14), // Smaller font size
                                    );
                                  } else {
                                    return Container();
                                  }
                                }),

                                const SizedBox(height: 25),
                                _buildSlider(),

                                const SizedBox(height: 20),
                                _buildTakerFees(),
                                // const SizedBox(height: 10),
                                // _buildTotalExclFees(),
                                const SizedBox(height: 10),
                                _buildCost(),
                                const Divider(
                                    color: Colors.white54), // Divider line
                                _buildAvailableBalance(), // Display available balance here
                                const SizedBox(height: 20),
                                _buildTradeButton(
                                    context), // Dropdown for Limit and Market
                              ],
                            ),
                          ),
                        ),
                        // OrderBook
                        Expanded(
                          flex: 4, // 4 parts out of 10
                          child: TradeOrderBookWidget(pair: arguments['pair']),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Tab bar and view for orders
                    Container(
                      height: constraints.maxHeight - 300,
                      child: Column(
                        children: [
                          Material(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            child: const TabBar(
                              tabs: [
                                Tab(text: 'Open Orders'),
                                Tab(text: 'Order History'),
                              ],
                              indicatorColor: Colors.orangeAccent,
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.grey,
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildOrdersList(_marketService, 'OPEN'),
                                _buildOrdersList(_marketService, 'CLOSED'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTrades() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(101, 75, 75, 75),
            Color.fromARGB(101, 95, 95, 95),
          ],
        ), // Gradient background
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ], // Shadow for a lifted effect
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: const Column(
        children: [
          Text(
            'Recent Trades',
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Price',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
              Text('Amount',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
              Text('Time',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          Divider(color: Colors.white38),
          SizedBox(height: 10),
          Text(
            'No trades yet.',
            style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
          )
        ],
      ),
    );
  }

  _buildTakerFees() {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${_tradeController.activeAction.value == 'Buy' ? 'Taker' : 'Maker'} Fees ",
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              //"${_tradeController.takerFees.value.toStringAsFixed(4)} ${_tradeController.firstPairName}",
              "${_tradeController.currentFee.toStringAsFixed(3)}%",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ));
  }

  Widget _buildOrdersList(MarketService marketService, String statusFilter) {
    return Obx(() {
      // Retrieve the correct list based on the status filter
      var filteredOrders = (statusFilter == 'OPEN')
          ? _tradeController.openOrders
          : _tradeController.orderHistory;

      if (filteredOrders.isEmpty) {
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text('No $statusFilter orders found'),
          ),
        );
      }

      return ListView.builder(
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return _buildOrderCard(order, marketService, context);
        },
      );
    });
  }

  Widget _buildOrderCard(
      Order order, MarketService marketService, BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Market:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(order.symbol),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Date:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                // Use the created_at field directly since it's now a DateTime object
                Text(DateFormat('MMMM dd, yyyy HH:mm:ss')
                    .format(order.created_at)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Side:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(order.side),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Price:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(order.price.toStringAsFixed(4)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Amount:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(order.amount.toString()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filled:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(order.filled.toString()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (order.status == 'OPEN' &&
                        order.filled ==
                            0.0) // Check if the order is open and unfilled
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () async {
                          bool success =
                              await marketService.cancelOrder(order.uuid);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Order successfully cancelled.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            // Optionally, refresh the list or update the UI
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to cancel order.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    Text(
                      order.status,
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // ... other widgets if any ...
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'OPEN':
        return Colors.orangeAccent;
      case 'CLOSED':
        return Colors.green;
      case 'CANCELED':
      case 'EXPIRED':
      case 'REJECTED':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  _buildCost() {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Cost", style: TextStyle(color: Colors.white)),
            Text(
                "${_tradeController.cost.value.toStringAsFixed(2)} ${_tradeController.secondPairName}",
                style: const TextStyle(color: Colors.white)),
          ],
        ));
  }

  _buildAvailableBalance() {
    // Obtain the second currency in the trading pair
    String secondCurrency = _tradeController.secondPairName;

    // Find the balance for the second currency from the spot wallet
    var currencyBalance = _walletSpotController.currencies.firstWhere(
        (currency) => currency['currency'] == secondCurrency,
        orElse: () => {'balance': 0.0} // Default to 0 if not found
        )['balance'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Available",
          style: TextStyle(color: Colors.grey),
        ),
        Text(
          "${currencyBalance.toStringAsFixed(2)} $secondCurrency",
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTradeButton(BuildContext context) {
    return Obx(() {
      var isBuy = _tradeController.activeAction.value == "Buy";
      String currencyCode =
          _tradeController.firstPairName; // Assuming this is the currency code

      // Wrap both buttons in a Row widget
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // OutlinedButton for the plus icon
          OutlinedButton(
            onPressed: () {
              // Navigate to CurrencySpotView when the button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CurrencySpotView(currencyCode: currencyCode),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: isBuy
                  ? appTheme.colorScheme.secondary
                  : appTheme.colorScheme.error,
              side: BorderSide(
                  color: isBuy
                      ? appTheme.colorScheme.secondary
                      : appTheme.colorScheme.error), // Border color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Icon(Icons.add,
                color: Colors.white), // Plus icon with white color
          ),
          const SizedBox(
              width: 8), // Space between the plus button and the buy button

          // Expanded to make the buy button take up the rest of the space
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (isBuy) {
                  _tradeController.buy();
                } else {
                  _tradeController.sell();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isBuy
                    ? appTheme.colorScheme.secondary
                    : appTheme.colorScheme.error,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Text(
                  "${isBuy ? 'Buy' : 'Sell'} ${_tradeController.firstPairName}"),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildActionButton(BuildContext context, String title) {
    Color activeButtonColor;
    Color inactiveButtonColor =
        const Color(0xFF2C2F33); // Gray color for inactive
    Color textColor;
    bool isActive = _tradeController.activeAction.value == title;

    if (title == "Buy") {
      activeButtonColor =
          appTheme.colorScheme.secondary; // Active color for Buy
      textColor = isActive
          ? Colors.white
          : Colors.white; // White text color for inactive
    } else {
      activeButtonColor = appTheme.colorScheme.error; // Active color for Sell
      textColor = isActive
          ? Colors.white
          : Colors.white; // White text color for inactive
    }

    return Expanded(
      child: SizedBox(
        height: 37, // Adjust height as needed
        child: GestureDetector(
          onTap: () {
            _tradeController.activeAction.value =
                title; // Update the active action
          },
          child: ClipPath(
            clipper:
                title == "Buy" ? LeftButtonClipper() : RightButtonClipper(),
            child: Container(
              color: isActive ? activeButtonColor : inactiveButtonColor,
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter', // Specify the font family
                    fontWeight: FontWeight.bold, // Make the font bold
                    fontSize: 16, // Set font size to 16
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonText(String title, Color buttonColor) {
    return Center(
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15.0,
          color: buttonColor.computeLuminance() > 0.5
              ? Colors.black
              : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F33), // Color of the dropdown
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.black26, // Border color
        ),
      ),
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            value: _tradeController.selectedOrderType.value,
            items: const ["Limit", "Market"]
                .map((String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Text color
                        ),
                      ),
                    ))
                .toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                _tradeController.selectedOrderType.value = newValue;
              }
            },
            buttonStyleData: ButtonStyleData(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: const Color(0xFF2C2F33), // Color of the dropdown
              ),
            ),
            iconStyleData: const IconStyleData(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.white, // Icon color
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: const Color(0xFF2C2F33), // Color of the dropdown menu
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 8.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlider() {
    return Obx(() {
      double maxSliderValue = _walletSpotController.currencies.firstWhere(
          (currency) => currency['currency'] == _tradeController.secondPairName,
          orElse: () => {'balance': 0.0})['balance'];

      // Update the available balance in the controller
      _tradeController.updateAvailableBalance(maxSliderValue);

      if (maxSliderValue <= 0) {
        _tradeController.sliderValue.value = 0;
        return const Text('No available balance.');
      }

      return CustomSlider(
        value: _tradeController.sliderValue,
        divisions: 4, // Assuming 100 divisions for granularity
        onChanged: (newValue) {
          _tradeController.sliderValue.value =
              newValue; // Update the RxDouble value
          _tradeController.updateAmountFromSlider();
        },
      );
    });
  }
}

class LeftButtonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0); // Start top-left
    path.lineTo(size.width, 0); // Top edge to top-right
    path.lineTo(size.width * 0.85, size.height); // Bottom edge, shifted left
    path.lineTo(0, size.height); // Bottom-left
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class RightButtonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.15, 0); // Start 15% from left along top edge
    path.lineTo(size.width, 0); // Top-right
    path.lineTo(size.width, size.height); // Bottom-right
    path.lineTo(0, size.height); // Bottom-left
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
