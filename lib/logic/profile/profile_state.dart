import 'package:equatable/equatable.dart';
import '../../data/models/profile_model.dart';
import 'profile_event.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Loading profiles
class ProfileLoading extends ProfileState {
  final String? operation; // Optional: what operation is loading

  const ProfileLoading({this.operation});

  @override
  List<Object?> get props => [operation];
}

/// Profiles loaded successfully
class ProfileLoaded extends ProfileState {
  final List<ProfileModel> profiles;
  final ProfileModel? selectedProfile;
  final bool isModified; // True if current profile has unsaved changes

  const ProfileLoaded({
    required this.profiles,
    this.selectedProfile,
    this.isModified = false,
  });

  ProfileLoaded copyWith({
    List<ProfileModel>? profiles,
    ProfileModel? selectedProfile,
    bool? isModified,
    bool clearSelectedProfile = false,
  }) {
    return ProfileLoaded(
      profiles: profiles ?? this.profiles,
      selectedProfile: clearSelectedProfile ? null : (selectedProfile ?? this.selectedProfile),
      isModified: isModified ?? this.isModified,
    );
  }

  @override
  List<Object?> get props => [profiles, selectedProfile, isModified];
}

/// Error state
class ProfileError extends ProfileState {
  final String message;
  final String? failedOperation; // For retry context
  final ProfileEvent? failedEvent; // Store the failed event for retry

  const ProfileError({
    required this.message,
    this.failedOperation,
    this.failedEvent,
  });

  @override
  List<Object?> get props => [message, failedOperation, failedEvent];
}
