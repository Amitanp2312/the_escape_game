import 'package:flutter/foundation.dart';

import '../models/game_state.dart';
import '../models/level_definition.dart';
import '../models/mission.dart';
import '../models/player_skin.dart';
import '../models/saved_profile.dart';
import '../models/shop_rules.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../services/vibration_service.dart';
import 'mission_tracker.dart';

class AppController extends ChangeNotifier {
  AppController({
    required this.storage,
    required this.audio,
    required this.vibration,
    required this._profile,
  });

  final StorageService storage;
  final AudioService audio;
  final VibrationService vibration;

  SavedProfile _profile;
  SavedProfile get profile => _profile;

  int get highScore => _profile.highScore;
  int get totalCoins => _profile.totalCoins;
  int get unlockedLevel => _profile.unlockedLevel;
  int get endlessBest => _profile.endlessBest;
  int get endlessBestWave => _profile.endlessBestWave;

  bool isLevelUnlocked(int index) => index <= _profile.unlockedLevel;

  int bestForLevel(int index) => _profile.levelBestScores['$index'] ?? 0;
  String get selectedSkinId => _profile.selectedSkinId;
  PlayerSkin get selectedSkin => PlayerSkinCatalog.byId(selectedSkinId);

  bool isSkinOwned(String id) => _profile.purchasedSkinIds.contains(id);

  List<MissionProgressView> missionViews() {
    final tracker = MissionTracker(
      Map<String, int>.from(_profile.missionProgress),
      {..._profile.completedMissionIds},
    );
    return tracker.views(claimedIds: {..._profile.claimedMissionIds});
  }

  Future<void> applySessionResult(SessionResult result) async {
    final tracker = MissionTracker(
      Map<String, int>.from(_profile.missionProgress),
      {..._profile.completedMissionIds},
    );
    tracker.applySession(result);
    _profile = _profile.copyWith(
      highScore: result.score > _profile.highScore
          ? result.score
          : _profile.highScore,
      totalCoins: _profile.totalCoins + result.coinsCollected,
      missionProgress: tracker.snapshotProgress(),
      completedMissionIds: tracker.snapshotCompleted(),
    );
    notifyListeners();
    await storage.saveProfile(_profile);
  }

  Future<void> completeLevel({
    required int levelIndex,
    required SessionResult result,
  }) async {
    await applySessionResult(result);
    final unlocked = LevelProgress.afterWin(
      unlockedLevel: _profile.unlockedLevel,
      beatenIndex: levelIndex,
    );
    final key = '$levelIndex';
    final previous = _profile.levelBestScores[key] ?? 0;
    final best = result.score > previous ? result.score : previous;
    _profile = _profile.copyWith(
      unlockedLevel: unlocked,
      levelBestScores: {..._profile.levelBestScores, key: best},
    );
    notifyListeners();
    await storage.saveProfile(_profile);
  }

  bool spendCoins(int amount) {
    if (amount <= 0 || _profile.totalCoins < amount) {
      return false;
    }
    _profile = _profile.copyWith(totalCoins: _profile.totalCoins - amount);
    notifyListeners();
    storage.saveProfile(_profile);
    return true;
  }

  Future<void> applyEndlessResult(
    SessionResult result, {
    required int wave,
  }) async {
    await applySessionResult(result);
    _profile = _profile.copyWith(
      endlessBest: result.score > _profile.endlessBest
          ? result.score
          : _profile.endlessBest,
      endlessBestWave: wave > _profile.endlessBestWave
          ? wave
          : _profile.endlessBestWave,
    );
    notifyListeners();
    await storage.saveProfile(_profile);
  }

  Future<bool> purchaseSkin(String skinId) async {
    final skin = PlayerSkinCatalog.byId(skinId);
    final owned = isSkinOwned(skin.id);
    if (!ShopRules.canPurchase(
      coins: _profile.totalCoins,
      price: skin.price,
      alreadyOwned: owned,
    )) {
      return false;
    }
    final purchased = [..._profile.purchasedSkinIds, skin.id];
    _profile = _profile.copyWith(
      totalCoins: _profile.totalCoins - skin.price,
      purchasedSkinIds: purchased,
      selectedSkinId: skin.id,
    );
    notifyListeners();
    await storage.saveProfile(_profile);
    return true;
  }

  Future<void> selectSkin(String skinId) async {
    if (!isSkinOwned(skinId)) {
      return;
    }
    _profile = _profile.copyWith(selectedSkinId: skinId);
    notifyListeners();
    await storage.saveProfile(_profile);
  }

  Future<bool> claimMission(MissionId id) async {
    final views = missionViews();
    final view = views.firstWhere((item) => item.definition.id == id);
    if (!view.canClaim) {
      return false;
    }
    _profile = _profile.copyWith(
      totalCoins: _profile.totalCoins + view.definition.coinReward,
      claimedMissionIds: [..._profile.claimedMissionIds, id.name],
    );
    notifyListeners();
    audio.playMission();
    await storage.saveProfile(_profile);
    return true;
  }

  Future<void> setMusicEnabled(bool enabled) async {
    await audio.setMusicEnabled(enabled);
    _profile = _profile.copyWith(musicEnabled: enabled);
    notifyListeners();
    await storage.saveProfile(_profile);
  }

  Future<void> setSoundEffectsEnabled(bool enabled) async {
    audio.setSoundEffectsEnabled(enabled);
    _profile = _profile.copyWith(soundEffectsEnabled: enabled);
    notifyListeners();
    await storage.saveProfile(_profile);
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    vibration.setEnabled(enabled);
    _profile = _profile.copyWith(vibrationEnabled: enabled);
    notifyListeners();
    await storage.saveProfile(_profile);
  }

  Future<void> resetProgress() async {
    _profile = await storage.resetProfile();
    await audio.setMusicEnabled(_profile.musicEnabled);
    audio.setSoundEffectsEnabled(_profile.soundEffectsEnabled);
    vibration.setEnabled(_profile.vibrationEnabled);
    notifyListeners();
  }

  void playTap() {
    audio.playTap();
    vibration.light();
  }
}
