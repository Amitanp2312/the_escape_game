import 'package:flame_audio/flame_audio.dart';

import '../utils/constants.dart';

class AudioService {
  bool musicEnabled = true;
  bool soundEffectsEnabled = true;
  bool _initialized = false;
  bool _pausedByBackground = false;
  bool _backgrounded = false;
  String _track = AudioAssets.backgroundMusic;
  double _volume = 0.28;

  Future<void> initialize({
    required bool musicEnabled,
    required bool soundEffectsEnabled,
  }) async {
    this.musicEnabled = musicEnabled;
    this.soundEffectsEnabled = soundEffectsEnabled;
    try {
      await Future<void>(() async {
        await FlameAudio.bgm.initialize(
          audioContext: AudioContextConfig(focus: AudioContextConfigFocus.gain)
              .build(),
        );
        await FlameAudio.audioCache.loadAll([
          AudioAssets.backgroundMusic,
          AudioAssets.bossMusic,
          ...AudioAssets.allEffects,
        ]);
      }).timeout(const Duration(seconds: 2));
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  Future<void> startMusic() => playTrack(AudioAssets.backgroundMusic);

  Future<void> playBossMusic() =>
      playTrack(AudioAssets.bossMusic, volume: 0.34);

  Future<void> playTrack(String file, {double volume = 0.28}) async {
    _volume = volume;
    if (!musicEnabled || _backgrounded) {
      _track = file;
      return;
    }
    if (_track == file && FlameAudio.bgm.isPlaying) {
      return;
    }
    _track = file;
    try {
      await FlameAudio.bgm.stop();
      await FlameAudio.bgm.play(file, volume: volume);
    } catch (_) {
      // Missing or failed audio should be ignored.
    }
  }

  Future<void> stopMusic() async {
    _pausedByBackground = false;
    try {
      await FlameAudio.bgm.stop();
    } catch (_) {
      // Missing or failed audio should be ignored.
    }
  }

  Future<void> pauseForBackground() async {
    if (_backgrounded) {
      return;
    }
    _backgrounded = true;
    _pausedByBackground = musicEnabled && FlameAudio.bgm.isPlaying;
    try {
      await FlameAudio.bgm.stop();
    } catch (_) {
      // Missing or failed audio should be ignored.
    }
  }

  Future<void> resumeFromBackground() async {
    _backgrounded = false;
    if (!_pausedByBackground || !musicEnabled) {
      _pausedByBackground = false;
      return;
    }
    _pausedByBackground = false;
    try {
      await FlameAudio.bgm.stop();
      await FlameAudio.bgm.play(_track, volume: _volume);
    } catch (_) {
      // Missing or failed audio should be ignored.
    }
  }

  Future<void> setMusicEnabled(bool enabled) async {
    musicEnabled = enabled;
    if (enabled) {
      await playTrack(_track, volume: _volume);
    } else {
      await stopMusic();
    }
  }

  void setSoundEffectsEnabled(bool enabled) {
    soundEffectsEnabled = enabled;
  }

  void playTap() => _play(AudioAssets.tap);
  void playCoin() => _play(AudioAssets.coin);
  void playPowerUp() => _play(AudioAssets.powerUp);
  void playCollision() => _play(AudioAssets.collision);
  void playGameOver() => _play(AudioAssets.gameOver);
  void playMission() => _play(AudioAssets.mission);

  Future<void> dispose() async {
    await stopMusic();
    try {
      FlameAudio.bgm.dispose();
    } catch (_) {
      // Best-effort cleanup.
    }
  }

  void _play(String fileName) {
    if (!soundEffectsEnabled || !_initialized || _backgrounded) {
      return;
    }
    try {
      FlameAudio.play(fileName, volume: 0.7);
    } catch (_) {
      // A missing sound file must not crash the game.
    }
  }
}
