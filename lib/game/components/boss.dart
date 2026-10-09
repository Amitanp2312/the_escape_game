import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

import '../../models/level_definition.dart';
import '../../utils/constants.dart';
import '../../utils/game_config.dart';
import '../managers/boss_combat.dart';
import '../managers/spawn_manager.dart';
import '../neon_escape_game.dart';
import '../sprite_bank.dart';
import 'boss_bullet.dart';
import 'obstacle.dart';

class BossComponent extends PositionComponent
    with HasGameReference<NeonEscapeGame>, CollisionCallbacks {
  BossComponent({required this.level})
    : combat = BossCombat(maxHp: level.bossMaxHp);

  final LevelDefinition level;
  final BossCombat combat;
  double _time = 0;
  double _fireTimer = 0.6;
  double _flash = 0;
  int _sweepLane = 0;
  bool entering = true;
  SpriteAnimationTicker? _anim;

  double _shieldTimer = 3;
  bool _shieldUp = true;
  double _summonTimer = 2.4;
  double _wallTimer = 2.2;
  int? warningLane;
  double warningTime = 0;

  void flash() {
    _flash = 0.16;
  }

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    final scale = (game.size.x / 390).clamp(0.85, 1.3);
    size = Vector2(150, 150) * scale;
    position = Vector2(game.size.x / 2, -size.y);
    priority = 6;
    add(
      RectangleHitbox.relative(Vector2(0.72, 0.68), parentSize: size)
        ..collisionType = CollisionType.passive,
    );
    _anim = game.sprites.ticker(level.bossSprite);
    if (level.mechanic == BossMechanic.shielded) {
      combat.invulnerable = true;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _anim?.update(dt);
    if (combat.defeated) {
      return;
    }
    _time += dt;
    _flash = math.max(0, _flash - dt);
    if (warningTime > 0) {
      warningTime = math.max(0, warningTime - dt);
      if (warningTime == 0 && warningLane != null) {
        _fireLaneWall(warningLane!);
        warningLane = null;
      }
    }
    final targetY = game.size.y * 0.18;
    if (entering) {
      position.y = (position.y + 180 * dt).clamp(-size.y, targetY);
      if (position.y >= targetY - 1) {
        entering = false;
      }
    } else {
      position.y = targetY;
    }
    final move = level.bossMoveSpeed * (combat.phase == 2 ? 1.35 : 1);
    position.x =
        game.size.x / 2 + math.sin(_time * move) * (game.size.x * 0.28);
    if (!entering) {
      _updateMechanic(dt);
      _fireTimer -= dt;
      if (_fireTimer <= 0) {
        _fire();
        _fireTimer = level.bossFireInterval / (combat.phase == 2 ? 1.15 : 1);
      }
    }
  }

  void _updateMechanic(double dt) {
    switch (level.mechanic) {
      case BossMechanic.basic:
        return;
      case BossMechanic.summoner:
        _summonTimer -= dt;
        if (_summonTimer <= 0) {
          _summonDrone();
          _summonTimer = 2.4;
        }
      case BossMechanic.shielded:
        _shieldTimer -= dt;
        if (_shieldTimer <= 0) {
          _shieldUp = !_shieldUp;
          combat.invulnerable = _shieldUp;
          _shieldTimer = _shieldUp ? 3 : 2;
          if (!_shieldUp) {
            flash();
          }
        }
      case BossMechanic.laneWall:
        _wallTimer -= dt;
        if (_wallTimer <= 0 && warningLane == null) {
          warningLane = math.Random().nextInt(GameConfig.laneCount);
          warningTime = 0.8;
          _wallTimer = 2.6;
        }
      case BossMechanic.twoPhase:
        if (combat.phase == 2) {
          _summonTimer -= dt;
          if (_summonTimer <= 0) {
            _summonDrone();
            _summonTimer = 2.0;
          }
        }
    }
  }

  void _summonDrone() {
    final lane = math.Random().nextInt(GameConfig.laneCount);
    game.world.add(
      ObstacleComponent(type: ObstacleType.cyberDrone, lane: lane),
    );
  }

  void _fireLaneWall(int lane) {
    final x = game.layout.laneCenter(lane);
    final originY = position.y + size.y * 0.35;
    final speed = GameConfig.bossProjectileSpeed;
    for (var i = 0; i < 5; i++) {
      game.world.add(
        BossBulletComponent(velocity: Vector2(0, speed))
          ..position = Vector2(x, originY - i * 18),
      );
    }
  }

  void _fire() {
    final origin = Vector2(position.x, position.y + size.y * 0.35);
    final speed = GameConfig.bossProjectileSpeed;
    final attack = combat.phase == 2 && level.mechanic == BossMechanic.twoPhase
        ? BossAttack.fan
        : level.bossAttack;
    switch (attack) {
      case BossAttack.aimed:
        final delta = game.player.position - origin;
        if (delta.length2 < 1) {
          return;
        }
        game.world.add(
          BossBulletComponent(velocity: delta.normalized() * speed)
            ..position = origin,
        );
      case BossAttack.fan:
        for (final angle in const [-32.0, -16.0, 0.0, 16.0, 32.0]) {
          final radians = angle * math.pi / 180;
          game.world.add(
            BossBulletComponent(
              velocity: Vector2(
                math.sin(radians) * speed,
                math.cos(radians) * speed,
              ),
            )..position = origin.clone(),
          );
        }
      case BossAttack.laneSweep:
        final lane = _sweepLane % GameConfig.laneCount;
        _sweepLane += 1;
        game.world.add(
          BossBulletComponent(velocity: Vector2(0, speed))
            ..position = Vector2(game.layout.laneCenter(lane), origin.y),
        );
    }
  }

  @override
  void render(Canvas canvas) {
    final sprite = _anim?.getSprite() ?? game.sprites.get(level.bossSprite);
    final openFlash =
        level.mechanic == BossMechanic.shielded && !combat.invulnerable;
    final opacity = (_flash > 0 || openFlash) ? 0.45 : 1.0;
    if (sprite != null) {
      renderSprite(canvas, sprite, size: size, opacity: opacity);
    } else {
      final rect = Offset.zero & size.toSize();
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(18)),
        Paint()..color = NeonColors.red.withValues(alpha: 0.22 * opacity),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(18)),
        Paint()
          ..color = NeonColors.pink.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
    if (_flash > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size.toSize(),
          const Radius.circular(18),
        ),
        Paint()..color = const Color(0x88FFFFFF),
      );
    }
    if (combat.invulnerable) {
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x * 0.52,
        Paint()
          ..color = NeonColors.cyan.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    }
    if (warningLane != null && warningTime > 0) {
      final x = game.layout.laneCenter(warningLane!) - position.x;
      final laneW = game.size.x / GameConfig.laneCount * 0.72;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x + size.x / 2, game.size.y * 0.4),
          width: laneW,
          height: game.size.y,
        ),
        Paint()..color = NeonColors.pink.withValues(alpha: 0.18),
      );
    }
  }
}
