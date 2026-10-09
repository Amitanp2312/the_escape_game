import 'package:flutter_test/flutter_test.dart';
import 'package:the_escape_game/game/managers/score_manager.dart';
import 'package:the_escape_game/models/weapon_type.dart';
import 'package:the_escape_game/utils/game_config.dart';

void main() {
  test('awards survival, coin, near-miss, and combo points', () {
    final manager = ScoreManager();
    manager.addSurvival(1, 1);
    expect(manager.score, GameConfig.survivalPointsPerSecond.round());
    manager.addCoin(1);
    expect(
      manager.score,
      GameConfig.survivalPointsPerSecond.round() + GameConfig.coinScoreValue,
    );
    manager.addNearMiss(1);
    expect(
      manager.score,
      GameConfig.survivalPointsPerSecond.round() +
          GameConfig.coinScoreValue +
          GameConfig.nearMissScoreValue,
    );
    for (var i = 0; i < GameConfig.comboDodgeCount; i++) {
      manager.registerDodge(multiplier: 1);
    }
    expect(manager.combo, GameConfig.comboDodgeCount);
    expect(manager.score, greaterThan(GameConfig.comboBonusScore));
  });

  test('double score multiplies pickups', () {
    final manager = ScoreManager();
    manager.addCoin(2);
    expect(manager.score, GameConfig.coinScoreValue * 2);
  });

  test('gem coins multiply the coin value', () {
    final manager = ScoreManager();
    manager.addCoin(1, value: 5);
    expect(manager.score, GameConfig.coinScoreValue * 5);
  });

  test('weapon kills use mode scores and the active multiplier', () {
    final manager = ScoreManager();
    manager.addObstacleDestroyed(1, weapon: WeaponType.laser);
    manager.addObstacleDestroyed(2, weapon: WeaponType.spread);
    manager.addObstacleDestroyed(1, weapon: WeaponType.proximityBlast);
    expect(
      manager.score,
      GameConfig.obstacleDestroyScoreLaser +
          GameConfig.obstacleDestroyScoreSpread * 2 +
          GameConfig.obstacleDestroyScoreProximity,
    );
  });
}
