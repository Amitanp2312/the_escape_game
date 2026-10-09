# Stormline: Sky Rush

A portrait-only endless dodging game built with Flutter, Dart, and Flame. The project is designed as a complete internship submission: playable offline on Android and iOS from a single codebase, with clean architecture, local persistence, and interview-friendly code.

## Overview

The player steers a neon vehicle at the bottom of the screen while obstacles stream downward. Coins and power-ups spawn in safe lanes. Difficulty ramps from Easy to Extreme as survival time grows. High score, coins, unlocked vehicles, missions, and audio settings are stored on-device with SharedPreferences. There is no backend and no Firebase dependency.

## Features

- Endless runner gameplay with swipe, drag, and tap lane controls
- Five obstacle types, coins, and four power-ups
- Lives, short invincibility after a hit, and a shield that absorbs one collision
- Score, distance, combo, and difficulty multiplier
- Vehicle shop with five unlockable skins
- Missions with coin rewards
- Persistent high score, coins, settings, and progress
- Procedural cyberpunk visuals and generated lightweight audio
- Splash, menu, pause, game over, shop, missions, high score, how to play, settings, and about screens

## Gameplay

Stay alive. Move left and right, dodge obstacles, collect coins, and pick up power-ups. Score increases while you survive and gets extra points for coins, near misses, and dodge combos. After three unprotected hits the run ends, coins and high score are saved, and you can replay immediately.

## Screens

| Screen | Purpose |
| --- | --- |
| Splash | Neon title animation, then auto-advance to the menu |
| Main Menu | Play, missions, shop, high score, how to play, settings, about, coin balance |
| Game | Flame canvas plus HUD (score, best, coins, lives, pause, active power-up) |
| Pause | Resume, restart, sound toggle, return to menu |
| Game Over | Final score, best, coins, distance, mission progress, play again |
| Shop | Unlock and select vehicles |
| Missions | Track and claim coin rewards |
| Settings | Music, sound effects, vibration, reset progress |
| How to Play | Short control and objective tutorial |
| About | Configurable internship metadata |

## Technologies Used

- Flutter 3.47+ / Dart 3.13+
- Flame game engine
- flame_audio for music and effects
- shared_preferences for offline saves
- Material 3 dark neon theme
- Built-in `ChangeNotifier` / `InheritedNotifier` / `ValueNotifier` (no extra state-management package)

State management stays small on purpose. `AppController` owns profile data that must survive between screens. The live HUD is a `ValueNotifier` inside the Flame game so menus do not rebuild every frame.

## Project Architecture

```
lib/
  main.dart                 App bootstrap, portrait lock
  app/                      Theme, routes, AppController, InheritedNotifier
  models/                   Saved profile, skins, missions, HUD, difficulty
  services/                 Storage, audio, vibration
  game/                     Flame game, components, managers
  screens/                  All Flutter screens and overlays
  widgets/                  Reusable neon UI
  utils/                    Constants, GameConfig, helpers
assets/
  audio/                    Generated WAV music and effects
  images/                   Placeholder for future sprites
  fonts/                    Placeholder for future fonts
```

Game balancing lives in `lib/utils/game_config.dart`. Persistence lives in `StorageService`, not in widgets. Difficulty, spawning, scoring, collisions, and power-up timers are separate managers so the Flame game class stays a coordinator.

## Installation

```bash
git clone <your-repo-url>
cd the_Escape_game
flutter pub get
```

Optional: regenerate audio assets.

```bash
python tool/generate_audio.py
```

## Running on Android

1. Start an emulator or connect a device (`flutter devices`).
2. From the project root:

```bash
flutter run
```

To build an APK:

```bash
flutter build apk --debug
```

## Running on iOS

iOS builds require a Mac with Xcode. On a Mac:

```bash
cd ios
pod install
cd ..
flutter run
```

This Windows workspace validates iOS configuration (portrait, display name) in `ios/Runner/Info.plist`. An actual iOS compile still needs macOS.

## Controls

- **Drag** left or right to steer smoothly
- **Swipe** left or right to snap toward the next lane
- **Tap** a lane to move toward it
- Pause from the HUD button

The vehicle is clamped to the screen edges.

## Game Mechanics

- **Lives:** 3. A hit removes one life, flashes/shakes, and grants brief invincibility.
- **Shield:** Blocks one collision or expires after its timer.
- **Coin magnet, slow motion, double score:** Limited duration, shown on the HUD.
- **Difficulty bands:** 0–30s Easy, 30–60s Medium, 60–120s Hard, 120s+ Extreme.
- **Fair spawning:** A row never fills every lane. Pickups spawn in remaining safe lanes.
- **Scoring:** +10 per second, +20 per coin, +25 near miss, combo bonus every 5 dodges, with a gradual multiplier.

## Folder Structure

See **Project Architecture** above. Start reading in this order:

1. `lib/utils/game_config.dart` — tunable numbers
2. `lib/app/app_controller.dart` — saved player data
3. `lib/game/neon_escape_game.dart` — game loop
4. `lib/game/managers/` — difficulty, spawn, score, collisions, power-ups
5. `lib/screens/game_screen.dart` — Flutter shell around Flame

## Future Improvements

- Replace procedural shapes with sprite art and a custom font
- Add more missions, daily challenges, and a local leaderboard
- Optional landscape tablet layout
- Richer audio mixing and haptic patterns
- Integration tests on a device farm

## Internship Learning Outcomes

- Structuring a Flutter app beyond a single `main.dart`
- Separating UI, game simulation, and persistence
- Using Flame for a game loop, collisions, and overlays
- Designing difficulty and spawn fairness so the game stays playable
- Saving offline progress safely, including corrupt-data fallbacks
- Writing focused unit tests around scoring, missions, shop rules, and storage

## Screenshots

Add device captures here for the internship report:

- `docs/screenshots/menu.png`
- `docs/screenshots/gameplay.png`
- `docs/screenshots/game_over.png`
- `docs/screenshots/shop.png`

Developer name and about-screen copy are configured in `lib/utils/constants.dart` (`AppInfo.developerName`).
