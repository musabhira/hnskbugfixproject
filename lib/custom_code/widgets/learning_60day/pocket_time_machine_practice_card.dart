import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'pocket_pronunciation_evaluator.dart';
import 'pocket_time_machine_trainer_modal.dart';

/// Verb drill item for Time Machine Practice Card
class TimeMachineCardItem {
  final String baseVerb;
  final String meaningMl;
  final String pastForm;
  final String presentForm;
  final String futureForm;
  final String pastSentence;
  final String presentSentence;
  final String futureSentence;
  final String trapWarning;

  const TimeMachineCardItem({
    required this.baseVerb,
    required this.meaningMl,
    required this.pastForm,
    required this.presentForm,
    required this.futureForm,
    required this.pastSentence,
    required this.presentSentence,
    required this.futureSentence,
    required this.trapWarning,
  });
}

/// Level 1: 12 Foundational Action Verbs (10-15 items as requested)
const List<TimeMachineCardItem> kLevel1TimeMachineItems = [
  TimeMachineCardItem(
    baseVerb: 'Go',
    meaningMl: 'പോകുക',
    pastForm: 'Went',
    presentForm: 'Go / Goes',
    futureForm: 'Will go',
    pastSentence: 'Yesterday, I went to the market.',
    presentSentence: 'Every day, I go for a walk.',
    futureSentence: 'Tomorrow, I will go to office.',
    trapWarning: '❌ "Did you went?" പറയരുത്! ✅ "Did you go?" എന്ന് പറയുക.',
  ),
  TimeMachineCardItem(
    baseVerb: 'See',
    meaningMl: 'കാണുക',
    pastForm: 'Saw',
    presentForm: 'See / Sees',
    futureForm: 'Will see',
    pastSentence: 'I saw a great movie yesterday.',
    presentSentence: 'I see my friends every weekend.',
    futureSentence: 'I will see you at the meeting.',
    trapWarning: '❌ "Did you saw?" തെറ്റാണ്. ✅ "Did you see?" ശരി.',
  ),
  TimeMachineCardItem(
    baseVerb: 'Do',
    meaningMl: 'ചെയ്യുക',
    pastForm: 'Did',
    presentForm: 'Do / Does',
    futureForm: 'Will do',
    pastSentence: 'I did all my tasks last night.',
    presentSentence: 'I do morning exercise daily.',
    futureSentence: 'I will do my best tomorrow.',
    trapWarning: '❌ "Did you did?" പറയരുത്. ✅ "Did you do?" എന്ന് പറയുക.',
  ),
  TimeMachineCardItem(
    baseVerb: 'Eat',
    meaningMl: 'കഴിക്കുക',
    pastForm: 'Ate',
    presentForm: 'Eat / Eats',
    futureForm: 'Will eat',
    pastSentence: 'I ate a light breakfast today.',
    presentSentence: 'I eat lunch at one PM.',
    futureSentence: 'I will eat dinner after work.',
    trapWarning: '❌ "Did you ate?" പറയരുത്. ✅ "Did you eat?" എന്ന് പറയുക.',
  ),
  TimeMachineCardItem(
    baseVerb: 'Buy',
    meaningMl: 'വാങ്ങുക',
    pastForm: 'Bought',
    presentForm: 'Buy / Buys',
    futureForm: 'Will buy',
    pastSentence: 'I bought a new book yesterday.',
    presentSentence: 'I buy fresh fruits weekly.',
    futureSentence: 'I will buy a laptop next month.',
    trapWarning: '❌ "Did you bought?" പറയരുത്. ✅ "Did you buy?" ശരി.',
  ),
  TimeMachineCardItem(
    baseVerb: 'Tell',
    meaningMl: 'പറയുക',
    pastForm: 'Told',
    presentForm: 'Tell / Tells',
    futureForm: 'Will tell',
    pastSentence: 'She told me the story yesterday.',
    presentSentence: 'I always tell the truth.',
    futureSentence: 'I will tell you the good news.',
    trapWarning: '❌ "Did you told?" തെറ്റാണ്. ✅ "Did you tell?" ശരി.',
  ),
  TimeMachineCardItem(
    baseVerb: 'Take',
    meaningMl: 'എടുക്കുക',
    pastForm: 'Took',
    presentForm: 'Take / Takes',
    futureForm: 'Will take',
    pastSentence: 'It took me thirty minutes.',
    presentSentence: 'I take notes during class.',
    futureSentence: 'I will take immediate action.',
    trapWarning: '❌ "Did you took?" പറയരുത്. ✅ "Did you take?" എന്ന് പറയുക.',
  ),
  TimeMachineCardItem(
    baseVerb: 'Write',
    meaningMl: 'എഴുതുക',
    pastForm: 'Wrote',
    presentForm: 'Write / Writes',
    futureForm: 'Will write',
    pastSentence: 'I wrote an email this morning.',
    presentSentence: 'I write in my journal daily.',
    futureSentence: 'I will write the report tonight.',
    trapWarning: '❌ "Did you wrote?" തെറ്റാണ്. ✅ "Did you write?" ശരി.',
  ),
  TimeMachineCardItem(
    baseVerb: 'Make',
    meaningMl: 'ഉണ്ടാക്കുക',
    pastForm: 'Made',
    presentForm: 'Make / Makes',
    futureForm: 'Will make',
    pastSentence: 'I made fresh coffee for everyone.',
    presentSentence: 'I make a daily to-do list.',
    futureSentence: 'I will make dinner tomorrow.',
    trapWarning: '❌ "Did you made?" തെറ്റാണ്. ✅ "Did you make?" ശരി.',
  ),
  TimeMachineCardItem(
    baseVerb: 'Come',
    meaningMl: 'വരുക',
    pastForm: 'Came',
    presentForm: 'Come / Comes',
    futureForm: 'Will come',
    pastSentence: 'He came to my office yesterday.',
    presentSentence: 'They come here every Friday.',
    futureSentence: 'I will come to your party.',
    trapWarning: '❌ "Did you came?" തെറ്റാണ്. ✅ "Did you come?" ശരി.',
  ),
  TimeMachineCardItem(
    baseVerb: 'Know',
    meaningMl: 'അറിയുക',
    pastForm: 'Knew',
    presentForm: 'Know / Knows',
    futureForm: 'Will know',
    pastSentence: 'I knew the correct answer.',
    presentSentence: 'I know English very well.',
    futureSentence: 'We will know the result soon.',
    trapWarning: '❌ "Did you knew?" പറയരുത്. ✅ "Did you know?" എന്ന് പറയുക.',
  ),
  TimeMachineCardItem(
    baseVerb: 'Think',
    meaningMl: 'ചിന്തിക്കുക',
    pastForm: 'Thought',
    presentForm: 'Think / Thinks',
    futureForm: 'Will think',
    pastSentence: 'I thought about your suggestion.',
    presentSentence: 'I think positive every day.',
    futureSentence: 'I will think about this problem.',
    trapWarning: '❌ "Did you thought?" തെറ്റാണ്. ✅ "Did you think?" ശരി.',
  ),
];

/// Level 2: 12 Intermediate Action Verbs (10-15 items for Level 2)
const List<TimeMachineCardItem> kLevel2TimeMachineItems = [
  TimeMachineCardItem(
    baseVerb: 'Speak',
    meaningMl: 'സംസാരിക്കുക',
    pastForm: 'Spoke',
    presentForm: 'Speak / Speaks',
    futureForm: 'Will speak',
    pastSentence: 'I spoke with my manager yesterday.',
    presentSentence: 'I speak English with confidence.',
    futureSentence: 'I will speak at the conference.',
    trapWarning: '❌ "Did you spoke?" പറയരുത്! ✅ "Did you speak?" ശരി.',
  ),
  TimeMachineCardItem(
    baseVerb: 'Find',
    meaningMl: 'കണ്ടെത്തുക',
    pastForm: 'Found',
    presentForm: 'Find / Finds',
    futureForm: 'Will find',
    pastSentence: 'I found my misplaced keys.',
    presentSentence: 'I find solutions quickly.',
    futureSentence: 'You will find peace here.',
    trapWarning: '❌ "Did you found?" തെറ്റാണ്. ✅ "Did you find?" ശരി.',
  ),
  TimeMachineCardItem(
    baseVerb: 'Give',
    meaningMl: 'നൽകുക',
    pastForm: 'Gave',
    presentForm: 'Give / Gives',
    futureForm: 'Will give',
    pastSentence: 'She gave me an inspiring book.',
    presentSentence: 'I give hundred percent effort.',
    futureSentence: 'I will give you an update.',
    trapWarning: '❌ "Did you gave?" പറയരുത്. ✅ "Did you give?" ശരി.',
  ),
  TimeMachineCardItem(
    baseVerb: 'Bring',
    meaningMl: 'കൊണ്ടുവരിക',
    pastForm: 'Brought',
    presentForm: 'Bring / Brings',
    futureForm: 'Will bring',
    pastSentence: 'He brought lunch for the team.',
    presentSentence: 'I bring water wherever I go.',
    futureSentence: 'I will bring the documents.',
    trapWarning: '❌ "Did you brought?" തെറ്റാണ്. ✅ "Did you bring?" ശരി.',
  ),
  TimeMachineCardItem(
    baseVerb: 'Build',
    meaningMl: 'നിർമ്മിക്കുക',
    pastForm: 'Built',
    presentForm: 'Build / Builds',
    futureForm: 'Will build',
    pastSentence: 'We built a great mobile app.',
    presentSentence: 'I build healthy habits daily.',
    futureSentence: 'We will build a strong future.',
    trapWarning: '❌ "Did you built?" പറയരുത്. ✅ "Did you build?" ശരി.',
  ),
  TimeMachineCardItem(
    baseVerb: 'Leave',
    meaningMl: 'പുറപ്പെടുക / വിടുക',
    pastForm: 'Left',
    presentForm: 'Leave / Leaves',
    futureForm: 'Will leave',
    pastSentence: 'I left the meeting on time.',
    presentSentence: 'I leave home at eight AM.',
    futureSentence: 'The bus will leave in five minutes.',
    trapWarning: '❌ "Did you left?" തെറ്റാണ്. ✅ "Did you leave?" ശരി.',
  ),
  TimeMachineCardItem(
    baseVerb: 'Feel',
    meaningMl: 'തോന്നുക / അനുഭവപ്പെടുക',
    pastForm: 'Felt',
    presentForm: 'Feel / Feels',
    futureForm: 'Will feel',
    pastSentence: 'I felt proud of my progress.',
    presentSentence: 'I feel energetic every morning.',
    futureSentence: 'You will feel much better soon.',
    trapWarning: '❌ "Did you felt?" തെറ്റാണ്. ✅ "Did you feel?" ശരി.',
  ),
  TimeMachineCardItem(
    baseVerb: 'Become',
    meaningMl: 'ആയിത്തീരുക',
    pastForm: 'Became',
    presentForm: 'Become / Becomes',
    futureForm: 'Will become',
    pastSentence: 'He became an expert speaker.',
    presentSentence: 'I become better step by step.',
    futureSentence: 'You will become fluent in English.',
    trapWarning: '❌ "Did you became?" തെറ്റാണ്. ✅ "Did you become?" ശരി.',
  ),
  TimeMachineCardItem(
    baseVerb: 'Begin',
    meaningMl: 'ആരംഭിക്കുക',
    pastForm: 'Began',
    presentForm: 'Begin / Begins',
    futureForm: 'Will begin',
    pastSentence: 'The class began at sharp ten.',
    presentSentence: 'I begin my day with meditation.',
    futureSentence: 'The show will begin soon.',
    trapWarning: '❌ "Did you began?" പറയരുത്. ✅ "Did you begin?" ശരി.',
  ),
  TimeMachineCardItem(
    baseVerb: 'Keep',
    meaningMl: 'സൂക്ഷിക്കുക / തുടരുക',
    pastForm: 'Kept',
    presentForm: 'Keep / Keeps',
    futureForm: 'Will keep',
    pastSentence: 'I kept my promise faithfully.',
    presentSentence: 'I keep learning new vocabulary.',
    futureSentence: 'I will keep trying my best.',
    trapWarning: '❌ "Did you kept?" തെറ്റാണ്. ✅ "Did you keep?" ശരി.',
  ),
  TimeMachineCardItem(
    baseVerb: 'Hold',
    meaningMl: 'പിടിക്കുക / നടത്തുക',
    pastForm: 'Held',
    presentForm: 'Hold / Holds',
    futureForm: 'Will hold',
    pastSentence: 'They held a grand reception.',
    presentSentence: 'I hold myself accountable.',
    futureSentence: 'We will hold an important meeting.',
    trapWarning: '❌ "Did you held?" തെറ്റാണ്. ✅ "Did you hold?" ശരി.',
  ),
  TimeMachineCardItem(
    baseVerb: 'Hear',
    meaningMl: 'കേൾക്കുക',
    pastForm: 'Heard',
    presentForm: 'Hear / Hears',
    futureForm: 'Will hear',
    pastSentence: 'I heard wonderful news yesterday.',
    presentSentence: 'I hear podcasts during my commute.',
    futureSentence: 'You will hear from us tomorrow.',
    trapWarning: '❌ "Did you heard?" തെറ്റാണ്. ✅ "Did you hear?" ശരി.',
  ),
];

/// ⏳ PocketTimeMachinePracticeCard
/// Embedded task card for level missions (Day 1 = Level 1, Day 2 = Level 2, etc.)
/// Includes Past vs Present vs Future switcher, native audio, Say It speech recognition,
/// and instant Speech Accuracy evaluation with percentage, correct/wrong counts, and tip.
class PocketTimeMachinePracticeCard extends StatefulWidget {
  final int day;
  final String selectedLanguage;
  final bool isCompleted;
  final ValueChanged<bool> onCompleted;
  final Function(String text)? onSpeak;
  final String stepNumber;

  const PocketTimeMachinePracticeCard({
    super.key,
    required this.day,
    this.selectedLanguage = 'Malayalam',
    required this.isCompleted,
    required this.onCompleted,
    this.onSpeak,
    this.stepNumber = '4',
  });

  @override
  State<PocketTimeMachinePracticeCard> createState() =>
      _PocketTimeMachinePracticeCardState();
}

class _PocketTimeMachinePracticeCardState
    extends State<PocketTimeMachinePracticeCard>
    with SingleTickerProviderStateMixin {
  late int _selectedLevel;
  int _activeVerbIndex = 0;
  int _selectedTenseIndex = 0; // 0 = Past, 1 = Present, 2 = Future

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isSpeechInitialized = false;
  bool _isListening = false;
  String _recognizedWords = '';
  PronunciationEvaluationResult? _evaluationResult;
  Timer? _listeningTimeoutTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  List<TimeMachineCardItem> get _currentItems {
    return _selectedLevel >= 2 ? kLevel2TimeMachineItems : kLevel1TimeMachineItems;
  }

  @override
  void initState() {
    super.initState();
    // Level 1 for day 1, Level 2 for day 2+, clamp up to 2
    _selectedLevel = widget.day >= 2 ? 2 : 1;
    _initTts();
    _initSpeechRecognizer();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.48);
    } catch (_) {}
  }

  Future<bool> _initSpeechRecognizer() async {
    try {
      _isSpeechInitialized = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening' || status == 'done') {
            if (mounted && _isListening) {
              _stopListening();
            }
          }
        },
        onError: (_) {
          if (mounted && _isListening) {
            _stopListening();
          }
        },
      );
      if (mounted) setState(() {});
      return _isSpeechInitialized;
    } catch (_) {
      _isSpeechInitialized = false;
      return false;
    }
  }

  @override
  void dispose() {
    _listeningTimeoutTimer?.cancel();
    _pulseController.dispose();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  Future<void> _speakText(String text) async {
    HapticFeedback.lightImpact();
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  String _getActiveSentence(TimeMachineCardItem item) {
    if (_selectedTenseIndex == 0) return item.pastSentence;
    if (_selectedTenseIndex == 1) return item.presentSentence;
    return item.futureSentence;
  }

  String _getActiveForm(TimeMachineCardItem item) {
    if (_selectedTenseIndex == 0) return item.pastForm;
    if (_selectedTenseIndex == 1) return item.presentForm;
    return item.futureForm;
  }

  Future<void> _toggleSayIt() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    HapticFeedback.mediumImpact();
    await _tts.stop();

    if (!_isSpeechInitialized) {
      final ok = await _initSpeechRecognizer();
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Microphone access needed for speaking practice.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    }

    setState(() {
      _isListening = true;
      _recognizedWords = '';
      _evaluationResult = null;
    });

    _listeningTimeoutTimer?.cancel();
    _listeningTimeoutTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && _isListening) {
        _stopListening();
      }
    });

    try {
      await _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _recognizedWords = result.recognizedWords;
            });
            if (result.finalResult) {
              _stopListening();
            }
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenFor: const Duration(seconds: 8),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          localeId: 'en_US',
          listenMode: stt.ListenMode.confirmation,
        ),
      );
    } catch (_) {
      _listeningTimeoutTimer?.cancel();
      if (mounted) {
        setState(() => _isListening = false);
      }
    }
  }

  Future<void> _stopListening() async {
    _listeningTimeoutTimer?.cancel();
    try {
      await _speech.stop();
    } catch (_) {}

    if (mounted) {
      setState(() => _isListening = false);
      _evaluateSpoken();
    }
  }

  void _evaluateSpoken() {
    final item = _currentItems[_activeVerbIndex % _currentItems.length];
    final targetSentence = _getActiveSentence(item);

    final eval = PocketPronunciationEvaluator.evaluate(
      targetSentence: targetSentence,
      spokenText: _recognizedWords,
    );

    setState(() {
      _evaluationResult = eval;
    });

    if (eval.accuracyPercentage >= 60) {
      HapticFeedback.heavyImpact();
      if (!widget.isCompleted) {
        widget.onCompleted(true);
      }
    } else {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _currentItems;
    final item = items[_activeVerbIndex % items.length];
    final activeSentence = _getActiveSentence(item);
    final activeForm = _getActiveForm(item);

    Color tenseColor;
    String tenseLabel;
    IconData tenseIcon;

    if (_selectedTenseIndex == 0) {
      tenseColor = const Color(0xFFF59E0B);
      tenseLabel = '⏪ YESTERDAY (PAST)';
      tenseIcon = Icons.history_rounded;
    } else if (_selectedTenseIndex == 1) {
      tenseColor = const Color(0xFF00E5FF);
      tenseLabel = '⏳ TODAY (PRESENT)';
      tenseIcon = Icons.today_rounded;
    } else {
      tenseColor = const Color(0xFF10B981);
      tenseLabel = '⏩ TOMORROW (FUTURE)';
      tenseIcon = Icons.upcoming_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isCompleted
              ? const Color(0xFF10B981).withValues(alpha: 0.6)
              : const Color(0xFFFFD700).withValues(alpha: 0.35),
          width: 1.3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Step Tag, Title & Verify Done
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                ),
                child: Text(
                  'STEP ${widget.stepNumber}',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    const Text('⏳', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'Time Machine Trainer',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Done verification button
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onCompleted(!widget.isCompleted);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.isCompleted
                        ? const Color(0xFF10B981).withValues(alpha: 0.2)
                        : Colors.white10,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: widget.isCompleted
                          ? const Color(0xFF10B981)
                          : Colors.white24,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: widget.isCompleted
                            ? const Color(0xFF10B981)
                            : Colors.white70,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.isCompleted ? 'DONE ✓' : 'MARK DONE',
                        style: GoogleFonts.outfit(
                          color: widget.isCompleted
                              ? const Color(0xFF10B981)
                              : Colors.white70,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Text(
            'Master Past vs Present vs Future without hesitation. Tap Say It to get instant accuracy score!',
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 11,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // 2. Level Selector: Level 1 & Level 2
          Row(
            children: [
              Text(
                'LEVEL:',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              _buildLevelChip(1, 'L1 (12 Verbs)'),
              const SizedBox(width: 6),
              _buildLevelChip(2, 'L2 (12 Verbs)'),
              const Spacer(),
              // Launch full modal button
              InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  PocketTimeMachineTrainerModal.show(
                    context,
                    currentDay: widget.day,
                    onTrainingCompleted: () => widget.onCompleted(true),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.open_in_new_rounded, color: Color(0xFF38BDF8), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'Full Lab',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF38BDF8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 3. Horizontal Verb Carousel (10-15 action verbs)
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final isCur = i == _activeVerbIndex;
                final v = items[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text('${v.baseVerb} (${v.meaningMl})'),
                    selected: isCur,
                    onSelected: (_) => setState(() {
                      _activeVerbIndex = i;
                      _evaluationResult = null;
                      _recognizedWords = '';
                    }),
                    selectedColor: const Color(0xFFFFD700),
                    backgroundColor: const Color(0xFF1C2234),
                    labelStyle: GoogleFonts.outfit(
                      color: isCur ? Colors.black : Colors.white70,
                      fontWeight: isCur ? FontWeight.w900 : FontWeight.w600,
                      fontSize: 11,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // 4. Past vs Present vs Future Switcher
          Row(
            children: [
              _buildTenseTab(0, '⏪ Yesterday', const Color(0xFFF59E0B)),
              const SizedBox(width: 6),
              _buildTenseTab(1, '⏳ Today', const Color(0xFF00E5FF)),
              const SizedBox(width: 6),
              _buildTenseTab(2, '⏩ Tomorrow', const Color(0xFF10B981)),
            ],
          ),
          const SizedBox(height: 12),

          // 5. Active Sentence Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0D111A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: tenseColor.withValues(alpha: 0.45), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(tenseIcon, color: tenseColor, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      tenseLabel,
                      style: GoogleFonts.outfit(
                        color: tenseColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: tenseColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        activeForm.toUpperCase(),
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  activeSentence,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '💡 ${item.trapWarning}',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFFDE68A),
                    fontSize: 10.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 6. Action Buttons: 🔊 Listen Native & 🎤 Say It Aloud
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _speakText(activeSentence),
                  icon: const Icon(Icons.volume_up_rounded, size: 16, color: Color(0xFFFFD700)),
                  label: Text(
                    'Listen 🔊',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFFD700), width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ScaleTransition(
                  scale: _isListening ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                  child: ElevatedButton.icon(
                    onPressed: _toggleSayIt,
                    icon: Icon(
                      _isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      _isListening ? 'Listening...' : 'Say It Aloud 🎙️',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isListening
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFF97316),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 4,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 7. Speech Pronunciation Evaluation Result Card
          if (_evaluationResult != null) ...[
            const SizedBox(height: 14),
            PocketPronunciationResultCard(
              result: _evaluationResult!,
              onListenNative: () => _speakText(activeSentence),
              onRetry: _toggleSayIt,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLevelChip(int level, String label) {
    final isSel = _selectedLevel == level;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedLevel = level;
          _activeVerbIndex = 0;
          _evaluationResult = null;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFFFFD700) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSel ? Colors.black : Colors.white70,
            fontSize: 10.5,
            fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTenseTab(int index, String label, Color color) {
    final isSel = _selectedTenseIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedTenseIndex = index;
            _evaluationResult = null;
            _recognizedWords = '';
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSel ? color.withValues(alpha: 0.22) : const Color(0xFF1C2234),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSel ? color : Colors.white12,
              width: isSel ? 1.3 : 0.8,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: isSel ? Colors.white : Colors.white60,
                fontSize: 11,
                fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
