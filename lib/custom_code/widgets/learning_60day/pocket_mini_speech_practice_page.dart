import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_voice_service.dart';
import 'pocket_pronunciation_evaluator.dart';
import 'pocket_fortress_defense_service.dart';

/// 📢 Model for Mini Speech Exercise
class MiniSpeechTopic {
  final int id;
  final String title;
  final String emoji;
  final String passageEn;
  final String passageMl;
  final String speechTipEn;
  final String speechTipMl;

  const MiniSpeechTopic({
    required this.id,
    required this.title,
    required this.emoji,
    required this.passageEn,
    required this.passageMl,
    required this.speechTipEn,
    required this.speechTipMl,
  });
}

/// 📢 Mini Speech Practice & Fluency Evaluation Page (Step 11)
///
/// Implemented according to User Audio Directives:
/// - Designed for learners who struggle or feel anxious speaking English
/// - Presents a short, manageable mini speech to practice
/// - User can listen to native model voice with natural pauses and cadence
/// - User speaks aloud into microphone
/// - Instant AI performance evaluation: Fluency Score, word-by-word accuracy, pacing, and feedback tips
class PocketMiniSpeechPracticePage extends StatefulWidget {
  final int day;
  final String? userId;
  final Function(int)? onStepFinished;

  const PocketMiniSpeechPracticePage({
    super.key,
    this.day = 1,
    this.userId,
    this.onStepFinished,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    String? userId,
    Function(int)? onStepFinished,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketMiniSpeechPracticePage(
          day: day,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<PocketMiniSpeechPracticePage> createState() =>
      _PocketMiniSpeechPracticePageState();
}

class _PocketMiniSpeechPracticePageState
    extends State<PocketMiniSpeechPracticePage> {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();

  int _currentTopicIndex = 0;
  bool _sttReady = false;
  bool _isListening = false;
  bool _isSpeakingTts = false;
  String _liveTranscript = '';
  PronunciationEvaluationResult? _evalResult;
  bool _isPassed = false;

  static const List<MiniSpeechTopic> _topics = [
    MiniSpeechTopic(
      id: 1,
      title: 'Self-Introduction Speech',
      emoji: '👋',
      passageEn:
          'Hello everyone! My name is Rahul. I am from Kerala. I am learning to speak English with confidence. Nice to meet you all!',
      passageMl:
          'എല്ലാവർക്കും നമസ്കാരം! എന്റെ പേര് രാഹുൽ. ഞാൻ കേരളത്തിൽ നിന്നാണ്. ആത്മവിശ്വാസത്തോടെ ഇംഗ്ലീഷ് സംസാരിക്കാൻ ഞാൻ പരിശീലിക്കുന്നു. എല്ലാവരെയും കണ്ടതിൽ സന്തോഷം!',
      speechTipEn: 'Take a gentle breath after "Hello everyone!" and speak with a warm smile.',
      speechTipMl: '"Hello everyone!" ന് ശേഷം ചെറിയൊരു ഇടവേള നൽകി പുഞ്ചിരിയോടെ സംസാരിക്കുക.',
    ),
    MiniSpeechTopic(
      id: 2,
      title: 'My Daily Routine',
      emoji: '🌅',
      passageEn:
          'Every morning, I practice English with my friends. I learn new words and speak aloud every day. It makes me happy!',
      passageMl:
          'എല്ലാ ദിവസവും രാവിലെ ഞാൻ കൂട്ടുകാരോടൊപ്പം ഇംഗ്ലീഷ് പരിശീലിക്കുന്നു. പുതിയ വാക്കുകൾ പഠിക്കുകയും ഉറക്കെ സംസാരിക്കുകയും ചെയ്യുന്നു. ഇത് എന്നെ സന്തോഷിപ്പിക്കുന്നു!',
      speechTipEn: 'Emphasize the action words: "practice", "learn", and "speak".',
      speechTipMl: '"practice", "learn", "speak" എന്നീ പ്രധാന വാക്കുകൾ വ്യക്തമായി ഉച്ചരിക്കുക.',
    ),
    MiniSpeechTopic(
      id: 3,
      title: 'My Dream and Goal',
      emoji: '🌟',
      passageEn:
          'My goal is to speak English fluently and fearlessly. Practice makes me better every single day. I believe in myself!',
      passageMl:
          'ഭയമില്ലാതെ ഒഴുക്കോടെ ഇംഗ്ലീഷ് സംസാരിക്കുകയാണ് എന്റെ ലക്ഷ്യം. പരിശീലനം എന്നെ ദിവസവും മെച്ചപ്പെടുത്തുന്നു. എനിക്ക് എന്നിൽ വിശ്വാസമുണ്ട്!',
      speechTipEn: 'Deliver the final sentence with high energy and confidence!',
      speechTipMl: 'അവസാന വാചകം പൂർണ്ണ ആത്മവിശ്വാസത്തോടെ പറയുക!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
    _initStt();
  }

  Future<void> _initTts() async {
    try {
      await PocketVoiceService.instance.configureOptimalFemaleVoice(_tts);
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeakingTts = false);
      });
    } catch (_) {}
  }

  Future<void> _initStt() async {
    try {
      _sttReady = await _stt.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
        onError: (_) {
          if (mounted) setState(() => _isListening = false);
        },
      );
    } catch (_) {}
  }

  Future<void> _playModelSpeech(String text) async {
    try {
      setState(() => _isSpeakingTts = true);
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      if (mounted) setState(() => _isSpeakingTts = false);
    }
  }

  Future<void> _toggleListening(String targetPassage) async {
    HapticFeedback.mediumImpact();
    if (_isListening) {
      await _stt.stop();
      setState(() => _isListening = false);
      _evaluateSpeech(targetPassage);
      return;
    }

    if (!_sttReady) {
      await _initStt();
    }

    if (_sttReady) {
      setState(() {
        _isListening = true;
        _liveTranscript = '';
        _evalResult = null;
      });

      await _stt.listen(
        onResult: (result) {
          setState(() {
            _liveTranscript = result.recognizedWords;
          });
          _evaluateSpeech(targetPassage);
        },
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.confirmation,
          cancelOnError: false,
        ),
      );
    }
  }

  void _evaluateSpeech(String targetPassage) {
    if (_liveTranscript.trim().isEmpty) return;

    final eval = PocketPronunciationEvaluator.evaluate(
      targetSentence: targetPassage,
      spokenText: _liveTranscript,
    );

    setState(() {
      _evalResult = eval;
      // Pass if 50%+ accuracy achieved (encouraging threshold for speech beginners)
      _isPassed = eval.accuracyPercentage >= 50;
    });

    if (_isPassed) {
      PocketGameSfx.instance.playSnapCorrect();
    }
  }

  Future<void> _onNextTopic() async {
    if (_currentTopicIndex + 1 < _topics.length) {
      setState(() {
        _currentTopicIndex++;
        _liveTranscript = '';
        _evalResult = null;
        _isPassed = false;
      });
    } else {
      await _finishSpeechPractice();
    }
  }

  Future<void> _finishSpeechPractice() async {
    final uid = widget.userId ?? SupaFlow.client.auth.currentUser?.id;
    final prefs = await SharedPreferences.getInstance();

    final userKey = uid != null ? 'pocket_day_${uid}_${widget.day}_step_11_done' : null;
    if (userKey != null) await prefs.setBool(userKey, true);
    await prefs.setBool('pocket_day_guest_${widget.day}_step_11_done', true);

    await PocketFortressDefenseService.recordTrainingPoints(40, uid);
    widget.onStepFinished?.call(11);

    if (!mounted) return;
    _showCompletionModal();
  }

  void _showCompletionModal() {
    PocketGameSfx.instance.playVictory();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE11D48), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE11D48).withValues(alpha: 0.45),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎙️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'MINI SPEECH CONQUERED! 📢',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You broke through speaking hesitation and delivered 3 spoken mini speeches with clarity!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF132238),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      '+40 POCKET SCORE AWARDED!',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'PROCEED TO ENGLISH HUB ➔',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    _stt.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topic = (_currentTopicIndex < _topics.length)
        ? _topics[_currentTopicIndex]
        : _topics.last;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📢', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  'Speech Practice',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              'Step 11 • Day ${widget.day}',
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE11D48).withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎙️', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  '${_currentTopicIndex + 1} / ${_topics.length}',
                  style: GoogleFonts.robotoMono(
                    color: const Color(0xFFE11D48),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Progress bar
            LinearProgressIndicator(
              value: (_currentTopicIndex + 1) / _topics.length,
              minHeight: 4,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE11D48)),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Speech Title & Topic Pill
                    Row(
                      children: [
                        Text(topic.emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Text(
                          topic.title,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Speech Passage Display Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131D2D),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _isPassed
                              ? const Color(0xFF10B981)
                              : const Color(0xFF334155),
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic.passageEn,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.45,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            topic.passageMl,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF94A3B8),
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Listen to model voice button
                          GestureDetector(
                            onTap: () => _playModelSpeech(topic.passageEn),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFF38BDF8)
                                        .withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isSpeakingTts
                                        ? Icons.volume_up_rounded
                                        : Icons.headphones_rounded,
                                    color: const Color(0xFF38BDF8),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Listen to Native Pace',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF38BDF8),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Helpful Speech Delivery Tip
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1B4B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFA855F7).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              topic.speechTipEn,
                              style: GoogleFonts.inter(
                                color: const Color(0xFFE9D5FF),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Big Glowing Microphone Button
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => _toggleListening(topic.passageEn),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isListening
                                    ? const Color(0xFFEF4444)
                                    : (_isPassed
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFE11D48)),
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isListening
                                            ? const Color(0xFFEF4444)
                                            : const Color(0xFFE11D48))
                                        .withValues(alpha: 0.5),
                                    blurRadius: _isListening ? 24 : 12,
                                    spreadRadius: _isListening ? 6 : 1,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isListening
                                    ? Icons.mic_rounded
                                    : (_isPassed
                                        ? Icons.check_circle_rounded
                                        : Icons.mic_none_rounded),
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isListening
                                ? 'Listening... Speak the speech aloud!'
                                : (_isPassed
                                    ? 'Great delivery! Ready for next ➔'
                                    : 'Tap mic and read the speech aloud'),
                            style: GoogleFonts.outfit(
                              color: _isListening
                                  ? const Color(0xFFFCA5A5)
                                  : (_isPassed
                                      ? const Color(0xFF34D399)
                                      : Colors.white70),
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Live Speech Transcript & Evaluation Breakdown Card
                    if (_liveTranscript.isNotEmpty) ...[
                      _buildEvaluationCard(),
                    ],

                    const SizedBox(height: 24),

                    // Continue / Next Button
                    if (_isPassed)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                          ),
                          onPressed: _onNextTopic,
                          child: Text(
                            _currentTopicIndex + 1 < _topics.length
                                ? 'NEXT MINI SPEECH ➔'
                                : 'COMPLETE STEP 11 & PROCEED ➔',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationCard() {
    final eval = _evalResult;
    final topic = _topics[_currentTopicIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sent speech bubble (User's spoken voice transcript)
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2, right: 8),
                  child: Icon(Icons.mic_rounded, size: 16, color: Colors.white70),
                ),
                Flexible(
                  child: Text(
                    _liveTranscript,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Full Pronunciation & Fluency Evaluation Breakdown Card (Same style as Day 1 Step 1)
        if (eval != null)
          PocketPronunciationResultCard(
            result: eval,
            onRetry: () => _toggleListening(topic.passageEn),
            onListenNative: () => _playModelSpeech(topic.passageEn),
          ),
      ],
    );
  }
}
