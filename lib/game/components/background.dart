import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../neon_escape_game.dart';

class CyberBackground extends PositionComponent
    with HasGameReference<NeonEscapeGame> {
  CyberBackground();

  double _travel = 0;
  final math.Random _random = math.Random(7);
  late final List<_Star> _stars;
  late final List<_Building> _buildings;

  @override
  Future<void> onLoad() async {
    size = game.size.clone();
    anchor = Anchor.topLeft;
    position = Vector2.zero();
    priority = -10;
    _stars = List.generate(28, (index) {
      return _Star(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        radius: 0.8 + _random.nextDouble() * 1.6,
        speed: 12 + _random.nextDouble() * 40,
      );
    });
    _buildings = List.generate(10, (index) {
      return _Building(
        xFactor: index / 10,
        widthFactor: 0.06 + _random.nextDouble() * 0.08,
        heightFactor: 0.12 + _random.nextDouble() * 0.22,
        color: index.isEven ? NeonColors.purple : NeonColors.magenta,
      );
    });
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _travel += dt * game.currentObstacleSpeed * game.worldSpeedFactor * 0.35;
    for (final star in _stars) {
      star.y += (star.speed * dt * game.worldSpeedFactor) / math.max(size.y, 1);
      if (star.y > 1) {
        star.y -= 1;
        star.x = _random.nextDouble();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final sprite = game.sprites.get(game.level.backgroundAsset);
    if (sprite != null) {
      final offset = _travel % size.y;
      sprite.render(canvas, position: Vector2(0, offset - size.y), size: size);
      sprite.render(canvas, position: Vector2(0, offset), size: size);
    } else {
      final rect = size.toRect();
      canvas.drawRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050510), Color(0xFF140824), Color(0xFF071226)],
          ).createShader(rect),
      );
      _drawSkyline(canvas);
      _drawGrid(canvas);
    }

    _drawStars(canvas);
    _drawHighway(canvas);
  }

  void _drawStars(Canvas canvas) {
    final paint = Paint()..color = const Color(0x88FFFFFF);
    for (final star in _stars) {
      canvas.drawCircle(
        Offset(star.x * size.x, star.y * size.y * 0.55),
        star.radius,
        paint,
      );
    }
  }

  void _drawSkyline(Canvas canvas) {
    final horizon = size.y * 0.28;
    for (final building in _buildings) {
      final x = building.xFactor * size.x;
      final width = building.widthFactor * size.x;
      final height = building.heightFactor * size.y;
      final rect = Rect.fromLTWH(x, horizon - height, width, height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        Paint()..color = building.color.withValues(alpha: 0.18),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        Paint()
          ..color = building.color.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  void _drawGrid(Canvas canvas) {
    final paint = Paint()
      ..color = NeonColors.cyan.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    final vanishing = Offset(size.x / 2, size.y * 0.26);
    for (var i = 0; i <= 8; i++) {
      final x = size.x * (i / 8);
      canvas.drawLine(vanishing, Offset(x, size.y), paint);
    }
    final offset = _travel % 70;
    for (var y = size.y * 0.3 + offset; y < size.y; y += 70) {
      final flatten = (y - size.y * 0.26) / (size.y * 0.74);
      final inset = flatten * 18;
      canvas.drawLine(Offset(inset, y), Offset(size.x - inset, y), paint);
    }
  }

  void _drawHighway(Canvas canvas) {
    final lanePaint = Paint()
      ..color = NeonColors.purple.withValues(alpha: 0.45)
      ..strokeWidth = 2;
    final dashOffset = _travel % 36;
    for (var lane = 1; lane < 3; lane++) {
      final x = size.x * lane / 3;
      for (var y = size.y * 0.32 + dashOffset; y < size.y; y += 36) {
        canvas.drawLine(Offset(x, y), Offset(x, y + 16), lanePaint);
      }
    }
  }
}

class _Star {
  _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
  });

  double x;
  double y;
  final double radius;
  final double speed;
}

class _Building {
  const _Building({
    required this.xFactor,
    required this.widthFactor,
    required this.heightFactor,
    required this.color,
  });

  final double xFactor;
  final double widthFactor;
  final double heightFactor;
  final Color color;
}
