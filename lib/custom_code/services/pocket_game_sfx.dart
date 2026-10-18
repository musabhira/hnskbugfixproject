import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 🎮 High-Performance Arcade Sound Effects Engine for Pocket Mates Games
/// Generates crisp, lag-free PCM sound effects in pure Dart with zero external asset files.
/// Includes synchronized haptic feedback and fallback protection.
class PocketGameSfx {
  static final PocketGameSfx _instance = PocketGameSfx._internal();
  static PocketGameSfx get instance => _instance;

  PocketGameSfx._internal() {
    _initPlayers();
  }

  AudioPlayer? _sfxPlayer;
  bool _isMuted = false;

  void setMuted(bool muted) {
    _isMuted = muted;
  }

  bool get isMuted => _isMuted;

  void _initPlayers() {
    try {
      _sfxPlayer = AudioPlayer(playerId: 'pocket_game_sfx_player');
      _sfxPlayer?.setReleaseMode(ReleaseMode.stop);
      _sfxPlayer?.setVolume(0.85);
    } catch (e) {
      debugPrint('⚠️ PocketGameSfx init error: $e');
    }
  }

  // Cached sound effect byte buffers
  static Uint8List? _popWav;
  static Uint8List? _correctChimeWav;
  static Uint8List? _errorBuzzWav;
  static Uint8List? _victoryWav;
  static Uint8List? _clickWav;

  /// 🎵 Quick tactile tile pop (e.g. selecting/tapping a tile)
  Future<void> playTilePop() async {
    HapticFeedback.selectionClick();
    SystemSound.play(SystemSoundType.click);
    if (_isMuted) return;

    _popWav ??= _createToneWav(
      frequencies: [880.0, 1100.0],
      durationMs: 70,
      decay: true,
      amplitude: 0.6,
    );
    _playBytes(_popWav!);
  }

  /// 🌟 Bright positive chime when a correct tile/word is snapped into position
  Future<void> playSnapCorrect() async {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);
    if (_isMuted) return;

    _correctChimeWav ??= _createToneWav(
      frequencies: [659.25, 880.0, 1046.5], // E5 -> A5 -> C6
      durationMs: 140,
      decay: true,
      amplitude: 0.75,
    );
    _playBytes(_correctChimeWav!);
  }

  /// ❌ Low error buzzer when an incorrect word or letter is chosen
  Future<void> playErrorBuzz() async {
    HapticFeedback.vibrate();
    SystemSound.play(SystemSoundType.alert);
    if (_isMuted) return;

    _errorBuzzWav ??= _createBuzzWav(
      frequency: 160.0,
      durationMs: 180,
      amplitude: 0.7,
    );
    _playBytes(_errorBuzzWav!);
  }

  /// 🏆 Triumphant 4-note victory fanfare when completing a round/word
  Future<void> playVictory() async {
    HapticFeedback.heavyImpact();
    if (_isMuted) return;

    _victoryWav ??= _createArpeggioWav(
      notes: [523.25, 659.25, 783.99, 1046.5], // C5, E5, G5, C6
      noteDurationMs: 100,
      amplitude: 0.8,
    );
    _playBytes(_victoryWav!);
  }

  /// 🔘 Fast wooden button click
  Future<void> playClick() async {
    HapticFeedback.selectionClick();
    SystemSound.play(SystemSoundType.click);
    if (_isMuted) return;

    _clickWav ??= _createToneWav(
      frequencies: [1200.0],
      durationMs: 30,
      decay: true,
      amplitude: 0.5,
    );
    _playBytes(_clickWav!);
  }

  void _playBytes(Uint8List bytes) {
    try {
      _sfxPlayer?.stop();
      _sfxPlayer?.play(BytesSource(bytes, mimeType: 'audio/wav'));
    } catch (_) {
      // Fallback already triggered via SystemSound
    }
  }

  // =========================================================================
  // 🎹 PURE DART SYNTHESIS: PCM WAV GENERATORS (ZERO ASSETS REQUIRED)
  // =========================================================================

  static const int _sampleRate = 22050;

  /// Generate a clean sine-wave tone with optional decaying envelope
  static Uint8List _createToneWav({
    required List<double> frequencies,
    required int durationMs,
    bool decay = true,
    double amplitude = 0.7,
  }) {
    final numSamples = (_sampleRate * (durationMs / 1000.0)).round();
    final dataSize = numSamples * 2; // 16-bit mono
    final buffer = ByteData(44 + dataSize);

    _writeWavHeader(buffer, dataSize);

    final freqStep = frequencies.length == 1
        ? (int i) => frequencies[0]
        : (int i) {
            final t = i / numSamples;
            final idx = (t * frequencies.length).clamp(0, frequencies.length - 1).toInt();
            return frequencies[idx];
          };

    double phase = 0.0;
    for (int i = 0; i < numSamples; i++) {
      final f = freqStep(i);
      phase += 2.0 * math.pi * f / _sampleRate;
      double sample = math.sin(phase);

      if (decay) {
        final progress = i / numSamples;
        sample *= math.exp(-3.5 * progress);
      }

      final intSample = (sample * 32767.0 * amplitude).clamp(-32768, 32767).toInt();
      buffer.setInt16(44 + (i * 2), intSample, Endian.little);
    }

    return buffer.buffer.asUint8List();
  }

  /// Generate a rich buzzy tone for error alerts
  static Uint8List _createBuzzWav({
    required double frequency,
    required int durationMs,
    double amplitude = 0.7,
  }) {
    final numSamples = (_sampleRate * (durationMs / 1000.0)).round();
    final dataSize = numSamples * 2;
    final buffer = ByteData(44 + dataSize);

    _writeWavHeader(buffer, dataSize);

    double phase = 0.0;
    for (int i = 0; i < numSamples; i++) {
      phase += 2.0 * math.pi * frequency / _sampleRate;
      // Mix fundamental + 2nd + 3rd harmonics for an authentic buzzer timbre
      double sample = (math.sin(phase) * 0.5) +
          (math.sin(phase * 2.0) * 0.3) +
          (math.sin(phase * 3.0) * 0.2);

      final progress = i / numSamples;
      sample *= (1.0 - (progress * 0.4)); // gentle release

      final intSample = (sample * 32767.0 * amplitude).clamp(-32768, 32767).toInt();
      buffer.setInt16(44 + (i * 2), intSample, Endian.little);
    }

    return buffer.buffer.asUint8List();
  }

  /// Generate an ascending arpeggio fanfare for victories
  static Uint8List _createArpeggioWav({
    required List<double> notes,
    required int noteDurationMs,
    double amplitude = 0.8,
  }) {
    final samplesPerNote = (_sampleRate * (noteDurationMs / 1000.0)).round();
    final totalSamples = samplesPerNote * notes.length;
    final dataSize = totalSamples * 2;
    final buffer = ByteData(44 + dataSize);

    _writeWavHeader(buffer, dataSize);

    int writeIdx = 0;
    for (final noteFreq in notes) {
      double phase = 0.0;
      for (int i = 0; i < samplesPerNote; i++) {
        phase += 2.0 * math.pi * noteFreq / _sampleRate;
        double sample = math.sin(phase);

        // Individual note envelope: quick attack, sustained, soft release
        final prog = i / samplesPerNote;
        if (prog < 0.1) {
          sample *= (prog / 0.1);
        } else {
          sample *= (1.0 - (prog - 0.1) * 0.35);
        }

        final intSample = (sample * 32767.0 * amplitude).clamp(-32768, 32767).toInt();
        buffer.setInt16(44 + (writeIdx * 2), intSample, Endian.little);
        writeIdx++;
      }
    }

    return buffer.buffer.asUint8List();
  }

  static void _writeWavHeader(ByteData buffer, int dataSize) {
    // RIFF chunk descriptor
    buffer.setUint8(0, 0x52); // 'R'
    buffer.setUint8(1, 0x49); // 'I'
    buffer.setUint8(2, 0x46); // 'F'
    buffer.setUint8(3, 0x46); // 'F'
    buffer.setUint32(4, 36 + dataSize, Endian.little);
    buffer.setUint8(8, 0x57);  // 'W'
    buffer.setUint8(9, 0x41);  // 'A'
    buffer.setUint8(10, 0x56); // 'V'
    buffer.setUint8(11, 0x45); // 'E'

    // 'fmt ' subchunk
    buffer.setUint8(12, 0x66); // 'f'
    buffer.setUint8(13, 0x6D); // 'm'
    buffer.setUint8(14, 0x74); // 't'
    buffer.setUint8(15, 0x20); // ' '
    buffer.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    buffer.setUint16(20, 1, Endian.little);  // AudioFormat (1 = PCM)
    buffer.setUint16(22, 1, Endian.little);  // NumChannels (1 = Mono)
    buffer.setUint32(24, _sampleRate, Endian.little); // SampleRate
    buffer.setUint32(28, _sampleRate * 2, Endian.little); // ByteRate (_sampleRate * 1 * 16/8)
    buffer.setUint16(32, 2, Endian.little);  // BlockAlign (1 * 16/8)
    buffer.setUint16(34, 16, Endian.little); // BitsPerSample

    // 'data' subchunk
    buffer.setUint8(36, 0x64); // 'd'
    buffer.setUint8(37, 0x61); // 'a'
    buffer.setUint8(38, 0x74); // 't'
    buffer.setUint8(39, 0x61); // 'a'
    buffer.setUint32(40, dataSize, Endian.little);
  }
}
