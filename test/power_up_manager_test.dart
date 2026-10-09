import 'package:flutter_test/flutter_test.dart';
import 'package:the_escape_game/game/managers/power_up_manager.dart';
import 'package:the_escape_game/models/power_up_type.dart';
import 'package:the_escape_game/utils/game_config.dart';

void main() {
  test('rapid fire and overcharge buff shots', () {
    final powerUps = PowerUpManager();
    expect(powerUps.bonusDamage, 0);
    expect(powerUps.fireIntervalScale, 1);
    powerUps.activate(PowerUpType.rapidFire);
    powerUps.activate(PowerUpType.overcharge);
    expect(powerUps.hasRapidFire, isTrue);
    expect(powerUps.hasOvercharge, isTrue);
    expect(powerUps.bonusDamage, 1);
    expect(powerUps.fireIntervalScale, GameConfig.rapidFireFactor);
  });

  test('repair is instant and is not stored as a timed buff', () {
    final powerUps = PowerUpManager()..activate(PowerUpType.repair);
    expect(powerUps.remaining.containsKey(PowerUpType.repair), isFalse);
  });
}
