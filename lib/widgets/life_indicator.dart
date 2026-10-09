import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/game_config.dart';

class LifeIndicator extends StatelessWidget {
  const LifeIndicator({super.key, required this.lives});

  final int lives;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$lives lives',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < GameConfig.initialLives; i++)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                i < lives ? Icons.favorite : Icons.favorite_border,
                color: i < lives ? NeonColors.pink : NeonColors.mutedText,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}
