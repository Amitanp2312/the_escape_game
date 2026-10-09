import '../utils/sprite_assets.dart';

enum BossAttack { aimed, fan, laneSweep }

enum BossMechanic { basic, summoner, shielded, laneWall, twoPhase }

class LevelDefinition {
  const LevelDefinition({
    required this.index,
    required this.name,
    required this.backgroundAsset,
    required this.bossSprite,
    required this.runSeconds,
    required this.minSpeed,
    required this.maxSpeed,
    required this.minSpawnInterval,
    required this.maxSpawnInterval,
    required this.obstacleTypeCount,
    required this.coinChance,
    required this.gemChance,
    required this.powerUpChance,
    required this.scoreMultiplier,
    required this.bossMaxHp,
    required this.bossMoveSpeed,
    required this.bossAttack,
    required this.bossFireInterval,
    required this.coinReward,
    this.mechanic = BossMechanic.basic,
  });

  final int index;
  final String name;
  final String backgroundAsset;
  final String bossSprite;
  final double runSeconds;
  final double minSpeed;
  final double maxSpeed;
  final double minSpawnInterval;
  final double maxSpawnInterval;
  final int obstacleTypeCount;
  final double coinChance;
  final double gemChance;
  final double powerUpChance;
  final double scoreMultiplier;
  final int bossMaxHp;
  final double bossMoveSpeed;
  final BossAttack bossAttack;
  final double bossFireInterval;
  final int coinReward;
  final BossMechanic mechanic;
}

class LevelCatalog {
  static const int count = 5;

  static const List<LevelDefinition> levels = [
    LevelDefinition(
      index: 1,
      name: 'Skyline Run',
      backgroundAsset: SpriteAssets.bg1,
      bossSprite: SpriteAssets.boss1,
      runSeconds: 28,
      minSpeed: 240,
      maxSpeed: 340,
      minSpawnInterval: 0.85,
      maxSpawnInterval: 1.15,
      obstacleTypeCount: 2,
      coinChance: 0.94,
      gemChance: 0.16,
      powerUpChance: 0.2,
      scoreMultiplier: 1,
      bossMaxHp: 24,
      bossMoveSpeed: 1.5,
      bossAttack: BossAttack.aimed,
      bossFireInterval: 1.35,
      coinReward: 40,
      mechanic: BossMechanic.basic,
    ),
    LevelDefinition(
      index: 2,
      name: 'Storm Highway',
      backgroundAsset: SpriteAssets.bg2,
      bossSprite: SpriteAssets.boss2,
      runSeconds: 34,
      minSpeed: 300,
      maxSpeed: 400,
      minSpawnInterval: 0.72,
      maxSpawnInterval: 0.95,
      obstacleTypeCount: 3,
      coinChance: 0.95,
      gemChance: 0.18,
      powerUpChance: 0.18,
      scoreMultiplier: 1.1,
      bossMaxHp: 34,
      bossMoveSpeed: 1.8,
      bossAttack: BossAttack.aimed,
      bossFireInterval: 1.15,
      coinReward: 60,
      mechanic: BossMechanic.summoner,
    ),
    LevelDefinition(
      index: 3,
      name: 'Nebula Siege',
      backgroundAsset: SpriteAssets.bg3,
      bossSprite: SpriteAssets.boss3,
      runSeconds: 40,
      minSpeed: 360,
      maxSpeed: 480,
      minSpawnInterval: 0.6,
      maxSpawnInterval: 0.8,
      obstacleTypeCount: 4,
      coinChance: 0.96,
      gemChance: 0.2,
      powerUpChance: 0.16,
      scoreMultiplier: 1.2,
      bossMaxHp: 48,
      bossMoveSpeed: 2.1,
      bossAttack: BossAttack.fan,
      bossFireInterval: 0.95,
      coinReward: 90,
      mechanic: BossMechanic.shielded,
    ),
    LevelDefinition(
      index: 4,
      name: 'Ember Descent',
      backgroundAsset: SpriteAssets.bg4,
      bossSprite: SpriteAssets.boss4,
      runSeconds: 45,
      minSpeed: 430,
      maxSpeed: 560,
      minSpawnInterval: 0.5,
      maxSpawnInterval: 0.68,
      obstacleTypeCount: 5,
      coinChance: 0.97,
      gemChance: 0.22,
      powerUpChance: 0.15,
      scoreMultiplier: 1.35,
      bossMaxHp: 64,
      bossMoveSpeed: 2.4,
      bossAttack: BossAttack.fan,
      bossFireInterval: 0.8,
      coinReward: 130,
      mechanic: BossMechanic.laneWall,
    ),
    LevelDefinition(
      index: 5,
      name: 'Aurora Fortress',
      backgroundAsset: SpriteAssets.bg5,
      bossSprite: SpriteAssets.boss5,
      runSeconds: 50,
      minSpeed: 500,
      maxSpeed: 660,
      minSpawnInterval: 0.42,
      maxSpawnInterval: 0.55,
      obstacleTypeCount: 5,
      coinChance: 0.98,
      gemChance: 0.24,
      powerUpChance: 0.14,
      scoreMultiplier: 1.5,
      bossMaxHp: 88,
      bossMoveSpeed: 2.8,
      bossAttack: BossAttack.laneSweep,
      bossFireInterval: 0.65,
      coinReward: 200,
      mechanic: BossMechanic.twoPhase,
    ),
  ];

  static LevelDefinition byIndex(int index) {
    return levels.firstWhere(
      (level) => level.index == index,
      orElse: () => levels.first,
    );
  }

  static LevelDefinition? nextAfter(LevelDefinition level) {
    if (level.index >= count) {
      return null;
    }
    return byIndex(level.index + 1);
  }
}

class EndlessRules {
  static const double scalePerLoop = 0.12;

  static LevelDefinition levelForWave(int wave) {
    final catalog = LevelCatalog.levels;
    final n = wave < 1 ? 1 : wave;
    final base = catalog[(n - 1) % catalog.length];
    final loops = (n - 1) ~/ catalog.length;
    final scale = 1 + loops * scalePerLoop;
    return LevelDefinition(
      index: base.index,
      name: base.name,
      backgroundAsset: base.backgroundAsset,
      bossSprite: base.bossSprite,
      runSeconds: base.runSeconds,
      minSpeed: base.minSpeed * scale,
      maxSpeed: base.maxSpeed * scale,
      minSpawnInterval: (base.minSpawnInterval / scale).clamp(0.35, 2),
      maxSpawnInterval: (base.maxSpawnInterval / scale).clamp(0.4, 2.2),
      obstacleTypeCount: base.obstacleTypeCount,
      coinChance: base.coinChance,
      gemChance: base.gemChance,
      powerUpChance: base.powerUpChance,
      scoreMultiplier: base.scoreMultiplier,
      bossMaxHp: (base.bossMaxHp * scale).round(),
      bossMoveSpeed: base.bossMoveSpeed * scale,
      bossAttack: base.bossAttack,
      bossFireInterval: (base.bossFireInterval / scale).clamp(0.45, 2),
      coinReward: base.coinReward,
      mechanic: base.mechanic,
    );
  }
}

class LevelProgress {
  static int afterWin({required int unlockedLevel, required int beatenIndex}) {
    final next = beatenIndex + 1;
    if (next <= unlockedLevel) {
      return unlockedLevel.clamp(1, LevelCatalog.count);
    }
    return next.clamp(1, LevelCatalog.count);
  }
}
