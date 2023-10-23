import 'package:bicrypto/Controllers/tarde/trade_controller.dart';
import 'package:bicrypto/widgets/market/orderbook.dart';
import 'package:bicrypto/widgets/tradeorderbook.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';

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
      body: Row(
        children: [
          // Buy and Sell Buttons and Dropdown
          Expanded(
            flex: 7, // 7 parts out of 10
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
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
                  _buildDropdown(), // Dropdown for Limit and Market
                ],
              ),
            ),
          ),
          // OrderBook
          Expanded(
            flex: 3, // 3 parts out of 10
            child: TradeOrderBookWidget(pair: arguments['pair']),
          ),
        ],
      ),
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
      buttonColor = Colors.white10;
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
      height: 40, // same height as the buttons
      color: Colors.white10, // Set the color here
      child: Obx(
        () => DropdownSearch<String>(
          selectedItem: _tradeController.selectedOrderType.value,
          items: const ["Limit", "Market"],
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              fillColor: Colors.white10,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          onChanged: (newValue) {
            if (newValue != null) {
              _tradeController.selectedOrderType.value = newValue;
            }
          },
          dropdownBuilder: (BuildContext context, String? selectedItem) {
            return Center(
              child: Text(
                selectedItem ?? "",
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            );
          },
          popupProps: const PopupProps.menu(
            fit: FlexFit.loose,
            menuProps: MenuProps(
              backgroundColor: Colors.white10,
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}
