import 'package:flutter_test/flutter_test.dart';
import 'package:the_escape_game/game/managers/boss_combat.dart';

void main() {
  test('boss HP drops and is defeated exactly once', () {
    final combat = BossCombat(maxHp: 5);
    expect(combat.applyDamage(2), isFalse);
    expect(combat.hp, 3);
    expect(combat.defeated, isFalse);
    expect(combat.applyDamage(3), isTrue);
    expect(combat.hp, 0);
    expect(combat.defeated, isTrue);
    expect(combat.applyDamage(1), isFalse);
    expect(combat.hp, 0);
  });

  test('shots do no damage while the shield is up', () {
    final combat = BossCombat(maxHp: 10)..invulnerable = true;
    expect(combat.applyDamage(4), isFalse);
    expect(combat.hp, 10);
    combat.invulnerable = false;
    expect(combat.applyDamage(4), isFalse);
    expect(combat.hp, 6);
  });

  test('phase 2 starts below 50% HP', () {
    final combat = BossCombat(maxHp: 10);
    expect(combat.phase, 1);
    combat.applyDamage(4);
    expect(combat.phase, 1);
    combat.applyDamage(1);
    expect(combat.hp, 5);
    expect(combat.phase, 2);
  });
}
