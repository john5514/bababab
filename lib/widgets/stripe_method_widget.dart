import 'package:flutter/material.dart';

class StripeMethodWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stripe', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Text(
          'Stripe Payment Gateway will be implemented here.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
