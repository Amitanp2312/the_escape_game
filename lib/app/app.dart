import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'app_controller.dart';
import 'routes.dart';
import 'theme.dart';

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing from the widget tree.');
    return scope!.notifier!;
  }

  static AppController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing from the widget tree.');
    return scope!.notifier!;
  }
}

class NeonEscapeApp extends StatefulWidget {
  const NeonEscapeApp({super.key, required this.controller});

  final AppController controller;

  @override
  State<NeonEscapeApp> createState() => _NeonEscapeAppState();
}

class _NeonEscapeAppState extends State<NeonEscapeApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onHide: widget.controller.audio.pauseForBackground,
      onPause: widget.controller.audio.pauseForBackground,
      onInactive: widget.controller.audio.pauseForBackground,
      onResume: widget.controller.audio.resumeFromBackground,
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: widget.controller,
      child: MaterialApp(
        title: AppInfo.gameTitle,
        debugShowCheckedModeBanner: false,
        theme: buildNeonTheme(),
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.table(),
      ),
    );
  }
}
