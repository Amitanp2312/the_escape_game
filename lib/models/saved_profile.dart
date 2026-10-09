import 'player_skin.dart';

class SavedProfile {
  const SavedProfile({
    required this.highScore,
    required this.totalCoins,
    required this.purchasedSkinIds,
    required this.selectedSkinId,
    required this.missionProgress,
    required this.completedMissionIds,
    required this.claimedMissionIds,
    required this.musicEnabled,
    required this.soundEffectsEnabled,
    required this.vibrationEnabled,
    this.unlockedLevel = 1,
    this.levelBestScores = const {},
    this.endlessBest = 0,
    this.endlessBestWave = 0,
  });

  final int highScore;
  final int totalCoins;
  final List<String> purchasedSkinIds;
  final String selectedSkinId;
  final Map<String, int> missionProgress;
  final List<String> completedMissionIds;
  final List<String> claimedMissionIds;
  final bool musicEnabled;
  final bool soundEffectsEnabled;
  final bool vibrationEnabled;
  final int unlockedLevel;
  final Map<String, int> levelBestScores;
  final int endlessBest;
  final int endlessBestWave;

  factory SavedProfile.initial() {
    return const SavedProfile(
      highScore: 0,
      totalCoins: 0,
      purchasedSkinIds: [PlayerSkinCatalog.defaultSkinId],
      selectedSkinId: PlayerSkinCatalog.defaultSkinId,
      missionProgress: {},
      completedMissionIds: [],
      claimedMissionIds: [],
      musicEnabled: true,
      soundEffectsEnabled: true,
      vibrationEnabled: true,
      unlockedLevel: 1,
      levelBestScores: {},
      endlessBest: 0,
      endlessBestWave: 0,
    );
  }

  factory SavedProfile.fromJson(Map<String, dynamic> json) {
    final purchased = _stringList(json['purchasedSkinIds']);
    if (!purchased.contains(PlayerSkinCatalog.defaultSkinId)) {
      purchased.insert(0, PlayerSkinCatalog.defaultSkinId);
    }

    return SavedProfile(
      highScore: _readInt(json['highScore']),
      totalCoins: _readInt(json['totalCoins']),
      purchasedSkinIds: purchased,
      selectedSkinId:
          json['selectedSkinId'] as String? ?? PlayerSkinCatalog.defaultSkinId,
      missionProgress: _intMap(json['missionProgress']),
      completedMissionIds: _stringList(json['completedMissionIds']),
      claimedMissionIds: _stringList(json['claimedMissionIds']),
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      soundEffectsEnabled: json['soundEffectsEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      unlockedLevel: _unlockedLevel(json['unlockedLevel']),
      levelBestScores: _intMap(json['levelBestScores']),
      endlessBest: _readInt(json['endlessBest']),
      endlessBestWave: _readInt(json['endlessBestWave']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'highScore': highScore,
      'totalCoins': totalCoins,
      'purchasedSkinIds': purchasedSkinIds,
      'selectedSkinId': selectedSkinId,
      'missionProgress': missionProgress,
      'completedMissionIds': completedMissionIds,
      'claimedMissionIds': claimedMissionIds,
      'musicEnabled': musicEnabled,
      'soundEffectsEnabled': soundEffectsEnabled,
      'vibrationEnabled': vibrationEnabled,
      'unlockedLevel': unlockedLevel,
      'levelBestScores': levelBestScores,
      'endlessBest': endlessBest,
      'endlessBestWave': endlessBestWave,
    };
  }

  SavedProfile copyWith({
    int? highScore,
    int? totalCoins,
    List<String>? purchasedSkinIds,
    String? selectedSkinId,
    Map<String, int>? missionProgress,
    List<String>? completedMissionIds,
    List<String>? claimedMissionIds,
    bool? musicEnabled,
    bool? soundEffectsEnabled,
    bool? vibrationEnabled,
    int? unlockedLevel,
    Map<String, int>? levelBestScores,
    int? endlessBest,
    int? endlessBestWave,
  }) {
    return SavedProfile(
      highScore: highScore ?? this.highScore,
      totalCoins: totalCoins ?? this.totalCoins,
      purchasedSkinIds: purchasedSkinIds ?? this.purchasedSkinIds,
      selectedSkinId: selectedSkinId ?? this.selectedSkinId,
      missionProgress: missionProgress ?? this.missionProgress,
      completedMissionIds: completedMissionIds ?? this.completedMissionIds,
      claimedMissionIds: claimedMissionIds ?? this.claimedMissionIds,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      unlockedLevel: unlockedLevel ?? this.unlockedLevel,
      levelBestScores: levelBestScores ?? this.levelBestScores,
      endlessBest: endlessBest ?? this.endlessBest,
      endlessBestWave: endlessBestWave ?? this.endlessBestWave,
    );
  }

  static int _unlockedLevel(Object? value) {
    final parsed = _readInt(value);
    if (parsed <= 0) {
      return 1;
    }
    return parsed.clamp(1, 5);
  }

  static int _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value') ?? 0;
  }

  static List<String> _stringList(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return <String>[];
  }

  static Map<String, int> _intMap(Object? value) {
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), _readInt(val)));
    }
    return <String, int>{};
  }
}
