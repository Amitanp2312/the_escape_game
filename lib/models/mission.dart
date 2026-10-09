import '../utils/game_config.dart';

enum MissionId { survive30, collect20Coins, score1000, useShield3, dodge100 }

class MissionDefinition {
  const MissionDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    required this.coinReward,
  });

  final MissionId id;
  final String title;
  final String description;
  final int target;
  final int coinReward;
}

class MissionCatalog {
  static const List<MissionDefinition> all = [
    MissionDefinition(
      id: MissionId.survive30,
      title: 'First Surge',
      description: 'Survive for 30 seconds in a single run.',
      target: GameConfig.surviveMissionSeconds,
      coinReward: MissionRewards.survive30,
    ),
    MissionDefinition(
      id: MissionId.collect20Coins,
      title: 'Neon Collector',
      description: 'Collect 20 coins across your runs.',
      target: GameConfig.coinMissionTarget,
      coinReward: MissionRewards.collect20Coins,
    ),
    MissionDefinition(
      id: MissionId.score1000,
      title: 'Four Digit Club',
      description: 'Score 1,000 points in a single run.',
      target: GameConfig.scoreMissionTarget,
      coinReward: MissionRewards.score1000,
    ),
    MissionDefinition(
      id: MissionId.useShield3,
      title: 'Barrier Specialist',
      description: 'Use a shield 3 times.',
      target: GameConfig.shieldMissionTarget,
      coinReward: MissionRewards.useShield3,
    ),
    MissionDefinition(
      id: MissionId.dodge100,
      title: 'Ghost in the Grid',
      description: 'Dodge 100 obstacles.',
      target: GameConfig.dodgeMissionTarget,
      coinReward: MissionRewards.dodge100,
    ),
  ];

  static MissionDefinition byId(MissionId id) {
    return all.firstWhere((mission) => mission.id == id);
  }
}

class MissionProgressView {
  const MissionProgressView({
    required this.definition,
    required this.progress,
    required this.completed,
    required this.claimed,
  });

  final MissionDefinition definition;
  final int progress;
  final bool completed;
  final bool claimed;

  int get target => definition.target;
  bool get canClaim => completed && !claimed;
  double get fraction =>
      target == 0 ? 1 : (progress / target).clamp(0, 1).toDouble();
}
