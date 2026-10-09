import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/helpers.dart';

class ScoreDisplay extends StatelessWidget {
  const ScoreDisplay({
    super.key,
    required this.score,
    this.label = 'SCORE',
    this.compact = false,
  });

  final int score;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: NeonColors.mutedText,
            fontSize: compact ? 10 : 11,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Text(
            formatScore(score),
            key: ValueKey(score),
            style: TextStyle(
              color: NeonColors.cyan,
              fontSize: compact ? 18 : 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
