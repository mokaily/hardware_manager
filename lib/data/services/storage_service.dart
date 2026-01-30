import 'package:hive_flutter/hive_flutter.dart';
import '../models/profile_model.dart';

class StorageService {
  static const String _profilesBoxName = 'profiles';
  Box<ProfileModel>? _profilesBox;

  /// Initialize Hive and open boxes
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      
      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ProfileModelAdapter());
      }

      // Open boxes
      _profilesBox = await Hive.openBox<ProfileModel>(_profilesBoxName);
    } catch (e) {
      throw StorageException('Failed to initialize storage: $e');
    }
  }

  /// Get all profiles
  List<ProfileModel> getAllProfiles() {
    try {
      if (_profilesBox == null) {
        throw StorageException('Storage not initialized');
      }
      return _profilesBox!.values.toList();
    } catch (e) {
      throw StorageException('Failed to load profiles: $e');
    }
  }

  /// Get profile by ID
  ProfileModel? getProfile(String id) {
    try {
      if (_profilesBox == null) {
        throw StorageException('Storage not initialized');
      }
      return _profilesBox!.get(id);
    } catch (e) {
      throw StorageException('Failed to get profile: $e');
    }
  }

  /// Save or update profile
  Future<void> saveProfile(ProfileModel profile) async {
    try {
      if (_profilesBox == null) {
        throw StorageException('Storage not initialized');
      }
      await _profilesBox!.put(profile.id, profile);
    } catch (e) {
      throw StorageException('Failed to save profile: $e');
    }
  }

  /// Delete profile
  Future<void> deleteProfile(String id) async {
    try {
      if (_profilesBox == null) {
        throw StorageException('Storage not initialized');
      }
      await _profilesBox!.delete(id);
    } catch (e) {
      throw StorageException('Failed to delete profile: $e');
    }
  }

  /// Clear all profiles (for testing)
  Future<void> clearAllProfiles() async {
    try {
      if (_profilesBox == null) {
        throw StorageException('Storage not initialized');
      }
      await _profilesBox!.clear();
    } catch (e) {
      throw StorageException('Failed to clear profiles: $e');
    }
  }

  /// Check if storage is initialized
  bool get isInitialized => _profilesBox != null && _profilesBox!.isOpen;

  /// Close storage
  Future<void> close() async {
    await _profilesBox?.close();
  }
}

/// Custom exception for storage errors
class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}
