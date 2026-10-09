import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

import '../../utils/constants.dart';
import '../../utils/game_config.dart';
import '../managers/spawn_manager.dart';
import '../neon_escape_game.dart';
import '../sprite_bank.dart';

class ObstacleComponent extends PositionComponent
    with HasGameReference<NeonEscapeGame>, CollisionCallbacks {
  ObstacleComponent({required this.type, required this.lane});

  final ObstacleType type;
  final int lane;
  late int hp = ObstacleRules.hp(type);
  bool countedPass = false;
  bool consumed = false;
  double _time = 0;
  double _hitFlash = 0;
  double _baseX = 0;
  SpriteAnimationTicker? _anim;

  bool applyHit(int damage) {
    if (consumed || damage <= 0) {
      return false;
    }
    hp -= damage;
    _hitFlash = 0.12;
    return hp <= 0;
  }

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    _applyLayout();
    position = Vector2(_baseX, -size.y);
    add(_hitbox());
    _anim = game.sprites.ticker(spriteForObstacle(type));
  }

  void _applyLayout() {
    final laneWidth = game.layout.laneWidth;
    size = switch (type) {
      ObstacleType.neonBarrier => Vector2(laneWidth * 0.78, 40),
      ObstacleType.energyCube => Vector2(laneWidth * 0.5, laneWidth * 0.5),
      ObstacleType.laserBlock => Vector2(laneWidth * 0.32, laneWidth * 0.58),
      ObstacleType.cyberDrone => Vector2(laneWidth * 0.46, laneWidth * 0.46),
      ObstacleType.movingBarrier => Vector2(laneWidth * 0.48, laneWidth * 0.48),
    };
    _baseX = game.layout.laneCenter(lane);
  }

  ShapeHitbox _hitbox() {
    final hitbox = type == ObstacleType.cyberDrone
        ? CircleHitbox.relative(0.72, parentSize: size)
        : RectangleHitbox.relative(Vector2(0.78, 0.78), parentSize: size);
    hitbox.collisionType = CollisionType.passive;
    return hitbox;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _anim?.update(dt);
    _time += dt;
    _hitFlash = math.max(0, _hitFlash - dt);
    position.y +=
        game.currentObstacleSpeed *
        game.worldSpeedFactor *
        ObstacleRules.speedFactor(type) *
        dt;
    if (type == ObstacleType.movingBarrier || type == ObstacleType.cyberDrone) {
      position.x =
          _baseX + math.sin(_time * 2.4) * (game.layout.laneWidth * 0.18);
    } else {
      position.x = _baseX;
    }

    if (!countedPass && !consumed && position.y > game.player.position.y) {
      countedPass = true;
      game.registerSuccessfulDodge(this);
    }
    if (position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final sprite =
        _anim?.getSprite() ?? game.sprites.get(spriteForObstacle(type));
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    if (type == ObstacleType.energyCube) {
      canvas.rotate(_time);
    }
    if (type == ObstacleType.cyberDrone) {
      canvas.translate(0, math.sin(_time * 5) * 3);
    }
    if (type == ObstacleType.movingBarrier) {
      final pulse = 0.9 + 0.1 * math.sin(_time * 6);
      canvas.scale(pulse);
    }
    canvas.translate(-size.x / 2, -size.y / 2);
    if (sprite != null) {
      renderSprite(
        canvas,
        sprite,
        size: size,
        opacity: _hitFlash > 0 ? 0.45 : 1,
      );
      canvas.restore();
      return;
    }
    _drawFallback(canvas);
    canvas.restore();
  }

  void _drawFallback(Canvas canvas) {
    final rect = Offset.zero & size.toSize();
    switch (type) {
      case ObstacleType.neonBarrier:
        _strokeRect(canvas, rect, NeonColors.magenta);
      case ObstacleType.energyCube:
        _strokeRect(canvas, rect, NeonColors.purple, radius: 8);
      case ObstacleType.laserBlock:
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(8)),
          Paint()..color = NeonColors.red.withValues(alpha: 0.85),
        );
        canvas.drawLine(
          Offset(size.x / 2, 0),
          Offset(size.x / 2, size.y),
          Paint()
            ..color = NeonColors.pink
            ..strokeWidth = 3,
        );
      case ObstacleType.cyberDrone:
        final center = Offset(size.x / 2, size.y / 2);
        canvas.drawCircle(
          center,
          size.x / 2,
          Paint()..color = NeonColors.cyan.withValues(alpha: 0.18),
        );
        canvas.drawCircle(
          center,
          size.x / 2,
          Paint()
            ..color = NeonColors.cyan
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );
        canvas.drawCircle(center, 5, Paint()..color = NeonColors.green);
      case ObstacleType.movingBarrier:
        _strokeRect(canvas, rect, NeonColors.gold, radius: 4);
    }
  }

  void _strokeRect(Canvas canvas, Rect rect, Color color, {double radius = 6}) {
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(rrect, Paint()..color = color.withValues(alpha: 0.18));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.3,
    );
  }
}

double obstacleNearMissDistance(ObstacleComponent obstacle, Vector2 playerPos) {
  return (obstacle.position.x - playerPos.x).abs();
}

bool isNearMiss(ObstacleComponent obstacle, Vector2 playerPos) {
  return obstacleNearMissDistance(obstacle, playerPos) <=
      GameConfig.nearMissDistance;
}
