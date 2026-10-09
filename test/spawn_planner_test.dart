import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:the_escape_game/game/managers/spawn_manager.dart';
import 'package:the_escape_game/models/weapon_type.dart';
import 'package:the_escape_game/utils/game_config.dart';

void main() {
  test('spawn rows always leave a safe lane and never fill the road', () {
    final planner = SpawnPlanner(random: Random(42));
    for (var i = 0; i < 200; i++) {
      final row = planner.planRow(obstacleTypeCount: 5, powerUpChance: 0.5);
      expect(
        row.obstacles.length,
        inInclusiveRange(1, GameConfig.laneCount - 1),
      );
      expect(row.occupiedLanes.length, row.obstacles.length);
      expect(row.safeLanes, isNotEmpty);
      if (row.powerUpLane != null) {
        expect(row.safeLanes.contains(row.powerUpLane), isTrue);
      }
      if (row.weaponLane != null) {
        expect(row.safeLanes.contains(row.weaponLane), isTrue);
        expect(row.occupiedLanes.contains(row.weaponLane), isFalse);
        expect(row.weaponLane, isNot(row.powerUpLane));
      }
      for (final lane in row.coinLanes) {
        expect(row.occupiedLanes.contains(lane), isFalse);
      }
      for (final coin in row.coinSpawns) {
        expect(row.occupiedLanes.contains(coin.lane), isFalse);
        expect(row.safeLanes.contains(coin.lane), isTrue);
      }
    }
  });

  test('tougher obstacles take more hits and deal more contact damage', () {
    expect(ObstacleRules.hp(ObstacleType.neonBarrier), 1);
    expect(ObstacleRules.hp(ObstacleType.cyberDrone), 3);
    expect(ObstacleRules.contactDamage(ObstacleType.laserBlock), 2);
    expect(ObstacleRules.speedFactor(ObstacleType.laserBlock), greaterThan(1));
    expect(ObstacleRules.weaponDamage(WeaponType.laser), 1);
    expect(ObstacleRules.weaponDamage(WeaponType.proximityBlast), 2);
  });
}
