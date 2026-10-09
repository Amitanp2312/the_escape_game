import '../models/game_state.dart';
import '../models/mission.dart';

class MissionTracker {
  MissionTracker(this._progress, this._completedIds);

  final Map<String, int> _progress;
  final Set<String> _completedIds;

  int progressFor(MissionId id) => _progress[id.name] ?? 0;

  bool isComplete(MissionId id) => _completedIds.contains(id.name);

  void applySession(SessionResult result) {
    _setBest(MissionId.survive30, result.survivalSeconds.floor());
    _add(MissionId.collect20Coins, result.coinsCollected);
    _setBest(MissionId.score1000, result.score);
    _add(MissionId.useShield3, result.shieldsUsed);
    _add(MissionId.dodge100, result.obstaclesDodged);
    _markCompleted();
  }

  Map<String, int> snapshotProgress() => Map<String, int>.from(_progress);

  List<String> snapshotCompleted() => _completedIds.toList();

  List<MissionProgressView> views({required Set<String> claimedIds}) {
    return MissionCatalog.all.map((definition) {
      final progress = progressFor(definition.id);
      return MissionProgressView(
        definition: definition,
        progress: progress.clamp(0, definition.target),
        completed: isComplete(definition.id) || progress >= definition.target,
        claimed: claimedIds.contains(definition.id.name),
      );
    }).toList();
  }

  void _add(MissionId id, int amount) {
    if (amount <= 0 || isComplete(id)) {
      return;
    }
    final target = MissionCatalog.byId(id).target;
    final next = (progressFor(id) + amount).clamp(0, target);
    _progress[id.name] = next;
  }

  void _setBest(MissionId id, int value) {
    if (isComplete(id)) {
      return;
    }
    final target = MissionCatalog.byId(id).target;
    final next = value.clamp(0, target);
    if (next > progressFor(id)) {
      _progress[id.name] = next;
    }
  }

  void _markCompleted() {
    for (final mission in MissionCatalog.all) {
      if (progressFor(mission.id) >= mission.target) {
        _completedIds.add(mission.id.name);
        _progress[mission.id.name] = mission.target;
      }
    }
  }
}
