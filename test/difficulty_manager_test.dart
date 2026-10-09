import 'package:flutter_test/flutter_test.dart';
import 'package:the_escape_game/game/managers/difficulty_manager.dart';
import 'package:the_escape_game/models/level_definition.dart';

void main() {
  final manager = DifficultyManager();

  test('ramps a level from its min speed to its max speed', () {
    final level = LevelCatalog.byIndex(1);
    final start = manager.evaluate(level: level, progress: 0);
    final end = manager.evaluate(level: level, progress: 1);
    expect(start.obstacleSpeed, closeTo(level.minSpeed, 0.01));
    expect(end.obstacleSpeed, closeTo(level.maxSpeed, 0.01));
    expect(start.spawnInterval, closeTo(level.maxSpawnInterval, 0.01));
    expect(end.spawnInterval, closeTo(level.minSpawnInterval, 0.01));
    expect(start.obstacleTypeCount, 2);
  });

  test('later levels are harder than earlier ones', () {
    final easy = manager.evaluate(level: LevelCatalog.byIndex(1), progress: 1);
    final mid = manager.evaluate(level: LevelCatalog.byIndex(3), progress: 1);
    final last = manager.evaluate(level: LevelCatalog.byIndex(5), progress: 1);
    expect(mid.obstacleSpeed, greaterThan(easy.obstacleSpeed));
    expect(last.obstacleSpeed, greaterThan(mid.obstacleSpeed));
    expect(last.obstacleTypeCount, 5);
    expect(last.spawnInterval, lessThan(easy.spawnInterval));
    expect(last.scoreMultiplier, greaterThan(1));
  });
}
