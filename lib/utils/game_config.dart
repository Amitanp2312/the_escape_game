class GameConfig {
  static const int laneCount = 3;
  static const int initialLives = 3;
  static const int maxLives = 5;

  static const double initialObstacleSpeed = 240;
  static const double maximumObstacleSpeed = 680;
  static const double minimumSpawnInterval = 0.42;
  static const double maximumSpawnInterval = 1.2;

  static const double survivalPointsPerSecond = 10;
  static const int coinScoreValue = 20;
  static const int gemCoinValue = 5;
  static const int bossHitScore = 15;
  static const int bossDefeatScore = 250;
  static const double bossProjectileSpeed = 340;
  static const int nearMissScoreValue = 25;
  static const int comboDodgeCount = 5;
  static const int comboBonusScore = 50;
  static const double nearMissDistance = 58;

  static const double shieldDuration = 6.5;
  static const double magnetDuration = 8;
  static const double slowMotionDuration = 5;
  static const double doubleScoreDuration = 8;
  static const double rapidFireDuration = 7;
  static const double overchargeDuration = 7;
  static const double rapidFireFactor = 0.48;
  static const double slowMotionFactor = 0.46;
  static const double magnetRadius = 190;
  static const double invincibilityDuration = 1.15;
  static const int continueCost = 30;
  static const double continueInvincibility = 2;

  static const double playerLerpSpeed = 18;
  static const double swipeVelocityThreshold = 420;
  static const double edgePadding = 18;
  static const double playerWidth = 46;
  static const double playerHeight = 64;

  static const double easyUntilSeconds = 30;
  static const double mediumUntilSeconds = 60;
  static const double hardUntilSeconds = 120;

  static const double powerUpChanceEasy = 0.18;
  static const double powerUpChanceMedium = 0.14;
  static const double powerUpChanceHard = 0.11;
  static const double powerUpChanceExtreme = 0.08;

  static const double coinChance = 0.92;
  static const double weaponPickupChance = 0.24;
  static const int maxObstaclesPerRow = 2;

  static const double laserFireInterval = 0.28;
  static const double spreadFireInterval = 0.48;
  static const double proximityCooldown = 2.4;
  static const double projectileSpeed = 680;
  static const double laserProjectileWidth = 8;
  static const double laserProjectileHeight = 22;
  static const double spreadProjectileSize = 12;
  static const int spreadPelletCount = 3;
  static const double spreadAngleDegrees = 18;
  static const double proximityBlastRadius = 118;
  static const int maxProximityTargets = 4;
  static const int obstacleDestroyScoreLaser = 12;
  static const int obstacleDestroyScoreSpread = 10;
  static const int obstacleDestroyScoreProximity = 22;

  static const double splashDurationSeconds = 2.3;
  static const double scoreMultiplierGainPerMinute = 0.35;
  static const double maxScoreMultiplier = 2.6;

  static const int surviveMissionSeconds = 30;
  static const int coinMissionTarget = 20;
  static const int scoreMissionTarget = 1000;
  static const int shieldMissionTarget = 3;
  static const int dodgeMissionTarget = 100;
}

class MissionRewards {
  static const int survive30 = 80;
  static const int collect20Coins = 60;
  static const int score1000 = 120;
  static const int useShield3 = 90;
  static const int dodge100 = 150;
}
