import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  static bool get _isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS);

  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _ambiencePlayer = AudioPlayer();
  final AudioPlayer _appMusicPlayer = AudioPlayer();
  bool _appMusicStarted = false;
  bool _welcomeSoundPlayed = false;
  bool _hasUserInteracted = !kIsWeb && !_isDesktop;
  bool _pendingAppMusicStart = false;
  bool _pendingAmbienceStart = false;
  bool _pendingWelcomeSound = false;
  bool _soundEnabled = true;
  bool _musicEnabled = true;

  bool get _canPlayAudio => !kIsWeb || _hasUserInteracted;

  Future<void> onAppLaunch() async {
    // Desktop/web: wait for first tap before audio (avoids Windows plugin crashes).
    if (kIsWeb || _isDesktop) {
      _pendingWelcomeSound = true;
      _pendingAppMusicStart = _musicEnabled;
      return;
    }
    await _playWelcomeSoundIfNeeded();
    await ensureAppBackgroundMusic();
  }

  Future<void> registerUserInteraction() async {
    if (!_hasUserInteracted) {
      _hasUserInteracted = true;
    }
    if (_pendingWelcomeSound) {
      await _playWelcomeSoundIfNeeded();
      _pendingWelcomeSound = false;
    }
    if (!_musicEnabled) {
      _pendingAppMusicStart = false;
      _pendingAmbienceStart = false;
      return;
    }
    if (_pendingAppMusicStart || !_appMusicStarted) {
      await ensureAppBackgroundMusic();
    }
    if (_pendingAmbienceStart) {
      await startUnderwaterAmbience();
    }
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    if (!enabled) {
      try {
        await _player.stop();
      } catch (_) {}
    }
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    if (enabled) {
      await ensureAppBackgroundMusic();
      return;
    }
    try {
      await _appMusicPlayer.stop();
      await _ambiencePlayer.stop();
      _appMusicStarted = false;
      _pendingAppMusicStart = false;
      _pendingAmbienceStart = false;
    } catch (_) {}
  }

  Future<void> success() async {
    await _playSafe(
      'sounds/success.mp3',
      fallback: SystemSoundType.click,
    );
  }

  Future<void> wrong() async {
    await _playSafe(
      'sounds/wrong_soft.mp3',
      fallback: SystemSoundType.alert,
    );
  }

  Future<void> bonus() async {
    await _playSafe('sounds/bonus.mp3', fallback: SystemSoundType.click);
  }

  Future<void> tapSoft() async {
    await _playSafe(
      'sounds/tap_soft.mp3',
      fallback: SystemSoundType.click,
    );
  }

  Future<void> startUnderwaterAmbience() async {
    if (!_musicEnabled) return;
    if (!_canPlayAudio) {
      _pendingAmbienceStart = true;
      return;
    }
    try {
      await _ambiencePlayer.setReleaseMode(ReleaseMode.loop);
      await _ambiencePlayer.setVolume(.42);
      await _ambiencePlayer.play(
        AssetSource('sounds/underwater_ambience.mp3'),
      );
      _pendingAmbienceStart = false;
    } catch (_) {}
  }

  Future<void> stopUnderwaterAmbience() async {
    try {
      await _ambiencePlayer.stop();
    } catch (_) {}
  }

  Future<void> startAppBackgroundMusic() async {
    if (!_musicEnabled) return;
    if (_appMusicStarted) return;
    if (!_canPlayAudio) {
      _pendingAppMusicStart = true;
      return;
    }
    try {
      await _appMusicPlayer.setReleaseMode(ReleaseMode.loop);
      await _appMusicPlayer.setVolume(.34);
      try {
        await _appMusicPlayer.play(
          AssetSource('sounds/underwater_ambience.mp3'),
        );
      } catch (_) {
        await _appMusicPlayer.play(AssetSource('sounds/bonus.mp3'));
      }
      _appMusicStarted = true;
      _pendingAppMusicStart = false;
    } catch (_) {}
  }

  Future<void> ensureAppBackgroundMusic() async {
    if (!_musicEnabled) return;
    if (_appMusicStarted) return;
    await startAppBackgroundMusic();
  }

  Future<void> _playWelcomeSoundIfNeeded() async {
    if (_welcomeSoundPlayed) return;
    if (!_soundEnabled) return;
    if (!_canPlayAudio) {
      _pendingWelcomeSound = true;
      return;
    }
    await bonus();
    _welcomeSoundPlayed = true;
  }

  Future<void> _playSafe(
    String assetPath, {
    required SystemSoundType fallback,
  }) async {
    if (!_soundEnabled) return;
    if (!_canPlayAudio) return;
    try {
      await _player.play(AssetSource(assetPath));
    } catch (_) {
      SystemSound.play(fallback);
    }
  }
}
