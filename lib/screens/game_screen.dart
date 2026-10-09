import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../app/app.dart';
import '../game/neon_escape_game.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';
import '../utils/game_config.dart';
import '../widgets/coin_display.dart';
import '../widgets/life_indicator.dart';
import '../widgets/power_up_indicator.dart';
import '../widgets/score_display.dart';
import '../widgets/weapon_indicator.dart';
import 'game_over_screen.dart';
import 'level_complete_screen.dart';
import 'pause_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.launch});

  final GameLaunch launch;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final NeonEscapeGame _game;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _game = NeonEscapeGame(
      appController: AppScope.read(context),
      level: widget.launch.level,
      endless: widget.launch.endless,
    );
    _lifecycle = AppLifecycleListener(
      onHide: _game.pauseGame,
      onPause: _game.pauseGame,
      onInactive: _game.pauseGame,
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _game.commitPendingResult();
    _game.pauseEngine();
    super.dispose();
    _game.dispose();
  }

  void _leaveRun() {
    _game.commitPendingResult();
    _game.audio.startMusic();
    _game.pauseEngine();
    Navigator.of(context).pop();
  }

  void _onBack() {
    if (_game.isPaused || _game.isGameOver || _game.isVictory) {
      _leaveRun();
      return;
    }
    _game.pauseGame();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        _onBack();
      },
      child: Scaffold(
        body: Stack(
          children: [
            GameWidget(
              game: _game,
              overlayBuilderMap: {
                OverlayIds.pause: (context, game) {
                  return PauseScreen(game: game as NeonEscapeGame);
                },
                OverlayIds.gameOver: (context, game) {
                  return GameOverScreen(game: game as NeonEscapeGame);
                },
                OverlayIds.victory: (context, game) {
                  return LevelCompleteScreen(game: game as NeonEscapeGame);
                },
              },
            ),
            ValueListenableBuilder<GamePhase>(
              valueListenable: _game.phase,
              builder: (context, phase, _) {
                if (phase != GamePhase.playing) {
                  return const SizedBox.shrink();
                }
                return Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapUp: (details) =>
                        _game.onTapAt(details.localPosition.dx),
                    onHorizontalDragUpdate: (details) =>
                        _game.onDragTo(details.localPosition.dx),
                    onHorizontalDragEnd: (details) {
                      final velocity = details.velocity.pixelsPerSecond.dx;
                      if (velocity.abs() >= GameConfig.swipeVelocityThreshold) {
                        _game.onSwipe(velocity > 0 ? 1 : -1);
                      }
                    },
                  ),
                );
              },
            ),
            SafeArea(
              child: ValueListenableBuilder<GamePhase>(
                valueListenable: _game.phase,
                builder: (context, phase, _) {
                  if (phase != GamePhase.playing) {
                    return const SizedBox.shrink();
                  }
                  return ValueListenableBuilder<HudState>(
                    valueListenable: _game.hud,
                    builder: (context, hud, _) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ScoreDisplay(
                                    score: hud.score,
                                    compact: true,
                                  ),
                                ),
                                ScoreDisplay(
                                  score: hud.highScore,
                                  label: 'BEST',
                                  compact: true,
                                ),
                                const SizedBox(width: 8),
                                Material(
                                  color: Colors.transparent,
                                  child: IconButton(
                                    tooltip: 'Pause',
                                    onPressed: _game.pauseGame,
                                    icon: const Icon(Icons.pause_circle_filled),
                                    color: NeonColors.cyan,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                CoinDisplay(
                                  coins: hud.sessionCoins,
                                  compact: true,
                                ),
                                const Spacer(),
                                LifeIndicator(lives: hud.lives),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                hud.endless
                                    ? 'WAVE ${hud.wave}'
                                    : hud.levelName.toUpperCase(),
                                style: const TextStyle(
                                  color: NeonColors.gold,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: hud.inBossFight ? 1 : hud.runProgress,
                                minHeight: 7,
                                backgroundColor: NeonColors.surfaceAlt,
                                color: hud.inBossFight
                                    ? NeonColors.pink
                                    : NeonColors.cyan,
                              ),
                            ),
                            if (hud.inBossFight) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Text(
                                    'BOSS',
                                    style: TextStyle(
                                      color: NeonColors.pink,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: hud.bossMaxHp <= 0
                                            ? 0
                                            : (hud.bossHp / hud.bossMaxHp)
                                                  .clamp(0.0, 1.0),
                                        minHeight: 8,
                                        backgroundColor: NeonColors.surfaceAlt,
                                        color: NeonColors.red,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${hud.bossHp}',
                                    style: const TextStyle(
                                      color: NeonColors.text,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  WeaponIndicator(
                                    label: hud.weaponShortLabel,
                                    color: NeonColors.forWeapon(hud.weapon),
                                  ),
                                  const SizedBox(width: 8),
                                  PowerUpIndicator(
                                    label: hud.activePowerUpLabel,
                                    remaining: hud.powerUpRemaining,
                                    duration: hud.powerUpDuration,
                                  ),
                                  if (hud.combo >= 3) ...[
                                    const SizedBox(width: 8),
                                    _ComboBadge(
                                      combo: hud.combo,
                                      pulse: hud.comboPulse,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (hud.bossBanner != null) ...[
                              const SizedBox(height: 18),
                              Center(
                                child: Text(
                                  hud.bossBanner!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: NeonColors.pink,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                    letterSpacing: 1.6,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComboBadge extends StatelessWidget {
  const _ComboBadge({required this.combo, required this.pulse});

  final int combo;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 160),
      scale: pulse ? 1.18 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: NeonColors.pink.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: NeonColors.pink.withValues(alpha: 0.7)),
        ),
        child: Text(
          'x$combo',
          style: const TextStyle(
            color: NeonColors.pink,
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}
