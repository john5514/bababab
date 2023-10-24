import 'package:bicrypto/Controllers/tarde/trade_controller.dart';
import 'package:bicrypto/widgets/tradeorderbook.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

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
      body: Column(
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
                                controller: _tradeController.priceController,
                                decoration:
                                    const InputDecoration(labelText: 'Price'),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _tradeController.amountController,
                                decoration:
                                    const InputDecoration(labelText: 'Amount'),
                              ),
                            ],
                          );
                        } else if (_tradeController.selectedOrderType.value ==
                            "Market") {
                          return TextFormField(
                            controller: _tradeController.amountController,
                            decoration:
                                const InputDecoration(labelText: 'Amount'),
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
                      _buildBuyButton(), // Dropdown for Limit and Market
                    ],
                  ),
                ),
              ),
              // OrderBook
              Expanded(
                flex: 4, // 3 parts out of 10
                child: TradeOrderBookWidget(pair: arguments['pair']),
              ),
            ],
          ),
          const SizedBox(height: 10), // Some padding beneath the main row
          Expanded(child: _buildRecentTrades()),
        ],
      ),
    );
  }

  Widget _buildRecentTrades() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color.fromARGB(101, 95, 95, 95)
            .withOpacity(0.7), // Slightly darker background
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: const Column(
        children: [
          Text(
            'Recent Trades',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Price', style: TextStyle(color: Colors.white)),
              Text('Amount', style: TextStyle(color: Colors.white)),
              Text('Time', style: TextStyle(color: Colors.white)),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'No trades yet.',
            style: TextStyle(color: Colors.white),
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

  _buildBuyButton() {
    return ElevatedButton(
      onPressed: () {
        // Logic to buy
        _tradeController.buy();
      },
      child: Text("Buy ${_tradeController.firstPairName}",
          style: const TextStyle(color: Colors.white)), // Updated style
    );
  }

  Widget _buildActionButton(BuildContext context, String title) {
    Color buttonColor;

    if (title == "Buy" && _tradeController.activeAction.value == "Buy") {
      buttonColor = const Color.fromARGB(255, 101, 195, 104);
    } else if (title == "Sell" &&
        _tradeController.activeAction.value == "Sell") {
      buttonColor = const Color.fromARGB(255, 246, 84, 72);
    } else {
      buttonColor = const Color.fromARGB(26, 255, 255, 255);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tradeController.activeAction.value =
              title; // Update the active action
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          color: buttonColor,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.0,
              color:
                  buttonColor == Colors.white10 ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.all(8.0),
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
        child: Material(
          type: MaterialType.canvas,
          color: Colors.orange,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          child: const SizedBox(
            // Empty container
            width: 20,
            height: 20,
          ),
        ),
      ),
      trackBar: FlutterSliderTrackBar(
        inactiveTrackBar: BoxDecoration(
          borderRadius: BorderRadius.circular(1),
          color: Colors.grey,
        ),
        activeTrackBar: BoxDecoration(
          borderRadius: BorderRadius.circular(1),
          color: Colors.orange,
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
        density: 0.04, // 25% division
        displayLines: true,
        linesAlignment: FlutterSliderHatchMarkAlignment.right,
      ),
    );
  }
}
