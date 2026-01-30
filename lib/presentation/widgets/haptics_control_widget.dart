import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/hardware/hardware_bloc.dart';
import '../../logic/hardware/hardware_event.dart';
import '../../logic/hardware/hardware_state.dart';
import '../../logic/profile/profile_bloc.dart';
import '../../logic/profile/profile_event.dart';
import '../../shared/indicators/vertical_slider_widget.dart';
import '../../shared/indicators/circular_indicator_button.dart';

class HapticsControlWidget extends StatelessWidget {
  const HapticsControlWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<HardwareBloc, HardwareState>(
      listenWhen: (previous, current) {
        return current is HardwareActive &&
            current.error != null &&
            (previous is! HardwareActive ||
                previous.errorTimestamp != current.errorTimestamp ||
                previous.error != current.error);
      },
      listener: (context, state) {
        if (state is HardwareActive && state.error != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                action: state.failedEvent != null
                    ? SnackBarAction(
                        label: 'Retry',
                        textColor: Colors.white,
                        onPressed: () {
                          if (state.isSimulationMode) {
                            context
                                .read<HardwareBloc>()
                                .add(const ToggleSimulationMode(false));
                          }
                          context.read<HardwareBloc>().add(state.failedEvent!);
                        },
                      )
                    : null,
              ),
            );
        }
      },
      child: BlocBuilder<HardwareBloc, HardwareState>(
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
                          "HAPTIC",
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
                              centerText: "120",
                              bottomText: "Normal",
                              progress: 0.47,
                              size: itemSize,
                              onTap: () {
                                setNewHaptics(context, 120);
                              },
                            ),
                            CircularIndicatorButton(
                              centerText: "60",
                              bottomText: "HESITATE",
                              progress: 0.235,
                              size: itemSize,
                              onTap: () {
                                setNewHaptics(context, 60);
                              },
                            ),
                            CircularIndicatorButton(
                              centerText: "225",
                              bottomText: "BOOST",
                              progress: 0.88,
                              size: itemSize,
                              onTap: () {
                                setNewHaptics(context, 225);
                              },
                            ),
                            CircularIndicatorButton(
                              centerText: "30",
                              bottomText: "LOW",
                              progress: 0.12,
                              size: itemSize,
                              onTap: () {
                                setNewHaptics(context, 30);
                              },
                            ),
                              VerticalSlider(
                                size: itemSize - 10,
                                min: 0.0,
                                max: 255.0,
                                previewDivideNumber: 1,
                              value: state.hapticsIntensity + 0.0,
                              onChanged: (v) {
                                setNewHaptics(context, v);
                              },
                              bottomText: "FEEDBACK",
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
      ),
    );
  }

  void setNewHaptics(BuildContext context, double value) {
    final intensity = value.round();
    // Update hardware with preview
    context.read<HardwareBloc>().add(
      SetHapticsIntensity(intensity, preview: true),
    );
    // Mark profile as modified
    context.read<ProfileBloc>().add(
      UpdateProfileParameters(hapticsIntensity: intensity),
    );
  }
}
