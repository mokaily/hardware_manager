import 'package:equatable/equatable.dart';
import 'hardware_event.dart';

abstract class HardwareState extends Equatable {
  const HardwareState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class HardwareInitial extends HardwareState {
  const HardwareInitial();
}

/// Hardware services are initializing
class HardwareInitializing extends HardwareState {
  const HardwareInitializing();
}

/// Hardware is active with current values
class HardwareActive extends HardwareState {
  final double audioLevel;
  final int hapticsIntensity;
  final double brightness;
  final bool isSimulationMode;
  final String? error;
  final HardwareEvent? failedEvent;
  final int? errorTimestamp;

  const HardwareActive({
    required this.audioLevel,
    required this.hapticsIntensity,
    required this.brightness,
    this.isSimulationMode = false,
    this.error,
    this.failedEvent,
    this.errorTimestamp,
  });

  HardwareActive copyWith({
    double? audioLevel,
    int? hapticsIntensity,
    double? brightness,
    bool? isSimulationMode,
    String? error,
    HardwareEvent? failedEvent,
    bool clearError = false,
  }) {
    return HardwareActive(
      audioLevel: audioLevel ?? this.audioLevel,
      hapticsIntensity: hapticsIntensity ?? this.hapticsIntensity,
      brightness: brightness ?? this.brightness,
      isSimulationMode: isSimulationMode ?? this.isSimulationMode,
      error: clearError ? null : (error ?? this.error),
      failedEvent: clearError ? null : (failedEvent ?? this.failedEvent),
      errorTimestamp: clearError ? null : (error != null ? DateTime.now().millisecondsSinceEpoch : errorTimestamp),
    );
  }

  @override
  List<Object?> get props => [
        audioLevel,
        hapticsIntensity,
        brightness,
        isSimulationMode,
        error,
        failedEvent,
        errorTimestamp
      ];
}


