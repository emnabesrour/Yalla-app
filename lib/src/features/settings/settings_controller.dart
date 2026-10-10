import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  const SettingsState({
    required this.themeMode,
    required this.soundOn,
    required this.musicOn,
    required this.guestMode,
    required this.languageCode,
  });

  final ThemeMode themeMode;
  final bool soundOn;
  final bool musicOn;
  final bool guestMode;
  final String languageCode;

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? soundOn,
    bool? musicOn,
    bool? guestMode,
    String? languageCode,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      soundOn: soundOn ?? this.soundOn,
      musicOn: musicOn ?? this.musicOn,
      guestMode: guestMode ?? this.guestMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController()
      : super(
          const SettingsState(
            themeMode: ThemeMode.light,
            soundOn: true,
            musicOn: true,
            guestMode: true,
            languageCode: 'ar',
          ),
        ) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      themeMode: (prefs.getBool('dark_mode') ?? false)
          ? ThemeMode.dark
          : ThemeMode.light,
      soundOn: prefs.getBool('sound_on') ?? true,
      musicOn: prefs.getBool('music_on') ?? true,
      guestMode: prefs.getBool('guest_mode') ?? true,
      languageCode: prefs.getString('lang') ?? 'ar',
    );
  }

  Future<void> toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    state = state.copyWith(themeMode: value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleSound(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_on', value);
    state = state.copyWith(soundOn: value);
  }

  Future<void> toggleMusic(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_on', value);
    state = state.copyWith(musicOn: value);
  }

  Future<void> setGuestMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('guest_mode', value);
    state = state.copyWith(guestMode: value);
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>(
  (ref) => SettingsController(),
);
