import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../widgets/neon_scaffold.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Choose a level. Beat the boss to unlock the next one.',
      'Fly the airplane. Swipe left or right to change lanes.',
      'Drag to steer smoothly. Tap a lane to snap toward it.',
      'Your airplane auto-fires. Dodge obstacles that still get through.',
      'Collect weapon pickups to switch fire: laser, spread, or blast.',
      'Grab gold coins and rare gems. Gems are worth five coins.',
      'When the progress bar fills, a boss appears. Shoot it and dodge its fire.',
      'Collect power-ups: shield, magnet, slow, 2X, rapid fire, overcharge, and spare lives.',
      'Beat all five levels. Spend coins in the vehicle shop.',
    ];
    return NeonScaffold(
      title: 'How to Play',
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        itemCount: steps.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NeonColors.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: NeonColors.cyan.withValues(alpha: 0.45),
              ),
            ),
            child: Text(
              '${index + 1}. ${steps[index]}',
              style: const TextStyle(
                color: NeonColors.text,
                fontSize: 16,
                height: 1.35,
              ),
            ),
          );
        },
      ),
    );
  }
}
