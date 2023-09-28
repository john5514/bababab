import 'package:flutter/material.dart';

class SelectedMethodPage extends StatelessWidget {
  final Map<String, dynamic> selectedMethod;

  const SelectedMethodPage({Key? key, required this.selectedMethod})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    bool isAgreedToTOS = false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedMethod['title'] ?? 'Selected Method',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${selectedMethod['title']}',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            SizedBox(height: 10),
            Text(
              'Instructions: ${selectedMethod['instructions'] ?? 'N/A'}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Deposit Amount',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
            ),
            SizedBox(height: 10),
            buildInfoRow('Flat Tax', 'ALL ${selectedMethod['fixed_fee']}'),
            buildInfoRow(
                'Percentage Tax', '${selectedMethod['percentage_fee']}%'),
            SizedBox(height: 10),
            buildInfoRow(
              'To pay today (ALL)',
              'ALL ${calculateTotalAmount(amountController.text, selectedMethod)}',
            ),
            CheckboxListTile(
              title: Text(
                'I agree to the Terms Of Service',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              value: isAgreedToTOS,
              onChanged: (value) {
                isAgreedToTOS = value!;
              },
              activeColor: Colors.orange,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: isAgreedToTOS ? () {} : null,
              child: Text('Deposit'),
              style: ElevatedButton.styleFrom(
                primary: Colors.orange,
                onPrimary: Colors.white,
                elevation: 6.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white)),
        Text(value, style: TextStyle(color: Colors.white)),
      ],
    );
  }

  double calculateTotalAmount(String amount, Map<String, dynamic> method) {
    double depositAmount = double.tryParse(amount) ?? 0;
    double fixedFee = (method['fixed_fee'] as num).toDouble();
    double percentageFee = (method['percentage_fee'] as num).toDouble();
    return depositAmount + fixedFee + (depositAmount * (percentageFee / 100));
  }
}
