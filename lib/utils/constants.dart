import 'package:flutter/material.dart';

import '../models/power_up_type.dart';
import '../models/weapon_type.dart';

/// Configurable internship metadata. Change these values in one place.
class AppInfo {
  static const String gameTitle = 'Stormline: Sky Rush';
  static const String shortTitle = 'STORMLINE';
  static const String subtitle = 'Sky Rush';
  static const String developerName = 'Internship Student';
  static const String projectType =
      'Mobile Game Development Internship Project';
  static const String technology = 'Flutter & Dart';
  static const String description =
      'Stormline: Sky Rush is a fast-paced endless sky runner where players '
      'fly a neon jet, auto-fire weapons, dodge futuristic obstacles, collect '
      'coins and power-ups, complete missions, unlock new vehicles, and '
      'compete against their personal high score.';
}

class OverlayIds {
  static const String pause = 'pause';
  static const String gameOver = 'gameOver';
  static const String victory = 'victory';
}

class StorageKeys {
  static const String profile = 'neon_escape_profile_v1';
}

class NeonColors {
  static const Color background = Color(0xFF050510);
  static const Color surface = Color(0xFF12122A);
  static const Color surfaceAlt = Color(0xFF1B1B36);
  static const Color cyan = Color(0xFF00F5FF);
  static const Color magenta = Color(0xFFFF2BD6);
  static const Color purple = Color(0xFFB14CFF);
  static const Color green = Color(0xFF39FF14);
  static const Color gold = Color(0xFFFFD700);
  static const Color pink = Color(0xFFFF4D8D);
  static const Color red = Color(0xFFFF3B5C);
  static const Color text = Color(0xFFF4F7FF);
  static const Color mutedText = Color(0xFF9AA4C7);

  static Color forPowerUp(PowerUpType type) {
    return switch (type) {
      PowerUpType.shield => cyan,
      PowerUpType.magnet => gold,
      PowerUpType.slowMotion => purple,
      PowerUpType.doubleScore => green,
      PowerUpType.rapidFire => pink,
      PowerUpType.overcharge => red,
      PowerUpType.repair => green,
    };
  }

  static Color forWeapon(WeaponType type) {
    return switch (type) {
      WeaponType.laser => cyan,
      WeaponType.spread => magenta,
      WeaponType.proximityBlast => gold,
    };
  }
}

class AudioAssets {
  static const String backgroundMusic = 'bgm.wav';
  static const String bossMusic = 'boss_bgm.wav';
  static const String coin = 'coin.wav';
  static const String powerUp = 'power_up.wav';
  static const String collision = 'collision.wav';
  static const String tap = 'tap.wav';
  static const String gameOver = 'game_over.wav';
  static const String mission = 'mission.wav';

  static const List<String> allEffects = [
    coin,
    powerUp,
    collision,
    tap,
    gameOver,
    mission,
  ];
}
