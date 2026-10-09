import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../../models/weapon_type.dart';
import '../../utils/constants.dart';
import '../neon_escape_game.dart';

class WeaponPickupComponent extends PositionComponent
    with HasGameReference<NeonEscapeGame>, CollisionCallbacks {
  WeaponPickupComponent({required this.lane, required this.type});

  final int lane;
  final WeaponType type;
  bool collected = false;
  double _pulse = 0;

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    final scale = (game.size.x / 390).clamp(0.82, 1.28);
    size = Vector2.all(34 * scale);
    position = Vector2(game.layout.laneCenter(lane), -size.y);
    add(
      CircleHitbox.relative(0.8, parentSize: size)
        ..collisionType = CollisionType.passive,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (collected) {
      removeFromParent();
      return;
    }
    _pulse += dt * 5;
    position.y += game.currentObstacleSpeed * game.worldSpeedFactor * dt;
    if (position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final color = NeonColors.forWeapon(type);
    final center = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(
      center,
      size.x / 2 + 2 * (0.5 + 0.5 * (1 - (_pulse % 1))),
      Paint()..color = color.withValues(alpha: 0.16),
    );
    canvas.drawCircle(
      center,
      size.x / 2.2,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
    final painter = TextPainter(
      text: TextSpan(
        text: type.shortLabel,
        style: TextStyle(
          color: color,
          fontSize: size.x * 0.18,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.x);
    painter.paint(
      canvas,
      Offset((size.x - painter.width) / 2, (size.y - painter.height) / 2),
    );
  }

  void markCollected() {
    collected = true;
  }
}
