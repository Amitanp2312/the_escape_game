import 'package:flutter/material.dart';

import '../utils/constants.dart';

ThemeData buildNeonTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: NeonColors.cyan,
    brightness: Brightness.dark,
    surface: NeonColors.surface,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: NeonColors.background,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      foregroundColor: NeonColors.text,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: NeonColors.surfaceAlt,
      contentTextStyle: const TextStyle(color: NeonColors.text),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: NeonColors.text,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
      headlineMedium: TextStyle(
        color: NeonColors.text,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: NeonColors.text,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(color: NeonColors.text, height: 1.35),
      bodyMedium: TextStyle(color: NeonColors.mutedText, height: 1.4),
    ),
  );
}
