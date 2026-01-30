import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/hardware/hardware_bloc.dart';
import '../../logic/hardware/hardware_event.dart';
import '../../logic/hardware/hardware_state.dart';

class StateShowcaseScreen extends StatelessWidget {
  const StateShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('State Architecture Showcase'),
      ),
      body: BlocBuilder<HardwareBloc, HardwareState>(
        builder: (context, state) {
          final isSimulationMode = 
              state is HardwareActive && state.isSimulationMode;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildArchitectureCard(context),
              const SizedBox(height: 16),
              _buildSimulationCard(context, isSimulationMode),
              const SizedBox(height: 16),
              if (isSimulationMode)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Hardware Simulation Active: All attempts to change volume, brightness, or haptics will fail and trigger error states.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildArchitectureCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unidirectional Data Flow',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              'This app uses the BLoC pattern ensures creating a stable, predictable state management system.',
            ),
            const SizedBox(height: 16),
            _buildFlowStep(context, '1. UI triggers Event', Icons.touch_app),
            _buildConnector(context),
            _buildFlowStep(context, '2. BLoC processes Logic', Icons.psychology),
            _buildConnector(context),
            _buildFlowStep(context, '3. New State emitted', Icons.refresh),
            _buildConnector(context),
            _buildFlowStep(context, '4. UI rebuilds', Icons.grid_view),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationCard(BuildContext context, bool isSimulationMode) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Error Simulation Mode',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Force hardware operations to fail to demonstrate error handling.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isSimulationMode,
                  onChanged: (value) {
                    context.read<HardwareBloc>().add(ToggleSimulationMode(value));
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Instructions:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('1. Enable the switch above'),
            const Text('2. Go to the "Profiles" tab'),
            const Text('3. Try moving any slider'),
            const Text('4. Observe the SnackBar error message'),
            const Text('5. Tap "Retry" (it will work and disable simulation will be off)'),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowStep(BuildContext context, String text, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildConnector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 19, top: 4, bottom: 4),
      child: Container(
        width: 2,
        height: 16,
        color: Colors.grey.withValues(alpha: 0.3),
      ),
    );
  }
}
