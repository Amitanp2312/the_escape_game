import 'dart:math' as math;

import '../../models/power_up_type.dart';
import '../../models/weapon_type.dart';
import '../../utils/game_config.dart';
import '../../utils/sprite_assets.dart';

enum ObstacleType {
  neonBarrier,
  energyCube,
  laserBlock,
  cyberDrone,
  movingBarrier,
}

class ObstacleRules {
  static int hp(ObstacleType type) {
    return switch (type) {
      ObstacleType.neonBarrier => 1,
      ObstacleType.energyCube => 2,
      ObstacleType.laserBlock => 2,
      ObstacleType.cyberDrone => 3,
      ObstacleType.movingBarrier => 3,
    };
  }

  static int contactDamage(ObstacleType type) {
    return switch (type) {
      ObstacleType.neonBarrier => 1,
      ObstacleType.energyCube => 1,
      ObstacleType.laserBlock => 2,
      ObstacleType.cyberDrone => 1,
      ObstacleType.movingBarrier => 2,
    };
  }

  static double speedFactor(ObstacleType type) {
    return switch (type) {
      ObstacleType.neonBarrier => 1,
      ObstacleType.energyCube => 1.08,
      ObstacleType.laserBlock => 1.28,
      ObstacleType.cyberDrone => 1.16,
      ObstacleType.movingBarrier => 1.12,
    };
  }

  static int weaponDamage(WeaponType weapon) {
    return switch (weapon) {
      WeaponType.laser => 1,
      WeaponType.spread => 1,
      WeaponType.proximityBlast => 2,
    };
  }
}

String spriteForObstacle(ObstacleType type) {
  return switch (type) {
    ObstacleType.neonBarrier => SpriteAssets.barrier,
    ObstacleType.energyCube => SpriteAssets.meteor,
    ObstacleType.laserBlock => SpriteAssets.missile,
    ObstacleType.cyberDrone => SpriteAssets.drone,
    ObstacleType.movingBarrier => SpriteAssets.mine,
  };
}

class ObstacleSpawn {
  const ObstacleSpawn({required this.lane, required this.type});

  final int lane;
  final ObstacleType type;
}

class CoinSpawn {
  const CoinSpawn({
    required this.lane,
    this.yOffset = 0,
    this.value = 1,
    this.isGem = false,
  });

  final int lane;
  final double yOffset;
  final int value;
  final bool isGem;
}

class SpawnRow {
  const SpawnRow({
    required this.obstacles,
    required this.coinSpawns,
    this.powerUpType,
    this.powerUpLane,
    this.weaponType,
    this.weaponLane,
  });

  final List<ObstacleSpawn> obstacles;
  final List<CoinSpawn> coinSpawns;
  final PowerUpType? powerUpType;
  final int? powerUpLane;
  final WeaponType? weaponType;
  final int? weaponLane;

  List<int> get coinLanes =>
      coinSpawns.map((coin) => coin.lane).toSet().toList();

  Set<int> get occupiedLanes =>
      obstacles.map((obstacle) => obstacle.lane).toSet();

  Set<int> get safeLanes {
    return {for (var lane = 0; lane < GameConfig.laneCount; lane++) lane}
        .difference(occupiedLanes);
  }
}

class SpawnPlanner {
  SpawnPlanner({math.Random? random}) : _random = random ?? math.Random();

  final math.Random _random;

  static const List<ObstacleType> _typesInUnlockOrder = [
    ObstacleType.neonBarrier,
    ObstacleType.energyCube,
    ObstacleType.laserBlock,
    ObstacleType.cyberDrone,
    ObstacleType.movingBarrier,
  ];

  SpawnRow planRow({
    required int obstacleTypeCount,
    required double powerUpChance,
    double coinChance = GameConfig.coinChance,
    double gemChance = 0.1,
  }) {
    final availableTypes = _typesInUnlockOrder
        .take(obstacleTypeCount.clamp(1, _typesInUnlockOrder.length))
        .toList();
    final maxObstacles = GameConfig.maxObstaclesPerRow.clamp(
      1,
      GameConfig.laneCount - 1,
    );
    final obstacleCount = _random.nextDouble() < 0.38 ? 1 : maxObstacles;
    final lanes = List<int>.generate(GameConfig.laneCount, (index) => index)
      ..shuffle(_random);
    final occupied = lanes.take(obstacleCount).toList();
    final obstacles = occupied
        .map(
          (lane) => ObstacleSpawn(
            lane: lane,
            type: availableTypes[_random.nextInt(availableTypes.length)],
          ),
        )
        .toList();

    final used = occupied.toSet();
    final safe = [
      for (var lane = 0; lane < GameConfig.laneCount; lane++)
        if (!used.contains(lane)) lane,
    ]..shuffle(_random);

    final coinSpawns = _planCoins(List.of(safe), coinChance, gemChance);

    PowerUpType? powerUpType;
    int? powerUpLane;
    if (safe.isNotEmpty && _random.nextDouble() < powerUpChance) {
      powerUpLane = safe.removeAt(0);
      powerUpType = _rollPowerUp();
    }

    WeaponType? weaponType;
    int? weaponLane;
    if (safe.isNotEmpty &&
        _random.nextDouble() < GameConfig.weaponPickupChance) {
      weaponLane = safe.removeAt(0);
      weaponType = WeaponType.values[_random.nextInt(WeaponType.values.length)];
    }

    return SpawnRow(
      obstacles: obstacles,
      coinSpawns: coinSpawns,
      powerUpType: powerUpType,
      powerUpLane: powerUpLane,
      weaponType: weaponType,
      weaponLane: weaponLane,
    );
  }

  PowerUpType _rollPowerUp() {
    final roll = _random.nextDouble();
    if (roll < 0.1) {
      return PowerUpType.repair;
    }
    if (roll < 0.32) {
      return PowerUpType.rapidFire;
    }
    if (roll < 0.54) {
      return PowerUpType.overcharge;
    }
    const rest = [
      PowerUpType.shield,
      PowerUpType.magnet,
      PowerUpType.slowMotion,
      PowerUpType.doubleScore,
    ];
    return rest[_random.nextInt(rest.length)];
  }

  List<CoinSpawn> _planCoins(
    List<int> safe,
    double coinChance,
    double gemChance,
  ) {
    if (safe.isEmpty || _random.nextDouble() > math.max(0.92, coinChance)) {
      return const [];
    }
    final roll = _random.nextDouble();
    if (roll < 0.46) {
      return _line(safe.first, gemChance);
    }
    if (roll < 0.78) {
      return _zigzag(safe, gemChance);
    }
    if (roll < 0.94) {
      return _arc(safe, gemChance);
    }
    return [
      for (final lane in safe)
        for (var i = 0; i < 2; i++)
          if (_random.nextDouble() < math.max(0.75, coinChance))
            _coin(lane, -i * 36.0, gemChance),
    ];
  }

  List<CoinSpawn> _line(int lane, double gemChance) {
    return [
      for (var i = 0; i < 6; i++)
        _coin(lane, -i * 32.0, i == 2 || i == 5 ? gemChance : gemChance * 0.35),
    ];
  }

  List<CoinSpawn> _zigzag(List<int> safe, double gemChance) {
    if (safe.length < 2) {
      return _line(safe.first, gemChance);
    }
    return [
      for (var i = 0; i < 7; i++)
        _coin(safe[i % 2], -i * 30.0, i == 0 || i == 3 ? gemChance : 0),
    ];
  }

  List<CoinSpawn> _arc(List<int> safe, double gemChance) {
    return [
      for (var i = 0; i < safe.length; i++)
        _coin(
          safe[i],
          -((i - (safe.length - 1) / 2).abs() * 28),
          i == 0 ? gemChance : 0,
        ),
    ];
  }

  CoinSpawn _coin(int lane, double yOffset, double gemChance) {
    final gem = gemChance > 0 && _random.nextDouble() < gemChance;
    return CoinSpawn(
      lane: lane,
      yOffset: yOffset,
      isGem: gem,
      value: gem ? GameConfig.gemCoinValue : 1,
    );
  }
}
