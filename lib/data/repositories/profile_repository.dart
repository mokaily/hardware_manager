import '../models/profile_model.dart';
import '../services/storage_service.dart';

class ProfileRepository {
  final StorageService _storageService;

  ProfileRepository(this._storageService);

  /// Load all profiles from storage
  Future<List<ProfileModel>> loadProfiles() async {
    try {
      final profiles = _storageService.getAllProfiles();
      
      // If no profiles exist, create a default one
      if (profiles.isEmpty) {
        final defaultProfile = ProfileModel.defaultProfile();
        await _storageService.saveProfile(defaultProfile);
        return [defaultProfile];
      }
      
      return profiles;
    } catch (e) {
      throw RepositoryException('Failed to load profiles: $e');
    }
  }

  /// Save or update a profile
  Future<void> saveProfile(ProfileModel profile) async {
    try {
      // Update the updatedAt timestamp
      final updatedProfile = profile.copyWith(updatedAt: DateTime.now());
      await _storageService.saveProfile(updatedProfile);
    } catch (e) {
      throw RepositoryException('Failed to save profile: $e');
    }
  }

  /// Create a new profile
  Future<ProfileModel> createProfile(String name) async {
    try {
      final newProfile = ProfileModel.create(name: name);
      await _storageService.saveProfile(newProfile);
      return newProfile;
    } catch (e) {
      throw RepositoryException('Failed to create profile: $e');
    }
  }

  /// Rename a profile
  Future<ProfileModel> renameProfile(String id, String newName) async {
    try {
      final profile = _storageService.getProfile(id);
      if (profile == null) {
        throw RepositoryException('Profile not found: $id');
      }

      final renamedProfile = profile.copyWith(
        name: newName,
        updatedAt: DateTime.now(),
      );
      await _storageService.saveProfile(renamedProfile);
      return renamedProfile;
    } catch (e) {
      throw RepositoryException('Failed to rename profile: $e');
    }
  }

  /// Duplicate a profile
  Future<ProfileModel> duplicateProfile(String id) async {
    try {
      final profile = _storageService.getProfile(id);
      if (profile == null) {
        throw RepositoryException('Profile not found: $id');
      }

      final duplicatedProfile = profile.duplicate();
      await _storageService.saveProfile(duplicatedProfile);
      return duplicatedProfile;
    } catch (e) {
      throw RepositoryException('Failed to duplicate profile: $e');
    }
  }

  /// Delete a profile
  Future<void> deleteProfile(String id) async {
    try {
      await _storageService.deleteProfile(id);
    } catch (e) {
      throw RepositoryException('Failed to delete profile: $e');
    }
  }

  /// Get a specific profile by ID
  ProfileModel? getProfile(String id) {
    try {
      return _storageService.getProfile(id);
    } catch (e) {
      throw RepositoryException('Failed to get profile: $e');
    }
  }

  /// Update profile parameters
  Future<ProfileModel> updateProfileParameters({
    required String id,
    double? audioLevel,
    int? hapticsIntensity,
    double? brightness,
  }) async {
    try {
      final profile = _storageService.getProfile(id);
      if (profile == null) {
        throw RepositoryException('Profile not found: $id');
      }

      final updatedProfile = profile.copyWith(
        audioLevel: audioLevel,
        hapticsIntensity: hapticsIntensity,
        brightness: brightness,
        updatedAt: DateTime.now(),
      );
      await _storageService.saveProfile(updatedProfile);
      return updatedProfile;
    } catch (e) {
      throw RepositoryException('Failed to update profile parameters: $e');
    }
  }
}

/// Custom exception for repository errors
class RepositoryException implements Exception {
  final String message;
  RepositoryException(this.message);

  @override
  String toString() => 'RepositoryException: $message';
}
