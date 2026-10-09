import 'package:flutter_test/flutter_test.dart';
import 'package:the_escape_game/app/mission_tracker.dart';
import 'package:the_escape_game/models/game_state.dart';
import 'package:the_escape_game/models/mission.dart';

void main() {
  test('completes single-run and cumulative missions', () {
    final tracker = MissionTracker({}, {});
    tracker.applySession(
      const SessionResult(
        score: 1200,
        coinsCollected: 8,
        distanceMeters: 400,
        survivalSeconds: 32,
        obstaclesDodged: 40,
        shieldsUsed: 1,
      ),
    );
    expect(tracker.isComplete(MissionId.survive30), isTrue);
    expect(tracker.isComplete(MissionId.score1000), isTrue);
    expect(tracker.progressFor(MissionId.collect20Coins), 8);
    expect(tracker.isComplete(MissionId.collect20Coins), isFalse);

    tracker.applySession(
      const SessionResult(
        score: 200,
        coinsCollected: 12,
        distanceMeters: 100,
        survivalSeconds: 10,
        obstaclesDodged: 60,
        shieldsUsed: 2,
      ),
    );
    expect(tracker.isComplete(MissionId.collect20Coins), isTrue);
    expect(tracker.isComplete(MissionId.useShield3), isTrue);
    expect(tracker.isComplete(MissionId.dodge100), isTrue);
  });
}
