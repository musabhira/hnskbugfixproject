import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_speech_normalizer.dart';
import 'games/meadow_runner_game_page.dart';

/// 💬 Chat message model for Step 3 Word & Letter Hunt
class Step3ChatMessage {
  final String id;
  final bool isAvatar;
  final String textEn;
  final String? textNative;
  final String? audioText;
  final List<Step3InBubbleOption>? inBubbleOptions;
  final String? speakThisPrompt;
  final Widget? cardContent;
  final bool isVoiceMessage;

  Step3ChatMessage({
    required this.id,
    required this.isAvatar,
    required this.textEn,
    this.textNative,
    this.audioText,
    this.inBubbleOptions,
    this.speakThisPrompt,
    this.cardContent,
    this.isVoiceMessage = false,
  });
}

class Step3InBubbleOption {
  final String labelEn;
  final String labelNative;
  final String icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final bool isHighlightedAnswer;
  final VoidCallback onTap;

  Step3InBubbleOption({
    required this.labelEn,
    required this.labelNative,
    required this.icon,
    this.backgroundColor = const Color(0xFF0F172A),
    this.borderColor = const Color(0xFF38BDF8),
    this.textColor = Colors.white,
    this.isHighlightedAnswer = false,
    required this.onTap,
  });
}

/// 🔍 Step 3: Conversational Avatar Chat for Letter & Word Hunt
class PocketDay1Step3AvatarChatPage extends StatefulWidget {
  final String? userId;
  final Function(int stepIndex)? onStepFinished;

  const PocketDay1Step3AvatarChatPage({
    super.key,
    this.userId,
    this.onStepFinished,
  });

  static Future<void> show(
    BuildContext context, {
    String? userId,
    Function(int stepIndex)? onStepFinished,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketDay1Step3AvatarChatPage(
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<PocketDay1Step3AvatarChatPage> createState() =>
      _PocketDay1Step3AvatarChatPageState();
}

class _PocketDay1Step3AvatarChatPageState
    extends State<PocketDay1Step3AvatarChatPage> with TickerProviderStateMixin {
  late final ScrollController _scrollController = ScrollController();
  late final FlutterTts _tts;
  late final stt.SpeechToText _speech;

  late final AnimationController _pulseController;
  late final AnimationController _micWaveController;

  final List<Step3ChatMessage> _messages = [];

  bool _isSpeaking = false;
  bool _isSoundMuted = false;
  bool _isListening = false;
  bool _speechAvailable = false;

  String _userName = 'Hira';
  String _currentExpectedVoicePhrase = 'Yes';
  int _currentHuntRound = 0; // 0 to 5 for 6 rounds

  static const List<Map<String, dynamic>> huntRounds = [
    {
      'target': 'A',
      'emoji': '🍎',
      'promptEn': 'Find Letter A! 🍎',
      'promptMl': 'അക്ഷരം A കണ്ടെത്തുക!',
      'options': ['B ⚽', 'A 🍎', 'C 🐱', 'D 🐶'],
      'correct': 'A',
      'clue': 'A for Apple',
    },
    {
      'target': 'Bed',
      'emoji': '🛏️',
      'promptEn': 'Find the word: Bed 🛏️',
      'promptMl': 'Bed (കിടക്ക) കണ്ടെത്തുക!',
      'options': ['Crow 🐦‍⬛', 'Grapes 🍇', 'Bed 🛏️', 'Apple 🍎'],
      'correct': 'Bed',
      'clue': 'A soft place where you sleep tonight',
    },
    {
      'target': 'Grapes',
      'emoji': '🍇',
      'promptEn': 'Find the word: Grapes 🍇',
      'promptMl': 'Grapes (മുന്തിരി) കണ്ടെത്തുക!',
      'options': ['Grapes 🍇', 'Book 📖', 'House 🏡', 'Sun ☀️'],
      'correct': 'Grapes',
      'clue': 'Sweet and juicy green fruit',
    },
    {
      'target': 'Water',
      'emoji': '💧',
      'promptEn': 'Find the word: Water 💧',
      'promptMl': 'Water (വെള്ളം) കണ്ടെത്തുക!',
      'options': ['Milk 🥛', 'Bed 🛏️', 'Water 💧', 'Fish 🐟'],
      'correct': 'Water',
      'clue': 'Clear drink you have when thirsty',
    },
    {
      'target': 'Friend',
      'emoji': '🤝',
      'promptEn': 'Find the word: Friend 🤝',
      'promptMl': 'Friend (സുഹൃത്ത്) കണ്ടെത്തുക!',
      'options': ['Door 🚪', 'Friend 🤝', 'Table 🪵', 'Clock ⏰'],
      'correct': 'Friend',
      'clue': 'Someone you play and talk with',
    },
    {
      'target': 'Crow',
      'emoji': '🐦‍⬛',
      'promptEn': 'Find the word: Crow 🐦‍⬛',
      'promptMl': 'Crow (കാക്ക) കണ്ടെത്തുക!',
      'options': ['Crow 🐦‍⬛', 'Cat 🐱', 'Dog 🐶', 'Bird 🐦'],
      'correct': 'Crow',
      'clue': 'A smart black bird in the sky',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAnimationControllers();
    _initAudioEngines();
    _loadUserData();

    // 🎵 Start pleasant ambient BGM immediately as requested
    PocketGameAudioService.instance.playAmbientAppTheme();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startWelcomeHuntFlow();
    });
  }

  void _initAnimationControllers() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _micWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  Future<void> _initAudioEngines() async {
    _tts = FlutterTts();
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.48);
      await _tts.setPitch(1.05);

      _tts.setStartHandler(() {
        if (mounted) setState(() => _isSpeaking = true);
      });
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
      _tts.setErrorHandler((_) {
        if (mounted) setState(() => _isSpeaking = false);
      });
    } catch (_) {}

    _speech = stt.SpeechToText();
    try {
      _speechAvailable = await _speech.initialize(
        onError: (_) {
          if (mounted) setState(() => _isListening = false);
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
      );
    } catch (_) {
      _speechAvailable = false;
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_display_name') ?? 'Hira';
      if (mounted) {
        setState(() {
          _userName = name;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
    _micWaveController.dispose();
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (_isSoundMuted) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 280,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  // =========================================================================
  // 🔍 CONVERSATIONAL FLOW
  // =========================================================================

  void _startWelcomeHuntFlow() {
    final promptEn =
        'Hi $_userName! Welcome to Step 3: Letter & Word Hunt! 🔍\n\n'
        'Would you like to hunt words in this chat or explore the open 2D Meadow Runner game? 🌳';
    final promptMl =
        'ഹായ് $_userName! സ്റ്റെപ്പ് 3-ലേക്ക് സ്വാഗതം! നമുക്ക് വാക്കുകളും അക്ഷരങ്ങളും വേട്ടയാടി കണ്ടെത്താം!\n\n'
        'ഇവിടെ ചാറ്റിൽ കളിക്കണോ അതോ 2D മെഡോ റണ്ണർ ഗെയിമിലേക്ക് പോകണോ? 🌿';

    _currentExpectedVoicePhrase = 'Chat Hunt or Meadow Game';

    setState(() {
      _messages.clear();
      _messages.add(
        Step3ChatMessage(
          id: 'welcome_hunt',
          isAvatar: true,
          textEn: promptEn,
          textNative: promptMl,
          audioText: 'Hi $_userName! Welcome to Step 3: Letter and Word Hunt! Let\'s find hidden words!',
          speakThisPrompt: 'Choose how to hunt:',
          inBubbleOptions: [
            Step3InBubbleOption(
              labelEn: '🔍 CHAT HUNT CHALLENGE',
              labelNative: 'ചാറ്റിൽ വേട്ടയാടാം! 💬',
              icon: '🔍',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF0284C7),
              borderColor: const Color(0xFF38BDF8),
              textColor: Colors.white,
              onTap: () => _handleVoiceSubmission(
                voiceText: 'Chat Hunt',
                action: _startChatHuntRounds,
              ),
            ),
            Step3InBubbleOption(
              labelEn: '🌳 2D MEADOW RUNNER GAME',
              labelNative: 'മെഡോ ഗെയിം കളിക്കാം! 🕹️',
              icon: '🏃',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFF34D399),
              textColor: Colors.white,
              onTap: () => _handleVoiceSubmission(
                voiceText: 'Meadow Game',
                action: _launchMeadowRunnerGame,
              ),
            ),
          ],
        ),
      );
    });

    _speak('Hi $_userName! Welcome to Step 3: Letter and Word Hunt! Let\'s find hidden words!');
    _scrollToBottom();
  }

  void _startChatHuntRounds() {
    _currentHuntRound = 0;
    _sendNextHuntQuestion();
  }

  void _sendNextHuntQuestion() {
    if (_currentHuntRound >= huntRounds.length) {
      _showHuntCompletedDialogue();
      return;
    }

    final roundData = huntRounds[_currentHuntRound];
    final target = roundData['target'] as String;
    final emoji = roundData['emoji'] as String;
    final promptEn = roundData['promptEn'] as String;
    final promptMl = roundData['promptMl'] as String;
    final clue = roundData['clue'] as String;
    final options = (roundData['options'] as List).cast<String>();
    final correct = roundData['correct'] as String;

    _currentExpectedVoicePhrase = target;

    final questionTextEn =
        '🎯 Round ${_currentHuntRound + 1} of 6:\n$promptEn\nClue: "$clue" $emoji';
    final questionTextMl =
        'റൗണ്ട് ${_currentHuntRound + 1} / 6:\n$promptMl\nസൂചന: $clue';

    setState(() {
      _messages.add(
        Step3ChatMessage(
          id: 'hunt_q_$_currentHuntRound',
          isAvatar: true,
          textEn: questionTextEn,
          textNative: questionTextMl,
          audioText: promptEn,
          speakThisPrompt: 'Speak or Tap the Correct Item: "$target"',
          inBubbleOptions: options.map((opt) {
            final isCorrect = opt.contains(correct);
            return Step3InBubbleOption(
              labelEn: opt,
              labelNative: isCorrect ? 'ഇത് ശരിയാണ്! ✨' : '',
              icon: isCorrect ? '🎯' : '📦',
              isHighlightedAnswer: isCorrect,
              backgroundColor: isCorrect ? const Color(0xFF047857) : const Color(0xFF1E293B),
              borderColor: isCorrect ? const Color(0xFF34D399) : Colors.white24,
              textColor: Colors.white,
              onTap: () {
                _handleVoiceSubmission(
                  voiceText: opt,
                  action: () => _handleHuntAnswer(isCorrect, opt),
                );
              },
            );
          }).toList(),
        ),
      );
    });

    _speak(promptEn);
    _scrollToBottom();
  }

  void _handleHuntAnswer(bool isCorrect, String selectedOption) {
    if (isCorrect) {
      HapticFeedback.mediumImpact();
      PocketGameAudioService.instance.playCoinSound();
      _currentHuntRound++;

      final praiseEn = 'Spot on, $_userName! 🎉 You found $selectedOption!';
      final praiseMl = 'ഗംഭീരം, $_userName! കൃത്യമായി കണ്ടെത്തി!';

      setState(() {
        _messages.add(
          Step3ChatMessage(
            id: 'hunt_correct_$_currentHuntRound',
            isAvatar: true,
            textEn: praiseEn,
            textNative: praiseMl,
            audioText: praiseEn,
          ),
        );
      });

      _speak(praiseEn);
      _scrollToBottom();

      Future.delayed(const Duration(milliseconds: 1100), () {
        if (!mounted) return;
        _sendNextHuntQuestion();
      });
    } else {
      HapticFeedback.lightImpact();
      final retryEn = 'Close! Look at the clue again, $_userName! Let\'s try! 💪';
      final retryMl = 'വീണ്ടും ഒന്നു ശ്രമിച്ച് നോക്കൂ!';

      setState(() {
        _messages.add(
          Step3ChatMessage(
            id: 'hunt_retry_${DateTime.now().millisecondsSinceEpoch}',
            isAvatar: true,
            textEn: retryEn,
            textNative: retryMl,
            audioText: retryEn,
          ),
        );
      });

      _speak(retryEn);
      _scrollToBottom();
    }
  }

  void _showHuntCompletedDialogue() {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playCoinSound();

    final replyEn =
        '🏆 OUTSTANDING, $_userName! You mastered all 6 rounds of Letter & Word Hunt!\n\n'
        'Step 3 is complete! Now let\'s proceed to Step 4: Spoken English Chat! 🎙️';
    final replyMl =
        'അഭിനന്ദനങ്ങൾ, $_userName! സ്റ്റെപ്പ് 3 പൂർത്തിയായി!\n\n'
        'ഇനി നമുക്ക് സ്റ്റെപ്പ് 4: സ്പോക്കൺ ഇംഗ്ലീഷ് ചാറ്റിലേക്ക് കടക്കാം! 🎙️';

    _currentExpectedVoicePhrase = 'Proceed to Step 4';

    setState(() {
      _messages.add(
        Step3ChatMessage(
          id: 'hunt_finish',
          isAvatar: true,
          textEn: replyEn,
          textNative: replyMl,
          audioText: 'Outstanding, $_userName! You completed Step 3! Let\'s go to Step 4 Spoken English!',
          speakThisPrompt: 'Tap below to enter Step 4: Spoken English 🎙️',
          inBubbleOptions: [
            Step3InBubbleOption(
              labelEn: '🎙️ PROCEED TO STEP 4: SPOKEN ENGLISH ➔',
              labelNative: 'സ്റ്റെപ്പ് 4-ലേക്ക് പോകാം',
              icon: '🚀',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFFFFD700),
              textColor: Colors.white,
              onTap: _completeStep3AndProceedToStep4,
            ),
          ],
        ),
      );
    });

    _speak('Outstanding, $_userName! You completed Step 3! Let\'s go to Step 4 Spoken English!');
    _scrollToBottom();
  }

  Future<void> _launchMeadowRunnerGame() async {
    HapticFeedback.heavyImpact();
    await _tts.stop();

    final roundsData = [
      {"round": 1, "target": "A", "prompt": {"en": "Find Letter A 🍎", "ml": "A കണ്ടെത്തുക"}, "options": ["B", "A", "C", "D"], "correct": "A"},
      {"round": 2, "target": "Bed", "prompt": {"en": "Find the word: Bed 🛏️", "ml": "Bed കണ്ടെത്തുക"}, "options": ["Crow", "Grapes", "Bed", "Apple"], "correct": "Bed"},
      {"round": 3, "target": "Crow", "prompt": {"en": "Find the word: Crow 🐦‍⬛", "ml": "Crow കണ്ടെത്തുക"}, "options": ["Water", "Crow", "Dog", "Cat"], "correct": "Crow"},
      {"round": 4, "target": "Grapes", "prompt": {"en": "Find the word: Grapes 🍇", "ml": "Grapes കണ്ടെത്തുക"}, "options": ["Grapes", "Book", "House", "Sun"], "correct": "Grapes"},
      {"round": 5, "target": "Water", "prompt": {"en": "Find the word: Water 💧", "ml": "Water കണ്ടെത്തുക"}, "options": ["Milk", "Bed", "Water", "Fish"], "correct": "Water"},
      {"round": 6, "target": "Friend", "prompt": {"en": "Find the word: Friend 🤝", "ml": "Friend കണ്ടെത്തുക"}, "options": ["Door", "Friend", "Table", "Clock"], "correct": "Friend"},
    ];

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: const Color(0xFF0A1118),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0F172A),
            title: Text('🌳 Meadow Hunt Quest', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: MeadowRunnerGamePage(
            rounds: roundsData,
            initialRound: 0,
            nativeLanguage: 'Malayalam',
            isFullscreen: true,
            onAllCompleted: () {
              Navigator.pop(context);
              _showHuntCompletedDialogue();
            },
          ),
        ),
      ),
    );
  }

  void _completeStep3AndProceedToStep4() {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playCoinSound();

    if (widget.onStepFinished != null) {
      widget.onStepFinished!(3);
    }
    Navigator.pop(context);
  }

  void _handleVoiceSubmission({
    required String voiceText,
    required VoidCallback action,
  }) {
    HapticFeedback.mediumImpact();
    PocketGameAudioService.instance.playCoinSound();

    setState(() {
      _messages.add(
        Step3ChatMessage(
          id: 'user_voice_${DateTime.now().millisecondsSinceEpoch}',
          isAvatar: false,
          textEn: voiceText,
          isVoiceMessage: true,
        ),
      );
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      action();
    });
  }

  Future<void> _startListeningToCentralMic() async {
    HapticFeedback.heavyImpact();

    if (_isListening) {
      if (_speechAvailable) {
        try {
          await _speech.stop();
        } catch (_) {}
      }
      setState(() => _isListening = false);
      return;
    }

    if (!_speechAvailable) {
      _handleVoiceSubmission(
        voiceText: _currentExpectedVoicePhrase,
        action: () {
          if (_currentHuntRound < huntRounds.length) {
            final roundData = huntRounds[_currentHuntRound];
            final options = (roundData['options'] as List).cast<String>();
            final correctOpt = options.firstWhere((o) => o.contains(roundData['correct'] as String), orElse: () => options.first);
            _handleHuntAnswer(true, correctOpt);
          } else {
            _completeStep3AndProceedToStep4();
          }
        },
      );
      return;
    }

    setState(() => _isListening = true);

    try {
      await _speech.listen(
        onResult: (result) {
          final raw = result.recognizedWords.trim();
          final recognized = PocketSpeechNormalizer.normalize(raw);
          if (recognized.isNotEmpty && result.finalResult) {
            setState(() => _isListening = false);
            _handleVoiceSubmission(
              voiceText: recognized.isEmpty ? raw : recognized,
              action: () {
                if (_currentHuntRound < huntRounds.length) {
                  final roundData = huntRounds[_currentHuntRound];
                  final correct = roundData['correct'] as String;
                  final isMatch = PocketSpeechNormalizer.isMatch(
                    spokenText: recognized,
                    targetSentence: correct,
                    thresholdPercentage: 40,
                  ) || recognized.toLowerCase().contains(correct.toLowerCase());
                  _handleHuntAnswer(isMatch, recognized);
                } else {
                  _completeStep3AndProceedToStep4();
                }
              },
            );
          }
        },
      );
    } catch (_) {
      setState(() => _isListening = false);
    }
  }

  // =========================================================================
  // 🎨 UI BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B11),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageItem(_messages[index]);
                },
              ),
            ),
            _buildMinimalFloatingMicBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
            onPressed: () => Navigator.pop(context),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Text('🔍', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'STEP 3: WORD & LETTER HUNT',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'CyberCat Discovery Quest',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // 🎵 BGM Music Toggle (User Audio Directive!)
          ValueListenableBuilder<bool>(
            valueListenable: PocketGameAudioService.instance.isMutedNotifier,
            builder: (context, isMuted, _) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  PocketGameAudioService.instance.toggleMute();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: !isMuted ? const Color(0xFF10B981).withValues(alpha: 0.2) : Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: !isMuted ? const Color(0xFF10B981) : Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        !isMuted ? Icons.music_note_rounded : Icons.music_off_rounded,
                        color: !isMuted ? const Color(0xFF10B981) : Colors.white60,
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        !isMuted ? 'BGM' : 'MUTED',
                        style: GoogleFonts.outfit(
                          color: !isMuted ? const Color(0xFF10B981) : Colors.white60,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: Icon(
              _isSoundMuted
                  ? Icons.volume_off_rounded
                  : (_isSpeaking ? Icons.volume_up_rounded : Icons.volume_up_outlined),
              color: _isSoundMuted ? Colors.white38 : const Color(0xFF38BDF8),
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() {
                _isSoundMuted = !_isSoundMuted;
                if (_isSoundMuted) _tts.stop();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Step3ChatMessage msg) {
    if (msg.isAvatar) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VectorAvatarWidget(
              config: VectorAvatarConfig.defaultConfig,
              size: 38,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.textEn,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                        if (msg.textNative != null && msg.textNative!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            msg.textNative!,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFBAE6FD),
                              fontSize: 12.5,
                              height: 1.3,
                            ),
                          ),
                        ],
                        if (msg.speakThisPrompt != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.touch_app_rounded, color: Color(0xFFFFD700), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                msg.speakThisPrompt!,
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFFD700),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (msg.inBubbleOptions != null && msg.inBubbleOptions!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: msg.inBubbleOptions!.map((opt) {
                        return GestureDetector(
                          onTap: opt.onTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: opt.backgroundColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: opt.borderColor, width: opt.isHighlightedAnswer ? 2 : 1),
                              boxShadow: opt.isHighlightedAnswer
                                  ? [
                                      BoxShadow(
                                        color: opt.borderColor.withValues(alpha: 0.35),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(opt.icon, style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      opt.labelEn,
                                      style: GoogleFonts.outfit(
                                        color: opt.textColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    if (opt.labelNative.isNotEmpty)
                                      Text(
                                        opt.labelNative,
                                        style: GoogleFonts.inter(
                                          color: opt.textColor.withValues(alpha: 0.8),
                                          fontSize: 10,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // 🟢 USER MESSAGE BUBBLE ON RIGHT
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF10B981)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (msg.isVoiceMessage) ...[
                    const Icon(Icons.mic_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      msg.textEn,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('👤', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildMinimalFloatingMicBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Speak or Tap: ',
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
              ),
              Text(
                '"$_currentExpectedVoicePhrase"',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: GestureDetector(
              onTap: _startListeningToCentralMic,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = _isListening ? 1.0 + (_pulseController.value * 0.15) : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isListening
                              ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                              : [const Color(0xFF0284C7), const Color(0xFF0284C7)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening ? Colors.redAccent : const Color(0xFF0284C7))
                                .withValues(alpha: 0.5),
                            blurRadius: 14,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
