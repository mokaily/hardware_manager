import 'package:flutter/material.dart';
import '../shapes/rectangular_slider_thumb_shape.dart';
import '../shapes/rectangular_slider_track_shape.dart';

class VerticalSlider extends StatelessWidget {
  final double size;
  final double value;
  final ValueChanged<double> onChanged;
  final String bottomText;
  final double min;
  final double max;
  final int divisions;
  final int previewDivideNumber;

  const VerticalSlider({
    super.key,
    required this.size,
    required this.value,
    required this.onChanged,
    required this.bottomText,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions = 100,
    this.previewDivideNumber = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 115,
          child: Text(
            bottomText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
    Padding(
    padding: EdgeInsetsGeometry.only(bottom: 10),
    child: SizedBox(
          height: 110,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: size,
                  thumbShape: CustomRectangularSliderThumbShape(
                    thumbWidth: size,
                    thumbHeight: size + 1,
                    borderRadius: 7,
                    gradientColors: [
                      Colors.indigo[500]!,
                      Colors.indigo[900]!,
                    ],
                  ),
                  activeTrackColor: Colors.grey[300],
                  inactiveTrackColor: Colors.grey[300],
                  trackShape: const CustomRectangularSliderTrackShape(
                    borderRadius: 9,
                  ),
                ),
                child: RotatedBox(
                  quarterTurns: -1,
                  child: Slider(
                    min: min,
                    max: max,
                    divisions: divisions,
                    value: value,
                    onChanged: onChanged,
                  ),
                ),
              ),
              Text(
                '${(value * previewDivideNumber).round()}${previewDivideNumber == 1 ? "" : "%"}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        ),
      ],
    );
  }
}
