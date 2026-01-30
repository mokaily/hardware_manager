import 'package:flutter/material.dart';

import '../shapes/custom_circle_indicator.dart';

class CircularIndicatorButton extends StatelessWidget {
  final String centerText;
  final String bottomText;
  final double progress;
  final double size;
  final VoidCallback onTap;

  const CircularIndicatorButton({
    super.key,
    required this.centerText,
    required this.bottomText,
    required this.progress,
    this.size = 60,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CustomCircleIndicator(
                progress: progress,
                strokeWidth: 2,
                size: size,
                backgroundColor: Colors.grey.shade300,
                progressColor: Colors.indigo,
                sweepAnglePercent: 0.75,
              ),
              Text(
                centerText,
                style: TextStyle(
                  fontSize: size * 0.25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(bottomText),
        ],
      ),
    );
  }
}
