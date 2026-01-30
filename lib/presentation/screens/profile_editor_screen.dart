import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/profile/profile_bloc.dart';
import '../../logic/profile/profile_event.dart';
import '../../logic/profile/profile_state.dart';
import '../../logic/theme/theme_cubit.dart';
import '../widgets/brightness_control_widget.dart';
import '../widgets/haptics_control_widget.dart';
import '../widgets/profile_dropdown.dart';
import '../widgets/audio_control_widget.dart';

class ProfileEditorScreen extends StatelessWidget {
  const ProfileEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileError) {
          _showErrorDialog(context, state);
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          bool profileHasChanged = state is ProfileLoaded && state.isModified;
          return Scaffold(
            appBar: AppBar(
              leadingWidth: 80,
              leading: TextButton(
                onPressed: profileHasChanged
                    ? () {
                        context.read<ProfileBloc>().add(
                          const SaveCurrentProfile(),
                        );
                      }
                    : null,
                child: const Text("Save"),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (state is ProfileLoaded &&
                        state.selectedProfile != null) {
                      showDeleteConfirmation(
                        context,
                        state.selectedProfile!.id,
                      );
                    }
                  },
                  child: const Text("Remove"),
                ),
              ],
              title: ProfileDropdown(profileHasChanged: profileHasChanged),
              centerTitle: true,
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProfileState state) {
    if (state is ProfileInitial || state is ProfileLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ProfileLoaded) {
      return _buildContent(context, state);
    }

    return const Center(child: Text('Something went wrong'));
  }

  Widget _buildContent(BuildContext context, ProfileLoaded state) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Text(
                  "ADJUST IT",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Align(alignment: Alignment.centerLeft, child: Icon(Icons.tune)),
              Align(
                alignment: Alignment.centerRight,
                child: BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, themeMode) {
                    return IconButton(
                      icon: Icon(
                        themeMode == ThemeMode.light
                            ? Icons.dark_mode
                            : Icons.light_mode,
                      ),
                      onPressed: () {
                        context.read<ThemeCubit>().toggleTheme();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // Controls
          Expanded(
            child: ListView(
              children: const [
                SizedBox(height: 24),
                AudioControlWidget(),
                HapticsControlWidget(),
                BrightnessControlWidget(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, ProfileError state) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 12),
            const Text('Error'),
          ],
        ),
        content: Text(state.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Dismiss'),
          ),
          if (state.failedEvent != null)
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProfileBloc>().add(state.failedEvent!);
                Navigator.pop(dialogContext);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  void showDeleteConfirmation(BuildContext context, String profileId) {
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
