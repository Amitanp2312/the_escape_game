import 'package:flutter/material.dart';

import '../app/app.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/neon_scaffold.dart';

class HighScoreScreen extends StatelessWidget {
  const HighScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return NeonScaffold(
      title: 'High Score',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'BEST RUN',
                style: TextStyle(
                  color: NeonColors.mutedText,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                formatScore(controller.highScore),
                style: const TextStyle(
                  color: NeonColors.gold,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Banked coins: ${formatScore(controller.totalCoins)}',
                style: const TextStyle(color: NeonColors.cyan),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
