import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../models/level_definition.dart';
import '../screens/about_screen.dart';
import '../screens/game_screen.dart';
import '../screens/high_score_screen.dart';
import '../screens/home_screen.dart';
import '../screens/how_to_play_screen.dart';
import '../screens/level_select_screen.dart';
import '../screens/missions_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/shop_screen.dart';
import '../screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String levels = '/levels';
  static const String game = '/game';
  static const String missions = '/missions';
  static const String shop = '/shop';
  static const String highScore = '/high-score';
  static const String howToPlay = '/how-to-play';
  static const String settings = '/settings';
  static const String about = '/about';

  static Map<String, WidgetBuilder> table() {
    return {
      splash: (_) => const SplashScreen(),
      home: (_) => const HomeScreen(),
      levels: (_) => const LevelSelectScreen(),
      game: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        final launch = switch (args) {
          GameLaunch() => args,
          LevelDefinition() => GameLaunch(level: args),
          _ => GameLaunch(level: LevelCatalog.levels.first),
        };
        return GameScreen(launch: launch);
      },
      missions: (_) => const MissionsScreen(),
      shop: (_) => const ShopScreen(),
      highScore: (_) => const HighScoreScreen(),
      howToPlay: (_) => const HowToPlayScreen(),
      settings: (_) => const SettingsScreen(),
      about: (_) => const AboutScreen(),
    };
  }
}
