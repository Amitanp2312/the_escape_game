import '../../models/weapon_type.dart';
import '../../utils/game_config.dart';
import 'weapon_manager.dart';

class ScoreManager {
  int score = 0;
  int combo = 0;
  double _survivalRemainder = 0;

  void reset() {
    score = 0;
    combo = 0;
    _survivalRemainder = 0;
  }

  void addSurvival(double dt, double multiplier) {
    _survivalRemainder += GameConfig.survivalPointsPerSecond * dt * multiplier;
    final gained = _survivalRemainder.floor();
    if (gained > 0) {
      score += gained;
      _survivalRemainder -= gained;
    }
  }

  void addCoin(double multiplier, {int value = 1}) {
    score += (GameConfig.coinScoreValue * value * multiplier).round();
  }

  void addBossHit(double multiplier) {
    score += (GameConfig.bossHitScore * multiplier).round();
  }

  void addBossDefeat(double multiplier) {
    score += (GameConfig.bossDefeatScore * multiplier).round();
  }

  void addNearMiss(double multiplier) {
    score += (GameConfig.nearMissScoreValue * multiplier).round();
  }

  void addObstacleDestroyed(double multiplier, {required WeaponType weapon}) {
    score += (WeaponRules.destroyScore(weapon) * multiplier).round();
  }

  int registerDodge({required double multiplier}) {
    combo += 1;
    var bonus = 0;
    if (combo > 0 && combo % GameConfig.comboDodgeCount == 0) {
      bonus = (GameConfig.comboBonusScore * multiplier).round();
      score += bonus;
    }
    return bonus;
  }

  void resetCombo() {
    combo = 0;
  }
}
