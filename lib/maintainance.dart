import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MaintenancePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/maintenance.json', // Your Lottie file
                width: MediaQuery.of(context).size.width * 0.6,
              ),
              const SizedBox(height: 30),
              const Text(
                'We’ll be back soon!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Sorry for the inconvenience but we’re performing some maintenance at the moment. We’ll be back up and running as soon as possible. Thank you for your patience!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Optional: Add logic to retry connection or reload the app
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
