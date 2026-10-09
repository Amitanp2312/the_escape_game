import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/helpers.dart';

class CoinDisplay extends StatelessWidget {
  const CoinDisplay({super.key, required this.coins, this.compact = false});

  final int coins;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$coins coins',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: compact ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: NeonColors.gold.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: NeonColors.gold.withValues(alpha: 0.8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.monetization_on,
              color: NeonColors.gold,
              size: compact ? 16 : 18,
            ),
            const SizedBox(width: 6),
            Text(
              formatScore(coins),
              style: TextStyle(
                color: NeonColors.gold,
                fontWeight: FontWeight.w800,
                fontSize: compact ? 13 : 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
