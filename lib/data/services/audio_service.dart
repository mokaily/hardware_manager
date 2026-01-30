import 'package:volume_controller/volume_controller.dart';
import 'dart:io';

class AudioService {
  final VolumeController _volumeController = VolumeController();
  
  /// Initialize audio service
  Future<void> initialize() async {
    try {
      // Listen to system volume changes (optional)
      _volumeController.showSystemUI = false; // Don't show system UI on volume change
    } catch (e) {
      throw AudioException('Failed to initialize audio service: $e');
    }
  }

  /// Set audio volume level (0.0 to 1.0)
  Future<void> setVolume(double level) async {
    try {
      // Clamp value between 0.0 and 1.0
      final clampedLevel = level.clamp(0.0, 1.0);
      
      _volumeController.setVolume(clampedLevel);
    } catch (e) {
      throw AudioException('Failed to set volume: $e');
    }
  }

  /// Get current audio volume level
  Future<double> getVolume() async {
    try {
      final volume = await _volumeController.getVolume();
      return volume;
    } catch (e) {
      throw AudioException('Failed to get volume: $e');
    }
  }

  /// Check if iOS (for platform-specific handling)
  bool get isIOS => Platform.isIOS;

  /// Check if Android
  bool get isAndroid => Platform.isAndroid;

  /// Get platform-specific volume info
  String getPlatformInfo() {
    if (isIOS) {
      return 'iOS: In-app audio control only';
    } else if (isAndroid) {
      return 'Android: System volume control';
    }
    return 'Unknown platform';
  }

  /// Dispose resources
  void dispose() {
    _volumeController.removeListener();
  }
}

/// Custom exception for audio errors
class AudioException implements Exception {
  final String message;
  AudioException(this.message);

  @override
  String toString() => 'AudioException: $message';
}
