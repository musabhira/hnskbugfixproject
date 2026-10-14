import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🎙️ PocketVoiceService: Free Native Multi-Persona Voice Engine
///
/// Implemented according to User Audio Directives:
/// - 100% Free: Uses only on-device native TTS voices (zero paid cloud APIs).
/// - Settings switchable personas:
///   1. 'female' -> Smooth Female (Ava / Samantha / Allison / sfg)
///   2. 'cybercat' -> CyberCat Warm & Friendly (higher pitch 1.25, cheerful pace)
///   3. 'male' -> Clear Male (Daniel / Alex / en-us-x-sfg#male)
///   4. 'british' -> British Accent (en-GB / Oliver / Serena / George)
class PocketVoiceService {
  static final PocketVoiceService instance = PocketVoiceService._internal();
  PocketVoiceService._internal();

  static const String prefKeyVoicePersona = 'tutor_voice_persona';
  String _currentPersona = 'female';

  String get currentPersona => _currentPersona;

  Future<String> getSelectedPersona() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentPersona = prefs.getString(prefKeyVoicePersona) ?? 'female';
    } catch (_) {}
    return _currentPersona;
  }

  Future<void> setPersona(String persona) async {
    _currentPersona = persona;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefKeyVoicePersona, persona);
    } catch (_) {}
  }

  /// Applies the optimal high-quality voice settings to any [FlutterTts] instance based on user preferences
  Future<void> configureOptimalFemaleVoice(FlutterTts tts) async {
    try {
      await getSelectedPersona();
      final isIos = !kIsWeb && Platform.isIOS;

      if (isIos) {
        try {
          await tts.setIosAudioCategory(
            IosTextToSpeechAudioCategory.playback,
            [
              IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
              IosTextToSpeechAudioCategoryOptions.allowBluetooth,
              IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            ],
            IosTextToSpeechAudioMode.defaultMode,
          );
        } catch (_) {}
      }

      await tts.setVolume(1.0);

      switch (_currentPersona) {
        case 'cybercat':
          await tts.setLanguage('en-US');
          await tts.setSpeechRate(isIos ? 0.50 : 0.48);
          await tts.setPitch(1.28); // Cheerful playful CyberCat tutor pitch
          await _applyVoiceCandidates(tts, ['ava', 'samantha', 'allison', 'karen', 'sfg', 'female']);
          break;

        case 'male':
          await tts.setLanguage('en-US');
          await tts.setSpeechRate(isIos ? 0.48 : 0.45);
          await tts.setPitch(0.95); // Deep, articulate male mentor pitch
          await _applyVoiceCandidates(tts, ['daniel', 'alex', 'oliver', 'en-us-x-sfg#male', 'male']);
          break;

        case 'british':
          await tts.setLanguage('en-GB');
          await tts.setSpeechRate(isIos ? 0.48 : 0.46);
          await tts.setPitch(1.08); // Polished British RP tutor
          await _applyVoiceCandidates(tts, ['oliver', 'serena', 'george', 'stephanie', 'en-gb']);
          break;

        case 'female':
        default:
          await tts.setLanguage('en-US');
          await tts.setSpeechRate(isIos ? 0.49 : 0.46);
          await tts.setPitch(1.12); // Smooth, pleasant female pitch
          await _applyVoiceCandidates(tts, [
            'ava',
            'samantha',
            'allison',
            'susan',
            'karen',
            'victoria',
            'sfg',
            'tpf',
            'iob',
            'female'
          ]);
          break;
      }
    } catch (e) {
      debugPrint('⚠️ Error configuring voice persona: $e');
    }
  }

  Future<void> _applyVoiceCandidates(FlutterTts tts, List<String> candidateNames) async {
    try {
      final rawVoices = await tts.getVoices;
      if (rawVoices is! List || rawVoices.isEmpty) return;

      Map? selectedVoice;
      for (final candidate in candidateNames) {
        for (final v in rawVoices) {
          if (v is Map) {
            final name = (v['name'] ?? '').toString().toLowerCase();
            final locale = (v['locale'] ?? '').toString().toLowerCase();
            if (locale.startsWith('en') && (name.contains(candidate) || locale.contains(candidate))) {
              selectedVoice = v;
              break;
            }
          }
        }
        if (selectedVoice != null) break;
      }

      if (selectedVoice != null) {
        final voiceMap = {
          "name": selectedVoice['name'].toString(),
          "locale": selectedVoice['locale'].toString(),
        };
        await tts.setVoice(voiceMap);
        debugPrint('🎙️ Applied Tutor Voice Persona [$_currentPersona]: ${voiceMap["name"]}');
      }
    } catch (e) {
      debugPrint('⚠️ Voice candidate selection error: $e');
    }
  }

  /// Previews the selected persona voice immediately
  Future<void> previewPersona(String persona) async {
    try {
      await setPersona(persona);
      final FlutterTts previewTts = FlutterTts();
      await configureOptimalFemaleVoice(previewTts);
      String previewLine;
      switch (persona) {
        case 'cybercat':
          previewLine = 'Hi! I am CyberCat! Let us learn English together!';
          break;
        case 'male':
          previewLine = 'Hello! I am your English tutor. Ready to practice speaking?';
          break;
        case 'british':
          previewLine = 'Good day! Let us practise your English pronunciation.';
          break;
        case 'female':
        default:
          previewLine = 'Hello! Welcome to Pocket Mates. Let us learn English!';
          break;
      }
      await previewTts.speak(previewLine);
    } catch (e) {
      debugPrint('⚠️ Voice preview error: $e');
    }
  }
}

