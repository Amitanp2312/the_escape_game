import 'package:flutter/material.dart';

import '../app/app.dart';
import '../game/neon_escape_game.dart';
import '../utils/constants.dart';
import '../widgets/neon_button.dart';

class PauseScreen extends StatelessWidget {
  const PauseScreen({super.key, required this.game});

  final NeonEscapeGame game;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final soundOn = controller.profile.soundEffectsEnabled;
    return Material(
      color: Colors.black.withValues(alpha: 0.72),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'PAUSED',
                    style: TextStyle(
                      color: NeonColors.cyan,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  NeonButton(
                    label: 'Resume',
                    icon: Icons.play_arrow_rounded,
                    onPressed: game.resumeGame,
                  ),
                  const SizedBox(height: 12),
                  NeonButton(
                    label: 'Restart',
                    color: NeonColors.purple,
                    icon: Icons.replay,
                    onPressed: game.restart,
                  ),
                  const SizedBox(height: 12),
                  NeonButton(
                    label: soundOn ? 'Sound On' : 'Sound Off',
                    color: NeonColors.gold,
                    icon: soundOn ? Icons.volume_up : Icons.volume_off,
                    onPressed: () =>
                        controller.setSoundEffectsEnabled(!soundOn),
                  ),
                  const SizedBox(height: 12),
                  NeonButton(
                    label: 'Main Menu',
                    color: NeonColors.pink,
                    icon: Icons.home_outlined,
                    onPressed: () {
                      game.commitPendingResult();
                      game.audio.startMusic();
                      game.pauseEngine();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
