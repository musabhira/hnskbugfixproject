import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_tts/flutter_tts.dart';

/// 🎙️ PocketVoiceService: Central High-Quality Female Voice Engine
///
/// Implemented according to User Audio Directives:
/// - Provides a high-quality, natural, smooth female voice across iOS and Android.
/// - iOS: Prioritizes neural & natural female voices (Ava, Samantha, Allison, Susan, Karen).
/// - Android: Prioritizes Google natural neural female voices (sfg, tpf, iob).
/// - Tuned with natural speech rate (0.47) and warm, friendly female pitch (1.12).
/// - Configures iOS audio session category to playback with speaker output.
class PocketVoiceService {
  static final PocketVoiceService instance = PocketVoiceService._internal();
  PocketVoiceService._internal();

  Map<String, String>? _cachedFemaleVoice;

  /// Applies the optimal high-quality smooth female voice settings to any [FlutterTts] instance
  Future<void> configureOptimalFemaleVoice(FlutterTts tts) async {
    try {
      await tts.setLanguage('en-US');

      // Natural smooth conversational pacing and gentle, warm female pitch
      final isIos = !kIsWeb && Platform.isIOS;
      await tts.setSpeechRate(isIos ? 0.49 : 0.46);
      await tts.setPitch(1.12); // Smooth, pleasant female pitch (warm teacher / CyberCat)
      await tts.setVolume(1.0);

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

      if (_cachedFemaleVoice != null) {
        await tts.setVoice(_cachedFemaleVoice!);
        return;
      }

      final rawVoices = await tts.getVoices;
      if (rawVoices is List && rawVoices.isNotEmpty) {
        // Priority ranking of premium smooth female voices
        final candidateNames = [
          'ava',        // iOS Premium Neural Female
          'samantha',   // iOS Natural Female
          'allison',    // iOS Warm Female
          'susan',      // iOS Clear Female
          'karen',      // iOS Friendly Female
          'victoria',   // iOS Refined Female
          'sfg',        // Android Google Neural Female (e.g. en-us-x-sfg#female)
          'tpf',        // Android Neural Female
          'iob',        // Android Smooth Female
          'female',     // Generic female identifier
        ];

        Map? selectedVoice;

        // 1. Look for English voices matching top candidates
        for (final candidate in candidateNames) {
          for (final v in rawVoices) {
            if (v is Map) {
              final name = (v['name'] ?? '').toString().toLowerCase();
              final locale = (v['locale'] ?? '').toString().toLowerCase();
              if (locale.startsWith('en') && name.contains(candidate)) {
                selectedVoice = v;
                break;
              }
            }
          }
          if (selectedVoice != null) break;
        }

        // 2. Fallback to any English voice marked as female
        if (selectedVoice == null) {
          for (final v in rawVoices) {
            if (v is Map) {
              final name = (v['name'] ?? '').toString().toLowerCase();
              final locale = (v['locale'] ?? '').toString().toLowerCase();
              if (locale.startsWith('en') &&
                  (name.contains('female') ||
                   name.contains('woman') ||
                   name.contains('girl'))) {
                selectedVoice = v;
                break;
              }
            }
          }
        }

        if (selectedVoice != null) {
          _cachedFemaleVoice = {
            "name": selectedVoice['name'].toString(),
            "locale": selectedVoice['locale'].toString(),
          };
          await tts.setVoice(_cachedFemaleVoice!);
          debugPrint(
            '🎙️ Configured Smooth Female Voice: ${_cachedFemaleVoice!["name"]} (${_cachedFemaleVoice!["locale"]})',
          );
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error configuring female voice: $e');
    }
  }
}
