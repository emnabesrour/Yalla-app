import 'package:flutter_tts/flutter_tts.dart';

class VoicePromptService {
  VoicePromptService._();
  static final VoicePromptService instance = VoicePromptService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    await _tts.setLanguage('ar');
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(1.08);
    await _tts.setVolume(1.0);
    _initialized = true;
  }

  Future<void> saySuccess() async {
    await _init();
    await _tts.speak('أحسنت! رائع!');
  }

  Future<void> sayTryAgain() async {
    await _init();
    await _tts.speak('حاول مرة أخرى');
  }

  Future<void> sayBossIntro() async {
    await _init();
    await _tts.speak('مستوى الزعيم! ركز وورينا مهاراتك');
  }
}
