import 'package:flutter/material.dart';
import 'dart:math';

class CustomCircleIndicator extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double strokeWidth;
  final double size;
  final Color backgroundColor;
  final Color progressColor;
  final double sweepAnglePercent; // 0.7 = 70% arc

  const CustomCircleIndicator({
    super.key,
    required this.progress,
    this.strokeWidth = 10,
    this.size = 100,
    this.backgroundColor = Colors.grey,
    this.progressColor = Colors.blue,
    this.sweepAnglePercent = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TopPartialCircularPainter(
          progress: progress,
          strokeWidth: strokeWidth,
          backgroundColor: backgroundColor,
          progressColor: progressColor,
          sweepAnglePercent: sweepAnglePercent,
        ),
      ),
    );
  }
}

class _TopPartialCircularPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final double sweepAnglePercent;

  _TopPartialCircularPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
    required this.sweepAnglePercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;

    // Start angle: to center the arc at the top (gap at bottom)
    // Top is 3pi/2 (or -pi/2). Start = Top - (sweep/2)
    final startAngle = (1.5 * pi) - (pi * sweepAnglePercent);
    final sweepAngle = 2 * pi * sweepAnglePercent; // how much of the circle is drawn

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw the background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    // Draw the progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress, // fill based on progress
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TopPartialCircularPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
