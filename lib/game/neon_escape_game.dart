import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../app/app_controller.dart';
import '../models/game_state.dart';
import '../models/level_definition.dart';
import '../models/mission.dart';
import '../models/player_skin.dart';
import '../models/power_up_type.dart';
import '../services/audio_service.dart';
import '../utils/constants.dart';
import '../utils/game_config.dart';
import '../utils/helpers.dart';
import 'components/background.dart';
import 'components/boss.dart';
import 'components/boss_bullet.dart';
import 'components/coin.dart';
import 'components/floating_text.dart';
import 'components/obstacle.dart';
import 'components/particle_burst.dart';
import 'components/player.dart';
import 'components/power_up.dart';
import 'components/projectile.dart';
import 'components/proximity_blast_effect.dart';
import 'components/weapon_pickup.dart';
import 'managers/collision_manager.dart';
import 'managers/continue_rules.dart';
import 'managers/difficulty_manager.dart';
import 'managers/mission_manager.dart';
import 'managers/power_up_manager.dart';
import 'managers/score_manager.dart';
import 'managers/spawn_manager.dart';
import 'managers/weapon_manager.dart';
import 'sprite_bank.dart';

class NeonEscapeGame extends FlameGame with HasCollisionDetection {
  NeonEscapeGame({
    required this.appController,
    required this.level,
    this.endless = false,
  });

  final AppController appController;
  LevelDefinition level;
  bool endless;
  int wave = 1;
  final ScoreManager scoreManager = ScoreManager();
  final PowerUpManager powerUps = PowerUpManager();
  final DifficultyManager difficultyManager = DifficultyManager();
  final SpawnPlanner planner = SpawnPlanner();
  final ValueNotifier<HudState> hud = ValueNotifier(const HudState());
  final ValueNotifier<GamePhase> phase = ValueNotifier(GamePhase.playing);

  late final CollisionManager collisions;
  late final WeaponManager weapons;
  late final SpriteBank sprites;
  late final PlayerComponent player;
  late final CyberBackground background;
  late SessionMissionManager missionPreview;
  BossComponent? boss;
  bool inBossFight = false;
  bool continuedThisRun = false;

  DifficultySnapshot difficulty = const DifficultySnapshot(
    tier: DifficultyTier.easy,
    level: 1,
    obstacleSpeed: GameConfig.initialObstacleSpeed,
    spawnInterval: GameConfig.maximumSpawnInterval,
    obstacleTypeCount: 2,
    powerUpChance: GameConfig.powerUpChanceEasy,
    scoreMultiplier: 1,
  );

  GameSessionStats stats = GameSessionStats();
  SessionResult? lastResult;
  List<MissionProgressView> lastMissionViews = const [];
  PlayerSkin get currentSkin => appController.selectedSkin;
  AudioService get audio => appController.audio;

  int lives = GameConfig.initialLives;
  double invincibleTimer = 0;
  double _spawnTimer = 0.35;
  double _shakeTime = 0;
  double _shakePower = 0;
  double _levelElapsed = 0;
  double _bossBannerTimer = 0;
  double _comboPulseTimer = 0;
  double _hudAcc = 0;
  SessionResult? _pendingResult;
  bool _resultCommitted = false;
  final math.Random _random = math.Random();

  LaneLayout get layout => LaneLayout(screenWidth: size.x);
  double get playerY => size.y * 0.82;
  double get currentObstacleSpeed => difficulty.obstacleSpeed;
  double get worldSpeedFactor =>
      powerUps.hasSlowMotion ? GameConfig.slowMotionFactor : 1;
  double get activeScoreMultiplier =>
      difficulty.scoreMultiplier * powerUps.scoreMultiplier;
  bool get isGameOver => phase.value == GamePhase.gameOver;
  bool get isPaused => phase.value == GamePhase.paused;
  bool get isVictory => phase.value == GamePhase.victory;
  int get continueCost => ContinueRules.costFor(levelIndex: level.index);
  bool get canContinue => ContinueRules.allowed(
    alreadyUsed: continuedThisRun,
    coins: appController.totalCoins,
    cost: continueCost,
  );

  @override
  Color backgroundColor() => NeonColors.background;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    collisions = CollisionManager(this);
    weapons = WeaponManager(this);
    sprites = SpriteBank(this);
    await sprites.loadAll();
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();

    background = CyberBackground();
    player = PlayerComponent(skin: currentSkin);
    await world.add(background);
    await world.add(player);
    player.position = Vector2(size.x / 2, playerY);
    player.targetX = player.position.x;
    if (endless) {
      level = EndlessRules.levelForWave(wave);
    }
    _bindMissionPreview();
    refreshHud();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      player.relayout();
      background.size = size.clone();
    }
  }

  @override
  void update(double dt) {
    final step = dt.clamp(0.0, 1 / 30);
    super.update(step);
    if (paused || isGameOver) {
      return;
    }
    if (isVictory) {
      _updateShake(step);
      return;
    }
    stats.survivalSeconds += step;
    _levelElapsed += step;
    stats.distanceMeters += currentObstacleSpeed * step * 0.085;
    invincibleTimer = math.max(0, invincibleTimer - step);
    _bossBannerTimer = math.max(0, _bossBannerTimer - step);
    _comboPulseTimer = math.max(0, _comboPulseTimer - step);
    powerUps.update(step);
    weapons.update(step);
    final progress = (_levelElapsed / level.runSeconds).clamp(0.0, 1.0);
    difficulty = difficultyManager.evaluate(level: level, progress: progress);
    scoreManager.addSurvival(step, activeScoreMultiplier);
    stats.score = scoreManager.score;
    if (!inBossFight) {
      _spawnTimer -= step * worldSpeedFactor;
      if (_spawnTimer <= 0) {
        _spawnRow();
        _spawnTimer = difficulty.spawnInterval;
      }
      if (_levelElapsed >= level.runSeconds) {
        _startBoss();
      }
    }
    _updateShake(step);
    _hudAcc += step;
    if (_hudAcc >= 0.08) {
      _hudAcc = 0;
      refreshHud();
    }
  }

  void onDragTo(double worldX) {
    if (isGameOver || isPaused || isVictory) {
      return;
    }
    player.moveToX(worldX);
  }

  void onSwipe(int direction) {
    if (isGameOver || isPaused || isVictory) {
      return;
    }
    player.nudgeLane(direction);
  }

  void onTapAt(double worldX) {
    if (isGameOver || isPaused || isVictory) {
      return;
    }
    player.snapToLaneAt(worldX);
  }

  void floatText(Vector2 at, String text, Color color) {
    world.add(FloatingText(position: at, text: text, color: color));
  }

  void registerSuccessfulDodge(ObstacleComponent obstacle) {
    stats.obstaclesDodged += 1;
    final bonus = scoreManager.registerDodge(multiplier: activeScoreMultiplier);
    if (isNearMiss(obstacle, player.position)) {
      scoreManager.addNearMiss(activeScoreMultiplier);
      floatText(obstacle.position.clone(), 'NEAR MISS', NeonColors.gold);
    }
    if (bonus > 0) {
      _comboPulseTimer = 0.4;
      floatText(
        player.position.clone() + Vector2(0, -36),
        'COMBO x${scoreManager.combo}',
        NeonColors.pink,
      );
    }
    stats.score = scoreManager.score;
  }

  void grantLife() {
    lives = math.min(lives + 1, GameConfig.maxLives);
    refreshHud();
  }

  void takeDamage(Vector2 at, {int amount = 1}) {
    if (isVictory || isGameOver) {
      return;
    }
    lives -= amount;
    scoreManager.resetCombo();
    invincibleTimer = GameConfig.invincibilityDuration;
    audio.playCollision();
    appController.vibration.heavy();
    triggerShake();
    spawnBurst(at, NeonColors.red);
    if (lives <= 0) {
      endGame();
    } else {
      refreshHud();
    }
  }

  void spawnBurst(Vector2 position, Color color) {
    world.add(ParticleBurst(position: position, color: color));
  }

  void triggerShake([double power = 8]) {
    _shakeTime = 0.22;
    _shakePower = power;
  }

  void pauseGame() {
    if (isGameOver || isPaused || isVictory) {
      return;
    }
    phase.value = GamePhase.paused;
    pauseEngine();
    overlays.add(OverlayIds.pause);
    refreshHud();
  }

  void resumeGame() {
    if (!isPaused) {
      return;
    }
    overlays.remove(OverlayIds.pause);
    phase.value = GamePhase.playing;
    resumeEngine();
    refreshHud();
  }

  void startLevel(LevelDefinition next) {
    endless = false;
    wave = 1;
    level = next;
    restart();
  }

  void restart() {
    commitPendingResult();
    overlays.remove(OverlayIds.pause);
    overlays.remove(OverlayIds.gameOver);
    overlays.remove(OverlayIds.victory);
    _clearEntities();
    lives = GameConfig.initialLives;
    invincibleTimer = 0;
    _spawnTimer = 0.35;
    _levelElapsed = 0;
    _bossBannerTimer = 0;
    _comboPulseTimer = 0;
    inBossFight = false;
    boss = null;
    continuedThisRun = false;
    _pendingResult = null;
    _resultCommitted = false;
    if (endless) {
      wave = 1;
      level = EndlessRules.levelForWave(1);
    }
    stats = GameSessionStats();
    lastResult = null;
    scoreManager.reset();
    powerUps.reset();
    weapons.reset();
    player.skin = currentSkin;
    player.position = Vector2(size.x / 2, playerY);
    player.targetX = player.position.x;
    _bindMissionPreview();
    phase.value = GamePhase.playing;
    _resumeRunAudio();
    if (paused) {
      resumeEngine();
    }
    refreshHud();
  }

  void endGame() {
    if (isGameOver || isVictory) {
      return;
    }
    phase.value = GamePhase.gameOver;
    pauseEngine();
    audio.stopMusic();
    audio.playGameOver();
    final result = SessionResult(
      score: scoreManager.score,
      coinsCollected: stats.coinsCollected,
      distanceMeters: stats.distanceMeters,
      survivalSeconds: stats.survivalSeconds,
      obstaclesDodged: stats.obstaclesDodged,
      shieldsUsed: stats.shieldsUsed,
    );
    lastResult = result;
    _pendingResult = result;
    lastMissionViews = missionPreview.preview(result);
    overlays.add(OverlayIds.gameOver);
    refreshHud();
  }

  void commitPendingResult() {
    if (_resultCommitted || _pendingResult == null) {
      return;
    }
    _resultCommitted = true;
    final result = SessionResult(
      score: scoreManager.score,
      coinsCollected: stats.coinsCollected,
      distanceMeters: stats.distanceMeters,
      survivalSeconds: stats.survivalSeconds,
      obstaclesDodged: stats.obstaclesDodged,
      shieldsUsed: stats.shieldsUsed,
    );
    lastResult = result;
    if (endless) {
      appController.applyEndlessResult(result, wave: wave);
    } else {
      appController.applySessionResult(result);
    }
  }

  bool continueRun() {
    if (!isGameOver || continuedThisRun) {
      return false;
    }
    if (!appController.spendCoins(continueCost)) {
      return false;
    }
    continuedThisRun = true;
    lastResult = null;
    lives = 1;
    invincibleTimer = GameConfig.continueInvincibility;
    _clearContinueHazards();
    overlays.remove(OverlayIds.gameOver);
    phase.value = GamePhase.playing;
    _resumeRunAudio();
    if (paused) {
      resumeEngine();
    }
    refreshHud();
    return true;
  }

  void _resumeRunAudio() {
    if (inBossFight) {
      audio.playBossMusic();
    } else {
      audio.startMusic();
    }
  }

  void refreshHud() {
    final featured = powerUps.featured;
    final best = endless
        ? math.max(appController.endlessBest, scoreManager.score)
        : math.max(appController.bestForLevel(level.index), scoreManager.score);
    hud.value = HudState(
      score: scoreManager.score,
      highScore: best,
      sessionCoins: stats.coinsCollected,
      lives: lives,
      activePowerUpLabel: featured?.shortLabel,
      powerUpRemaining: featured == null ? 0 : powerUps.remainingFor(featured),
      powerUpDuration: featured == null ? 1 : powerUps.durationStored(featured),
      combo: scoreManager.combo,
      difficultyLabel: difficulty.label,
      weapon: weapons.equipped,
      levelName: level.name,
      runProgress: inBossFight
          ? 1
          : (_levelElapsed / level.runSeconds).clamp(0.0, 1.0),
      inBossFight: inBossFight,
      bossHp: boss?.combat.hp ?? 0,
      bossMaxHp: level.bossMaxHp,
      endless: endless,
      wave: wave,
      bossBanner: _bossBannerTimer > 0 ? 'INCOMING: ${level.name}' : null,
      comboPulse: _comboPulseTimer > 0,
    );
  }

  @override
  void onRemove() {
    commitPendingResult();
    hud.dispose();
    phase.dispose();
    super.onRemove();
  }

  void _spawnRow() {
    final row = planner.planRow(
      obstacleTypeCount: difficulty.obstacleTypeCount,
      powerUpChance: difficulty.powerUpChance,
      coinChance: level.coinChance,
      gemChance: level.gemChance,
    );
    for (final spawn in row.obstacles) {
      world.add(ObstacleComponent(type: spawn.type, lane: spawn.lane));
    }
    for (final coin in row.coinSpawns) {
      world.add(
        CoinComponent(
          lane: coin.lane,
          yOffset: coin.yOffset,
          value: coin.value,
          isGem: coin.isGem,
        ),
      );
    }
    if (row.powerUpType != null && row.powerUpLane != null) {
      world.add(
        PowerUpComponent(lane: row.powerUpLane!, type: row.powerUpType!),
      );
    }
    if (row.weaponType != null && row.weaponLane != null) {
      world.add(
        WeaponPickupComponent(lane: row.weaponLane!, type: row.weaponType!),
      );
    }
  }

  void _clearEntities() {
    final toRemove = world.children.where((component) {
      return component is ObstacleComponent ||
          component is CoinComponent ||
          component is PowerUpComponent ||
          component is WeaponPickupComponent ||
          component is ProjectileComponent ||
          component is ProximityBlastEffect ||
          component is ParticleBurst ||
          component is FloatingText ||
          component is BossComponent ||
          component is BossBulletComponent;
    }).toList();
    for (final component in toRemove) {
      component.removeFromParent();
    }
  }

  void _clearContinueHazards() {
    final nearbyY = player.position.y;
    final toRemove = world.children.where((component) {
      if (component is BossBulletComponent) {
        return true;
      }
      if (component is ObstacleComponent) {
        return (component.position.y - nearbyY).abs() < 220;
      }
      return false;
    }).toList();
    for (final component in toRemove) {
      component.removeFromParent();
    }
  }

  void _startBoss() {
    if (inBossFight || boss != null) {
      return;
    }
    inBossFight = true;
    _bossBannerTimer = 1.5;
    audio.playBossMusic();
    boss = BossComponent(level: level);
    world.add(boss!);
  }

  void onBossDefeated(BossComponent defeated) {
    if (isVictory || isGameOver || defeated.combat.defeated == false) {
      return;
    }
    scoreManager.addBossDefeat(activeScoreMultiplier);
    stats.score = scoreManager.score;
    spawnBurst(defeated.position.clone(), NeonColors.gold);
    spawnBurst(defeated.position.clone() + Vector2(-24, 12), NeonColors.pink);
    spawnBurst(defeated.position.clone() + Vector2(24, 8), NeonColors.cyan);
    _spawnCoinShower(defeated.position.clone());
    stats.coinsCollected += level.coinReward;
    defeated.removeFromParent();
    boss = null;
    inBossFight = false;
    if (endless) {
      _advanceEndlessWave();
      return;
    }
    _winLevel();
  }

  void _advanceEndlessWave() {
    wave += 1;
    level = EndlessRules.levelForWave(wave);
    _levelElapsed = 0;
    _spawnTimer = 0.35;
    _bossBannerTimer = 0;
    audio.startMusic();
    refreshHud();
  }

  void _spawnCoinShower(Vector2 at) {
    for (var i = 0; i < 14; i++) {
      final offset = Vector2((i - 6.5) * 18, (i % 3) * 16.0);
      world.add(
        CoinComponent(
          start: at + offset,
          drift: Vector2((i - 6.5) * 16, 90 + i * 10),
          value: i == 0 ? GameConfig.gemCoinValue : 1,
          isGem: i == 0,
        ),
      );
    }
  }

  void _winLevel() {
    if (isVictory || isGameOver) {
      return;
    }
    phase.value = GamePhase.victory;
    pauseEngine();
    audio.stopMusic();
    audio.playMission();
    final result = SessionResult(
      score: scoreManager.score,
      coinsCollected: stats.coinsCollected,
      distanceMeters: stats.distanceMeters,
      survivalSeconds: stats.survivalSeconds,
      obstaclesDodged: stats.obstaclesDodged,
      shieldsUsed: stats.shieldsUsed,
    );
    lastResult = result;
    _pendingResult = result;
    lastMissionViews = missionPreview.preview(result);
    appController.completeLevel(levelIndex: level.index, result: result);
    _resultCommitted = true;
    overlays.add(OverlayIds.victory);
    refreshHud();
  }

  void _bindMissionPreview() {
    missionPreview = SessionMissionManager(
      startingProgress: appController.profile.missionProgress,
      completedIds: {...appController.profile.completedMissionIds},
      claimedIds: {...appController.profile.claimedMissionIds},
    );
  }

  void _updateShake(double dt) {
    if (_shakeTime <= 0) {
      camera.viewfinder.position = Vector2.zero();
      return;
    }
    _shakeTime -= dt;
    camera.viewfinder.position = Vector2(
      (_random.nextDouble() - 0.5) * 2 * _shakePower,
      (_random.nextDouble() - 0.5) * 2 * _shakePower,
    );
  }
}
