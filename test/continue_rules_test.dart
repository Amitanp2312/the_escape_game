import 'package:flutter_test/flutter_test.dart';
import 'package:the_escape_game/game/managers/continue_rules.dart';
import 'package:the_escape_game/utils/game_config.dart';

void main() {
  test('continue cost scales with level index', () {
    expect(ContinueRules.costFor(levelIndex: 1), GameConfig.continueCost);
    expect(ContinueRules.costFor(levelIndex: 3), GameConfig.continueCost * 3);
  });

  test('second continue is blocked', () {
    expect(
      ContinueRules.allowed(alreadyUsed: true, coins: 999, cost: 30),
      isFalse,
    );
  });

  test('continue is refused when coins are too low', () {
    expect(
      ContinueRules.allowed(alreadyUsed: false, coins: 29, cost: 30),
      isFalse,
    );
    expect(
      ContinueRules.allowed(alreadyUsed: false, coins: 30, cost: 30),
      isTrue,
    );
  });
}
