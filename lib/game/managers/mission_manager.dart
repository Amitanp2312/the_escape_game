import '../../models/game_state.dart';
import '../../models/mission.dart';
import '../../app/mission_tracker.dart';

class SessionMissionManager {
  SessionMissionManager({
    required Map<String, int> startingProgress,
    required Set<String> completedIds,
    required this._claimedIds,
  }) : _tracker = MissionTracker(Map<String, int>.from(startingProgress), {
         ...completedIds,
       });

  final MissionTracker _tracker;
  final Set<String> _claimedIds;

  List<MissionProgressView> preview(SessionResult result) {
    final preview = MissionTracker(_tracker.snapshotProgress(), {
      ..._tracker.snapshotCompleted(),
    });
    preview.applySession(result);
    return preview.views(claimedIds: _claimedIds);
  }
}
