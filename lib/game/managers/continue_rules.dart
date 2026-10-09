import '../../utils/game_config.dart';

class ContinueRules {
  static int costFor({required int levelIndex}) {
    return GameConfig.continueCost * levelIndex.clamp(1, 99);
  }

  static bool allowed({
    required bool alreadyUsed,
    required int coins,
    required int cost,
  }) {
    return !alreadyUsed && coins >= cost;
  }
}
