import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

class ParticleBurst extends PositionComponent {
  ParticleBurst({
    required Vector2 position,
    required this.color,
    this.particleCount = 10,
  }) {
    this.position = position;
    anchor = Anchor.center;
    size = Vector2.all(8);
    priority = 20;
  }

  final Color color;
  final int particleCount;
  late final List<_Spark> _sparks;
  double _life = 0.35;

  @override
  Future<void> onLoad() async {
    final random = math.Random();
    _sparks = List.generate(particleCount, (index) {
      final angle = (index / particleCount) * math.pi * 2;
      final speed = 70 + random.nextDouble() * 90;
      return _Spark(dx: math.cos(angle) * speed, dy: math.sin(angle) * speed);
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    _life -= dt;
    for (final spark in _sparks) {
      spark.x += spark.dx * dt;
      spark.y += spark.dy * dt;
    }
    if (_life <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color.withValues(alpha: (_life / 0.35).clamp(0, 1));
    for (final spark in _sparks) {
      canvas.drawCircle(Offset(spark.x, spark.y), 2.4, paint);
    }
  }
}

class _Spark {
  _Spark({required this.dx, required this.dy});

  double x = 0;
  double y = 0;
  final double dx;
  final double dy;
}
