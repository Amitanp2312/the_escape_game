import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:the_escape_game/app/app.dart';
import 'package:the_escape_game/app/app_controller.dart';
import 'package:the_escape_game/services/audio_service.dart';
import 'package:the_escape_game/services/storage_service.dart';
import 'package:the_escape_game/services/vibration_service.dart';

Future<AppController> createTestController() async {
  SharedPreferences.setMockInitialValues({});
  final storage = StorageService();
  await storage.initialize();
  final profile = await storage.loadProfile();
  final audio = AudioService()
    ..musicEnabled = false
    ..soundEffectsEnabled = false;
  return AppController(
    storage: storage,
    audio: audio,
    vibration: VibrationService()..setEnabled(false),
    profile: profile,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('splash screen shows the game title', (tester) async {
    final controller = await createTestController();
    await tester.pumpWidget(NeonEscapeApp(controller: controller));
    expect(find.text('STORMLINE'), findsOneWidget);
    expect(find.text('Sky Rush'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2400));
    await tester.pump();
    expect(find.text('Play'), findsOneWidget);
  });
}
