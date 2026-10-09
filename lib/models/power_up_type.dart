enum PowerUpType {
  shield,
  magnet,
  slowMotion,
  doubleScore,
  rapidFire,
  overcharge,
  repair,
}

extension PowerUpTypeInfo on PowerUpType {
  String get displayName {
    return switch (this) {
      PowerUpType.shield => 'Shield',
      PowerUpType.magnet => 'Coin Magnet',
      PowerUpType.slowMotion => 'Slow Motion',
      PowerUpType.doubleScore => 'Double Score',
      PowerUpType.rapidFire => 'Rapid Fire',
      PowerUpType.overcharge => 'Overcharge',
      PowerUpType.repair => 'Repair',
    };
  }

  String get shortLabel {
    return switch (this) {
      PowerUpType.shield => 'SHIELD',
      PowerUpType.magnet => 'MAGNET',
      PowerUpType.slowMotion => 'SLOW',
      PowerUpType.doubleScore => '2X',
      PowerUpType.rapidFire => 'FIRE',
      PowerUpType.overcharge => 'DMG',
      PowerUpType.repair => 'HP',
    };
  }
}
