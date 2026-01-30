import 'package:vibration/vibration.dart';
import 'dart:io';

class HapticsService {
  bool _isInitialized = false;
  bool _hasVibrator = false;
  bool _hasAmplitudeControl = false;

  /// Initialize haptics service
  Future<void> initialize() async {
    try {
      // Check if device has vibrator
      _hasVibrator = await Vibration.hasVibrator() ?? false;
      
      // Check if device supports amplitude control (Android 8.0+)
      _hasAmplitudeControl = await Vibration.hasAmplitudeControl() ?? false;
      
      _isInitialized = true;
    } catch (e) {
      throw HapticsException('Failed to initialize haptics service: $e');
    }
  }

  /// Trigger haptic feedback with intensity (0-255)
  Future<void> triggerHaptic(int intensity) async {
    try {
      if (!_isInitialized) {
        throw HapticsException('Haptics service not initialized');
      }

      if (!_hasVibrator) {
        // Device doesn't support vibration, silently return
        return;
      }

      // Clamp intensity between 0 and 255
      final clampedIntensity = intensity.clamp(0, 255);

      if (_hasAmplitudeControl) {
        // Android with amplitude control
        await Vibration.vibrate(
          duration: 100,
          amplitude: clampedIntensity,
        );
      } else {
        // iOS or older Android - use duration mapping
        final duration = _mapIntensityToDuration(clampedIntensity);
        await Vibration.vibrate(duration: duration);
      }
    } catch (e) {
      throw HapticsException('Failed to trigger haptic: $e');
    }
  }

  /// Preview haptic feedback (instant, short vibration)
  Future<void> previewHaptic(int intensity) async {
    try {
      if (!_isInitialized || !_hasVibrator) {
        return;
      }

      final clampedIntensity = intensity.clamp(0, 255);

      if (_hasAmplitudeControl) {
        // Quick preview with amplitude
        await Vibration.vibrate(
          duration: 50,
          amplitude: clampedIntensity,
        );
      } else {
        // Quick preview with duration
        final duration = _mapIntensityToDuration(clampedIntensity, isPreview: true);
        await Vibration.vibrate(duration: duration);
      }
    } catch (e) {
      // Silently fail for preview
      print('Preview haptic failed: $e');
    }
  }

  /// Trigger predefined haptic pattern
  Future<void> triggerPattern(HapticPattern pattern) async {
    try {
      if (!_isInitialized || !_hasVibrator) {
        return;
      }

      switch (pattern) {
        case HapticPattern.light:
          await Vibration.vibrate(duration: 20);
          break;
        case HapticPattern.medium:
          await Vibration.vibrate(duration: 50);
          break;
        case HapticPattern.heavy:
          await Vibration.vibrate(duration: 100);
          break;
        case HapticPattern.success:
          await Vibration.vibrate(pattern: [0, 50, 50, 50]);
          break;
        case HapticPattern.warning:
          await Vibration.vibrate(pattern: [0, 100, 50, 100]);
          break;
        case HapticPattern.error:
          await Vibration.vibrate(pattern: [0, 100, 100, 100, 100, 100]);
          break;
      }
    } catch (e) {
      throw HapticsException('Failed to trigger pattern: $e');
    }
  }

  /// Cancel ongoing vibration
  Future<void> cancel() async {
    try {
      await Vibration.cancel();
    } catch (e) {
      // Silently fail
      print('Failed to cancel vibration: $e');
    }
  }

  /// Map intensity (0-255) to duration in milliseconds
  int _mapIntensityToDuration(int intensity, {bool isPreview = false}) {
    if (isPreview) {
      // Preview: 10ms to 50ms
      return ((intensity / 255) * 40 + 10).round();
    } else {
      // Normal: 20ms to 200ms
      return ((intensity / 255) * 180 + 20).round();
    }
  }

  /// Check if iOS
  bool get isIOS => Platform.isIOS;

  /// Check if Android
  bool get isAndroid => Platform.isAndroid;

  /// Get capabilities info
  String getCapabilitiesInfo() {
    if (!_hasVibrator) {
      return 'No vibrator available';
    }
    if (_hasAmplitudeControl) {
      return 'Full haptic control (amplitude)';
    }
    return 'Basic haptic control (duration)';
  }

  /// Getters
  bool get hasVibrator => _hasVibrator;
  bool get hasAmplitudeControl => _hasAmplitudeControl;
  bool get isInitialized => _isInitialized;
}

/// Predefined haptic patterns
enum HapticPattern {
  light,
  medium,
  heavy,
  success,
  warning,
  error,
}

/// Custom exception for haptics errors
class HapticsException implements Exception {
  final String message;
  HapticsException(this.message);

  @override
  String toString() => 'HapticsException: $message';
}
