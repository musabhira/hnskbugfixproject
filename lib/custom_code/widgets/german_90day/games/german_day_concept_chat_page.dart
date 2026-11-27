import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_pronunciation_evaluator.dart';
import '../curriculum_data/pocket_german_90day_master_data.dart';
import '../curriculum_data/pocket_german_days1to5_data.dart';
import '../german_localization_helper.dart';

enum GermanConceptChatMode {
  conceptRoom, // Step 1 (Days 2–90)
  day1Vocab20, // Step 4 (Day 1)
  spokenDialogue, // Step 4 (Days 2–90)
}

/// 🇩🇪 Dedicated German Concept Room, Day-1 20-Word Chat, and Spoken Dialogue (Days 1–90)
/// Uses de-DE TTS/STT, PocketGerman90DayMasterData, and GermanLocalizationHelper (6 native languages).
class GermanDayConceptChatPage extends StatefulWidget {
  final int day;
  final int stepIndex;
  final GermanConceptChatMode mode;
  final String? userId;
  final void Function(int stepIndex)? onStepFinished;

  const GermanDayConceptChatPage({
    super.key,
    required this.day,
    required this.stepIndex,
    required this.mode,
    this.userId,
    this.onStepFinished,
  });

  static Future<bool?> show(
    BuildContext context, {
    required int day,
    required int stepIndex,
    required GermanConceptChatMode mode,
    String? userId,
    void Function(int stepIndex)? onStepFinished,
  }) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => GermanDayConceptChatPage(
          day: day,
          stepIndex: stepIndex,
          mode: mode,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<GermanDayConceptChatPage> createState() =>
      _GermanDayConceptChatPageState();
}

class _GermanDayConceptChatPageState extends State<GermanDayConceptChatPage> {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();
  bool _sttReady = false;
  bool _isListening = false;
  String _spoken = '';
  int _itemIndex = 0;
  bool _completed = false;

  late final List<Map<String, String>> _items;
  late final String _headerTitle;
  late final String _blueprintRule;

  @override
  void initState() {
    super.initState();
    _initData();
    _initAudio();
  }

  void _initData() {
    final d = widget.day.clamp(1, 90);
    final spec = PocketGerman90DayMasterData.getAvatarChatSpecMap(d);
    _blueprintRule = (spec['blueprintExplanationMl'] ??
            spec['blueprintTitle'] ??
            'Deutsch A1–B2')
        .toString();

    if (widget.mode == GermanConceptChatMode.day1Vocab20) {
      _headerTitle = GermanLocalizationHelper.pick(
        en: 'Tag 1 • 20 Everyday German Words',
        ml: 'ഡേ 1 • 20 നിത്യജീവിത ജർമൻ വാക്കുകൾ',
        ta: 'நாள் 1 • 20 அன்றாட ஜெர்மன் சொற்கள்',
        hi: 'दिन 1 • 20 रोज़मर्रा के जर्मन शब्द',
        kn: 'ದಿನ 1 • 20 ದೈನಂದಿನ ಜರ್ಮನ್ ಪದಗಳು',
        te: 'రోజు 1 • 20 రోజువారీ జర్మన్ పదాలు',
      );
      _items = PocketGermanDays1To5Data.germanDay1Vocab20.map((w) {
        final word = (w['word'] ?? '').toString();
        final sent = (w['sentence'] ?? word).toString();
        final ml = (w['meaningMl'] ?? '').toString();
        final en = (w['meaningEn'] ?? word).toString();
        return {
          'de': word,
          'sentence': sent,
          'meaning': GermanLocalizationHelper.isEnglishNative
              ? en
              : (ml.isNotEmpty ? ml : word),
          'note': (w['sentenceMl'] ?? '').toString(),
        };
      }).toList();
    } else if (widget.mode == GermanConceptChatMode.spokenDialogue) {
      _headerTitle = GermanLocalizationHelper.pick(
        en: 'Tag $d • Spoken German Dialogue',
        ml: 'ഡേ $d • ജർമൻ സംഭാഷണ പരിശീലനം',
        ta: 'நாள் $d • ஜெர்மன் உரையாடல்',
        hi: 'दिन $d • जर्मन संवाद',
        kn: 'ದಿನ $d • ಜರ್ಮನ್ ಸಂಭಾಷಣೆ',
        te: 'రోజు $d • జర్మన్ సంభాషణ',
      );
      final sentences = PocketGerman90DayMasterData.getSentencesForDay(d);
      _items = sentences.map((s) {
        return {
          'de': s.sentence,
          'sentence': s.sentence,
          'meaning': s.getLocalizedTranslation(),
          'note': s.hint,
        };
      }).toList();
    } else {
      _headerTitle = 'Tag $d • ${(spec['titleEn'] ?? 'Deutsch').toString()}';
      final drills = (spec['drills'] as List? ?? const []);
      final vocab = PocketGerman90DayMasterData.getVocabForDay(d);
      final list = <Map<String, String>>[];
      for (final dr in drills) {
        if (dr is Map) {
          list.add({
            'de': (dr['en'] ?? '').toString(),
            'sentence': (dr['en'] ?? '').toString(),
            'meaning': (dr['ml'] ?? '').toString(),
            'note': (dr['rule'] ?? '').toString(),
          });
        }
      }
      for (final v in vocab.take(5)) {
        list.add({
          'de': v.word,
          'sentence': v.exampleSentence.isNotEmpty ? v.exampleSentence : v.word,
          'meaning': GermanLocalizationHelper.vocabMeaning(v),
          'note': GermanLocalizationHelper.partOfSpeechLabel(v.partOfSpeech),
        });
      }
      _items = list.isNotEmpty
          ? list
          : [
              {
                'de': 'Ich lerne heute Deutsch.',
                'sentence': 'Ich lerne heute Deutsch.',
                'meaning': 'ഞാൻ ഇന്ന് ജർമൻ പഠിക്കുന്നു.',
                'note': 'V2 Verb Position',
              }
            ];
    }
  }

  Future<void> _initAudio() async {
    try {
      await _tts.setLanguage('de-DE');
      await _tts.setSpeechRate(0.45);
    } catch (_) {}
    if (_items.isNotEmpty) {
      await _speakGerman(_items.first['sentence'] ?? '');
    }
  }

  Future<void> _speakGerman(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _tts.stop();
      await _tts.setLanguage('de-DE');
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> _listenGerman() async {
    HapticFeedback.mediumImpact();
    if (_isListening) {
      await _stt.stop();
      setState(() => _isListening = false);
      return;
    }
    if (!_sttReady) {
      try {
        _sttReady = await _stt.initialize(
          onStatus: (s) {
            if ((s == 'done' || s == 'notListening') && mounted) {
              setState(() => _isListening = false);
            }
          },
          onError: (_) {
            if (mounted) setState(() => _isListening = false);
          },
        );
      } catch (_) {}
    }
    if (_sttReady) {
      setState(() {
        _isListening = true;
        _spoken = '';
      });
      await _stt.listen(
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.confirmation,
          cancelOnError: true,
        ),
        localeId: 'de_DE',
        onResult: (res) {
          if (!mounted) return;
          setState(() => _spoken = res.recognizedWords);
        },
      );
    } else {
      // Graceful simulator fallback
      final target = _items[_itemIndex]['sentence'] ?? '';
      setState(() => _spoken = target);
    }
  }

  Future<void> _advanceItem() async {
    PocketGameAudioService.instance.playCorrectSound();
    if (_itemIndex + 1 < _items.length) {
      setState(() {
        _itemIndex++;
        _spoken = '';
      });
      await _speakGerman(_items[_itemIndex]['sentence'] ?? '');
    } else {
      await _markStepDone();
    }
  }

  Future<void> _markStepDone() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = widget.userId ?? SupaFlow.client.auth.currentUser?.id;
    if (uid != null && uid.isNotEmpty) {
      await prefs.setBool(
          'pocket_de_day_${uid}_${widget.day}_step_${widget.stepIndex}_done',
          true);
      await prefs.setBool(
          'pocket_de_day_${uid}_${widget.day}_step_${widget.stepIndex}_completed',
          true);
    }
    await prefs.setBool(
        'pocket_de_day_guest_${widget.day}_step_${widget.stepIndex}_done',
        true);
    await prefs.setBool(
        'pocket_de_day_guest_${widget.day}_step_${widget.stepIndex}_completed',
        true);
    widget.onStepFinished?.call(widget.stepIndex);
    if (!mounted) return;
    setState(() => _completed = true);
  }

  @override
  void dispose() {
    _tts.stop();
    _stt.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[_itemIndex.clamp(0, _items.length - 1)];
    final targetSentence = item['sentence'] ?? '';
    final eval = _spoken.trim().isNotEmpty
        ? PocketPronunciationEvaluator.evaluate(
            targetSentence: targetSentence,
            spokenText: _spoken,
          )
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1118),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white),
          onPressed: () => Navigator.pop(context, _completed),
        ),
        title: Text(
          _headerTitle,
          style: GoogleFonts.outfit(
            color: const Color(0xFFFFCE00),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: _completed
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 56)),
                      const SizedBox(height: 12),
                      Text(
                        GermanLocalizationHelper.pick(
                          en: 'Ausgezeichnet! Step Complete!',
                          ml: 'അഭിനന്ദനങ്ങൾ! ഈ സ്റ്റെപ്പ് പൂർത്തിയായി!',
                          ta: 'வாழ்த்துகள்! இந்த படி முடிந்தது!',
                          hi: 'बहुत बढ़िया! यह चरण पूरा हुआ!',
                          kn: 'ಅಭಿನಂದನೆಗಳು! ಈ ಹಂತ ಪೂರ್ಣಗೊಂಡಿದೆ!',
                          te: 'అభినందనలు! ఈ దశ పూర్తయింది!',
                        ),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          'Weiter ✓',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LinearProgressIndicator(
                      value: (_itemIndex + 1) / _items.length,
                      backgroundColor: Colors.white12,
                      color: const Color(0xFFFFCE00),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_itemIndex + 1} / ${_items.length} • 🇩🇪 CyberCat',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFCE00),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: const Color(0xFFFFCE00)
                                .withValues(alpha: 0.45)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['de'] ?? '',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFCE00),
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (targetSentence != (item['de'] ?? ''))
                            Text(
                              targetSentence,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            item['meaning'] ?? '',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF93C5FD),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if ((item['note'] ?? '').isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              item['note']!,
                              style: GoogleFonts.inter(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E293B),
                                  foregroundColor: const Color(0xFFFFCE00),
                                ),
                                onPressed: () => _speakGerman(targetSentence),
                                icon: const Icon(Icons.volume_up_rounded),
                                label: const Text('Hören (de-DE)'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        '💡 $_blueprintRule',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (_spoken.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '🎙️ "$_spoken"${eval != null ? " (${eval.accuracyPercentage}%)" : ""}',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF34D399),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isListening
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: _listenGerman,
                            icon: Icon(_isListening
                                ? Icons.stop_rounded
                                : Icons.mic_rounded),
                            label: Text(_isListening ? 'Stop' : 'Sprechen'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: _advanceItem,
                            child: Text(
                              _itemIndex + 1 == _items.length
                                  ? 'Fertig ✓'
                                  : 'Weiter ➔',
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
