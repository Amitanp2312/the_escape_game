import 'level_definition.dart';
import 'weapon_type.dart';

class GameLaunch {
  const GameLaunch({required this.level, this.endless = false});

  final LevelDefinition level;
  final bool endless;
}

enum DifficultyTier { easy, medium, hard, extreme }

class DifficultySnapshot {
  const DifficultySnapshot({
    required this.tier,
    required this.level,
    required this.obstacleSpeed,
    required this.spawnInterval,
    required this.obstacleTypeCount,
    required this.powerUpChance,
    required this.scoreMultiplier,
  });

  final DifficultyTier tier;
  final int level;
  final double obstacleSpeed;
  final double spawnInterval;
  final int obstacleTypeCount;
  final double powerUpChance;
  final double scoreMultiplier;

  String get label {
    return switch (tier) {
      DifficultyTier.easy => 'Easy',
      DifficultyTier.medium => 'Medium',
      DifficultyTier.hard => 'Hard',
      DifficultyTier.extreme => 'Extreme',
    };
  }
}

enum GamePhase { playing, paused, gameOver, victory }

class HudState {
  const HudState({
    this.score = 0,
    this.highScore = 0,
    this.sessionCoins = 0,
    this.lives = 3,
    this.activePowerUpLabel,
    this.powerUpRemaining = 0,
    this.powerUpDuration = 1,
    this.combo = 0,
    this.difficultyLabel = 'Easy',
    this.weapon = WeaponType.laser,
    this.levelName = 'Skyline Run',
    this.runProgress = 0,
    this.inBossFight = false,
    this.bossHp = 0,
    this.bossMaxHp = 1,
    this.endless = false,
    this.wave = 1,
    this.bossBanner,
    this.comboPulse = false,
  });

  final int score;
  final int highScore;
  final int sessionCoins;
  final int lives;
  final String? activePowerUpLabel;
  final double powerUpRemaining;
  final double powerUpDuration;
  final int combo;
  final String difficultyLabel;
  final WeaponType weapon;
  final String levelName;
  final double runProgress;
  final bool inBossFight;
  final int bossHp;
  final int bossMaxHp;
  final bool endless;
  final int wave;
  final String? bossBanner;
  final bool comboPulse;

  String get weaponShortLabel => weapon.shortLabel;
}

class SessionResult {
  const SessionResult({
    required this.score,
    required this.coinsCollected,
    required this.distanceMeters,
    required this.survivalSeconds,
    required this.obstaclesDodged,
    required this.shieldsUsed,
  });

  final int score;
  final int coinsCollected;
  final double distanceMeters;
  final double survivalSeconds;
  final int obstaclesDodged;
  final int shieldsUsed;
}

class GameSessionStats {
  int score = 0;
  int coinsCollected = 0;
  int obstaclesDodged = 0;
  int obstaclesDestroyed = 0;
  int shieldsUsed = 0;
  int combo = 0;
  double survivalSeconds = 0;
  double distanceMeters = 0;
}
