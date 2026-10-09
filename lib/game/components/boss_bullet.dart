import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../utils/constants.dart';
import '../neon_escape_game.dart';

class BossBulletComponent extends PositionComponent
    with HasGameReference<NeonEscapeGame>, CollisionCallbacks {
  BossBulletComponent({required this.velocity});

  final Vector2 velocity;
  bool consumed = false;

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    size = Vector2(14, 18);
    priority = 7;
    add(
      CircleHitbox.relative(0.72, parentSize: size)
        ..collisionType = CollisionType.passive,
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
    if (position.y > game.size.y + size.y ||
        position.x < -size.x ||
        position.x > game.size.x + size.x) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(
      center,
      size.x / 2,
      Paint()..color = NeonColors.red.withValues(alpha: 0.28),
    );
    canvas.drawCircle(center, 5, Paint()..color = NeonColors.pink);
  }

  void markConsumed() {
    consumed = true;
  }
}
