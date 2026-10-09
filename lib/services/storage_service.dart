import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_profile.dart';
import '../utils/constants.dart';

class StorageService {
  StorageService({SharedPreferences? preferences}) : _injected = preferences;

  final SharedPreferences? _injected;
  SharedPreferences? _preferences;

  Future<void> initialize() async {
    _preferences = _injected ?? await SharedPreferences.getInstance();
  }

  Future<SavedProfile> loadProfile() async {
    try {
      final prefs = _requirePrefs();
      final raw = prefs.getString(StorageKeys.profile);
      if (raw == null || raw.trim().isEmpty) {
        return SavedProfile.initial();
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return SavedProfile.initial();
      }
      return SavedProfile.fromJson(decoded);
    } catch (_) {
      return SavedProfile.initial();
    }
  }

  Future<void> saveProfile(SavedProfile profile) async {
    try {
      final prefs = _requirePrefs();
      await prefs.setString(StorageKeys.profile, jsonEncode(profile.toJson()));
    } catch (_) {
      // Persistence should never crash gameplay or menus.
    }
  }

  Future<SavedProfile> resetProfile() async {
    final fresh = SavedProfile.initial();
    await saveProfile(fresh);
    return fresh;
  }

  SharedPreferences _requirePrefs() {
    final prefs = _preferences;
    if (prefs == null) {
      throw StateError('StorageService.initialize() must be called first.');
    }
    return prefs;
  }
}
