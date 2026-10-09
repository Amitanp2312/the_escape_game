import '../../models/game_state.dart';
import '../../models/level_definition.dart';
import '../../utils/helpers.dart';

class DifficultyManager {
  DifficultySnapshot evaluate({
    required LevelDefinition level,
    required double progress,
  }) {
    final t = progress.clamp(0.0, 1.0);
    final speed = lerpDoubleClamped(level.minSpeed, level.maxSpeed, t);
    final spawn = lerpDoubleClamped(
      level.maxSpawnInterval,
      level.minSpawnInterval,
      t,
    );
    final tier = switch (level.index) {
      1 => DifficultyTier.easy,
      2 => DifficultyTier.medium,
      3 => DifficultyTier.hard,
      _ => DifficultyTier.extreme,
    };
    return DifficultySnapshot(
      tier: tier,
      level: level.index,
      obstacleSpeed: speed,
      spawnInterval: spawn,
      obstacleTypeCount: level.obstacleTypeCount,
      powerUpChance: level.powerUpChance,
      scoreMultiplier: level.scoreMultiplier,
    );
  }
}
