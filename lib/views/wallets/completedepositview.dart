import 'package:flutter/material.dart';

class CompleteDepositView extends StatelessWidget {
  final Map<String, dynamic> method;

  CompleteDepositView({Key? key, required this.method}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Deposit'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Complete the deposit using ${method['name']}'),
            ElevatedButton(
              onPressed: () {
                // Perform the deposit using the selected method
              },
              child: Text('Deposit'),
            ),
          ],
        ),
      ),
    );
  }
}
