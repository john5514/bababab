import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CongratulationsScreen extends StatelessWidget {
  const CongratulationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define a text style for the congratulations message
    TextStyle messageStyle = const TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      shadows: <Shadow>[
        Shadow(
          offset: Offset(2.0, 2.0),
          blurRadius: 3.0,
          color: Color.fromARGB(150, 0, 0, 0),
        ),
      ],
    );

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Use a Container to constrain the size of the Lottie animation
            Container(
              height: 400, // Set a fixed height for the animation
              child: Lottie.asset('assets/animations/congrat.json'),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              child: Text(
                'Congratulations!\nTwo-Step Verification is enabled.',
                textAlign: TextAlign.center,
                style: messageStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
