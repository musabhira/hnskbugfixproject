import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_voice_service.dart';
import 'pocket_fortress_defense_service.dart';

/// 🔄 Model for Negative Sentence Transformation Challenge
class NegativeSentenceRound {
  final int id;
  final String positiveSentence;
  final String positiveSentenceMl;
  final String negativeSentence;
  final String negativeSentenceMl;
  final String ruleTipEn;
  final String ruleTipMl;
  final List<String> wordBank; // Target words + distractors

  const NegativeSentenceRound({
    required this.id,
    required this.positiveSentence,
    required this.positiveSentenceMl,
    required this.negativeSentence,
    required this.negativeSentenceMl,
    required this.ruleTipEn,
    required this.ruleTipMl,
    required this.wordBank,
  });
}

/// 🔄 Negative Sentence Transformation Builder Page (Step 10)
///
/// Implemented according to User Audio Directives:
/// - Similar sleek UI to Sentence Builder
/// - Minimal sentence shown at top (Positive statement)
/// - Learner converts it into a proper Negative sentence using the Word Bank
/// - Sequential tap logic: correct word snaps in; incorrect word vibrates and shakes without adding
/// - Teaches proper placement of 'not', 'do not', 'does not', 'did not', 'cannot'
class PocketNegativeSentenceBuilderPage extends StatefulWidget {
  final int day;
  final String? userId;
  final Function(int)? onStepFinished;

  const PocketNegativeSentenceBuilderPage({
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
        builder: (_) => PocketNegativeSentenceBuilderPage(
          day: day,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<PocketNegativeSentenceBuilderPage> createState() =>
      _PocketNegativeSentenceBuilderPageState();
}

class _PocketNegativeSentenceBuilderPageState
    extends State<PocketNegativeSentenceBuilderPage>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();

  late AnimationController _shakeAnimController;

  int _currentIndex = 0;
  final List<String> _assembledWords = [];
  List<String> _activeWordBank = [];
  String? _shakingWord;
  bool _isSpeaking = false;
  bool _isRoundPassed = false;
  bool _isFinishedAll = false;

  static const List<NegativeSentenceRound> _rounds = [
    NegativeSentenceRound(
      id: 1,
      positiveSentence: 'I am ready.',
      positiveSentenceMl: 'ഞാൻ തയ്യാറാണ്.',
      negativeSentence: 'I am not ready.',
      negativeSentenceMl: 'ഞാൻ തയ്യാറല്ല.',
      ruleTipEn: 'Add "not" right after "am / is / are"',
      ruleTipMl: '"am / is / are" ന് ശേഷം "not" ചേർക്കുക',
      wordBank: ['I', 'am', 'not', 'ready.', 'We', 'are', 'do', 'never'],
    ),
    NegativeSentenceRound(
      id: 2,
      positiveSentence: 'She likes tea.',
      positiveSentenceMl: 'അവൾക്ക് ചായ ഇഷ്ടമാണ്.',
      negativeSentence: 'She does not like tea.',
      negativeSentenceMl: 'അവൾക്ക് ചായ ഇഷ്ടമല്ല.',
      ruleTipEn: 'Singular (He/She) takes "does not + base verb"',
      ruleTipMl: 'He / She വരുമ്പോൾ "does not + base verb" ഉപയോഗിക്കുക',
      wordBank: ['She', 'does', 'not', 'like', 'tea.', 'do', 'likes', 'is', 'did'],
    ),
    NegativeSentenceRound(
      id: 3,
      positiveSentence: 'They play football.',
      positiveSentenceMl: 'അവർ ഫുട്ബോൾ കളിക്കുന്നു.',
      negativeSentence: 'They do not play football.',
      negativeSentenceMl: 'അവർ ഫുട്ബോൾ കളിക്കുന്നില്ല.',
      ruleTipEn: 'Plural (They/We/I/You) takes "do not + verb"',
      ruleTipMl: 'They / We വരുമ്പോൾ "do not + verb" ഉപയോഗിക്കുക',
      wordBank: ['They', 'do', 'not', 'play', 'football.', 'does', 'are', 'played', 'can'],
    ),
    NegativeSentenceRound(
      id: 4,
      positiveSentence: 'He can drive a car.',
      positiveSentenceMl: 'അവന് കാർ ഓടിക്കാൻ കഴിയും.',
      negativeSentence: 'He cannot drive a car.',
      negativeSentenceMl: 'അവന് കാർ ഓടിക്കാൻ കഴിയില്ല.',
      ruleTipEn: 'Modal verb "can" becomes "cannot"',
      ruleTipMl: '"can" മാറ്റി "cannot" ചേർക്കുക',
      wordBank: ['He', 'cannot', 'drive', 'a', 'car.', 'can', 'not', 'does', 'did'],
    ),
    NegativeSentenceRound(
      id: 5,
      positiveSentence: 'We went to the market yesterday.',
      positiveSentenceMl: 'ഞങ്ങൾ ഇന്നലെ മാർക്കറ്റിൽ പോയി.',
      negativeSentence: 'We did not go to the market yesterday.',
      negativeSentenceMl: 'ഞങ്ങൾ ഇന്നലെ മാർക്കറ്റിൽ പോയില്ല.',
      ruleTipEn: 'Past tense negative uses "did not + base verb (go)"',
      ruleTipMl: 'കഴിഞ്ഞ കാര്യങ്ങൾക്ക് "did not + base verb (go)" ഉപയോഗിക്കുക',
      wordBank: ['We', 'did', 'not', 'go', 'to', 'the', 'market', 'yesterday.', 'went', 'do', 'does'],
    ),
    NegativeSentenceRound(
      id: 6,
      positiveSentence: 'It is raining outside.',
      positiveSentenceMl: 'പുറത്ത് മഴ പെയ്യുന്നുണ്ട്.',
      negativeSentence: 'It is not raining outside.',
      negativeSentenceMl: 'പുറത്ത് മഴ പെയ്യുന്നില്ല.',
      ruleTipEn: 'Continuous tense adds "not" after "is"',
      ruleTipMl: '"is" ന് ശേഷം "not" ചേർക്കുക',
      wordBank: ['It', 'is', 'not', 'raining', 'outside.', 'does', 'was', 'no', 'are'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initTts();

    _shakeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );

    _loadRound(_currentIndex);
  }

  Future<void> _initTts() async {
    try {
      await PocketVoiceService.instance.configureOptimalFemaleVoice(_tts);
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
    } catch (_) {}
  }

  void _loadRound(int index) {
    if (index >= _rounds.length) {
      _finishAllRounds();
      return;
    }

    final round = _rounds[index];
    final shuffled = List<String>.from(round.wordBank)..shuffle(math.Random());

    setState(() {
      _assembledWords.clear();
      _activeWordBank = shuffled;
      _isRoundPassed = false;
    });

    _speak(round.positiveSentence);
  }

  Future<void> _speak(String text) async {
    try {
      setState(() => _isSpeaking = true);
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  void _onWordTapped(String word) {
    if (_isRoundPassed || _isFinishedAll) return;
    final round = _rounds[_currentIndex];
    final expectedTokens = round.negativeSentence.split(' ');
    final nextTargetIndex = _assembledWords.length;

    if (nextTargetIndex >= expectedTokens.length) return;

    final targetExpectedWord = expectedTokens[nextTargetIndex];

    if (word == targetExpectedWord) {
      // Correct!
      PocketGameSfx.instance.playSnapCorrect();
      setState(() {
        _assembledWords.add(word);
        _activeWordBank.remove(word);
      });

      if (_assembledWords.length == expectedTokens.length) {
        _onRoundCompleted();
      }
    } else {
      // Incorrect! Trigger haptic vibration & shake animation
      PocketGameSfx.instance.playErrorBuzz();
      HapticFeedback.heavyImpact();
      setState(() {
        _shakingWord = word;
      });
      _shakeAnimController.forward(from: 0.0).then((_) {
        if (mounted) setState(() => _shakingWord = null);
      });
    }
  }

  void _onRoundCompleted() {
    setState(() => _isRoundPassed = true);
    PocketGameSfx.instance.playVictory();
    final round = _rounds[_currentIndex];
    _speak(round.negativeSentence);

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      if (_currentIndex + 1 < _rounds.length) {
        setState(() {
          _currentIndex++;
        });
        _loadRound(_currentIndex);
      } else {
        _finishAllRounds();
      }
    });
  }

  Future<void> _finishAllRounds() async {
    setState(() => _isFinishedAll = true);
    final uid = widget.userId ?? SupaFlow.client.auth.currentUser?.id;
    final prefs = await SharedPreferences.getInstance();

    final userKey = uid != null ? 'pocket_day_${uid}_${widget.day}_step_10_done' : null;
    if (userKey != null) await prefs.setBool(userKey, true);
    await prefs.setBool('pocket_day_guest_${widget.day}_step_10_done', true);

    await PocketFortressDefenseService.recordTrainingPoints(35, uid);
    widget.onStepFinished?.call(10);

    if (!mounted) return;
    _showCompletionModal();
  }

  void _showCompletionModal() {
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
            border: Border.all(color: const Color(0xFFA855F7), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA855F7).withValues(alpha: 0.4),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🌟', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'NEGATIVE SENTENCES MASTERED! 🔄',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You transformed 6 statements into flawless negative sentences with zero grammar mistakes!',
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
                      '+35 POCKET SCORE AWARDED!',
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
                    backgroundColor: const Color(0xFFA855F7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'PROCEED TO STEP 11 ➔',
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
    _shakeAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final round = (_currentIndex < _rounds.length) ? _rounds[_currentIndex] : _rounds.last;

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
                const Text('🔄', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  'Negative Sentence',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              'Step 10 • Day ${widget.day}',
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
              border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎯', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  '${_currentIndex + 1} / ${_rounds.length}',
                  style: GoogleFonts.robotoMono(
                    color: const Color(0xFFA855F7),
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
              value: (_currentIndex + 1) / _rounds.length,
              minHeight: 4,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFA855F7)),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Target Card: Positive sentence to transform
                    _buildPositivePromptCard(round),

                    const SizedBox(height: 18),

                    // Transformation Goal & Rule Capsule
                    _buildRulePill(round),

                    const SizedBox(height: 20),

                    // Assembled Negative Sentence Bar
                    _buildAssembledSentenceBar(round),

                    const SizedBox(height: 24),

                    // Word Bank Chips Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'WORD BANK • TAP IN NEGATIVE ORDER:',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (_assembledWords.isNotEmpty && !_isRoundPassed)
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                final removed = _assembledWords.removeLast();
                                _activeWordBank.add(removed);
                              });
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.undo_rounded, size: 14, color: Colors.white60),
                                const SizedBox(width: 4),
                                Text(
                                  'Undo',
                                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Word Bank Touch Chips
                    _buildWordBankWrap(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositivePromptCard(NegativeSentenceRound round) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131D2D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.6), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'POSITIVE STATEMENT',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF60A5FA),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _speak(round.positiveSentence),
                child: Icon(
                  _isSpeaking ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                  color: const Color(0xFF60A5FA),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            round.positiveSentence,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            round.positiveSentenceMl,
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulePill(NegativeSentenceRound round) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.4), width: 1.0),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  round.ruleTipEn,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFE9D5FF),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  round.ruleTipMl,
                  style: GoogleFonts.inter(
                    color: Colors.white60,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssembledSentenceBar(NegativeSentenceRound round) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 68),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isRoundPassed
              ? const Color(0xFF10B981)
              : const Color(0xFFA855F7).withValues(alpha: 0.7),
          width: 1.6,
        ),
        boxShadow: [
          if (_isRoundPassed)
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.4),
              blurRadius: 12,
            ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (_assembledWords.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Tap words in the bank to form the negative sentence...',
                style: GoogleFonts.inter(color: Colors.white30, fontSize: 13),
              ),
            )
          else
            for (final w in _assembledWords)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: (w.toLowerCase() == 'not' ||
                            w.toLowerCase() == 'cannot' ||
                            w.toLowerCase() == 'never')
                        ? [const Color(0xFFDC2626), const Color(0xFFEF4444)]
                        : [const Color(0xFF6B21A8), const Color(0xFF9333EA)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (w.toLowerCase() == 'not' || w.toLowerCase() == 'cannot')
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFFE9D5FF),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  w,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildWordBankWrap() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _activeWordBank.map((word) {
        final isShaking = _shakingWord == word;

        Widget chip = GestureDetector(
          onTap: () => _onWordTapped(word),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isShaking ? const Color(0xFF7F1D1D) : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isShaking ? const Color(0xFFEF4444) : const Color(0xFF475569),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isShaking ? const Color(0xFFEF4444) : Colors.black)
                      .withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              word,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );

        if (isShaking) {
          chip = AnimatedBuilder(
            animation: _shakeAnimController,
            builder: (context, child) {
              final offset = math.sin(_shakeAnimController.value * math.pi * 5) * 8.0;
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: chip,
          );
        }

        return chip;
      }).toList(),
    );
  }
}
