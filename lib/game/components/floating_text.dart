import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

class FloatingText extends PositionComponent {
  FloatingText({
    required Vector2 position,
    required this.text,
    required this.color,
  }) {
    this.position = position.clone();
    anchor = Anchor.center;
    priority = 30;
  }

  final String text;
  final Color color;
  double _life = 0.7;

  @override
  void update(double dt) {
    super.update(dt);
    _life -= dt;
    position.y -= 42 * dt;
    if (_life <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color.withValues(alpha: (_life / 0.7).clamp(0.0, 1.0)),
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
  }
}
