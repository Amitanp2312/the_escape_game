import 'dart:math' as math;

import 'package:flame/components.dart';

import '../../models/weapon_type.dart';
import '../../utils/game_config.dart';
import '../components/obstacle.dart';
import '../components/projectile.dart';
import '../components/proximity_blast_effect.dart';
import '../neon_escape_game.dart';

class WeaponLoadout {
  WeaponType equipped = WeaponType.laser;
  double cooldown = 0;

  void reset() {
    equipped = WeaponType.laser;
    cooldown = 0;
  }

  void equip(WeaponType type) {
    equipped = type;
    cooldown = math.min(cooldown, 0.12);
  }

  bool readyToFire(double dt, {double intervalScale = 1}) {
    cooldown -= dt;
    if (cooldown > 0) {
      return false;
    }
    cooldown = WeaponRules.fireInterval(equipped) * intervalScale;
    return true;
  }
}

class WeaponRules {
  static double fireInterval(WeaponType type) {
    return switch (type) {
      WeaponType.laser => GameConfig.laserFireInterval,
      WeaponType.spread => GameConfig.spreadFireInterval,
      WeaponType.proximityBlast => GameConfig.proximityCooldown,
    };
  }

  static int destroyScore(WeaponType type) {
    return switch (type) {
      WeaponType.laser => GameConfig.obstacleDestroyScoreLaser,
      WeaponType.spread => GameConfig.obstacleDestroyScoreSpread,
      WeaponType.proximityBlast => GameConfig.obstacleDestroyScoreProximity,
    };
  }

  static List<Vector2> shotVelocities(WeaponType type) {
    final speed = GameConfig.projectileSpeed;
    return switch (type) {
      WeaponType.laser => [Vector2(0, -speed)],
      WeaponType.spread => [
        for (var i = 0; i < GameConfig.spreadPelletCount; i++)
          _velocityAtAngle(_spreadAngleForIndex(i), speed),
      ],
      WeaponType.proximityBlast => const [],
    };
  }

  static double _spreadAngleForIndex(int index) {
    if (GameConfig.spreadPelletCount <= 1) {
      return 0;
    }
    final t = index / (GameConfig.spreadPelletCount - 1);
    return (t * 2 - 1) * GameConfig.spreadAngleDegrees;
  }

  static Vector2 _velocityAtAngle(double degrees, double speed) {
    final radians = degrees * math.pi / 180;
    return Vector2(math.sin(radians) * speed, -math.cos(radians) * speed);
  }

  static bool isInBlastRadius({
    required Vector2 center,
    required Vector2 target,
    required double radius,
  }) {
    return center.distanceTo(target) <= radius;
  }
}

class WeaponManager {
  WeaponManager(this.game);

  final NeonEscapeGame game;
  final WeaponLoadout loadout = WeaponLoadout();

  WeaponType get equipped => loadout.equipped;

  void reset() {
    loadout.reset();
  }

  void equip(WeaponType type) {
    loadout.equip(type);
  }

  void update(double dt) {
    if (game.isGameOver || game.isPaused || game.isVictory) {
      return;
    }
    if (!loadout.readyToFire(
      dt,
      intervalScale: game.powerUps.fireIntervalScale,
    )) {
      return;
    }
    _fire();
  }

  void _fire() {
    switch (loadout.equipped) {
      case WeaponType.laser:
      case WeaponType.spread:
        final muzzle = game.player.muzzleWorld;
        for (final velocity in WeaponRules.shotVelocities(loadout.equipped)) {
          game.world.add(
            ProjectileComponent(weapon: loadout.equipped, velocity: velocity)
              ..position = muzzle.clone(),
          );
        }
      case WeaponType.proximityBlast:
        _blast();
    }
  }

  void _blast() {
    final center = game.player.position.clone();
    game.world.add(
      ProximityBlastEffect(
        position: center,
        radius: GameConfig.proximityBlastRadius,
      ),
    );
    game.audio.playCollision();
    game.triggerShake(4);
    var hits = 0;
    for (final obstacle in game.world.children.whereType<ObstacleComponent>()) {
      if (hits >= GameConfig.maxProximityTargets) {
        break;
      }
      if (obstacle.consumed) {
        continue;
      }
      if (!WeaponRules.isInBlastRadius(
        center: center,
        target: obstacle.position,
        radius: GameConfig.proximityBlastRadius,
      )) {
        continue;
      }
      game.collisions.destroyObstacleByWeapon(
        obstacle,
        WeaponType.proximityBlast,
      );
      hits += 1;
    }
    final boss = game.boss;
    if (boss != null && !boss.combat.defeated) {
      if (WeaponRules.isInBlastRadius(
        center: center,
        target: boss.position,
        radius: GameConfig.proximityBlastRadius,
      )) {
        game.collisions.handleBossHit(boss, WeaponType.proximityBlast);
      }
    }
  }
}
