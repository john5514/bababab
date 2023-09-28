import 'package:flutter/material.dart';

class SelectedMethodPage extends StatelessWidget {
  final Map<String, dynamic> selectedMethod;

  // Update the constructor to receive selectedMethod from the arguments
  const SelectedMethodPage({Key? key, required this.selectedMethod})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    bool isAgreedToTOS = false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Selected Method', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Method: ${selectedMethod['title']}',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              'Instructions: ${selectedMethod['instructions'] ?? 'N/A'}',
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Deposit Amount'),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Flat Tax', style: TextStyle(color: Colors.white)),
                Text('ALL ${selectedMethod['fixed_fee']}',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Percentage Tax', style: TextStyle(color: Colors.white)),
                Text('${selectedMethod['percentage_fee']}%',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('To pay today (ALL)',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                Text(
                    'ALL ${calculateTotalAmount(amountController.text, selectedMethod)}',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
            CheckboxListTile(
              title: Text('I agree to the Terms Of Service',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              value: isAgreedToTOS,
              onChanged: (value) {
                isAgreedToTOS = value!;
              },
            ),
            ElevatedButton(
              onPressed: isAgreedToTOS ? () {} : null,
              child: Text('Deposit'),
            ),
          ],
        ),
      ),
    );
  }

  double calculateTotalAmount(String amount, Map<String, dynamic> method) {
    double depositAmount = double.tryParse(amount) ?? 0;
    double fixedFee = (method['fixed_fee'] as num).toDouble();
    double percentageFee = (method['percentage_fee'] as num).toDouble();
    return depositAmount + fixedFee + (depositAmount * (percentageFee / 100));
  }
}
