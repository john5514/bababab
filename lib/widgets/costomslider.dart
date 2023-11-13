import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSlider extends StatefulWidget {
  final RxDouble value;
  final int divisions;
  final ValueChanged<double> onChanged;

  const CustomSlider({
    Key? key,
    required this.value,
    required this.divisions,
    required this.onChanged,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CustomSliderState createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  OverlayEntry? _overlayEntry;

  void _showTooltip(Offset globalPosition, double value) {
    _overlayEntry?.remove();
    _overlayEntry = _createOverlayEntry(globalPosition, value);
    Overlay.of(context)?.insert(_overlayEntry!);
  }

  void _removeTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry(Offset position, double value) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var offset = renderBox.localToGlobal(position);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx - 30, // Center the box on the thumb
        top: offset.dy - 60, // Show above the slider thumb
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${(value * 100).toStringAsFixed(0)}%', // Convert value to percentage
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use Obx here to make sure the slider rebuilds whenever sliderValue changes
    return Obx(() {
      return GestureDetector(
        onHorizontalDragUpdate: (details) {
          RenderBox? box = context.findRenderObject() as RenderBox?;
          if (box != null) {
            Offset localOffset = box.globalToLocal(details.globalPosition);
            double newSliderValue =
                (localOffset.dx / box.size.width) * widget.divisions;
            if (newSliderValue >= 0 && newSliderValue <= widget.divisions) {
              double newValue = newSliderValue / widget.divisions;
              widget.onChanged(newValue);
              widget.value.value = newValue; // Update the RxDouble value
              _showTooltip(localOffset, newValue);
            }
          }
        },
        onHorizontalDragEnd: (details) {
          _removeTooltip();
        },
        child: SizedBox(
          width: double.infinity,
          height: 30,
          child: CustomPaint(
            painter: SliderPainter(
              value: widget.value.value, // Use the RxDouble value here
              divisions: widget.divisions,
            ),
          ),
        ),
      );
    });
  }
}

class SliderPainter extends CustomPainter {
  final double value;
  final int divisions;
  final double padding; // Added padding variable

  SliderPainter({
    required this.value,
    required this.divisions,
    this.padding = 11.0, // Default padding value of 20
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double trackHeight = 2;
    const double activeDiamondSize = 14;
    const double inactiveDiamondSize = 10;
    const double thumbDiamondSize = 20;
    const Color activeColor = Colors.white;
    final Color inactiveColor = Colors.grey.shade600;
    final paddedWidth =
        size.width - (padding * 2); // Adjust the width for padding

    // Paint for the track
    Paint trackPaint = Paint()
      ..color = inactiveColor
      ..strokeWidth = trackHeight;

    // Paint for the active track
    Paint activeTrackPaint = Paint()
      ..color = activeColor
      ..strokeWidth = trackHeight;

    // Draw the inactive track
    canvas.drawLine(
      Offset(padding, size.height / 2),
      Offset(size.width - padding, size.height / 2),
      trackPaint,
    );

    // Draw the active track
    canvas.drawLine(
      Offset(padding, size.height / 2),
      Offset(padding + paddedWidth * value, size.height / 2),
      activeTrackPaint,
    );

    // Draw the divisions
    for (int i = 0; i <= divisions; i++) {
      double x = padding + (paddedWidth / divisions) * i;
      bool isPassed = (x <= padding + paddedWidth * value);
      _drawDiamond(
        canvas,
        Offset(x, size.height / 2),
        isPassed ? activeDiamondSize : inactiveDiamondSize,
        isPassed ? activeColor : inactiveColor,
      );
    }

    // Draw the thumb as a diamond shape
    _drawDiamond(
      canvas,
      Offset(padding + paddedWidth * value, size.height / 2),
      thumbDiamondSize,
      activeColor,
    );
  }

  void _drawDiamond(
    Canvas canvas,
    Offset position,
    double size,
    Color color,
  ) {
    Paint diamondPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Path path = Path()
      ..moveTo(position.dx, position.dy - size / 2)
      ..lineTo(position.dx + size / 2, position.dy)
      ..lineTo(position.dx, position.dy + size / 2)
      ..lineTo(position.dx - size / 2, position.dy)
      ..close();

    canvas.drawPath(path, diamondPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
