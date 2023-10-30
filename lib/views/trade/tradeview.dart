import 'package:bicrypto/Controllers/tarde/trade_controller.dart';
import 'package:bicrypto/views/market/markethome.dart';
import 'package:bicrypto/widgets/tradeorderbook.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'dart:ui';

class SfSliderThemeData {}

class TradeView extends StatelessWidget {
  final TradeController _tradeController = Get.put(TradeController());

  TradeView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments = Get.arguments;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Row(
          children: [
            Obx(() => Text(_tradeController.tradeName.value)),
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
      body: LayoutBuilder(
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
                              if (_tradeController.selectedOrderType.value ==
                                  "Limit") {
                                return Column(
                                  children: [
                                    TextFormField(
                                      controller:
                                          _tradeController.priceController,
                                      decoration: const InputDecoration(
                                          labelText: 'Price'),

                                      keyboardType: TextInputType
                                          .number, // Allow only number input
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      controller:
                                          _tradeController.amountController,
                                      decoration: const InputDecoration(
                                          labelText: 'Amount'),
                                      keyboardType: TextInputType
                                          .number, // Allow only number input
                                    ),
                                  ],
                                );
                              } else if (_tradeController
                                      .selectedOrderType.value ==
                                  "Market") {
                                return TextFormField(
                                  controller: _tradeController.amountController,
                                  decoration: const InputDecoration(
                                      labelText: 'Amount'),
                                  keyboardType: TextInputType
                                      .number, // Allow only number input
                                );
                              } else {
                                return Container();
                              }
                            }),
                            const SizedBox(height: 10),
                            _buildSlider(),
                            const SizedBox(height: 10),
                            _buildTakerFees(),
                            const SizedBox(height: 10),
                            _buildTotalExclFees(),
                            const SizedBox(height: 10),
                            _buildCost(),
                            const SizedBox(height: 20),
                            _buildTradeButton(), // Dropdown for Limit and Market
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
                const SizedBox(height: 10), // Some padding beneath the main row
                SizedBox(
                  height: constraints.maxHeight - 300,
                  child: _buildRecentTrades(),
                ),
              ],
            ),
          );
        },
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
            const Text("Taker Fees (0.1%)",
                style: TextStyle(color: Colors.white)), // Updated style
            Text(
                "${_tradeController.takerFees.value} ${_tradeController.firstPairName}",
                style: const TextStyle(color: Colors.white)), // Updated style
          ],
        ));
  }

  _buildTotalExclFees() {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Total (excl. fees)",
                style: TextStyle(color: Colors.white)), // Updated style
            Text(
                "${_tradeController.totalExclFees.value} ${_tradeController.firstPairName}",
                style: const TextStyle(color: Colors.white)), // Updated style
          ],
        ));
  }

  _buildCost() {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Cost",
                style: TextStyle(color: Colors.white)), // Updated style
            Text(
                "${_tradeController.cost.value} ${_tradeController.secondPairName}",
                style: const TextStyle(color: Colors.white)), // Updated style
          ],
        ));
  }

  Widget _buildTradeButton() {
    return Obx(() {
      var isBuy = _tradeController.activeAction.value == "Buy";
      return ElevatedButton(
        onPressed: () {
          if (isBuy) {
            _tradeController.buy();
          } else {
            _tradeController.sell(); // Implement this method in your controller
          }
        },
        style: ElevatedButton.styleFrom(
          primary: isBuy
              ? const Color.fromARGB(255, 101, 195, 104)
              : const Color.fromARGB(
                  255, 246, 84, 72), // Green for buy, red for sell
        ),
        child: Text(
          "${isBuy ? 'Buy' : 'Sell'} ${_tradeController.firstPairName}",
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
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
          const Color.fromARGB(255, 101, 195, 104); // Active color for Buy
      textColor = isActive
          ? Colors.white
          : Colors.white; // White text color for inactive
    } else {
      activeButtonColor =
          const Color.fromARGB(255, 246, 84, 72); // Active color for Sell
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
    return FlutterSlider(
      values: [_tradeController.sliderValue.value],
      min: 0,
      max: 100,
      onDragging: (handlerIndex, lowerValue, upperValue) {
        _tradeController.sliderValue.value = lowerValue;
      },
      handler: FlutterSliderHandler(
        decoration: const BoxDecoration(),
        child: const Material(
          type: MaterialType.canvas,
          color:
              Color.fromARGB(255, 177, 175, 175), // Darker diamond for handler
          elevation: 0,
          shape: DiamondShape(), // Custom diamond shape
          child: SizedBox(
            width: 16,
            height: 16,
          ),
        ),
      ),
      trackBar: FlutterSliderTrackBar(
        inactiveTrackBar: BoxDecoration(
          borderRadius: BorderRadius.circular(1),
          color: Colors.grey[300], // Lighter track color
        ),
        activeTrackBar: BoxDecoration(
          borderRadius: BorderRadius.circular(1),
          color: Colors
              .grey[300], // Keep it the same as inactive for consistent look
        ),
      ),
      tooltip: FlutterSliderTooltip(
        textStyle: const TextStyle(fontSize: 17, color: Colors.white),
        boxStyle: FlutterSliderTooltipBox(
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        format: (value) {
          return "${double.parse(value).toStringAsFixed(0)}%";
        },
      ),
      hatchMark: FlutterSliderHatchMark(
        smallLine: const FlutterSliderSizedBox(width: 2, height: 10),
        bigLine: const FlutterSliderSizedBox(width: 2, height: 20),
        density: 0.04,
        displayLines: false, // No lines, just the diamonds
        linesAlignment: FlutterSliderHatchMarkAlignment.right,
      ),
    );
  }
}

// Custom diamond shape
class DiamondShape extends ShapeBorder {
  const DiamondShape();

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..moveTo(rect.left + rect.width / 2, rect.top)
      ..lineTo(rect.right, rect.top + rect.height / 2)
      ..lineTo(rect.left + rect.width / 2, rect.bottom)
      ..lineTo(rect.left, rect.top + rect.height / 2)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
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
