import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

import '../../models/player_skin.dart';
import '../../utils/constants.dart';
import '../../utils/game_config.dart';
import '../../utils/helpers.dart';
import '../../utils/sprite_assets.dart';
import '../neon_escape_game.dart';
import '../sprite_bank.dart';
import 'boss.dart';
import 'boss_bullet.dart';
import 'coin.dart';
import 'obstacle.dart';
import 'power_up.dart';
import 'weapon_pickup.dart';

class PlayerComponent extends PositionComponent
    with HasGameReference<NeonEscapeGame>, CollisionCallbacks {
  PlayerComponent({required this.skin});

  PlayerSkin skin;
  double targetX = 0;
  double _pulse = 0;
  double _bank = 0;
  SpriteAnimationTicker? _anim;

  Vector2 get muzzleWorld => Vector2(position.x, position.y - size.y * 0.48);

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    _applySize();
    add(
      RectangleHitbox.relative(Vector2(0.62, 0.7), parentSize: size)
        ..collisionType = CollisionType.active,
    );
    _anim = game.sprites.ticker(SpriteAssets.airplane);
  }

  void relayout() {
    _applySize();
    position.y = game.playerY;
    targetX = game.layout.clampPlayerX(
      targetX == 0 ? game.size.x / 2 : targetX,
      size.x,
    );
    position.x = game.layout.clampPlayerX(position.x, size.x);
  }

  void _applySize() {
    final scale = (game.size.x / 390).clamp(0.82, 1.28);
    size = Vector2(GameConfig.playerWidth, GameConfig.playerHeight) * scale;
  }

  void moveToX(double worldX) {
    targetX = game.layout.clampPlayerX(worldX, size.x);
  }

  void nudgeLane(int direction) {
    final lane = game.layout.laneAt(position.x) + direction;
    targetX = game.layout.clampPlayerX(game.layout.laneCenter(lane), size.x);
  }

  void snapToLaneAt(double worldX) {
    targetX = game.layout.clampPlayerX(
      game.layout.laneCenter(game.layout.laneAt(worldX)),
      size.x,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _anim?.update(dt);
    _pulse += dt * 10;
    final t = (GameConfig.playerLerpSpeed * dt).clamp(0.0, 1.0);
    position.x = lerpDoubleClamped(position.x, targetX, t);
    position.x = game.layout.clampPlayerX(position.x, size.x);
    final desiredBank = ((targetX - position.x) / 70).clamp(-0.38, 0.38);
    _bank = lerpDoubleClamped(_bank, desiredBank, (10 * dt).clamp(0.0, 1.0));
    position.y = game.playerY + math.sin(_pulse * 0.35) * 3;
  }

  @override
  void render(Canvas canvas) {
    final blink =
        game.invincibleTimer > 0 && (game.invincibleTimer * 16).floor().isEven;
    final opacity = blink ? 0.35 : 1.0;
    final rect = Rect.fromCenter(
      center: Offset(size.x / 2, size.y / 2),
      width: size.x,
      height: size.y,
    );

    if (game.powerUps.hasShield) {
      canvas.drawCircle(
        rect.center,
        size.x * 0.72,
        Paint()
          ..color = skin.glow.withValues(alpha: 0.18 + 0.08 * math.sin(_pulse))
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        rect.center,
        size.x * 0.72,
        Paint()
          ..color = skin.glow.withValues(alpha: 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4,
      );
    }

    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    canvas.rotate(_bank);
    canvas.translate(-rect.center.dx, -rect.center.dy);

    final sprite =
        _anim?.getSprite() ?? game.sprites.get(SpriteAssets.airplane);
    if (sprite != null) {
      renderSprite(
        canvas,
        sprite,
        size: size,
        opacity: opacity,
        tint: ColorFilter.mode(
          skin.primary.withValues(alpha: 1),
          BlendMode.modulate,
        ),
      );
    } else {
      _drawFallbackPlane(canvas, rect, opacity);
    }

    canvas.restore();

    final exhaustY = rect.bottom - 2;
    canvas.drawCircle(
      Offset(rect.center.dx - 6, exhaustY),
      3 + math.sin(_pulse).abs() * 2,
      Paint()..color = NeonColors.magenta.withValues(alpha: 0.7 * opacity),
    );
    canvas.drawCircle(
      Offset(rect.center.dx + 6, exhaustY),
      3 + math.cos(_pulse).abs() * 2,
      Paint()..color = NeonColors.cyan.withValues(alpha: 0.7 * opacity),
    );
  }

  void _drawFallbackPlane(Canvas canvas, Rect rect, double opacity) {
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final fill = Paint()
      ..color = skin.primary.withValues(alpha: 0.22 * opacity);
    final stroke = Paint()
      ..color = skin.primary.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final wings = Path()
      ..moveTo(cx, cy - 6)
      ..lineTo(rect.right, cy + 8)
      ..lineTo(cx + 7, cy + 10)
      ..lineTo(cx - 7, cy + 10)
      ..lineTo(rect.left, cy + 8)
      ..close();
    canvas.drawPath(wings, fill);
    canvas.drawPath(wings, stroke);

    final fuselage = Path()
      ..moveTo(cx, rect.top + 2)
      ..lineTo(cx + 7, cy)
      ..lineTo(cx + 5, rect.bottom - 10)
      ..lineTo(cx - 5, rect.bottom - 10)
      ..lineTo(cx - 7, cy)
      ..close();
    canvas.drawPath(fuselage, fill);
    canvas.drawPath(fuselage, stroke);

    final tail = Path()
      ..moveTo(cx, rect.bottom - 22)
      ..lineTo(cx + 11, rect.bottom - 4)
      ..lineTo(cx, rect.bottom - 9)
      ..lineTo(cx - 11, rect.bottom - 4)
      ..close();
    canvas.drawPath(tail, fill);
    canvas.drawPath(tail, stroke);

    final cockpit = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy - 8),
        width: size.x * 0.28,
        height: size.y * 0.22,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      cockpit,
      Paint()..color = skin.secondary.withValues(alpha: 0.85 * opacity),
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is ObstacleComponent) {
      game.collisions.handleObstacle(other);
    } else if (other is CoinComponent) {
      game.collisions.handleCoin(other);
    } else if (other is PowerUpComponent) {
      game.collisions.handlePowerUp(other);
    } else if (other is WeaponPickupComponent) {
      game.collisions.handleWeaponPickup(other);
    } else if (other is BossBulletComponent) {
      game.collisions.handleBossBullet(other);
    } else if (other is BossComponent) {
      game.collisions.handleBossTouch(other);
    }
  }
}
