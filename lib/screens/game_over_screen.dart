import 'package:flutter/material.dart';

import '../app/app.dart';
import '../game/neon_escape_game.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/neon_button.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key, required this.game});

  final NeonEscapeGame game;

  @override
  Widget build(BuildContext context) {
    final result = game.lastResult;
    final score = result?.score ?? game.scoreManager.score;
    final coins = result?.coinsCollected ?? game.stats.coinsCollected;
    final distance = result?.distanceMeters ?? game.stats.distanceMeters;
    final best = AppScope.of(context).highScore;
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
                    'GAME OVER',
                    style: TextStyle(
                      color: NeonColors.pink,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _stat('Final Score', formatScore(score)),
                  _stat('Best Score', formatScore(best)),
                  _stat('Coins Collected', formatScore(coins)),
                  _stat('Distance Survived', formatDistance(distance)),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Mission Progress',
                      style: TextStyle(
                        color: NeonColors.cyan,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...game.lastMissionViews.map((view) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              view.definition.title,
                              style: const TextStyle(
                                color: NeonColors.mutedText,
                              ),
                            ),
                          ),
                          Text(
                            '${view.progress}/${view.target}',
                            style: TextStyle(
                              color: view.completed
                                  ? NeonColors.green
                                  : NeonColors.text,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 18),
                  if (!game.continuedThisRun)
                    NeonButton(
                      label: 'Continue (${game.continueCost})',
                      color: NeonColors.gold,
                      icon: Icons.favorite,
                      onPressed: game.canContinue ? game.continueRun : null,
                    ),
                  if (!game.continuedThisRun) const SizedBox(height: 12),
                  NeonButton(
                    label: 'Play Again',
                    icon: Icons.replay,
                    onPressed: game.restart,
                  ),
                  const SizedBox(height: 12),
                  NeonButton(
                    label: 'Main Menu',
                    color: NeonColors.purple,
                    icon: Icons.home_outlined,
                    onPressed: () {
                      game.commitPendingResult();
                      game.audio.startMusic();
                      Navigator.of(context).popUntil((route) => route.isFirst);
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
