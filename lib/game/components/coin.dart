import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

import '../../utils/constants.dart';
import '../../utils/game_config.dart';
import '../../utils/sprite_assets.dart';
import '../neon_escape_game.dart';
import '../sprite_bank.dart';

class CoinComponent extends PositionComponent
    with HasGameReference<NeonEscapeGame>, CollisionCallbacks {
  CoinComponent({
    this.lane = 0,
    this.yOffset = 0,
    this.value = 1,
    this.isGem = false,
    this.start,
    this.drift,
  });

  final int lane;
  final double yOffset;
  final int value;
  final bool isGem;
  final Vector2? start;
  final Vector2? drift;
  bool collected = false;
  double _spin = 0;
  SpriteAnimationTicker? _anim;

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    final scale = (game.size.x / 390).clamp(0.82, 1.28);
    size = Vector2.all((isGem ? 34 : 26) * scale);
    position =
        start?.clone() ??
        Vector2(game.layout.laneCenter(lane), -size.y + yOffset);
    add(
      CircleHitbox.relative(0.78, parentSize: size)
        ..collisionType = CollisionType.passive,
    );
    _anim = game.sprites.ticker(isGem ? SpriteAssets.gem : SpriteAssets.coin);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _anim?.update(dt);
    if (collected) {
      size.scale((1 - dt * 8).clamp(0.1, 1.0));
      if (size.x < 4) {
        removeFromParent();
      }
      return;
    }
    _spin += dt * 6;
    if (drift != null) {
      position += drift! * dt;
    }
    if (game.powerUps.hasMagnet) {
      final delta = game.player.position - position;
      if (delta.length < GameConfig.magnetRadius) {
        position += delta.normalized() * 280 * dt;
      }
    }
    if (drift == null) {
      position.y += game.currentObstacleSpeed * game.worldSpeedFactor * dt;
    }
    if (position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final sprite =
        _anim?.getSprite() ??
        game.sprites.get(isGem ? SpriteAssets.gem : SpriteAssets.coin);
    if (sprite != null) {
      renderSprite(canvas, sprite, size: size);
    } else {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.scale(0.35 + 0.65 * (0.5 + 0.5 * math.cos(_spin)), 1);
      canvas.translate(-center.dx, -center.dy);
      _drawFallback(canvas, center);
      canvas.restore();
    }
    canvas.drawCircle(
      Offset(center.dx + math.cos(_spin) * size.x * 0.22, center.dy - 6),
      2.2,
      Paint()..color = const Color(0xCCFFFFFF),
    );
  }

  void _drawFallback(Canvas canvas, Offset center) {
    final color = isGem ? NeonColors.cyan : NeonColors.gold;
    final radius = size.x / 2;
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = color.withValues(alpha: 0.18),
    );
    canvas.drawCircle(
      center,
      radius * 0.78,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
    canvas.drawCircle(center, isGem ? 6 : 4, Paint()..color = color);
  }

  void markCollected() {
    collected = true;
  }
}
