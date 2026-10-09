import 'package:flutter/material.dart';

import '../utils/constants.dart';

class PlayerSkin {
  const PlayerSkin({
    required this.id,
    required this.name,
    required this.price,
    required this.primary,
    required this.secondary,
    required this.glow,
  });

  final String id;
  final String name;
  final int price;
  final Color primary;
  final Color secondary;
  final Color glow;

  bool get isFree => price <= 0;
}

class PlayerSkinCatalog {
  static const String defaultSkinId = 'neon_blue';

  static const List<PlayerSkin> all = [
    PlayerSkin(
      id: defaultSkinId,
      name: 'Neon Blue',
      price: 0,
      primary: NeonColors.cyan,
      secondary: Color(0xFF0077FF),
      glow: NeonColors.cyan,
    ),
    PlayerSkin(
      id: 'cyber_red',
      name: 'Cyber Red',
      price: 500,
      primary: NeonColors.red,
      secondary: Color(0xFFFF7A18),
      glow: NeonColors.pink,
    ),
    PlayerSkin(
      id: 'plasma_green',
      name: 'Plasma Green',
      price: 1000,
      primary: NeonColors.green,
      secondary: Color(0xFF00C2A8),
      glow: NeonColors.green,
    ),
    PlayerSkin(
      id: 'shadow_purple',
      name: 'Shadow Purple',
      price: 2000,
      primary: NeonColors.purple,
      secondary: NeonColors.magenta,
      glow: NeonColors.purple,
    ),
    PlayerSkin(
      id: 'golden_racer',
      name: 'Golden Racer',
      price: 5000,
      primary: NeonColors.gold,
      secondary: Color(0xFFFFF1A8),
      glow: NeonColors.gold,
    ),
  ];

  static PlayerSkin byId(String id) {
    return all.firstWhere((skin) => skin.id == id, orElse: () => all.first);
  }
}
