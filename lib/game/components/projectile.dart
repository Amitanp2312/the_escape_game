import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../models/weapon_type.dart';
import '../../utils/constants.dart';
import '../../utils/game_config.dart';
import '../neon_escape_game.dart';
import 'boss.dart';
import 'obstacle.dart';

class ProjectileComponent extends PositionComponent
    with HasGameReference<NeonEscapeGame>, CollisionCallbacks {
  ProjectileComponent({required this.weapon, required this.velocity});

  final WeaponType weapon;
  final Vector2 velocity;
  bool consumed = false;

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    size = weapon == WeaponType.laser
        ? Vector2(
            GameConfig.laserProjectileWidth,
            GameConfig.laserProjectileHeight,
          )
        : Vector2.all(GameConfig.spreadProjectileSize);
    priority = 8;
    add(
      RectangleHitbox.relative(Vector2(0.7, 0.8), parentSize: size)
        ..collisionType = CollisionType.active,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (consumed) {
      removeFromParent();
      return;
    }
    position += velocity * dt;
    if (position.y < -size.y ||
        position.x < -size.x ||
        position.x > game.size.x + size.x) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final color = NeonColors.forWeapon(weapon);
    final rect = Offset.zero & size.toSize();
    if (weapon == WeaponType.laser) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()..color = color.withValues(alpha: 0.28),
      );
      canvas.drawLine(
        Offset(size.x / 2, 0),
        Offset(size.x / 2, size.y),
        Paint()
          ..color = color
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
      return;
    }
    final center = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(
      center,
      size.x / 2,
      Paint()..color = color.withValues(alpha: 0.22),
    );
    canvas.drawCircle(
      center,
      size.x / 2.4,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is ObstacleComponent) {
      game.collisions.handleProjectileHit(this, other);
    } else if (other is BossComponent) {
      game.collisions.handleProjectileBossHit(this, other);
    }
  }
}
