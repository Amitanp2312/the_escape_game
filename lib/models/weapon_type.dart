enum WeaponType { laser, spread, proximityBlast }

extension WeaponTypeInfo on WeaponType {
  String get displayName {
    return switch (this) {
      WeaponType.laser => 'Laser',
      WeaponType.spread => 'Spread Fire',
      WeaponType.proximityBlast => 'Proximity Blast',
    };
  }

  String get shortLabel {
    return switch (this) {
      WeaponType.laser => 'LASER',
      WeaponType.spread => 'SPREAD',
      WeaponType.proximityBlast => 'BLAST',
    };
  }
}
