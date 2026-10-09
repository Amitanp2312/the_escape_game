import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_escape_game/models/saved_profile.dart';
import 'package:the_escape_game/services/storage_service.dart';
import 'package:the_escape_game/utils/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('saves and reloads a profile', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.initialize();
    final updated = SavedProfile.initial().copyWith(
      highScore: 900,
      totalCoins: 42,
    );
    await storage.saveProfile(updated);
    final loaded = await storage.loadProfile();
    expect(loaded.highScore, 900);
    expect(loaded.totalCoins, 42);
  });

  test('saves unlocked level and defaults missing unlock to 1', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.initialize();
    await storage.saveProfile(
      SavedProfile.initial().copyWith(
        unlockedLevel: 3,
        levelBestScores: {'1': 400},
      ),
    );
    final loaded = await storage.loadProfile();
    expect(loaded.unlockedLevel, 3);
    expect(loaded.levelBestScores['1'], 400);

    final legacy = SavedProfile.fromJson({
      'highScore': 10,
      'totalCoins': 4,
      'purchasedSkinIds': ['neon_blue'],
      'selectedSkinId': 'neon_blue',
    });
    expect(legacy.unlockedLevel, 1);
    expect(legacy.levelBestScores, isEmpty);
    expect(legacy.endlessBest, 0);
    expect(legacy.endlessBestWave, 0);
  });

  test(
    'endless fields save, reload, and default to 0 on older saves',
    () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.initialize();
      await storage.saveProfile(
        SavedProfile.initial().copyWith(endlessBest: 1200, endlessBestWave: 7),
      );
      final loaded = await storage.loadProfile();
      expect(loaded.endlessBest, 1200);
      expect(loaded.endlessBestWave, 7);
    },
  );

  test('falls back to defaults when stored data is corrupt', () async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.profile: '{this is not json',
    });
    final storage = StorageService();
    await storage.initialize();
    final loaded = await storage.loadProfile();
    expect(loaded.highScore, 0);
    expect(loaded.totalCoins, 0);
    expect(loaded.purchasedSkinIds, contains('neon_blue'));
  });
}
