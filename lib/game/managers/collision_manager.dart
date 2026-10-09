import '../../models/power_up_type.dart';
import '../../models/weapon_type.dart';
import '../../utils/constants.dart';
import '../../utils/game_config.dart';
import 'spawn_manager.dart';
import 'weapon_manager.dart';
import '../components/boss.dart';
import '../components/boss_bullet.dart';
import '../components/coin.dart';
import '../components/obstacle.dart';
import '../components/power_up.dart';
import '../components/projectile.dart';
import '../components/weapon_pickup.dart';
import '../neon_escape_game.dart';

class CollisionManager {
  CollisionManager(this.game);

  final NeonEscapeGame game;

  bool get _stopped => game.isGameOver || game.isVictory;

  void handleObstacle(ObstacleComponent obstacle) {
    if (obstacle.consumed || _stopped) {
      return;
    }
    if (game.invincibleTimer > 0) {
      return;
    }
    if (game.powerUps.hasShield) {
      obstacle.consumed = true;
      game.powerUps.consumeShield();
      game.audio.playPowerUp();
      game.spawnBurst(obstacle.position.clone(), NeonColors.cyan);
      obstacle.removeFromParent();
      game.refreshHud();
      return;
    }

    obstacle.consumed = true;
    obstacle.removeFromParent();
    game.takeDamage(
      obstacle.position.clone(),
      amount: ObstacleRules.contactDamage(obstacle.type),
    );
  }

  void handleCoin(CoinComponent coin) {
    if (coin.collected || game.isGameOver) {
      return;
    }
    coin.markCollected();
    game.stats.coinsCollected += coin.value;
    game.scoreManager.addCoin(game.activeScoreMultiplier, value: coin.value);
    final points =
        (GameConfig.coinScoreValue * coin.value * game.activeScoreMultiplier)
            .round();
    game.floatText(
      coin.position.clone(),
      '+$points',
      coin.isGem ? NeonColors.pink : NeonColors.gold,
    );
    game.audio.playCoin();
    game.spawnBurst(coin.position.clone(), NeonColors.gold);
    game.refreshHud();
  }

  void handlePowerUp(PowerUpComponent powerUp) {
    if (powerUp.collected || _stopped) {
      return;
    }
    powerUp.markCollected();
    if (powerUp.type == PowerUpType.repair) {
      game.grantLife();
      game.floatText(powerUp.position.clone(), '+1 LIFE', NeonColors.green);
    } else {
      game.powerUps.activate(powerUp.type);
      game.floatText(
        powerUp.position.clone(),
        powerUp.type.shortLabel,
        NeonColors.forPowerUp(powerUp.type),
      );
    }
    if (powerUp.type == PowerUpType.shield) {
      game.stats.shieldsUsed += 1;
    }
    game.audio.playPowerUp();
    game.spawnBurst(
      powerUp.position.clone(),
      NeonColors.forPowerUp(powerUp.type),
    );
    game.refreshHud();
  }

  void handleWeaponPickup(WeaponPickupComponent pickup) {
    if (pickup.collected || _stopped) {
      return;
    }
    pickup.markCollected();
    game.weapons.equip(pickup.type);
    game.audio.playPowerUp();
    game.spawnBurst(pickup.position.clone(), NeonColors.forWeapon(pickup.type));
    game.refreshHud();
  }

  void handleProjectileHit(
    ProjectileComponent projectile,
    ObstacleComponent obstacle,
  ) {
    if (projectile.consumed || obstacle.consumed || _stopped) {
      return;
    }
    hitObstacleByWeapon(obstacle, projectile.weapon);
    projectile.consumed = true;
    projectile.removeFromParent();
  }

  void destroyObstacleByWeapon(ObstacleComponent obstacle, WeaponType weapon) {
    hitObstacleByWeapon(obstacle, weapon);
  }

  void hitObstacleByWeapon(ObstacleComponent obstacle, WeaponType weapon) {
    if (obstacle.consumed || _stopped) {
      return;
    }
    final damage =
        ObstacleRules.weaponDamage(weapon) + game.powerUps.bonusDamage;
    if (!obstacle.applyHit(damage)) {
      game.floatText(
        obstacle.position.clone(),
        '$damage',
        NeonColors.forWeapon(weapon),
      );
      game.spawnBurst(obstacle.position.clone(), NeonColors.forWeapon(weapon));
      return;
    }
    obstacle.consumed = true;
    obstacle.countedPass = true;
    game.stats.obstaclesDestroyed += 1;
    game.scoreManager.addObstacleDestroyed(
      game.activeScoreMultiplier,
      weapon: weapon,
    );
    game.stats.score = game.scoreManager.score;
    final points =
        (WeaponRules.destroyScore(weapon) * game.activeScoreMultiplier).round();
    game.floatText(
      obstacle.position.clone(),
      '+$points',
      NeonColors.forWeapon(weapon),
    );
    game.audio.playCoin();
    game.spawnBurst(obstacle.position.clone(), NeonColors.forWeapon(weapon));
    obstacle.removeFromParent();
    game.refreshHud();
  }

  void handleProjectileBossHit(
    ProjectileComponent projectile,
    BossComponent boss,
  ) {
    if (projectile.consumed || _stopped) {
      return;
    }
    projectile.consumed = true;
    projectile.removeFromParent();
    handleBossHit(boss, projectile.weapon);
  }

  void handleBossHit(BossComponent boss, WeaponType weapon) {
    if (boss.combat.defeated || _stopped) {
      return;
    }
    final damage =
        (weapon == WeaponType.proximityBlast ? 3 : 1) +
        game.powerUps.bonusDamage;
    if (boss.combat.invulnerable) {
      game.floatText(boss.position.clone(), 'BLOCKED', NeonColors.cyan);
      return;
    }
    boss.flash();
    game.spawnBurst(boss.position.clone(), NeonColors.forWeapon(weapon));
    game.scoreManager.addBossHit(game.activeScoreMultiplier);
    game.stats.score = game.scoreManager.score;
    game.floatText(boss.position.clone(), '$damage', NeonColors.pink);
    final killed = boss.combat.applyDamage(damage);
    game.refreshHud();
    if (killed) {
      game.onBossDefeated(boss);
    }
  }

  void handleBossBullet(BossBulletComponent bullet) {
    if (bullet.consumed || _stopped) {
      return;
    }
    if (game.invincibleTimer > 0) {
      return;
    }
    bullet.markConsumed();
    bullet.removeFromParent();
    if (game.powerUps.hasShield) {
      game.powerUps.consumeShield();
      game.audio.playPowerUp();
      game.spawnBurst(bullet.position.clone(), NeonColors.cyan);
      game.refreshHud();
      return;
    }
    game.takeDamage(bullet.position.clone());
  }

  void handleBossTouch(BossComponent boss) {
    if (boss.combat.defeated || _stopped) {
      return;
    }
    if (game.invincibleTimer > 0) {
      return;
    }
    if (game.powerUps.hasShield) {
      game.powerUps.consumeShield();
      game.audio.playPowerUp();
      game.spawnBurst(boss.position.clone(), NeonColors.cyan);
      game.refreshHud();
      return;
    }
    game.takeDamage(boss.position.clone());
  }
}
