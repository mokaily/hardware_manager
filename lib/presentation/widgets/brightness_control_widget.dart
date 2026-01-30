import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/hardware/hardware_bloc.dart';
import '../../logic/hardware/hardware_event.dart';
import '../../logic/hardware/hardware_state.dart';
import '../../logic/profile/profile_bloc.dart';
import '../../logic/profile/profile_event.dart';
import '../../shared/indicators/vertical_slider_widget.dart';
import '../../shared/indicators/circular_indicator_button.dart';

class BrightnessControlWidget extends StatelessWidget {
  const BrightnessControlWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HardwareBloc, HardwareState>(
      builder: (context, state) {
        if (state is! HardwareActive) {
          return const SizedBox.shrink();
        }

        return Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Determine responsive item size
              // 5 items, assuming roughly equal spacing preference
              // We want some gap (e.g. at least 8px)
              const double minGap = 8.0;
              const int itemCount = 5;

              // Calculate max available width for items removing gaps
              final double availableWidthForItems =
                  constraints.maxWidth - (minGap * (itemCount - 1));

              // Calculate raw item size
              double itemSize = availableWidthForItems / itemCount;

              // Cap the size so they don't get too large on big screens
              // but let them shrink as needed for small screens
              if (itemSize > 90) {
                itemSize = 90;
              }

              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Column(
                    children: [
                      Icon(Icons.circle, size: 18),
                      SizedBox(height: 5),
                      Text(
                        "BRIGHTNESS",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 35),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CircularIndicatorButton(
                            centerText: "50%",
                            bottomText: "Normal",
                            progress: 0.5,
                            size: itemSize,
                            onTap: () {
                              setNewBrightness(context, 0.50);

                            },
                          ),
                          CircularIndicatorButton(
                            centerText: "25%",
                            bottomText: "LOW",
                            progress: 0.25,
                            size: itemSize,
                            onTap: () {
                              setNewBrightness(context, 0.25);

                            },
                          ),
                          CircularIndicatorButton(
                            centerText: "10%",
                            bottomText: "DARK",
                            progress: 0.10,
                            size: itemSize,
                            onTap: () {
                              setNewBrightness(context, 0.10);

                            },
                          ),
                          CircularIndicatorButton(
                            centerText: "75%",
                            bottomText: "BRIGHT",
                            progress: 0.75,
                            size: itemSize,
                            onTap: () {
                              setNewBrightness(context, 0.75);
                            },
                          ),
                          VerticalSlider(
                            size: itemSize - 10,
                            value: state.brightness,
                            onChanged: (v) {
                              setNewBrightness(context, v);
                            },
                            bottomText: "LEDS",
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
  void setNewBrightness(BuildContext context, double value) {
    context.read<HardwareBloc>().add(
      SetBrightness(value),
    );
    context.read<ProfileBloc>().add(
      UpdateProfileParameters(brightness: value),
    );
  }
}
