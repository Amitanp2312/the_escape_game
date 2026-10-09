import 'package:flutter/services.dart';

class VibrationService {
  bool enabled = true;

  void setEnabled(bool value) {
    enabled = value;
  }

  Future<void> light() async {
    if (!enabled) {
      return;
    }
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Haptics are optional and device-dependent.
    }
  }

  Future<void> medium() async {
    if (!enabled) {
      return;
    }
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  Future<void> heavy() async {
    if (!enabled) {
      return;
    }
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }
}
