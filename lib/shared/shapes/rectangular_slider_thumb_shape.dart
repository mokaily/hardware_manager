import 'package:flutter/material.dart';

class CustomRectangularSliderThumbShape extends SliderComponentShape {
  final double thumbWidth;
  final double thumbHeight;
  final double borderRadius;

  final List<Color>? gradientColors;

  const CustomRectangularSliderThumbShape({
    required this.thumbWidth,
    required this.thumbHeight,
    this.borderRadius = 0,
    this.gradientColors,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(thumbWidth, thumbHeight);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter? labelPainter,
        required RenderBox? parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final rect = Rect.fromCenter(
      center: center,
      width: thumbWidth,
      height: thumbHeight,
    );

    Paint paint;
    if (gradientColors != null && gradientColors!.length >= 2) {
      final gradient = LinearGradient(
        colors: gradientColors!,
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      );
      paint = Paint()..shader = gradient.createShader(rect);
    } else {
      paint = Paint()..color = sliderTheme.thumbColor ?? Colors.blue;
    }

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    context.canvas.drawRRect(rrect, paint);
  }
}
