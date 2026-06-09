import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModeKey = 'theme_mode';
const _autoReconnectKey = 'auto_reconnect';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.autoReconnectOnLaunch,
  });

  final ThemeMode themeMode;
  final bool autoReconnectOnLaunch;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? autoReconnectOnLaunch,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      autoReconnectOnLaunch:
          autoReconnectOnLaunch ?? this.autoReconnectOnLaunch,
    );
  }
}

class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    final themeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
    final autoReconnect = prefs.getBool(_autoReconnectKey) ?? false;

    return AppSettings(
      themeMode: ThemeMode.values[themeIndex.clamp(0, ThemeMode.values.length - 1)],
      autoReconnectOnLaunch: autoReconnect,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setInt(_themeModeKey, mode.index);
    state = AsyncData((state.value ?? const AppSettings(
      themeMode: ThemeMode.system,
      autoReconnectOnLaunch: false,
    )).copyWith(themeMode: mode));
  }

  Future<void> setAutoReconnect(bool value) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(_autoReconnectKey, value);
    state = AsyncData((state.value ?? const AppSettings(
      themeMode: ThemeMode.system,
      autoReconnectOnLaunch: false,
    )).copyWith(autoReconnectOnLaunch: value));
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(SettingsController.new);
