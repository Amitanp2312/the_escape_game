import 'package:flutter/material.dart';

import '../app/app.dart';
import '../app/routes.dart';
import '../models/game_state.dart';
import '../models/level_definition.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/neon_scaffold.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return NeonScaffold(
      title: 'Select Level',
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        itemCount: LevelCatalog.levels.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == LevelCatalog.levels.length) {
            return _EndlessCard(
              unlocked: controller.unlockedLevel >= 2,
              best: controller.endlessBest,
              bestWave: controller.endlessBestWave,
              onTap: () {
                controller.playTap();
                Navigator.pushNamed(
                  context,
                  AppRoutes.game,
                  arguments: GameLaunch(
                    level: EndlessRules.levelForWave(1),
                    endless: true,
                  ),
                );
              },
            );
          }
          final level = LevelCatalog.levels[index];
          final unlocked = controller.isLevelUnlocked(level.index);
          final best = controller.bestForLevel(level.index);
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: unlocked
                  ? () {
                      controller.playTap();
                      Navigator.pushNamed(
                        context,
                        AppRoutes.game,
                        arguments: GameLaunch(level: level),
                      );
                    }
                  : null,
              child: Ink(
                height: 108,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (unlocked ? NeonColors.cyan : NeonColors.mutedText)
                        .withValues(alpha: 0.6),
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/images/${level.backgroundAsset}'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: unlocked ? 0.35 : 0.7),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'LEVEL ${level.index}',
                              style: const TextStyle(
                                color: NeonColors.gold,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.4,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              level.name,
                              style: const TextStyle(
                                color: NeonColors.text,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              unlocked
                                  ? 'Best ${formatScore(best)}  ·  Reward ${level.coinReward}'
                                  : 'Locked',
                              style: const TextStyle(
                                color: NeonColors.mutedText,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        unlocked ? Icons.play_circle_fill : Icons.lock,
                        color: unlocked
                            ? NeonColors.cyan
                            : NeonColors.mutedText,
                        size: 36,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EndlessCard extends StatelessWidget {
  const _EndlessCard({
    required this.unlocked,
    required this.best,
    required this.bestWave,
    required this.onTap,
  });

  final bool unlocked;
  final int best;
  final int bestWave;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: unlocked ? onTap : null,
        child: Ink(
          height: 108,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (unlocked ? NeonColors.pink : NeonColors.mutedText)
                  .withValues(alpha: 0.7),
            ),
            color: NeonColors.surfaceAlt.withValues(alpha: 0.7),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'ENDLESS',
                        style: TextStyle(
                          color: NeonColors.pink,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Wave Mode',
                        style: TextStyle(
                          color: NeonColors.text,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unlocked
                            ? 'Best ${formatScore(best)}  ·  Wave $bestWave'
                            : 'Beat Level 1 to unlock',
                        style: const TextStyle(
                          color: NeonColors.mutedText,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  unlocked ? Icons.all_inclusive : Icons.lock,
                  color: unlocked ? NeonColors.pink : NeonColors.mutedText,
                  size: 36,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
