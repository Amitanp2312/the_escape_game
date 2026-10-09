import 'package:flutter/material.dart';

import '../utils/constants.dart';

class PowerUpIndicator extends StatelessWidget {
  const PowerUpIndicator({
    super.key,
    required this.label,
    required this.remaining,
    required this.duration,
  });

  final String? label;
  final double remaining;
  final double duration;

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return const SizedBox.shrink();
    }
    final progress = duration <= 0
        ? 0.0
        : (remaining / duration).clamp(0.0, 1.0);
    return Container(
      width: 118,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: NeonColors.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NeonColors.green.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label!,
            style: const TextStyle(
              color: NeonColors.green,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.toDouble(),
              minHeight: 6,
              backgroundColor: NeonColors.surfaceAlt,
              color: NeonColors.green,
            ),
          ),
        ],
      ),
    );
  }
}
