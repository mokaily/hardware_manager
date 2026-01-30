import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/profile/profile_bloc.dart';
import '../../logic/profile/profile_event.dart';
import '../../logic/profile/profile_state.dart';
import '../../logic/hardware/hardware_bloc.dart';
import '../../logic/hardware/hardware_event.dart';

class ProfileDropdown extends StatelessWidget {
  final bool profileHasChanged;
  const ProfileDropdown({super.key, required this.profileHasChanged});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is! ProfileLoaded) {
          return const SizedBox.shrink();
        }
        // profileHasChanged
        String profileName = state.selectedProfile?.name ?? 'No Profile';
        profileName += profileHasChanged ? "*" : "";
        return PopupMenuButton<String>(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(width: 12),
                Text(
                  profileName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Spacer(),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
          itemBuilder: (context) {
            return [
              // Profile selection items
              ...state.profiles.map((profile) {
                final isSelected = profile.id == state.selectedProfile?.id;
                return PopupMenuItem<String>(
                  value: 'select_${profile.id}',
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: isSelected ? Theme.of(context).colorScheme.primary : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(profile.name)),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'rename_${profile.id}',
                            child: const Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Rename'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'duplicate_${profile.id}',
                            child: const Row(
                              children: [
                                Icon(Icons.copy, size: 20),
                                SizedBox(width: 8),
                                Text('Duplicate'),
                              ],
                            ),
                          ),
                          if (state.profiles.length > 1)
                            PopupMenuItem(
                              value: 'delete_${profile.id}',
                              child: const Row(
                                children: [
                                  Icon(Icons.delete, size: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                        ],
                        onSelected: (action) => _handleProfileAction(context, action),
                      ),
                    ],
                  ),
                );
              }),
              const PopupMenuDivider(),
              // Create new profile
              PopupMenuItem<String>(
                value: 'create_new',
                child: Row(
                  children: [
                    Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    const Text('Create New Profile'),
                  ],
                ),
              ),
            ];
          },
          onSelected: (value) => _handleMenuAction(context, value),
        );
      },
    );
  }

  void _handleMenuAction(BuildContext context, String value) {
    if (value.startsWith('select_')) {
      final profileId = value.substring(7);
      final profileBloc = context.read<ProfileBloc>();
      final hardwareBloc = context.read<HardwareBloc>();
      
      // Select profile
      profileBloc.add(SelectProfile(profileId));
      
      // Apply profile settings to hardware
      final state = profileBloc.state;
      if (state is ProfileLoaded) {
        final profile = state.profiles.firstWhere((p) => p.id == profileId);
        hardwareBloc.add(ApplyProfileSettings(profile));
      }
    } else if (value == 'create_new') {
      _showCreateProfileDialog(context);
    }
  }

  void _handleProfileAction(BuildContext context, String action) {
    if (action.startsWith('rename_')) {
      final profileId = action.substring(7);
      _showRenameProfileDialog(context, profileId);
    } else if (action.startsWith('duplicate_')) {
      final profileId = action.substring(10);
      context.read<ProfileBloc>().add(DuplicateProfile(profileId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile duplicated')),
      );
    } else if (action.startsWith('delete_')) {
      final profileId = action.substring(7);
      _showDeleteConfirmation(context, profileId);
    }
  }

  void _showCreateProfileDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create New Profile'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Profile Name',
            hintText: 'Enter profile name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<ProfileBloc>().add(CreateProfile(controller.text.trim()));
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showRenameProfileDialog(BuildContext context, String profileId) {
    final state = context.read<ProfileBloc>().state;
    if (state is! ProfileLoaded) return;

    final profile = state.profiles.firstWhere((p) => p.id == profileId);
    final controller = TextEditingController(text: profile.name);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename Profile'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Profile Name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<ProfileBloc>().add(
                      RenameProfile(profileId, controller.text.trim()),
                    );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String profileId) {
    final state = context.read<ProfileBloc>().state;
    if (state is! ProfileLoaded) return;

    final profile = state.profiles.firstWhere((p) => p.id == profileId);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text('Are you sure you want to delete "${profile.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProfileBloc>().add(DeleteProfile(profileId));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
