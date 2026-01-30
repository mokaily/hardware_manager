import 'package:equatable/equatable.dart';
import '../../data/models/profile_model.dart';

abstract class HardwareEvent extends Equatable {
  const HardwareEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize hardware services
class InitializeHardware extends HardwareEvent {
  const InitializeHardware();
}

/// Set audio level
class SetAudioLevel extends HardwareEvent {
  final double level;

  const SetAudioLevel(this.level);

  @override
  List<Object?> get props => [level];
}

/// Set haptics intensity
class SetHapticsIntensity extends HardwareEvent {
  final int intensity;
  final bool preview; // If true, trigger preview vibration

  const SetHapticsIntensity(this.intensity, {this.preview = false});

  @override
  List<Object?> get props => [intensity, preview];
}

/// Set brightness level
class SetBrightness extends HardwareEvent {
  final double level;

  const SetBrightness(this.level);

  @override
  List<Object?> get props => [level];
}

/// Apply all settings from a profile
class ApplyProfileSettings extends HardwareEvent {
  final ProfileModel profile;

  const ApplyProfileSettings(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Toggle simulation mode (for testing error handling)
class ToggleSimulationMode extends HardwareEvent {
  final bool enabled;

  const ToggleSimulationMode(this.enabled);

  @override
  List<Object?> get props => [enabled];
}
