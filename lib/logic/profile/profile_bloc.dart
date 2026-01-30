import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/models/profile_model.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;
  ProfileModel? _originalProfile; // Store original for comparison

  ProfileBloc(this._repository) : super(const ProfileInitial()) {
    on<LoadProfiles>(_onLoadProfiles);
    on<SelectProfile>(_onSelectProfile);
    on<CreateProfile>(_onCreateProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<SaveCurrentProfile>(_onSaveCurrentProfile);
    on<RenameProfile>(_onRenameProfile);
    on<DuplicateProfile>(_onDuplicateProfile);
    on<DeleteProfile>(_onDeleteProfile);
    on<UpdateProfileParameters>(_onUpdateProfileParameters);
  }

  /// Load all profiles
  Future<void> _onLoadProfiles(
    LoadProfiles event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading(operation: 'Loading profiles'));

      final profiles = await _repository.loadProfiles();

      // Select first profile by default
      final selectedProfile = profiles.isNotEmpty ? profiles.first : null;
      _originalProfile = selectedProfile;

      emit(ProfileLoaded(
        profiles: profiles,
        selectedProfile: selectedProfile,
        isModified: false,
      ));
    } catch (e) {
      emit(ProfileError(
        message: 'Failed to load profiles: ${e.toString()}',
        failedOperation: 'load',
        failedEvent: event,
      ));
    }
  }

  /// Select a profile
  Future<void> _onSelectProfile(
    SelectProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state is! ProfileLoaded) return;

      final currentState = state as ProfileLoaded;
      final profile = currentState.profiles.firstWhere(
        (p) => p.id == event.profileId,
        orElse: () => throw Exception('Profile not found'),
      );

      _originalProfile = profile;

      emit(currentState.copyWith(
        selectedProfile: profile,
        isModified: false,
      ));
    } catch (e) {
      emit(ProfileError(
        message: 'Failed to select profile: ${e.toString()}',
        failedOperation: 'select',
        failedEvent: event,
      ));
    }
  }

  /// Create a new profile
  Future<void> _onCreateProfile(
    CreateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state is! ProfileLoaded) return;

      final currentState = state as ProfileLoaded;
      emit(const ProfileLoading(operation: 'Creating profile'));

      final newProfile = await _repository.createProfile(event.name);
      final updatedProfiles = [...currentState.profiles, newProfile];

      _originalProfile = newProfile;

      emit(ProfileLoaded(
        profiles: updatedProfiles,
        selectedProfile: newProfile,
        isModified: false,
      ));
    } catch (e) {
      emit(ProfileError(
        message: 'Failed to create profile: ${e.toString()}',
        failedOperation: 'create',
        failedEvent: event,
      ));
    }
  }

  /// Update profile (in-memory, marks as modified)
  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state is! ProfileLoaded) return;

      final currentState = state as ProfileLoaded;
      
      // Check if modified compared to original
      final isModified = _originalProfile != null && 
                        event.profile != _originalProfile;

      emit(currentState.copyWith(
        selectedProfile: event.profile,
        isModified: isModified,
      ));
    } catch (e) {
      emit(ProfileError(
        message: 'Failed to update profile: ${e.toString()}',
        failedOperation: 'update',
        failedEvent: event,
      ));
    }
  }

  /// Save current profile to storage
  Future<void> _onSaveCurrentProfile(
    SaveCurrentProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state is! ProfileLoaded) return;

      final currentState = state as ProfileLoaded;
      if (currentState.selectedProfile == null) return;

      emit(const ProfileLoading(operation: 'Saving profile'));

      await _repository.saveProfile(currentState.selectedProfile!);

      // Update original profile
      _originalProfile = currentState.selectedProfile;

      // Update profiles list
      final updatedProfiles = currentState.profiles.map((p) {
        return p.id == currentState.selectedProfile!.id
            ? currentState.selectedProfile!
            : p;
      }).toList();

      emit(ProfileLoaded(
        profiles: updatedProfiles,
        selectedProfile: currentState.selectedProfile,
        isModified: false,
      ));
    } catch (e) {
      emit(ProfileError(
        message: 'Failed to save profile: ${e.toString()}',
        failedOperation: 'save',
        failedEvent: event,
      ));
    }
  }

  /// Rename a profile
  Future<void> _onRenameProfile(
    RenameProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state is! ProfileLoaded) return;

      final currentState = state as ProfileLoaded;
      emit(const ProfileLoading(operation: 'Renaming profile'));

      final renamedProfile = await _repository.renameProfile(
        event.profileId,
        event.newName,
      );

      final updatedProfiles = currentState.profiles.map((p) {
        return p.id == event.profileId ? renamedProfile : p;
      }).toList();

      final updatedSelectedProfile = currentState.selectedProfile?.id == event.profileId
          ? renamedProfile
          : currentState.selectedProfile;

      if (updatedSelectedProfile?.id == event.profileId) {
        _originalProfile = renamedProfile;
      }

      emit(ProfileLoaded(
        profiles: updatedProfiles,
        selectedProfile: updatedSelectedProfile,
        isModified: false,
      ));
    } catch (e) {
      emit(ProfileError(
        message: 'Failed to rename profile: ${e.toString()}',
        failedOperation: 'rename',
        failedEvent: event,
      ));
    }
  }

  /// Duplicate a profile
  Future<void> _onDuplicateProfile(
    DuplicateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state is! ProfileLoaded) return;

      final currentState = state as ProfileLoaded;
      emit(const ProfileLoading(operation: 'Duplicating profile'));

      final duplicatedProfile = await _repository.duplicateProfile(event.profileId);
      final updatedProfiles = [...currentState.profiles, duplicatedProfile];

      emit(ProfileLoaded(
        profiles: updatedProfiles,
        selectedProfile: currentState.selectedProfile,
        isModified: currentState.isModified,
      ));
    } catch (e) {
      emit(ProfileError(
        message: 'Failed to duplicate profile: ${e.toString()}',
        failedOperation: 'duplicate',
        failedEvent: event,
      ));
    }
  }

  /// Delete a profile
  Future<void> _onDeleteProfile(
    DeleteProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state is! ProfileLoaded) return;

      final currentState = state as ProfileLoaded;
      
      // Don't allow deleting the last profile
      if (currentState.profiles.length <= 1) {
        emit(const ProfileError(
          message: 'Cannot delete the last profile',
          failedOperation: 'delete',
        ));
        return;
      }

      emit(const ProfileLoading(operation: 'Deleting profile'));

      await _repository.deleteProfile(event.profileId);

      final updatedProfiles = currentState.profiles
          .where((p) => p.id != event.profileId)
          .toList();

      // If deleted profile was selected, select first profile
      ProfileModel? newSelectedProfile = currentState.selectedProfile;
      if (currentState.selectedProfile?.id == event.profileId) {
        newSelectedProfile = updatedProfiles.isNotEmpty ? updatedProfiles.first : null;
        _originalProfile = newSelectedProfile;
      }

      emit(ProfileLoaded(
        profiles: updatedProfiles,
        selectedProfile: newSelectedProfile,
        isModified: false,
      ));
    } catch (e) {
      emit(ProfileError(
        message: 'Failed to delete profile: ${e.toString()}',
        failedOperation: 'delete',
        failedEvent: event,
      ));
    }
  }

  /// Update profile parameters (marks as modified)
  Future<void> _onUpdateProfileParameters(
    UpdateProfileParameters event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state is! ProfileLoaded) return;

      final currentState = state as ProfileLoaded;
      if (currentState.selectedProfile == null) return;

      final updatedProfile = currentState.selectedProfile!.copyWith(
        audioLevel: event.audioLevel,
        hapticsIntensity: event.hapticsIntensity,
        brightness: event.brightness,
      );

      // Check if modified
      final isModified = _originalProfile != null && 
                        updatedProfile != _originalProfile;

      emit(currentState.copyWith(
        selectedProfile: updatedProfile,
        isModified: isModified,
      ));
    } catch (e) {
      emit(ProfileError(
        message: 'Failed to update parameters: ${e.toString()}',
        failedOperation: 'update_parameters',
        failedEvent: event,
      ));
    }
  }
}
