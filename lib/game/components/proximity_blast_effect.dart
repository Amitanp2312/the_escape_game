import 'dart:ui';

import 'package:flame/components.dart';

import '../../utils/constants.dart';

class ProximityBlastEffect extends PositionComponent {
  ProximityBlastEffect({required Vector2 position, required this.radius}) {
    this.position = position;
    anchor = Anchor.center;
    size = Vector2.all(radius * 2);
    priority = 18;
  }

  final double radius;
  double _life = 0.28;

  @override
  void update(double dt) {
    super.update(dt);
    _life -= dt;
    if (_life <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final t = (1 - _life / 0.28).clamp(0.0, 1.0);
    final current = radius * (0.35 + 0.65 * t);
    final center = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(
      center,
      current,
      Paint()..color = NeonColors.gold.withValues(alpha: 0.16 * (1 - t)),
    );
    canvas.drawCircle(
      center,
      current,
      Paint()
        ..color = NeonColors.gold.withValues(alpha: 0.9 * (1 - t))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }
}
