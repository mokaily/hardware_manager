import 'package:screen_brightness/screen_brightness.dart';
import 'dart:io';

class BrightnessService {
  final ScreenBrightness _screenBrightness = ScreenBrightness();
  bool _isInitialized = false;

  /// Initialize brightness service
  Future<void> initialize() async {
    try {
      _isInitialized = true;
    } catch (e) {
      throw BrightnessException('Failed to initialize brightness service: $e');
    }
  }

  /// Set screen brightness (0.0 to 1.0)
  Future<void> setBrightness(double level) async {
    try {
      if (!_isInitialized) {
        throw BrightnessException('Brightness service not initialized');
      }

      // Clamp value between 0.0 and 1.0
      final clampedLevel = level.clamp(0.0, 1.0);

      await _screenBrightness.setScreenBrightness(clampedLevel);
    } catch (e) {
      throw BrightnessException('Failed to set brightness: $e');
    }
  }

  /// Get current screen brightness
  Future<double> getBrightness() async {
    try {
      if (!_isInitialized) {
        throw BrightnessException('Brightness service not initialized');
      }

      final brightness = await _screenBrightness.current;
      return brightness;
    } catch (e) {
      throw BrightnessException('Failed to get brightness: $e');
    }
  }

  /// Reset brightness to system default
  Future<void> resetBrightness() async {
    try {
      if (!_isInitialized) {
        throw BrightnessException('Brightness service not initialized');
      }

      await _screenBrightness.resetScreenBrightness();
    } catch (e) {
      throw BrightnessException('Failed to reset brightness: $e');
    }
  }

  /// Check if has permission to change brightness
  Future<bool> hasPermission() async {
    try {
      // Try to get current brightness to check permission
      await _screenBrightness.current;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if iOS
  bool get isIOS => Platform.isIOS;

  /// Check if Android
  bool get isAndroid => Platform.isAndroid;

  /// Get platform-specific info
  String getPlatformInfo() {
    if (isIOS) {
      return 'iOS: App-level brightness control';
    } else if (isAndroid) {
      return 'Android: System brightness control';
    }
    return 'Unknown platform';
  }

  /// Dispose resources
  Future<void> dispose() async {
    // Reset to system brightness when app closes
    try {
      await resetBrightness();
    } catch (e) {
      // Silently fail
      print('Failed to reset brightness on dispose: $e');
    }
  }

  bool get isInitialized => _isInitialized;
}

/// Custom exception for brightness errors
class BrightnessException implements Exception {
  final String message;
  BrightnessException(this.message);

  @override
  String toString() => 'BrightnessException: $message';
}
