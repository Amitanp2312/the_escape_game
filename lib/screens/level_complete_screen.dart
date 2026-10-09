import 'package:flutter/material.dart';

import '../game/neon_escape_game.dart';
import '../models/level_definition.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/neon_button.dart';

class LevelCompleteScreen extends StatelessWidget {
  const LevelCompleteScreen({super.key, required this.game});

  final NeonEscapeGame game;

  @override
  Widget build(BuildContext context) {
    final result = game.lastResult;
    final next = LevelCatalog.nextAfter(game.level);
    return Material(
      color: Colors.black.withValues(alpha: 0.78),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'LEVEL CLEAR',
                    style: TextStyle(
                      color: NeonColors.gold,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    game.level.name,
                    style: const TextStyle(
                      color: NeonColors.cyan,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _stat('Score', formatScore(result?.score ?? 0)),
                  _stat('Coins', formatScore(result?.coinsCollected ?? 0)),
                  _stat('Reward', '+${game.level.coinReward}'),
                  const SizedBox(height: 18),
                  if (next != null)
                    NeonButton(
                      label: 'Next Level',
                      icon: Icons.fast_forward_rounded,
                      onPressed: () => game.startLevel(next),
                    ),
                  if (next != null) const SizedBox(height: 12),
                  NeonButton(
                    label: 'Replay',
                    color: NeonColors.purple,
                    icon: Icons.replay,
                    onPressed: game.restart,
                  ),
                  const SizedBox(height: 12),
                  NeonButton(
                    label: 'Level Select',
                    color: NeonColors.pink,
                    icon: Icons.map_outlined,
                    onPressed: () {
                      game.commitPendingResult();
                      game.audio.startMusic();
                      game.pauseEngine();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: NeonColors.mutedText),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: NeonColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
