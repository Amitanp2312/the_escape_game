import 'package:flutter_test/flutter_test.dart';
import 'package:the_escape_game/models/level_definition.dart';

void main() {
  test('catalog has five increasing levels each with a boss', () {
    expect(LevelCatalog.levels, hasLength(5));
    expect(LevelCatalog.count, 5);
    for (var i = 0; i < LevelCatalog.levels.length; i++) {
      final level = LevelCatalog.levels[i];
      expect(level.index, i + 1);
      expect(level.bossMaxHp, greaterThan(0));
      expect(level.coinReward, greaterThan(0));
      expect(level.runSeconds, greaterThan(0));
      expect(level.maxSpeed, greaterThan(level.minSpeed));
      expect(level.minSpawnInterval, lessThan(level.maxSpawnInterval));
      if (i > 0) {
        expect(
          level.minSpeed,
          greaterThan(LevelCatalog.levels[i - 1].minSpeed),
        );
        expect(
          level.bossMaxHp,
          greaterThan(LevelCatalog.levels[i - 1].bossMaxHp),
        );
      }
    }
    expect(
      LevelCatalog.levels.map((level) => level.name).toSet(),
      hasLength(5),
    );
    expect(LevelCatalog.nextAfter(LevelCatalog.byIndex(5)), isNull);
    expect(LevelCatalog.nextAfter(LevelCatalog.byIndex(1))?.index, 2);
  });

  test('endless wave 6 uses level 1 again, faster, with more boss HP', () {
    final wave1 = EndlessRules.levelForWave(1);
    final wave6 = EndlessRules.levelForWave(6);
    expect(wave1.index, 1);
    expect(wave6.index, 1);
    expect(wave6.name, wave1.name);
    expect(wave6.minSpeed, greaterThan(wave1.minSpeed));
    expect(wave6.maxSpeed, greaterThan(wave1.maxSpeed));
    expect(wave6.bossMaxHp, greaterThan(wave1.bossMaxHp));
    expect(wave6.minSpawnInterval, lessThan(wave1.minSpawnInterval));
    expect(
      wave6.bossMaxHp,
      (wave1.bossMaxHp * (1 + EndlessRules.scalePerLoop)).round(),
    );
  });

  test('beating a level unlocks the next and caps at five', () {
    expect(LevelProgress.afterWin(unlockedLevel: 1, beatenIndex: 1), 2);
    expect(LevelProgress.afterWin(unlockedLevel: 3, beatenIndex: 1), 3);
    expect(LevelProgress.afterWin(unlockedLevel: 4, beatenIndex: 5), 5);
  });
}
