import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/hardware/hardware_bloc.dart';
import '../../logic/hardware/hardware_event.dart';
import '../../logic/hardware/hardware_state.dart';
import '../../logic/profile/profile_bloc.dart';
import '../../logic/profile/profile_event.dart';
import '../../shared/indicators/vertical_slider_widget.dart';
import '../../shared/indicators/circular_indicator_button.dart';

class AudioControlWidget extends StatelessWidget {
  const AudioControlWidget({super.key});

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
              const double minGap = 8.0;
              const int itemCount = 5;

              final double availableWidthForItems =
                  constraints.maxWidth - (minGap * (itemCount - 1));

              double itemSize = availableWidthForItems / itemCount;
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
                        "AUDIO",
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
                            centerText: "0%",
                            bottomText: "MUTE",
                            progress: 0.0,
                            size: itemSize,
                            onTap: () {
                              setNewAudio(context, 0.0);
                            },
                          ),
                          CircularIndicatorButton(
                            centerText: "25%",
                            bottomText: "QUIET",
                            progress: 0.25,
                            size: itemSize,
                            onTap: () {
                              setNewAudio(context, 0.25);
                            },
                          ),
                          CircularIndicatorButton(
                            centerText: "50%",
                            bottomText: "NORMAL",
                            progress: 0.50,
                            size: itemSize,
                            onTap: () {
                              setNewAudio(context, 0.50);
                            },
                          ),
                          CircularIndicatorButton(
                            centerText: "75%",
                            bottomText: "LOUD",
                            progress: 0.75,
                            size: itemSize,
                            onTap: () {
                              setNewAudio(context, 0.75);
                            },
                          ),
                          VerticalSlider(
                            size: itemSize - 10,
                            value: state.audioLevel,
                            onChanged: (v) {
                              setNewAudio(context, v);
                            },
                            bottomText: "MASTER",
                          ),
                        ],
                      ),
                      SizedBox(
                        width: itemSize * 3,
                        height: 35,
                        child: Divider(height: 30, color: Colors.grey),
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

  void setNewAudio(BuildContext context, double value) {
    context.read<HardwareBloc>().add(SetAudioLevel(value));
    context.read<ProfileBloc>().add(UpdateProfileParameters(audioLevel: value));
  }
}
