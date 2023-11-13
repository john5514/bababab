import 'package:flutter/material.dart';

class CustomSlider extends StatelessWidget {
  final double value;
  final int divisions;
  final ValueChanged<double> onChanged;

  const CustomSlider({
    Key? key,
    required this.value,
    required this.divisions,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This widget uses a GestureDetector to enable sliding functionality.
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        RenderBox? box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          Offset localOffset = box.globalToLocal(details.globalPosition);
          double newSliderValue = (localOffset.dx / box.size.width) * divisions;
          if (newSliderValue >= 0 && newSliderValue <= divisions) {
            onChanged(newSliderValue / divisions);
          }
        }
      },
      child: Container(
        width: double.infinity, // Container takes the full width of the parent
        height: 30, // Height of the slider area
        child: CustomPaint(
          painter: SliderPainter(
            value: value,
            divisions: divisions,
          ),
        ),
      ),
    );
  }
}

class SliderPainter extends CustomPainter {
  final double value;
  final int divisions;
  final double padding; // Added padding variable

  SliderPainter({
    required this.value,
    required this.divisions,
    this.padding = 20.0, // Default padding value of 20
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paddedWidth =
        size.width - (padding * 2); // Adjust the width for padding

    Paint trackPaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 2;

    // Draw the inactive track with padding
    canvas.drawLine(
      Offset(padding, size.height / 2),
      Offset(size.width - padding, size.height / 2),
      trackPaint,
    );

    // Draw the active track with padding
    trackPaint.color = Colors.green;
    canvas.drawLine(
      Offset(padding, size.height / 2),
      Offset(padding + paddedWidth * value, size.height / 2),
      trackPaint,
    );

    // Draw the dividers with padding
    for (int i = 0; i <= divisions; i++) {
      double x = padding + (paddedWidth / divisions) * i;
      bool isPassed = (x <= padding + paddedWidth * value);
      _drawDiamond(canvas, Offset(x, size.height / 2), isPassed);
    }

    // Draw the thumb with padding
    Paint thumbPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(padding + paddedWidth * value, size.height / 2),
      12, // Radius of thumb
      thumbPaint,
    );
  }

  void _drawDiamond(Canvas canvas, Offset position, bool isPassed) {
    Paint diamondPaint = Paint()
      ..color = isPassed ? Colors.white : Colors.grey.shade700
      ..style = PaintingStyle.fill;

    double size = 10; // Size of the diamond
    Path path = Path()
      ..moveTo(position.dx, position.dy - size)
      ..lineTo(position.dx + size, position.dy)
      ..lineTo(position.dx, position.dy + size)
      ..lineTo(position.dx - size, position.dy)
      ..close();

    canvas.drawPath(path, diamondPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
