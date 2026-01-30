import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/audio_service.dart';
import '../../data/services/haptics_service.dart';
import '../../data/services/brightness_service.dart';
import 'hardware_event.dart';
import 'hardware_state.dart';

class HardwareBloc extends Bloc<HardwareEvent, HardwareState> {
  final AudioService _audioService;
  final HapticsService _hapticsService;
  final BrightnessService _brightnessService;

  HardwareBloc({
    required AudioService audioService,
    required HapticsService hapticsService,
    required BrightnessService brightnessService,
  })  : _audioService = audioService,
        _hapticsService = hapticsService,
        _brightnessService = brightnessService,
        super(const HardwareInitial()) {
    on<InitializeHardware>(_onInitializeHardware);
    on<SetAudioLevel>(_onSetAudioLevel);
    on<SetHapticsIntensity>(_onSetHapticsIntensity);
    on<SetBrightness>(_onSetBrightness);
    on<ApplyProfileSettings>(_onApplyProfileSettings);
    on<ToggleSimulationMode>(_onToggleSimulationMode);
  }

  /// Toggle simulation mode
  Future<void> _onToggleSimulationMode(
    ToggleSimulationMode event,
    Emitter<HardwareState> emit,
  ) async {
    if (state is HardwareActive) {
      final currentState = state as HardwareActive;
      emit(currentState.copyWith(isSimulationMode: event.enabled));
    }
  }

  /// Initialize all hardware services
  Future<void> _onInitializeHardware(
    InitializeHardware event,
    Emitter<HardwareState> emit,
  ) async {
    try {
      emit(const HardwareInitializing());

      // Initialize all services
      await _audioService.initialize();
      await _hapticsService.initialize();
      await _brightnessService.initialize();

      // Get current values
      final currentAudio = await _audioService.getVolume();
      final currentBrightness = await _brightnessService.getBrightness();

      emit(HardwareActive(
        audioLevel: currentAudio,
        hapticsIntensity: 128, // Default middle value
        brightness: currentBrightness,
      ));
    } catch (e) {
      emit(HardwareActive(
        audioLevel: 0.5,
        hapticsIntensity: 128,
        brightness: 0.5,
        error: 'Failed to initialize hardware: ${e.toString()}',
        failedEvent: event,
      ));
    }
  }

  /// Set audio level
  Future<void> _onSetAudioLevel(
    SetAudioLevel event,
    Emitter<HardwareState> emit,
  ) async {
    try {
      if (state is! HardwareActive) return;

      final currentState = state as HardwareActive;

      // Check for simulation mode
      if (currentState.isSimulationMode) {
        throw Exception('Simulated audio failure');
      }

      // Apply audio level
      await _audioService.setVolume(event.level);

      // Update state
      // Update state
      emit(currentState.copyWith(
        audioLevel: event.level,
        clearError: true,
      ));
    } catch (e) {
      if (state is HardwareActive) {
        emit((state as HardwareActive).copyWith(
          error: e.toString(),
          failedEvent: event,
        ));
      }
    }
  }

  /// Set haptics intensity
  Future<void> _onSetHapticsIntensity(
    SetHapticsIntensity event,
    Emitter<HardwareState> emit,
  ) async {
    try {
      if (state is! HardwareActive) return;

      final currentState = state as HardwareActive;

      // Check for simulation mode
      if (currentState.isSimulationMode) {
        throw Exception('Simulated haptics failure');
      }

      // Trigger haptic feedback
      if (event.preview) {
        await _hapticsService.previewHaptic(event.intensity);
      } else {
        await _hapticsService.triggerHaptic(event.intensity);
      }

      // Update state
      // Update state
      emit(currentState.copyWith(
        hapticsIntensity: event.intensity,
        clearError: true,
      ));
    } catch (e) {
      if (state is HardwareActive) {
        emit((state as HardwareActive).copyWith(
          error: e.toString(),
          failedEvent: event,
        ));
      }
    }
  }

  /// Set brightness level
  Future<void> _onSetBrightness(
    SetBrightness event,
    Emitter<HardwareState> emit,
  ) async {
    try {
      if (state is! HardwareActive) return;

      final currentState = state as HardwareActive;

      // Check for simulation mode
      if (currentState.isSimulationMode) {
        throw Exception('Simulated brightness failure');
      }

      // Apply brightness
      await _brightnessService.setBrightness(event.level);

      // Update state
      // Update state
      emit(currentState.copyWith(
        brightness: event.level,
        clearError: true,
      ));
    } catch (e) {
      if (state is HardwareActive) {
        emit((state as HardwareActive).copyWith(
          error: e.toString(),
          failedEvent: event,
        ));
      }
    }
  }

  /// Apply all settings from a profile
  Future<void> _onApplyProfileSettings(
    ApplyProfileSettings event,
    Emitter<HardwareState> emit,
  ) async {
    try {
      // Apply all settings
      await _audioService.setVolume(event.profile.audioLevel);
      await _hapticsService.triggerHaptic(event.profile.hapticsIntensity);
      await _brightnessService.setBrightness(event.profile.brightness);

      // Update state
      // Update state
      emit(HardwareActive(
        audioLevel: event.profile.audioLevel,
        hapticsIntensity: event.profile.hapticsIntensity,
        brightness: event.profile.brightness,
      ));
    } catch (e) {
      if (state is HardwareActive) {
        emit((state as HardwareActive).copyWith(
          error: 'Failed to apply profile settings: ${e.toString()}',
          failedEvent: event,
        ));
      }
    }
  }
}
