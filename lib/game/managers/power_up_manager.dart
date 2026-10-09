import '../../models/power_up_type.dart';
import '../../utils/game_config.dart';

class PowerUpManager {
  final Map<PowerUpType, double> remaining = {};
  final Map<PowerUpType, double> durations = {};

  bool get hasShield => remaining.containsKey(PowerUpType.shield);
  bool get hasMagnet => remaining.containsKey(PowerUpType.magnet);
  bool get hasSlowMotion => remaining.containsKey(PowerUpType.slowMotion);
  bool get hasDoubleScore => remaining.containsKey(PowerUpType.doubleScore);
  bool get hasRapidFire => remaining.containsKey(PowerUpType.rapidFire);
  bool get hasOvercharge => remaining.containsKey(PowerUpType.overcharge);
  bool get hasAny => remaining.isNotEmpty;

  double get scoreMultiplier => hasDoubleScore ? 2 : 1;
  int get bonusDamage => hasOvercharge ? 1 : 0;
  double get fireIntervalScale => hasRapidFire ? GameConfig.rapidFireFactor : 1;

  PowerUpType? get featured {
    for (final type in PowerUpType.values) {
      if (remaining.containsKey(type)) {
        return type;
      }
    }
    return null;
  }

  void activate(PowerUpType type) {
    if (type == PowerUpType.repair) {
      return;
    }
    final duration = durationFor(type);
    remaining[type] = duration;
    durations[type] = duration;
  }

  void consumeShield() {
    remaining.remove(PowerUpType.shield);
    durations.remove(PowerUpType.shield);
  }

  void update(double dt) {
    final expired = <PowerUpType>[];
    for (final entry in remaining.entries) {
      final next = entry.value - dt;
      if (next <= 0) {
        expired.add(entry.key);
      } else {
        remaining[entry.key] = next;
      }
    }
    for (final type in expired) {
      remaining.remove(type);
      durations.remove(type);
    }
  }

  void reset() {
    remaining.clear();
    durations.clear();
  }

  double remainingFor(PowerUpType type) => remaining[type] ?? 0;

  double durationStored(PowerUpType type) =>
      durations[type] ?? durationFor(type);

  static double durationFor(PowerUpType type) {
    return switch (type) {
      PowerUpType.shield => GameConfig.shieldDuration,
      PowerUpType.magnet => GameConfig.magnetDuration,
      PowerUpType.slowMotion => GameConfig.slowMotionDuration,
      PowerUpType.doubleScore => GameConfig.doubleScoreDuration,
      PowerUpType.rapidFire => GameConfig.rapidFireDuration,
      PowerUpType.overcharge => GameConfig.overchargeDuration,
      PowerUpType.repair => 0,
    };
  }
}
