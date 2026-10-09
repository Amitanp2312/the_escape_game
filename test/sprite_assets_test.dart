import 'package:flutter_test/flutter_test.dart';
import 'package:the_escape_game/utils/constants.dart';
import 'package:the_escape_game/utils/sprite_assets.dart';

void main() {
  test('every animated sprite has a 4-frame sheet', () {
    expect(SpriteAssets.sheets.length, 13);
    for (final entry in SpriteAssets.sheets.entries) {
      expect(entry.value.frames, 4);
      expect(entry.value.stepTime, greaterThan(0));
      expect(entry.value.file, endsWith('_sheet.png'));
      expect(SpriteAssets.stills, contains(entry.key));
    }
  });

  test('run and boss music are separate tracks', () {
    expect(AudioAssets.bossMusic, isNot(AudioAssets.backgroundMusic));
    expect(AudioAssets.allEffects, isNot(contains(AudioAssets.bossMusic)));
    expect(
      AudioAssets.allEffects,
      isNot(contains(AudioAssets.backgroundMusic)),
    );
  });
}
