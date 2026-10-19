import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_speech_normalizer.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_voice_service.dart';
import 'games/meadow_runner_game_page.dart';

/// 💬 Chat message model for Day 2 Step 3 Word & Location Hunt
class Day2Step3ChatMessage {
  final String id;
  final bool isAvatar;
  final String textEn;
  final String? textNative;
  final String? audioText;
  final List<Day2Step3InBubbleOption>? inBubbleOptions;
  final String? speakThisPrompt;
  final Widget? cardContent;
  final bool isVoiceMessage;

  Day2Step3ChatMessage({
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

class Day2Step3InBubbleOption {
  final String labelEn;
  final String labelNative;
  final String icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final bool isHighlightedAnswer;
  final VoidCallback onTap;

  Day2Step3InBubbleOption({
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

/// 🔍 Day 2 Step 3: Conversational Avatar Chat for Letter & Word Hunt (Where I Live & Locations)
///
/// Features addressing user audio directive:
/// 1. Exactly follows Day 1 Step 3 structure: Avatar conversational intro asking if user wants
///    to play in Chat or 2D Meadow Runner game!
/// 2. 100% Unique Day 2 Vocabulary Content (NO duplicates from Day 1).
/// 3. Option button taps submit as User Text Bubbles (isVoiceMessage: false), NOT voice notes.
/// 4. Microphone speaking creates a pure WhatsApp-style voice note bubble with NO transcript text.
/// 5. Dedicated Red SEND button while recording with strict de-duplication guard.
class PocketDay2Step3AvatarChatPage extends StatefulWidget {
  final String? userId;
  final Function(int stepIndex)? onStepFinished;

  const PocketDay2Step3AvatarChatPage({
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
        builder: (_) => PocketDay2Step3AvatarChatPage(
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<PocketDay2Step3AvatarChatPage> createState() =>
      _PocketDay2Step3AvatarChatPageState();
}

class _PocketDay2Step3AvatarChatPageState
    extends State<PocketDay2Step3AvatarChatPage> with TickerProviderStateMixin {
  late final ScrollController _scrollController = ScrollController();
  late final FlutterTts _tts;
  late final stt.SpeechToText _speech;

  late final AnimationController _pulseController;
  late final AnimationController _micWaveController;

  final List<Day2Step3ChatMessage> _messages = [];

  bool _isSpeaking = false;
  bool _isSoundMuted = false;
  bool _isListening = false;
  bool _speechAvailable = false;
  bool _isSubmittingVoice = false;
  String _liveRecordedWords = '';

  String _userName = 'Hira';
  String _currentExpectedVoicePhrase = 'Live';
  int _currentHuntRound = 0; // 0 to 4 for 5 rounds

  /// 🌟 100% Unique Day 2 Location & Living Word Hunt Curriculum
  static const List<Map<String, dynamic>> huntRounds = [
    {
      'target': 'Live',
      'emoji': '🏡',
      'promptEn': 'Find the word: Live 🏡',
      'promptMl': 'Live (താമസിക്കുക) കണ്ടെത്തുക!',
      'options': ['Live 🏡', 'Stay 🏨', 'Come 🚶', 'Reach 🏁'],
      'correct': 'Live',
      'clue': 'To dwell or make your home in a place (താമസിക്കുക)',
    },
    {
      'target': 'Stay',
      'emoji': '🏨',
      'promptEn': 'Find the word: Stay 🏨',
      'promptMl': 'Stay (നിൽക്കുക / താമസിക്കുക) കണ്ടെത്തുക!',
      'options': ['Home 🏠', 'Stay 🏨', 'City 🏙️', 'Street 🛣️'],
      'correct': 'Stay',
      'clue': 'To remain or reside in a place for a period',
    },
    {
      'target': 'Home',
      'emoji': '🏠',
      'promptEn': 'Find the word: Home 🏠',
      'promptMl': 'Home (വീട്) കണ്ടെത്തുക!',
      'options': ['Room 🚪', 'Street 🛣️', 'Home 🏠', 'Village 🌾'],
      'correct': 'Home',
      'clue': 'A cozy place where family lives together (വീട്)',
    },
    {
      'target': 'City',
      'emoji': '🏙️',
      'promptEn': 'Find the word: City 🏙️',
      'promptMl': 'City (നഗരം) കണ്ടെത്തുക!',
      'options': ['City 🏙️', 'Town 🏘️', 'Forest 🌲', 'Lake 🌊'],
      'correct': 'City',
      'clue': 'A large bustling urban center with roads and tall buildings',
    },
    {
      'target': 'Town',
      'emoji': '🏘️',
      'promptEn': 'Find the word: Town 🏘️',
      'promptMl': 'Town (പട്ടണം) കണ്ടെത്തുക!',
      'options': ['Village 🌾', 'Town 🏘️', 'Station 🚉', 'Port ⚓'],
      'correct': 'Town',
      'clue': 'A populated area smaller than a city but larger than a village',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAnimationControllers();
    _initAudioEngines();
    _loadUserData();

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
      await PocketVoiceService.instance.configureOptimalFemaleVoice(_tts);
    } catch (_) {
      try {
        await _tts.setLanguage('en-IN');
        await _tts.setSpeechRate(0.48);
        await _tts.setPitch(1.05);
      } catch (_) {}
    }

    try {
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
    } catch (_) {}
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
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
    // Smooth micro catch-up after layout pass to eliminate sudden jumps
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      final current = _scrollController.position.pixels;
      if ((max - current).abs() > 4) {
        _scrollController.animateTo(
          max,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  // =========================================================================
  // 🔍 CONVERSATIONAL FLOW
  // =========================================================================

  void _startWelcomeHuntFlow() {
    final promptEn =
        'Hi $_userName! Welcome to Day 2 Step 3: Location & Word Hunt! 🔍\n\n'
        'Would you like to hunt living & place words in this chat or explore the open 2D Meadow Runner game? 🌳';
    final promptMl =
        'ഹായ് $_userName! ഡേ 2 സ്റ്റെപ്പ് 3-ലേക്ക് സ്വാഗതം! നമുക്ക് പുതിയ വാക്കുകൾ വേട്ടയാടി കണ്ടെത്താം!\n\n'
        'ഇവിടെ ചാറ്റിൽ കളിക്കണോ അതോ 2D മെഡോ റണ്ണർ ഗെയിമിലേക്ക് പോകണോ? 🌿';

    _currentExpectedVoicePhrase = 'Chat Hunt or Meadow Game';

    setState(() {
      _messages.clear();
      _messages.add(
        Day2Step3ChatMessage(
          id: 'welcome_hunt',
          isAvatar: true,
          textEn: promptEn,
          textNative: promptMl,
          audioText: 'Hi $_userName! Welcome to Day 2 Step 3: Word and Location Hunt! Let\'s find hidden words!',
          speakThisPrompt: 'Choose how to hunt:',
          inBubbleOptions: [
            Day2Step3InBubbleOption(
              labelEn: '🔍 CHAT HUNT CHALLENGE',
              labelNative: 'ഇവിടെ ചാറ്റിൽ കളിക്കാം ⭐',
              icon: '🔍',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFF34D399),
              textColor: Colors.white,
              onTap: () => _handleTextSubmission(
                text: '🔍 I choose Chat Hunt!',
                action: _startChatHuntRound,
              ),
            ),
            Day2Step3InBubbleOption(
              labelEn: '🏃 2D MEADOW RUNNER GAME',
              labelNative: '2D ഗെയിമിൽ ഓടി കണ്ടെത്താം 🌳',
              icon: '🏃',
              isHighlightedAnswer: false,
              backgroundColor: const Color(0xFF1E293B),
              borderColor: const Color(0xFF38BDF8),
              textColor: const Color(0xFFBAE6FD),
              onTap: () => _handleTextSubmission(
                text: '🏃 Let\'s play 2D Meadow Runner!',
                action: _launchMeadowRunnerGame,
              ),
            ),
          ],
        ),
      );
    });

    _speak('Hi $_userName! Welcome to Day 2 Step 3: Word and Location Hunt! Choose how you want to play.');
    _scrollToBottom();
  }

  void _startChatHuntRound() {
    if (_currentHuntRound >= huntRounds.length) {
      _showHuntCompletedDialogue();
      return;
    }

    final roundData = huntRounds[_currentHuntRound];
    final target = roundData['target'] as String;
    final emoji = roundData['emoji'] as String;
    final promptEn = roundData['promptEn'] as String;
    final promptMl = roundData['promptMl'] as String;
    final options = (roundData['options'] as List).cast<String>();
    final correct = roundData['correct'] as String;
    final clue = roundData['clue'] as String;

    _currentExpectedVoicePhrase = target;

    setState(() {
      _messages.add(
        Day2Step3ChatMessage(
          id: 'hunt_round_$_currentHuntRound',
          isAvatar: true,
          textEn: 'Round ${_currentHuntRound + 1} of ${huntRounds.length}:\n$promptEn\n\n💡 Clue: $clue',
          textNative: promptMl,
          audioText: 'Round ${_currentHuntRound + 1}: $promptEn. Clue: $clue',
          cardContent: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF10B981), width: 1.5),
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target Word: $target',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tap the matching choice or speak into mic!',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          speakThisPrompt: 'Tap the correct word:',
          inBubbleOptions: options.map((opt) {
            final isCorrect = opt.toLowerCase().contains(correct.toLowerCase());
            return Day2Step3InBubbleOption(
              labelEn: opt,
              labelNative: isCorrect ? 'ശരിയായ ഉത്തരം' : 'മറ്റൊരു വാക്ക്',
              icon: isCorrect ? '🎯' : '📦',
              isHighlightedAnswer: isCorrect,
              backgroundColor: isCorrect ? const Color(0xFF064E3B) : const Color(0xFF1E293B),
              borderColor: isCorrect ? const Color(0xFF10B981) : Colors.white24,
              textColor: isCorrect ? const Color(0xFF34D399) : Colors.white70,
              onTap: () => _handleTextSubmission(
                text: opt,
                action: () {
                  if (isCorrect) {
                    _onHuntAnswerCorrect(target);
                  } else {
                    _onHuntAnswerWrong(target);
                  }
                },
              ),
            );
          }).toList(),
        ),
      );
    });

    _speak('$promptEn. Tap the correct word.');
    _scrollToBottom();
  }

  void _onHuntAnswerCorrect(String target) {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playCorrectSound();

    setState(() {
      _messages.add(
        Day2Step3ChatMessage(
          id: 'praise_${DateTime.now().millisecondsSinceEpoch}',
          isAvatar: true,
          textEn: 'Spot on! 🎯 You found "$target"!\nAwesome visual memory, $_userName! ⭐',
          textNative: 'കൃത്യമായി കണ്ടെത്തി! ഗംഭീരമായിരിക്കുന്നു! 🌟',
          audioText: 'Spot on! You found $target! Awesome job!',
        ),
      );
      _currentHuntRound++;
    });

    _speak('Spot on! You found $target!');
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      _startChatHuntRound();
    });
  }

  void _onHuntAnswerWrong(String target) {
    HapticFeedback.lightImpact();
    PocketGameAudioService.instance.playIncorrectSound();

    setState(() {
      _messages.add(
        Day2Step3ChatMessage(
          id: 'wrong_${DateTime.now().millisecondsSinceEpoch}',
          isAvatar: true,
          textEn: 'Not quite! Look for "$target" carefully. Try again! 👀',
          textNative: 'ശ്രദ്ധിച്ചു നോക്കൂ, "$target" കണ്ടെത്താം! വീണ്ടും ശ്രമിക്കൂ.',
          audioText: 'Not quite! Look for $target carefully. Try again!',
        ),
      );
    });

    _speak('Not quite! Look for $target carefully.');
    _scrollToBottom();
  }

  void _showHuntCompletedDialogue() {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playVictorySfx();

    setState(() {
      _messages.add(
        Day2Step3ChatMessage(
          id: 'hunt_complete',
          isAvatar: true,
          textEn:
              '🎉 INCREDIBLE JOB, $_userName!\n\n'
              'You successfully hunted all 5 Day 2 Location Words! Your English vocabulary is growing stronger every day! 🚀\n\n'
              '+50 POCKET SCORE AWARDED! 💎',
          textNative:
              'അഭിനന്ദനങ്ങൾ, $_userName! താങ്കൾ ഇന്നത്തെ എല്ലാ വാക്കുകളും വിജയകരമായി കണ്ടെത്തി!\n\n'
              '+50 പോയിന്റ് ലഭിച്ചു! 🌟',
          audioText: 'Incredible job, $_userName! You completed Day 2 Step 3 Word Hunt! 50 points awarded!',
          cardContent: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF065F46), Color(0xFF047857)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
            ),
            child: Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STEP 3 COMPLETE! 🌟',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Day 2 Step 4: Spoken English is ready to open!',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          inBubbleOptions: [
            Day2Step3InBubbleOption(
              labelEn: 'Step 4: Spoken English ➔',
              labelNative: 'സ്റ്റെപ്പ് 4: സ്പോക്കൺ ഇംഗ്ലീഷ്',
              icon: '🎙️',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF10B981),
              borderColor: const Color(0xFFFFD700),
              textColor: Colors.black,
              onTap: () => _handleTextSubmission(
                text: 'Step 4: Spoken English ➔',
                action: _completeStep3,
              ),
            ),
          ],
        ),
      );
    });

    _speak('Outstanding, $_userName! You completed Day 2 Step 3! Ready for Spoken English!');
    _scrollToBottom();
  }

  Future<void> _launchMeadowRunnerGame() async {
    HapticFeedback.heavyImpact();
    await _tts.stop();

    final roundsData = [
      {"round": 1, "target": "Live", "prompt": {"en": "Find the word: Live 🏡", "ml": "Live കണ്ടെത്തുക"}, "options": ["Stay", "Live", "Come", "Reach"], "correct": "Live"},
      {"round": 2, "target": "Stay", "prompt": {"en": "Find the word: Stay 🏨", "ml": "Stay കണ്ടെത്തുക"}, "options": ["Home", "Stay", "City", "Town"], "correct": "Stay"},
      {"round": 3, "target": "Home", "prompt": {"en": "Find the word: Home 🏠", "ml": "Home കണ്ടെത്തുക"}, "options": ["Room", "Street", "Home", "Village"], "correct": "Home"},
      {"round": 4, "target": "City", "prompt": {"en": "Find the word: City 🏙️", "ml": "City കണ്ടെത്തുക"}, "options": ["City", "Town", "Park", "House"], "correct": "City"},
      {"round": 5, "target": "Town", "prompt": {"en": "Find the word: Town 🏘️", "ml": "Town കണ്ടെത്തുക"}, "options": ["Village", "Town", "City", "Street"], "correct": "Town"},
    ];

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: const Color(0xFF0A1118),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0F172A),
            title: Text('🌳 Meadow Hunt Quest • Day 2', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
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

  Future<void> _completeStep3() async {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playCoinSound();

    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = widget.userId ?? 'guest';
      await prefs.setBool('pocket_day_${uid}_2_step_3_done', true);
    } catch (_) {}

    if (widget.onStepFinished != null) {
      widget.onStepFinished!(3);
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  /// Handles voice recording submission (creates a pure WhatsApp-style voice note bubble)
  void _handleVoiceSubmission({
    required String voiceText,
    required VoidCallback action,
  }) {
    HapticFeedback.mediumImpact();
    PocketGameAudioService.instance.playCoinSound();

    setState(() {
      _messages.add(
        Day2Step3ChatMessage(
          id: 'user_voice_${DateTime.now().millisecondsSinceEpoch}',
          isAvatar: false,
          textEn: voiceText,
          isVoiceMessage: true,
        ),
      );
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      action();
    });
  }

  /// Handles text button selection submission (creates a clean USER TEXT message bubble)
  void _handleTextSubmission({
    required String text,
    required VoidCallback action,
  }) {
    HapticFeedback.mediumImpact();

    setState(() {
      _messages.add(
        Day2Step3ChatMessage(
          id: 'user_text_${DateTime.now().millisecondsSinceEpoch}',
          isAvatar: false,
          textEn: text,
          isVoiceMessage: false,
        ),
      );
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      action();
    });
  }

  void _onConfirmAndSendVoice() async {
    if (_isSubmittingVoice) return;
    _isSubmittingVoice = true;

    HapticFeedback.mediumImpact();
    try {
      if (_speechAvailable) await _speech.stop();
    } catch (_) {}

    final raw = _liveRecordedWords.trim();
    if (raw.isEmpty) {
      _isSubmittingVoice = false;
      setState(() => _isListening = false);
      _speak('I could not hear you clearly. Tap the mic and speak aloud.');
      return;
    }

    final normalized = PocketSpeechNormalizer.normalize(raw);
    final finalVoiceText = normalized.isNotEmpty ? normalized : raw;

    setState(() {
      _isListening = false;
    });

    _handleVoiceSubmission(
      voiceText: finalVoiceText,
      action: () {
        _isSubmittingVoice = false;
        final target = huntRounds[_currentHuntRound]['target'] as String;
        final isMatch = PocketSpeechNormalizer.isMatch(
          spokenText: finalVoiceText,
          targetSentence: target,
          thresholdPercentage: 40,
        );
        if (isMatch) {
          _onHuntAnswerCorrect(target);
        } else {
          _onHuntAnswerWrong(target);
        }
      },
    );
  }

  Future<void> _startListening() async {
    HapticFeedback.heavyImpact();

    if (_isListening) {
      _onConfirmAndSendVoice();
      return;
    }

    _liveRecordedWords = '';
    setState(() => _isListening = true);

    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    if (isMobile && _speechAvailable) {
      try {
        await _speech.listen(
          onResult: (result) {
            final words = result.recognizedWords.trim();
            if (words.isNotEmpty && mounted) {
              setState(() {
                _liveRecordedWords = words;
              });
            }
          },
          listenOptions: stt.SpeechListenOptions(
            listenFor: const Duration(seconds: 15),
            pauseFor: const Duration(seconds: 3),
            partialResults: true,
            listenMode: stt.ListenMode.confirmation,
            cancelOnError: true,
          ),
        );
      } catch (_) {
        if (mounted && _liveRecordedWords.isEmpty) {
          _liveRecordedWords = _currentExpectedVoicePhrase;
        }
      }
    } else {
      if (mounted && _liveRecordedWords.isEmpty) {
        _liveRecordedWords = _currentExpectedVoicePhrase;
      }
    }
  }

  // =========================================================================
  // 🎨 BUILD UI
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
                ),
                border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
              ),
              child: Center(
                child: Text(_isSpeaking ? '🗣️' : '🐱', style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CyberCat • Step 3',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Day 2: Location & Word Hunt 🔍',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF38BDF8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSoundMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: _isSoundMuted ? Colors.redAccent : const Color(0xFF38BDF8),
            ),
            onPressed: () {
              setState(() {
                _isSoundMuted = !_isSoundMuted;
                if (_isSoundMuted) _tts.stop();
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildChatMessage(msg);
                },
              ),
            ),

            // Bottom Speaking Input Section
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessage(Day2Step3ChatMessage msg) {
    if (!msg.isAvatar) {
      if (!msg.isVoiceMessage) {
        // Clean User Text Message Bubble
        return Padding(
          padding: const EdgeInsets.only(bottom: 14, left: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF047857), Color(0xFF065F46)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(4),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    border: Border.all(
                      color: const Color(0xFF34D399).withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    msg.textEn,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                ),
                child: const Center(
                  child: Text('👤', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      }

      // Pure WhatsApp style voice note bubble
      return Padding(
        padding: const EdgeInsets.only(bottom: 14, left: 36),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF065F46), Color(0xFF047857)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(6),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border.all(
                    color: const Color(0xFF34D399).withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _speak(msg.textEn);
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF10B981),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            18,
                            (barIdx) {
                              final heights = [6, 12, 18, 14, 8, 16, 22, 12, 18, 10, 16, 20, 14, 8, 18, 12, 16, 8];
                              final h = heights[barIdx % heights.length].toDouble();
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 1.2),
                                width: 2.8,
                                height: h,
                                decoration: BoxDecoration(
                                  color: barIdx < 10 ? const Color(0xFF34D399) : Colors.white38,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '0:02',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '• Voice Note',
                              style: TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
              ),
              child: const Center(
                child: Text('👤', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      );
    }

    // Avatar bubble with in-bubble options
    return Container(
      margin: const EdgeInsets.only(bottom: 18, right: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF1E293B),
            ),
            child: const Center(
              child: Text('🐱', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF131D2D),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(color: Colors.white12),
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
                      height: 1.45,
                    ),
                  ),
                  if (msg.textNative != null && msg.textNative!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      msg.textNative!,
                      style: GoogleFonts.notoSansMalayalam(
                        color: const Color(0xFF94A3B8),
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (msg.cardContent != null) ...[
                    const SizedBox(height: 10),
                    msg.cardContent!,
                  ],
                  if (msg.inBubbleOptions != null && msg.inBubbleOptions!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white12, height: 1),
                    const SizedBox(height: 10),
                    if (msg.speakThisPrompt != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          msg.speakThisPrompt!,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ...msg.inBubbleOptions!.map((opt) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: opt.onTap,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: opt.backgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: opt.borderColor,
                                width: opt.isHighlightedAnswer ? 1.6 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(opt.icon, style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        opt.labelEn,
                                        style: GoogleFonts.outfit(
                                          color: opt.textColor,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (opt.labelNative.isNotEmpty)
                                        Text(
                                          opt.labelNative,
                                          style: GoogleFonts.notoSansMalayalam(
                                            color: Colors.white60,
                                            fontSize: 11,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isListening ? 'RECORDING VOICE...' : '🎙️ VOCABULARY HUNT',
                  style: GoogleFonts.inter(
                    color: _isListening ? const Color(0xFFF87171) : const Color(0xFFFFD700),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isListening
                      ? 'Listening... Tap SEND when finished 🎙️'
                      : 'Tap mic below to speak your answer',
                  style: GoogleFonts.outfit(
                    color: _isListening ? Colors.white : Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Action button: Mic or Red Send Button
          GestureDetector(
            onTap: _isListening ? _onConfirmAndSendVoice : _startListening,
            child: AnimatedBuilder(
              animation: _micWaveController,
              builder: (context, child) {
                if (_isListening) {
                  return Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                      ),
                      border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(
                            alpha: 0.4 + (_micWaveController.value * 0.3),
                          ),
                          blurRadius: 12 + (_micWaveController.value * 8),
                          spreadRadius: _micWaveController.value * 3,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'SEND',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(
                          alpha: 0.3 + (_micWaveController.value * 0.3),
                        ),
                        blurRadius: 10 + (_micWaveController.value * 8),
                        spreadRadius: _micWaveController.value * 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
