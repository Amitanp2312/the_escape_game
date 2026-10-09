import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';
import 'app/app_controller.dart';
import 'services/audio_service.dart';
import 'services/storage_service.dart';
import 'services/vibration_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final storage = StorageService();
  await storage.initialize();
  final profile = await storage.loadProfile();

  final audio = AudioService();
  await audio.initialize(
    musicEnabled: profile.musicEnabled,
    soundEffectsEnabled: profile.soundEffectsEnabled,
  );

  final vibration = VibrationService()..setEnabled(profile.vibrationEnabled);
  final controller = AppController(
    storage: storage,
    audio: audio,
    vibration: vibration,
    profile: profile,
  );

  runApp(NeonEscapeApp(controller: controller));
}
