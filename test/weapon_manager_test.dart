import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_escape_game/game/managers/weapon_manager.dart';
import 'package:the_escape_game/models/weapon_type.dart';
import 'package:the_escape_game/utils/game_config.dart';

void main() {
  test('laser is the default loadout and reset restores it', () {
    final loadout = WeaponLoadout()..equip(WeaponType.spread);
    expect(loadout.equipped, WeaponType.spread);
    loadout.reset();
    expect(loadout.equipped, WeaponType.laser);
    expect(loadout.cooldown, 0);
  });

  test('cooldown blocks fire until the weapon interval elapses', () {
    final loadout = WeaponLoadout();
    expect(loadout.readyToFire(0), isTrue);
    expect(loadout.cooldown, GameConfig.laserFireInterval);
    expect(loadout.readyToFire(GameConfig.laserFireInterval / 2), isFalse);
    expect(loadout.readyToFire(GameConfig.laserFireInterval), isTrue);
  });

  test('rapid fire shortens the shot interval', () {
    final loadout = WeaponLoadout();
    expect(
      loadout.readyToFire(0, intervalScale: GameConfig.rapidFireFactor),
      isTrue,
    );
    expect(
      loadout.cooldown,
      closeTo(
        GameConfig.laserFireInterval * GameConfig.rapidFireFactor,
        0.0001,
      ),
    );
  });

  test('spread fires three angled shots and laser fires one', () {
    final laser = WeaponRules.shotVelocities(WeaponType.laser);
    expect(laser, hasLength(1));
    expect(laser.first.x, 0);
    expect(laser.first.y, -GameConfig.projectileSpeed);

    final spread = WeaponRules.shotVelocities(WeaponType.spread);
    expect(spread, hasLength(GameConfig.spreadPelletCount));
    expect(spread[1].x, closeTo(0, 0.001));
    expect(spread.first.x, lessThan(0));
    expect(spread.last.x, greaterThan(0));
    expect(WeaponRules.shotVelocities(WeaponType.proximityBlast), isEmpty);
  });

  test('blast radius includes nearby obstacles and ignores far ones', () {
    final center = Vector2(100, 400);
    expect(
      WeaponRules.isInBlastRadius(
        center: center,
        target: Vector2(100, 400 + GameConfig.proximityBlastRadius),
        radius: GameConfig.proximityBlastRadius,
      ),
      isTrue,
    );
    expect(
      WeaponRules.isInBlastRadius(
        center: center,
        target: Vector2(100, 400 + GameConfig.proximityBlastRadius + 1),
        radius: GameConfig.proximityBlastRadius,
      ),
      isFalse,
    );
  });
}
