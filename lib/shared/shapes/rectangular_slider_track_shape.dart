import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomRectangularSliderTrackShape extends SliderTrackShape {
  final double borderRadius;

  const CustomRectangularSliderTrackShape({this.borderRadius = 0});

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4.0;
    
    // Calculate horizontal padding based on overlay and thumb width
    // This defines the interactive range (Thumb center travel)
    final double overlayWidth = sliderTheme.overlayShape?.getPreferredSize(isEnabled, isDiscrete).width ?? 0;
    final double thumbWidth = sliderTheme.thumbShape?.getPreferredSize(isEnabled, isDiscrete).width ?? 0;
    
    final double horizontalPadding = math.max(overlayWidth / 2, thumbWidth / 2);
    
    final double trackLeft = offset.dx + horizontalPadding;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    // Calculate available width for travel
    final double trackWidth = math.max(0, parentBox.size.width - (horizontalPadding * 2));
    
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
      PaintingContext context,
      Offset offset, {
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required Animation<double> enableAnimation,
        required Offset thumbCenter,
        bool isDiscrete = false,
        bool isEnabled = false,
        TextDirection textDirection = TextDirection.ltr,
        Offset? secondaryOffset,
      }) {
    // We ignore the passed 'trackRect' (which is the interactive rect) 
    // and recalculate the Visual Track Rect to fill the parent box width.
    
    final double trackHeight = sliderTheme.trackHeight ?? 4.0;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    
    // The visual track fills the entire width
    final visualTrackRect = Rect.fromLTWH(offset.dx, trackTop, trackWidth, trackHeight);

    final activePaint = Paint()..color = sliderTheme.activeTrackColor!;
    final inactivePaint = Paint()..color = sliderTheme.inactiveTrackColor!;

    // Draw active part from visual Start to Thumb Center
    final left = Rect.fromLTRB(visualTrackRect.left, visualTrackRect.top, thumbCenter.dx, visualTrackRect.bottom);
    
    // Draw inactive part from Thumb Center to visual End
    final right = Rect.fromLTRB(thumbCenter.dx, visualTrackRect.top, visualTrackRect.right, visualTrackRect.bottom);

    context.canvas.drawRRect(RRect.fromRectAndRadius(left, Radius.circular(borderRadius)), activePaint);
    context.canvas.drawRRect(RRect.fromRectAndRadius(right, Radius.circular(borderRadius)), inactivePaint);
  }
}
