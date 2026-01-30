import 'package:equatable/equatable.dart';
import '../../data/models/profile_model.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load all profiles from storage
class LoadProfiles extends ProfileEvent {
  const LoadProfiles();
}

/// Select a profile
class SelectProfile extends ProfileEvent {
  final String profileId;

  const SelectProfile(this.profileId);

  @override
  List<Object?> get props => [profileId];
}

/// Create a new profile
class CreateProfile extends ProfileEvent {
  final String name;

  const CreateProfile(this.name);

  @override
  List<Object?> get props => [name];
}

/// Update current profile with new parameters
class UpdateProfile extends ProfileEvent {
  final ProfileModel profile;

  const UpdateProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Save current profile (when modified)
class SaveCurrentProfile extends ProfileEvent {
  const SaveCurrentProfile();
}

/// Rename a profile
class RenameProfile extends ProfileEvent {
  final String profileId;
  final String newName;

  const RenameProfile(this.profileId, this.newName);

  @override
  List<Object?> get props => [profileId, newName];
}

/// Duplicate a profile
class DuplicateProfile extends ProfileEvent {
  final String profileId;

  const DuplicateProfile(this.profileId);

  @override
  List<Object?> get props => [profileId];
}

/// Delete a profile
class DeleteProfile extends ProfileEvent {
  final String profileId;

  const DeleteProfile(this.profileId);

  @override
  List<Object?> get props => [profileId];
}

/// Update profile parameters (audio, haptics, brightness)
class UpdateProfileParameters extends ProfileEvent {
  final double? audioLevel;
  final int? hapticsIntensity;
  final double? brightness;

  const UpdateProfileParameters({
    this.audioLevel,
    this.hapticsIntensity,
    this.brightness,
  });

  @override
  List<Object?> get props => [audioLevel, hapticsIntensity, brightness];
}
