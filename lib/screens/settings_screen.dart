import 'package:flutter/material.dart';

import '../app/app.dart';
import '../utils/constants.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final profile = controller.profile;
    return NeonScaffold(
      title: 'Settings',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _toggle(
            label: 'Music',
            value: profile.musicEnabled,
            onChanged: controller.setMusicEnabled,
          ),
          _toggle(
            label: 'Sound Effects',
            value: profile.soundEffectsEnabled,
            onChanged: controller.setSoundEffectsEnabled,
          ),
          _toggle(
            label: 'Vibration',
            value: profile.vibrationEnabled,
            onChanged: controller.setVibrationEnabled,
          ),
          const SizedBox(height: 28),
          NeonButton(
            label: 'Reset Game Progress',
            color: NeonColors.red,
            icon: Icons.restart_alt,
            onPressed: () => _confirmReset(context),
          ),
        ],
      ),
    );
  }

  Widget _toggle({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: NeonColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NeonColors.purple.withValues(alpha: 0.5)),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          label,
          style: const TextStyle(
            color: NeonColors.text,
            fontWeight: FontWeight.w700,
          ),
        ),
        value: value,
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return NeonColors.cyan;
          }
          return NeonColors.mutedText;
        }),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: NeonColors.surface,
          title: const Text('Reset progress?'),
          content: const Text(
            'This clears coins, high score, unlocked vehicles, missions, and settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
    if (confirmed == true && context.mounted) {
      AppScope.of(context).playTap();
      await AppScope.of(context).resetProgress();
    }
  }
}
