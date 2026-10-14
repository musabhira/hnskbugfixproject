import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_voice_service.dart';
import 'pocket_pronunciation_evaluator.dart';
import 'games/pocket_vocab_open_world_drive_page.dart';
import 'pocket_fortress_defense_service.dart';

/// 💬 Chat Message Model for Step 2 Vocabulary
class Step2ChatMessage {
  final String id;
  final bool isAvatar;
  final String textEn;
  final String textNative;
  final String? audioText;
  final Widget? cardContent;
  final List<Step2InBubbleOption>? inBubbleOptions;
  final String? speakThisPrompt;
  final bool isVoiceMessage;
  final DateTime timestamp;

  Step2ChatMessage({
    required this.id,
    required this.isAvatar,
    required this.textEn,
    this.textNative = '',
    this.audioText,
    this.cardContent,
    this.inBubbleOptions,
    this.speakThisPrompt,
    this.isVoiceMessage = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// 🔘 In-Bubble Option Button
class Step2InBubbleOption {
  final String labelEn;
  final String labelNative;
  final String? icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final bool isHighlightedAnswer;
  final VoidCallback onTap;

  const Step2InBubbleOption({
    required this.labelEn,
    this.labelNative = '',
    this.icon,
    this.backgroundColor = const Color(0xFF1E293B),
    this.borderColor = const Color(0xFF38BDF8),
    this.textColor = Colors.white,
    this.isHighlightedAnswer = false,
    required this.onTap,
  });
}

/// 🐱 Step 2: Voice-First Conversational Avatar Chat for Everyday Vocabulary (20 Words)
class PocketDay1Step2AvatarChatPage extends StatefulWidget {
  final String? userId;
  final Function(int stepIndex)? onStepFinished;

  const PocketDay1Step2AvatarChatPage({
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
        builder: (_) => PocketDay1Step2AvatarChatPage(
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<PocketDay1Step2AvatarChatPage> createState() =>
      _PocketDay1Step2AvatarChatPageState();
}

class _PocketDay1Step2AvatarChatPageState
    extends State<PocketDay1Step2AvatarChatPage> with TickerProviderStateMixin {
  late final ScrollController _scrollController = ScrollController();
  late final FlutterTts _tts;
  late final stt.SpeechToText _speech;

  late final AnimationController _pulseController;
  late final AnimationController _micWaveController;
  late final AnimationController _cardFloatController;

  final List<Step2ChatMessage> _messages = [];

  bool _isSpeaking = false;
  bool _isSoundMuted = false;
  bool _isListening = false;
  bool _speechAvailable = false;

  String _userName = 'Hira';
  String _currentExpectedVoicePhrase = 'Yes';
  int _currentWordIndex = 0; // 0 to 19 for 20 words

  // 🎮 Word Game State
  final Set<String> _masteredWords = {};
  String? _lastMasteredWord;

  // 📚 20 Essential Everyday Beginner Words for Day 1
  static const List<Map<String, dynamic>> vocab20Words = [
    {
      'word': 'Book',
      'meaningEn': 'Written pages to read',
      'meaningMl': 'പുസ്തകം',
      'emoji': '📖',
      'sentence': 'This is a book.',
      'sentenceMl': 'ഇത് ഒരു പുസ്തകമാണ്.',
      'exampleEn': 'This is a book.',
      'exampleMl': 'ഇത് ഒരു പുസ്തകമാണ്.',
    },
    {
      'word': 'Car',
      'meaningEn': 'A vehicle with four wheels',
      'meaningMl': 'കാർ',
      'emoji': '🚗',
      'sentence': 'This is a car.',
      'sentenceMl': 'ഇത് ഒരു കാറാണ്.',
      'exampleEn': 'This is a car.',
      'exampleMl': 'ഇത് ഒരു കാറാണ്.',
    },
    {
      'word': 'Water',
      'meaningEn': 'Drinkable clear liquid',
      'meaningMl': 'വെള്ളം',
      'emoji': '💧',
      'sentence': 'I drink water.',
      'sentenceMl': 'ഞാൻ വെള്ളം കുടിക്കുന്നു.',
      'exampleEn': 'I drink water.',
      'exampleMl': 'ഞാൻ വെള്ളം കുടിക്കുന്നു.',
    },
    {
      'word': 'Food',
      'meaningEn': 'Things we eat for energy',
      'meaningMl': 'ഭക്ഷണം',
      'emoji': '🍲',
      'sentence': 'I eat food.',
      'sentenceMl': 'ഞാൻ ഭക്ഷണം കഴിക്കുന്നു.',
      'exampleEn': 'I eat food.',
      'exampleMl': 'ഞാൻ ഭക്ഷണം കഴിക്കുന്നു.',
    },
    {
      'word': 'Home',
      'meaningEn': 'The place where you live',
      'meaningMl': 'വീട്',
      'emoji': '🏠',
      'sentence': 'This is my home.',
      'sentenceMl': 'ഇത് എന്റെ വീടാണ്.',
      'exampleEn': 'This is my home.',
      'exampleMl': 'ഇത് എന്റെ വീടാണ്.',
    },
    {
      'word': 'Friend',
      'meaningEn': 'A companion you like',
      'meaningMl': 'സുഹൃത്ത്',
      'emoji': '🤝',
      'sentence': 'You are my friend.',
      'sentenceMl': 'നീ എന്റെ സുഹൃത്താണ്.',
      'exampleEn': 'You are my friend.',
      'exampleMl': 'നീ എന്റെ സുഹൃത്താണ്.',
    },
    {
      'word': 'Cat',
      'meaningEn': 'A cute pet animal',
      'meaningMl': 'പൂച്ച',
      'emoji': '🐱',
      'sentence': 'I love my cat.',
      'sentenceMl': 'ഞാൻ പൂച്ചയെ ഇഷ്ടപ്പെടുന്നു.',
      'exampleEn': 'I love my cat.',
      'exampleMl': 'ഞാൻ പൂച്ചയെ ഇഷ്ടപ്പെടുന്നു.',
    },
    {
      'word': 'School',
      'meaningEn': 'Place to learn and study',
      'meaningMl': 'സ്കൂൾ',
      'emoji': '🏫',
      'sentence': 'I go to school.',
      'sentenceMl': 'ഞാൻ സ്കൂളിൽ പോകുന്നു.',
      'exampleEn': 'I go to school.',
      'exampleMl': 'ഞാൻ സ്കൂളിൽ പോകുന്നു.',
    },
    {
      'word': 'Tree',
      'meaningEn': 'A plant with green leaves',
      'meaningMl': 'മരം',
      'emoji': '🌳',
      'sentence': 'Look at the tree.',
      'sentenceMl': 'മരത്തിലേക്ക് നോക്കൂ.',
      'exampleEn': 'Look at the tree.',
      'exampleMl': 'മരത്തിലേക്ക് നോക്കൂ.',
    },
    {
      'word': 'Sun',
      'meaningEn': 'Star giving light and warmth',
      'meaningMl': 'സൂര്യൻ',
      'emoji': '☀️',
      'sentence': 'The sun is bright.',
      'sentenceMl': 'സൂര്യൻ തിളങ്ങുന്നു.',
      'exampleEn': 'The sun is bright.',
      'exampleMl': 'സൂര്യൻ തിളങ്ങുന്നു.',
    },
    {
      'word': 'Ball',
      'meaningEn': 'Round toy for playing',
      'meaningMl': 'പന്ത്',
      'emoji': '⚽',
      'sentence': 'I have a ball.',
      'sentenceMl': 'എന്റെ കൈയിൽ പന്തുണ്ട്.',
      'exampleEn': 'I have a ball.',
      'exampleMl': 'എന്റെ കൈയിൽ പന്തുണ്ട്.',
    },
    {
      'word': 'Door',
      'meaningEn': 'Entrance to a room or house',
      'meaningMl': 'വാതിൽ',
      'emoji': '🚪',
      'sentence': 'Open the door.',
      'sentenceMl': 'വാതിൽ തുറക്കൂ.',
      'exampleEn': 'Open the door.',
      'exampleMl': 'വാതിൽ തുറക്കൂ.',
    },
    {
      'word': 'Milk',
      'meaningEn': 'Nutritious white drink',
      'meaningMl': 'പാൽ',
      'emoji': '🥛',
      'sentence': 'I drink milk.',
      'sentenceMl': 'ഞാൻ പാൽ കുടിക്കുന്നു.',
      'exampleEn': 'I drink milk.',
      'exampleMl': 'ഞാൻ പാൽ കുടിക്കുന്നു.',
    },
    {
      'word': 'Apple',
      'meaningEn': 'Sweet red fruit',
      'meaningMl': 'ആപ്പിൾ',
      'emoji': '🍎',
      'sentence': 'I like apple.',
      'sentenceMl': 'എനിക്ക് ആപ്പിൾ ഇഷ്ടമാണ്.',
      'exampleEn': 'I like apple.',
      'exampleMl': 'എനിക്ക് ആപ്പിൾ ഇഷ്ടമാണ്.',
    },
    {
      'word': 'Bird',
      'meaningEn': 'Creature with wings that flies',
      'meaningMl': 'പക്ഷി',
      'emoji': '🐦',
      'sentence': 'The bird flies.',
      'sentenceMl': 'പക്ഷി പറക്കുന്നു.',
      'exampleEn': 'The bird flies.',
      'exampleMl': 'പക്ഷി പറക്കുന്നു.',
    },
    {
      'word': 'Dog',
      'meaningEn': 'Friendly pet animal',
      'meaningMl': 'പട്ടി / നായ',
      'emoji': '🐕',
      'sentence': 'The dog runs.',
      'sentenceMl': 'പട്ടി ഓടുന്നു.',
      'exampleEn': 'The dog runs.',
      'exampleMl': 'പട്ടി ഓടുന്നു.',
    },
    {
      'word': 'Fish',
      'meaningEn': 'Animal living in water',
      'meaningMl': 'മീൻ / മത്സ്യം',
      'emoji': '🐟',
      'sentence': 'The fish swims.',
      'sentenceMl': 'മീൻ നീന്തുന്നു.',
      'exampleEn': 'The fish swims.',
      'exampleMl': 'മീൻ നീന്തുന്നു.',
    },
    {
      'word': 'Clock',
      'meaningEn': 'Instrument showing time',
      'meaningMl': 'ക്ലോക്ക്',
      'emoji': '⏰',
      'sentence': 'Check the clock.',
      'sentenceMl': 'ക്ലോക്ക് നോക്കൂ.',
      'exampleEn': 'Check the clock.',
      'exampleMl': 'ക്ലോക്ക് നോക്കൂ.',
    },
    {
      'word': 'Pen',
      'meaningEn': 'Tool used for writing',
      'meaningMl': 'പേന',
      'emoji': '🖊️',
      'sentence': 'This is a pen.',
      'sentenceMl': 'ഇത് ഒരു പേനയാണ്.',
      'exampleEn': 'This is a pen.',
      'exampleMl': 'ഇത് ഒരു പേനയാണ്.',
    },
    {
      'word': 'Star',
      'meaningEn': 'Twinkling light in the night sky',
      'meaningMl': 'നക്ഷത്രം',
      'emoji': '⭐',
      'sentence': 'See the star.',
      'sentenceMl': 'നക്ഷത്രത്തെ കാണൂ.',
      'exampleEn': 'See the star.',
      'exampleMl': 'നക്ഷത്രത്തെ കാണൂ.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _micWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _cardFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _initUserName();
    _initTts();
    _initSpeechRecognizer();

    // 🎵 User Audio Directive: Ensure background music plays softly on load
    PocketGameAudioService.instance.playAmbientAppTheme();
    PocketGameAudioService.instance.setVolume(0.16);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startWelcomeDiagnosticFlow();
    });
  }

  void _initUserName() {
    final user = SupaFlow.client.auth.currentUser;
    final metaName = user?.userMetadata?['display_name'] ??
        user?.userMetadata?['full_name'];
    if (metaName != null && metaName.toString().trim().isNotEmpty) {
      _userName = metaName.toString().trim();
      return;
    }
    final email = user?.email ?? '';
    if (email.isNotEmpty) {
      final namePart = email.split('@').first;
      if (namePart.isNotEmpty) {
        _userName = namePart[0].toUpperCase() + namePart.substring(1);
        return;
      }
    }
    _userName = 'Hira';
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    try {
      await PocketVoiceService.instance.configureOptimalFemaleVoice(_tts);

      _tts.setStartHandler(() {
        if (mounted) setState(() => _isSpeaking = true);
      });
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
      _tts.setCancelHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
      _tts.setErrorHandler((_) {
        if (mounted) setState(() => _isSpeaking = false);
      });
    } catch (_) {}
  }

  Future<void> _initSpeechRecognizer() async {
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (!isMobile) {
      _speechAvailable = false;
      return;
    }

    try {
      _speech = stt.SpeechToText();
      final available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted && _isListening) {
              setState(() => _isListening = false);
            }
          }
        },
        onError: (_) {
          if (mounted && _isListening) {
            setState(() => _isListening = false);
          }
        },
      );
      if (mounted) setState(() => _speechAvailable = available);
    } catch (_) {
      if (mounted) setState(() => _speechAvailable = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
    _micWaveController.dispose();
    _cardFloatController.dispose();
    _tts.stop();
    try {
      if (_speechAvailable) _speech.stop();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (_isSoundMuted) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void _toggleSpeaker() {
    HapticFeedback.lightImpact();
    setState(() {
      _isSoundMuted = !_isSoundMuted;
    });
    if (_isSoundMuted) {
      _tts.stop();
      _isSpeaking = false;
    } else {
      final lastAvatar = _messages.lastWhere(
        (m) => m.isAvatar && m.audioText != null,
        orElse: () => _messages.first,
      );
      if (lastAvatar.audioText != null) {
        _speak(lastAvatar.audioText!);
      }
    }
  }

  void _stopAndMuteTtsGlobally() {
    HapticFeedback.lightImpact();
    _tts.stop();
    setState(() {
      _isSpeaking = false;
      _isSoundMuted = true;
    });
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🔇 Voice muted for upcoming messages. Tap speaker on any bubble to turn back on.',
          style: GoogleFonts.inter(fontSize: 12),
        ),
        backgroundColor: const Color(0xFF1E293B),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _unmuteAndSpeakBubble(String text) {
    HapticFeedback.lightImpact();
    setState(() {
      _isSoundMuted = false;
    });
    _speak(text);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 260,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  // =========================================================================
  // 🎙️ STEP 2 CONVERSATION FLOW (Vocabulary)
  // =========================================================================

  /// Phase 1: Greeting & Initial Diagnostic
  void _startWelcomeDiagnosticFlow() {
    final promptEn =
        'Hi $_userName! Shall we learn 20 essential everyday English words today? 📚';
    final promptMl =
        'ഹായ് $_userName! നമുക്ക് നിത്യജീവിതത്തിലെ 20 പ്രധാനപ്പെട്ട വാക്കുകൾ പഠിച്ചാലോ?';

    _currentExpectedVoicePhrase = 'Yes';
    _currentWordIndex = 0;

    setState(() {
      _messages.clear();
      _messages.add(
        Step2ChatMessage(
          id: 'welcome_vocab',
          isAvatar: true,
          textEn: promptEn,
          textNative: promptMl,
          audioText:
              'Hi $_userName! Shall we learn 20 essential everyday English words today?',
          speakThisPrompt: 'Speak or Tap the Answer:',
          inBubbleOptions: [
            Step2InBubbleOption(
              labelEn: '✅ YES, LET\'S LEARN WORDS!',
              labelNative: 'പഠിക്കാം! 🌟',
              icon: '✅',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFF34D399),
              textColor: Colors.white,
              onTap: () => _handleVoiceSubmission(
                voiceText: 'Yes',
                action: _onUserWantsToLearnVocabulary,
              ),
            ),
            Step2InBubbleOption(
              labelEn: '⚡ SKIP TO LEVEL 3',
              labelNative: 'അറിയാം (Next Level) ➔',
              icon: '⚡',
              isHighlightedAnswer: false,
              backgroundColor: const Color(0xFF1E293B),
              borderColor: Colors.white24,
              textColor: const Color(0xFFFFD700),
              onTap: () => _handleVoiceSubmission(
                voiceText: 'Skip',
                action: _onUserAlreadyKnowsVocabulary,
              ),
            ),
          ],
        ),
      );
    });

    _speak('Hi $_userName! Shall we learn 20 essential everyday English words today?');
    _scrollToBottom();
  }

  void _onUserAlreadyKnowsVocabulary() {
    final replyEn =
        'Awesome, $_userName! 🎉 You already know basic vocabulary! Step 2 is complete! Let\'s drive to Level 3! 🚗';
    final replyMl =
        'വളരെ നല്ലത്, $_userName! നിങ്ങൾക്ക് വാക്കുകൾ അറിയാവുന്നതിനാൽ Step 2 പൂർത്തിയായി. നമുക്ക് ലെവൽ 3-ലേക്ക് പോകാം!';

    _currentExpectedVoicePhrase = 'Proceed to Level 3';

    setState(() {
      _messages.add(
        Step2ChatMessage(
          id: 'avatar_skip_step2',
          isAvatar: true,
          textEn: replyEn,
          textNative: replyMl,
          audioText:
              'Awesome, $_userName! Step 2 is complete! Let\'s drive to Level 3!',
          speakThisPrompt: 'Tap below to exit & drive to Level 3 🚗',
          inBubbleOptions: [
            Step2InBubbleOption(
              labelEn: '🚗 PROCEED TO LEVEL 3 (NEXT) ➔',
              labelNative: 'ലെവൽ 3-ലേക്ക് ഡ്രൈവ് ചെയ്യാം',
              icon: '🏎️',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFFFFD700),
              textColor: Colors.white,
              onTap: _completeStep2AndDriveToLevel3,
            ),
          ],
        ),
      );
    });

    _speak('Awesome, $_userName! Step 2 is complete! Let\'s drive to Level 3!');
    _scrollToBottom();
  }

  void _onUserWantsToLearnVocabulary() {
    final replyEn =
        'Fantastic, $_userName! Would you like to play an interactive Word Game or practice speaking in chat? 🎮🗣️';
    final replyMl =
        'ഗംഭീരം, $_userName! നമുക്ക് വേഡ് ഗെയിം കളിച്ച് പഠിക്കണോ, അതോ സംസാരിച്ച് പഠിക്കണോ?';

    _currentExpectedVoicePhrase = 'Word Game or Speaking';

    setState(() {
      _messages.add(
        Step2ChatMessage(
          id: 'vocab_mode_choice',
          isAvatar: true,
          textEn: replyEn,
          textNative: replyMl,
          audioText:
              'Fantastic, $_userName! Would you like to play an interactive Word Game, or practice speaking in chat?',
          speakThisPrompt: 'Choose your learning style:',
          inBubbleOptions: [
            Step2InBubbleOption(
              labelEn: '🎮 PLAY WORD GAME',
              labelNative: 'ഗെയിം കളിച്ച് പഠിക്കാം! 🕹️',
              icon: '🎮',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF9333EA),
              borderColor: const Color(0xFFC084FC),
              textColor: Colors.white,
              onTap: () => _handleVoiceSubmission(
                voiceText: 'Game',
                action: _startWordGameMode,
              ),
            ),
            Step2InBubbleOption(
              labelEn: '🗣️ SPEAKING CHAT',
              labelNative: 'സംസാരിച്ചു പഠിക്കാം! 🎙️',
              icon: '🗣️',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF0284C7),
              borderColor: const Color(0xFF38BDF8),
              textColor: Colors.white,
              onTap: () => _handleVoiceSubmission(
                voiceText: 'Speaking',
                action: _startTeachingVocabSequence,
              ),
            ),
          ],
        ),
      );
    });

    _speak('Would you like to play an interactive Word Game, or practice speaking in chat?');
    _scrollToBottom();
  }

  // =========================================================================
  // 🎮 INTERACTIVE WORD GAME MODE (User Audio Directive!)
  // =========================================================================

  void _startWordGameMode() {
    _currentWordIndex = 0;
    _currentExpectedVoicePhrase = 'Drive Quest';

    final replyEn =
        '🚗 Ready for the Open-World Vocabulary Driving Quest, $_userName?\n\n'
        'Tap the button below to launch into the green hills! Drive your sports car, clear checkpoint gates, and speak 20 everyday words to unlock the path! 🌟';
    final replyMl =
        '$_userName, പച്ചപ്പും മലനിരകളും നിറഞ്ഞ ഓപ്പൺ-വേൾഡ് ഡ്രൈവിംഗ് ഗെയിമിലേക്ക് പോകാം!\n\n'
        'താഴെയുള്ള ബട്ടണിൽ ടാപ്പ് ചെയ്യൂ! കാർ ഡ്രൈവ് ചെയ്ത് 20 വാക്കുകൾ സംസാരിച്ച് ചെക്ക്‌പോസ്റ്റുകൾ അൺലോക്ക് ചെയ്യാം! 🚗💨';

    setState(() {
      _messages.add(
        Step2ChatMessage(
          id: 'word_game_open_world_prompt',
          isAvatar: true,
          textEn: replyEn,
          textNative: replyMl,
          audioText:
              'Ready for the Open-World Vocabulary Driving Quest, $_userName? Tap the button below to start driving!',
          cardContent: _buildOpenWorldDriveLaunchCard(),
          speakThisPrompt: 'Tap below to launch Full-Screen Drive Game 🚗',
          inBubbleOptions: [
            Step2InBubbleOption(
              labelEn: '🚀 START OPEN-WORLD DRIVE QUEST 🚗',
              labelNative: 'ഫുൾ-സ്ക്രീൻ ഗെയിം ആരംഭിക്കുക ➔',
              icon: '🏎️',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFFFFD700),
              textColor: Colors.white,
              onTap: _launchOpenWorldDriveGame,
            ),
            Step2InBubbleOption(
              labelEn: '🗣️ SWITCH TO SPEAKING CHAT',
              labelNative: 'സംസാരിച്ചു പഠിക്കുന്നതിലേക്ക് മാറ്റുക',
              icon: '💬',
              isHighlightedAnswer: false,
              backgroundColor: const Color(0xFF1E293B),
              borderColor: const Color(0xFF38BDF8),
              textColor: const Color(0xFF7DD3FC),
              onTap: _startTeachingVocabSequence,
            ),
          ],
        ),
      );
    });

    _speak('Ready for the Open-World Vocabulary Driving Quest, $_userName? Tap the button below to start driving!');
    _scrollToBottom();
  }

  Future<void> _launchOpenWorldDriveGame() async {
    HapticFeedback.heavyImpact();
    await _tts.stop();
    setState(() => _isSpeaking = false);

    await PocketVocabOpenWorldDrivePage.show(
      context,
      userId: widget.userId,
      onCompleted: () {
        if (!mounted) return;
        _showFinalCompletionDialogue();
      },
    );
  }

  Widget _buildOpenWorldDriveLaunchCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF047857).withValues(alpha: 0.35),
            blurRadius: 14,
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
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: const Text('🏎️', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OPEN-WORLD DRIVE QUEST 🌄',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Full-Screen 2D Landscape • 20 Checkpoints',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF34D399),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                _buildDriveFeatureBullet(
                  '🌄',
                  'Lush Green Meadows, Sun, Sky & Trail',
                  'പച്ചപ്പും മലനിരകളും നിറഞ്ഞ മനോഹരമായ ഓപ്പൺ വേൾഡ്',
                ),
                const SizedBox(height: 8),
                _buildDriveFeatureBullet(
                  '🚗',
                  'Dr. Driving Style Controls & Speedometer',
                  'സ്റ്റിയറിംഗ് അമ്പുകൾ, ഗ്യാസ് പെഡൽ, ബ്രേക്ക്',
                ),
                const SizedBox(height: 8),
                _buildDriveFeatureBullet(
                  '🎙️',
                  'Voice Gateway Checkpoints',
                  'ഓരോ ചെക്ക്‌പോസ്റ്റിലും വാക്ക് പറഞ്ഞ് ഗേറ്റ് തുറക്കുക',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _launchOpenWorldDriveGame,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF10B981)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🚀', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    'CLICK TO LAUNCH GAME 🚗',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriveFeatureBullet(String emoji, String titleEn, String titleMl) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 15)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleEn,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                titleMl,
                style: GoogleFonts.inter(
                  color: Colors.white60,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWordGameArenaCard() {
    final words = vocab20Words;
    final cardColors = [
      const Color(0xFF0284C7),
      const Color(0xFF059669),
      const Color(0xFFD97706),
      const Color(0xFF7C3AED),
      const Color(0xFFDB2777),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B132B), Color(0xFF1C2541)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text('🎮', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Everyday Word Quest Arena',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Mastered: ${_masteredWords.length} / 20 Words 🏆',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFFDE047),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: Text(
                  'TAP TO HEAR 🎧',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF34D399),
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Active Word Showcase Banner
          if (_lastMasteredWord != null) ...[
            Builder(builder: (ctx) {
              final active = words.firstWhere(
                (w) => w['word'] == _lastMasteredWord,
                orElse: () => words.first,
              );
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                ),
                child: Row(
                  children: [
                    Text(active['emoji'] ?? '✨', style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🌟 "${active['word']}" • ${active['meaningMl']}',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            active['exampleEn'] ?? '',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded,
                          color: Color(0xFFFFD700), size: 22),
                      onPressed: () => _speak('${active['word']}. ${active['exampleEn']}'),
                    ),
                  ],
                ),
              );
            }),
          ],

          // Responsive Word Cards Grid
          SizedBox(
            height: 320,
            child: AnimatedBuilder(
              animation: _cardFloatController,
              builder: (ctx, _) {
                final screenW = MediaQuery.of(context).size.width;
                final cols = screenW > 380 ? 2 : 2;
                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: words.length,
                  itemBuilder: (c, i) {
                    final item = words[i];
                    final wrd = item['word']?.toString() ?? '';
                    final ml = item['meaningMl']?.toString() ?? '';
                    final em = item['emoji']?.toString() ?? '';
                    final ex = item['exampleEn']?.toString() ?? '';
                    final isDone = _masteredWords.contains(wrd);
                    final color = cardColors[i % cardColors.length];

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        setState(() {
                          _masteredWords.add(wrd);
                          _lastMasteredWord = wrd;
                          _currentExpectedVoicePhrase = wrd;
                        });
                        _speak('$wrd! $ex');

                        if (_masteredWords.length >= 20) {
                          _showFinalCompletionDialogue();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isDone
                              ? const LinearGradient(
                                  colors: [Color(0xFF065F46), Color(0xFF047857)],
                                )
                              : LinearGradient(
                                  colors: [color.withValues(alpha: 0.85), const Color(0xFF1E293B)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDone ? const Color(0xFFFFD700) : Colors.white24,
                            width: isDone ? 1.4 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDone ? const Color(0xFF059669).withValues(alpha: 0.3) : Colors.black26,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(em, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    wrd,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    ml,
                                    style: GoogleFonts.inter(
                                      color: isDone ? const Color(0xFFD1FAE5) : Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (isDone)
                              const Icon(Icons.check_circle_rounded,
                                  color: Color(0xFFFFD700), size: 16),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 🗣️ SPEAKING CHAT MODE (20 Words)
  // =========================================================================

  void _startTeachingVocabSequence() {
    _currentWordIndex = 0;
    _presentWordAtCurrentIndex();
  }

  void _presentWordAtCurrentIndex() {
    if (_currentWordIndex >= vocab20Words.length) {
      _showFinalCompletionDialogue();
      return;
    }

    final item = vocab20Words[_currentWordIndex];
    final word = item['word']?.toString() ?? 'Book';
    final meaningMl = item['meaningMl']?.toString() ?? 'പുസ്തകം';
    final emoji = item['emoji']?.toString() ?? '📖';
    final sentence = item['sentence']?.toString() ?? item['exampleEn']?.toString() ?? 'This is a $word.';
    final sentenceMl = item['sentenceMl']?.toString() ?? item['exampleMl']?.toString() ?? '';

    _currentExpectedVoicePhrase = sentence;

    final replyEn = '$word $emoji ($meaningMl)\nRepeat: "$sentence"';
    final replyMl = sentenceMl.isNotEmpty 
        ? '$word $emoji ($meaningMl)\nഎന്റെ കൂടെ പറയൂ: "$sentence"\n($sentenceMl)'
        : '$word $emoji ($meaningMl)\nഎന്റെ കൂടെ പറയൂ: "$sentence"';

    setState(() {
      _messages.add(
        Step2ChatMessage(
          id: 'teach_word_$word',
          isAvatar: true,
          textEn: replyEn,
          textNative: replyMl,
          audioText: '$word! Repeat after me: $sentence',
          speakThisPrompt: 'Speak into mic or tap below 👇',
          inBubbleOptions: [
            Step2InBubbleOption(
              labelEn: '🎙️ SAY: "$sentence" $emoji',
              labelNative: 'മൈക്കിലൂടെ പറയൂ അല്ലെങ്കിൽ ഇവിടെ ടാപ്പ് ചെയ്യൂ',
              icon: emoji,
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF1E3A8A),
              borderColor: const Color(0xFF38BDF8),
              textColor: const Color(0xFFE0F2FE),
              onTap: () => _handleVoiceSubmission(
                voiceText: '$sentence $emoji',
                action: _advanceToNextWord,
              ),
            ),
            Step2InBubbleOption(
              labelEn: '⚡ SKIP TO LEVEL 3 ➔',
              labelNative: 'നേരിട്ട് ലെവൽ 3-ലേക്ക് പോകാം',
              icon: '⚡',
              isHighlightedAnswer: false,
              backgroundColor: const Color(0xFF1E293B),
              borderColor: Colors.white24,
              textColor: const Color(0xFFFFD700),
              onTap: _completeStep2AndDriveToLevel3,
            ),
          ],
        ),
      );
    });

    _speak('$word! Repeat after me: $sentence');
    _scrollToBottom();
  }

  void _advanceToNextWord() {
    _currentWordIndex++;
    if (_currentWordIndex < vocab20Words.length) {
      _presentWordAtCurrentIndex();
    } else {
      _showFinalCompletionDialogue();
    }
  }

  void _showFinalCompletionDialogue() {
    final replyEn =
        'Congratulations, $_userName! 🏆 You mastered all 20 essential everyday words! Step 2 is completed! Let\'s drive to Level 3! 🚗';
    final replyMl =
        'അഭിനന്ദനങ്ങൾ, $_userName! 🏆 നിങ്ങൾ നിത്യജീവിതത്തിലെ 20 വാക്കുകൾ സംസാരിച്ചു പഠിച്ചു! Step 2 പൂർത്തിയായി. മൂന്നാമത്തെ ലെവലിലേക്ക് വണ്ടി ഓടിച്ചു പോകാം!';

    setState(() {
      _messages.add(
        Step2ChatMessage(
          id: 'avatar_final_vocab_complete',
          isAvatar: true,
          textEn: replyEn,
          textNative: replyMl,
          audioText:
              'Congratulations, $_userName! You completed Step 2! Let\'s drive to Level 3!',
          speakThisPrompt: 'Tap below to exit to mountain map & drive to Level 3 🚗',
          inBubbleOptions: [
            Step2InBubbleOption(
              labelEn: '🚗 DRIVE TO LEVEL 3 (NEXT) ➔',
              labelNative: 'പുറത്തേക്ക് പോയി വണ്ടി ലെവൽ 3-ലേക്ക് ഡ്രൈവ് ചെയ്യും',
              icon: '🏎️',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFFFFD700),
              textColor: Colors.white,
              onTap: _completeStep2AndDriveToLevel3,
            ),
          ],
        ),
      );
    });

    _speak('Congratulations, $_userName! You completed Step 2! Let\'s drive to Level 3!');
    _scrollToBottom();
  }

  void _handleVoiceSubmission({
    required String voiceText,
    required VoidCallback action,
  }) {
    HapticFeedback.mediumImpact();
    PocketGameAudioService.instance.playCoinSound();

    setState(() {
      _messages.add(
        Step2ChatMessage(
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

    setState(() {
      _isListening = true;
    });

    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    if (isMobile && _speechAvailable) {
      try {
        await _speech.listen(
          onResult: (result) {
            if (result.recognizedWords.isNotEmpty) {
              _speech.stop();
              setState(() => _isListening = false);
              _processSpokenText(result.recognizedWords);
            }
          },
          listenOptions: stt.SpeechListenOptions(
            listenFor: const Duration(seconds: 5),
            pauseFor: const Duration(seconds: 2),
            partialResults: false,
            listenMode: stt.ListenMode.confirmation,
          ),
        );
      } catch (_) {
        _simulateVoiceCaptureFallback();
      }
    } else {
      _simulateVoiceCaptureFallback();
    }
  }

  void _simulateVoiceCaptureFallback() {
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => _isListening = false);
      _processSpokenText(_currentExpectedVoicePhrase);
    });
  }

  /// Evaluates learner's spoken input against current word or prompt and gives corrective feedback
  void _processSpokenText(String spokenText) {
    // 1. Initial greeting preference
    if (_messages.length <= 1) {
      final lower = spokenText.toLowerCase();
      if (lower.contains('yes') || lower.contains('learn') || lower.contains('teach') || lower.contains('want')) {
        _handleVoiceSubmission(
          voiceText: spokenText,
          action: _onUserWantsToLearnVocabulary,
        );
      } else if (lower.contains('no') || lower.contains('skip') || lower.contains('next') || lower.contains('already')) {
        _handleVoiceSubmission(
          voiceText: spokenText,
          action: _onUserAlreadyKnowsVocabulary,
        );
      } else {
        _showMisunderstoodDialogue(
          spokenText: spokenText,
          expectedText: 'Yes or No',
          tip: 'Please say "Yes" to learn 20 essential words, or "No" to skip!',
          tipMl: '20 വാക്കുകൾ പഠിക്കണമെങ്കിൽ "Yes" എന്നും, അടുത്തതിലേക്ക് പോകണമെങ്കിൽ "No" എന്നും പറയൂ!',
        );
      }
      return;
    }

    // 2. Choice between Game or Speaking
    if (_currentExpectedVoicePhrase.contains('Word Game or Speaking')) {
      final lower = spokenText.toLowerCase();
      if (lower.contains('game') || lower.contains('drive') || lower.contains('car')) {
        _handleVoiceSubmission(
          voiceText: spokenText,
          action: _startWordGameMode,
        );
      } else if (lower.contains('speak') || lower.contains('chat') || lower.contains('repeat')) {
        _handleVoiceSubmission(
          voiceText: spokenText,
          action: _startTeachingVocabSequence,
        );
      } else {
        _showMisunderstoodDialogue(
          spokenText: spokenText,
          expectedText: 'Game or Speaking',
          tip: 'Say "Game" to play open-world driving, or "Speaking" to practice words in chat!',
          tipMl: '"Game" എന്ന് പറഞ്ഞാൽ ഡ്രൈവിംഗ് ഗെയിം കളിക്കാം, "Speaking" എന്ന് പറഞ്ഞാൽ ചാറ്റിൽ പഠിക്കാം!',
        );
      }
      return;
    }

    // 3. Word repetition drill evaluation
    final evaluation = PocketPronunciationEvaluator.evaluate(
      targetSentence: _currentExpectedVoicePhrase,
      spokenText: spokenText,
    );

    final cleanTarget = _currentExpectedVoicePhrase.toLowerCase().replaceAll(RegExp(r"[^\w'\s]"), '').trim();
    final cleanSpoken = spokenText.toLowerCase().replaceAll(RegExp(r"[^\w'\s]"), '').trim();

    final isMatch = evaluation.accuracyPercentage >= 50 ||
        cleanSpoken.contains(cleanTarget) ||
        cleanTarget.contains(cleanSpoken);

    if (isMatch) {
      _handleVoiceSubmission(
        voiceText: spokenText,
        action: _advanceToNextWord,
      );
    } else {
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playIncorrectSound();

      setState(() {
        _messages.add(
          Step2ChatMessage(
            id: 'user_voice_err_${DateTime.now().millisecondsSinceEpoch}',
            isAvatar: false,
            textEn: spokenText,
            isVoiceMessage: true,
          ),
        );

        final focus = evaluation.focusWords.join(', ');
        _messages.add(
          Step2ChatMessage(
            id: 'correction_${DateTime.now().millisecondsSinceEpoch}',
            isAvatar: true,
            textEn: 'Not quite! You said: "$spokenText"\nExpected: "$_currentExpectedVoicePhrase"${focus.isNotEmpty ? "\n\n💡 Focus on: $focus" : ""}',
            textNative: 'വായന ശരിയായില്ല! നിങ്ങൾ പറഞ്ഞത്: "$spokenText"\nശരിയായത്: "$_currentExpectedVoicePhrase"\nഒന്നുകൂടി മൈക്കിൽ പറഞ്ഞു നോക്കൂ! 🎙️',
            audioText: 'Let\'s try again. Repeat after me: $_currentExpectedVoicePhrase',
            speakThisPrompt: 'Tap mic below to try again 👇',
          ),
        );
      });

      _speak('Let\'s try again. Repeat after me: $_currentExpectedVoicePhrase');
      _scrollToBottom();
    }
  }

  void _showMisunderstoodDialogue({
    required String spokenText,
    required String expectedText,
    required String tip,
    required String tipMl,
  }) {
    HapticFeedback.lightImpact();
    PocketGameAudioService.instance.playIncorrectSound();

    setState(() {
      _messages.add(
        Step2ChatMessage(
          id: 'user_voice_${DateTime.now().millisecondsSinceEpoch}',
          isAvatar: false,
          textEn: spokenText,
          isVoiceMessage: true,
        ),
      );
      _messages.add(
        Step2ChatMessage(
          id: 'clarify_${DateTime.now().millisecondsSinceEpoch}',
          isAvatar: true,
          textEn: 'I heard: "$spokenText"\n$tip',
          textNative: tipMl,
          audioText: tip,
          speakThisPrompt: 'Tap mic or option below to continue 👇',
        ),
      );
    });
    _speak(tip);
    _scrollToBottom();
  }

  VoidCallback _getNextVoiceAction() {
    if (_messages.length <= 1) {
      if (_currentExpectedVoicePhrase.toLowerCase().contains('yes') ||
          _currentExpectedVoicePhrase.toLowerCase().contains('learn')) {
        return _onUserWantsToLearnVocabulary;
      } else {
        return _onUserAlreadyKnowsVocabulary;
      }
    } else if (_currentExpectedVoicePhrase.toLowerCase().contains('game')) {
      return _startWordGameMode;
    } else if (_currentWordIndex < vocab20Words.length) {
      return _advanceToNextWord;
    } else {
      return _showFinalCompletionDialogue;
    }
  }

  Future<void> _completeStep2AndDriveToLevel3() async {
    HapticFeedback.heavyImpact();
    await _tts.stop();
    try {
      if (_speechAvailable) await _speech.stop();
    } catch (_) {}

    final uid = widget.userId ?? SupaFlow.client.auth.currentUser?.id;
    final prefs = await SharedPreferences.getInstance();
    final key = 'pocket_day_${uid ?? "guest"}_1_step_2_done';
    await prefs.setBool(key, true);

    if (uid != null && uid.isNotEmpty) {
      await PocketFortressDefenseService.recordTrainingPoints(30, uid);
    }

    if (mounted) {
      widget.onStepFinished?.call(2);
      Navigator.pop(context);
    }
  }

  // =========================================================================
  // 🎨 UI BUILDERS
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1118),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: SafeArea(child: _buildAppBar()),
      ),
      body: ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 130),
        itemCount: _messages.length,
        itemBuilder: (ctx, index) {
          final msg = _messages[index];
          return _buildChatMessageItem(msg);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildCentralFloatingMic(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: const Border(bottom: BorderSide(color: Colors.white10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _tts.stop();
              try {
                if (_speechAvailable) _speech.stop();
              } catch (_) {}
              Navigator.pop(context);
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1.0),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 10),

          // CyberCat Avatar
          Stack(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isSpeaking
                        ? const Color(0xFF10B981)
                        : const Color(0xFFFFD700),
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isSpeaking
                              ? const Color(0xFF10B981)
                              : const Color(0xFFFFD700))
                          .withValues(alpha: 0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: VectorAvatarWidget(
                    config: VectorAvatarConfig.defaultConfig,
                    size: 38,
                    showAura: false,
                  ),
                ),
              ),
              if (_isSpeaking)
                Positioned(
                  bottom: -1,
                  right: -1,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.volume_up_rounded,
                        size: 9, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'DAY 1 • STEP 2',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Text(
                  'CyberCat AI English Mate 🐱',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // BGM Background Music Mute/Unmute
          ValueListenableBuilder<bool>(
            valueListenable: PocketGameAudioService.instance.isMutedNotifier,
            builder: (context, isBgmMuted, _) {
              return IconButton(
                icon: Icon(
                  isBgmMuted ? Icons.music_off_rounded : Icons.music_note_rounded,
                  color: isBgmMuted ? Colors.white38 : const Color(0xFF38BDF8),
                  size: 21,
                ),
                tooltip: isBgmMuted ? 'Unmute Background Music' : 'Mute Background Music',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  PocketGameAudioService.instance.toggleMute();
                },
              );
            },
          ),

          // Speaker Voice Mute/Unmute
          IconButton(
            icon: Icon(
              _isSoundMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: _isSoundMuted ? Colors.white38 : const Color(0xFFFFD700),
              size: 22,
            ),
            tooltip: _isSoundMuted ? 'Unmute Audio' : 'Mute Audio',
            onPressed: _toggleSpeaker,
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessageItem(Step2ChatMessage msg) {
    if (msg.isAvatar) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VectorAvatarWidget(
              config: VectorAvatarConfig.defaultConfig,
              size: 34,
              showAura: false,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                  border: Border.all(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'CyberCat 🐱',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        if (msg.audioText != null)
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              if (_isSpeaking) {
                                _stopAndMuteTtsGlobally();
                              } else if (_isSoundMuted) {
                                _unmuteAndSpeakBubble(msg.audioText!);
                              } else {
                                _stopAndMuteTtsGlobally();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: _isSpeaking
                                    ? const Color(0xFFEF4444).withValues(alpha: 0.22)
                                    : (_isSoundMuted
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : const Color(0xFF38BDF8).withValues(alpha: 0.18)),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _isSpeaking
                                      ? const Color(0xFFEF4444)
                                      : (_isSoundMuted
                                          ? Colors.white24
                                          : const Color(0xFF38BDF8)),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isSpeaking
                                        ? Icons.stop_circle_rounded
                                        : (_isSoundMuted
                                            ? Icons.volume_off_rounded
                                            : Icons.volume_up_rounded),
                                    color: _isSpeaking
                                        ? const Color(0xFFF87171)
                                        : (_isSoundMuted
                                            ? Colors.white54
                                            : const Color(0xFF38BDF8)),
                                    size: 13,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isSpeaking
                                        ? 'STOP'
                                        : (_isSoundMuted ? 'MUTED' : 'VOICE'),
                                    style: GoogleFonts.outfit(
                                      color: _isSpeaking
                                          ? const Color(0xFFF87171)
                                          : (_isSoundMuted
                                              ? Colors.white54
                                              : const Color(0xFF38BDF8)),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
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
                      msg.textEn,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    if (msg.textNative.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        msg.textNative,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                    if (msg.cardContent != null) ...[
                      const SizedBox(height: 12),
                      msg.cardContent!,
                    ],
                    if (msg.inBubbleOptions != null &&
                        msg.inBubbleOptions!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      const SizedBox(height: 10),
                      if (msg.speakThisPrompt != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            msg.speakThisPrompt!,
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFDE047),
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ...msg.inBubbleOptions!.map((opt) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: opt.backgroundColor,
                              foregroundColor: opt.textColor,
                              elevation: opt.isHighlightedAnswer ? 4 : 0,
                              shadowColor: opt.isHighlightedAnswer
                                  ? opt.borderColor.withValues(alpha: 0.4)
                                  : Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: opt.borderColor,
                                  width: opt.isHighlightedAnswer ? 1.5 : 1.0,
                                ),
                              ),
                            ),
                            onPressed: opt.onTap,
                            child: Row(
                              children: [
                                if (opt.icon != null) ...[
                                  Text(opt.icon!, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        opt.labelEn,
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          color: opt.textColor,
                                        ),
                                      ),
                                      if (opt.labelNative.isNotEmpty)
                                        Text(
                                          opt.labelNative,
                                          style: GoogleFonts.inter(
                                            color: opt.textColor.withValues(alpha: 0.75),
                                            fontSize: 10.5,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded,
                                    size: 13, color: Colors.white70),
                              ],
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
    } else {
      // User message
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (msg.isVoiceMessage)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.mic_rounded, color: Colors.white, size: 16),
                    ),
                  Flexible(
                    child: Text(
                      msg.textEn,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildWordVisualCard({
    required String word,
    required String meaningMl,
    required String emoji,
    required String exampleEn,
    required String exampleMl,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF38BDF8), width: 1.2),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      meaningMl,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF34D399),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700), size: 22),
                onPressed: () => _speak('$word. $exampleEn'),
              ),
            ],
          ),
          if (exampleEn.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Example: "$exampleEn"',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (exampleMl.isNotEmpty)
                    Text(
                      exampleMl,
                      style: GoogleFonts.inter(
                        color: Colors.white60,
                        fontSize: 10.5,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCentralFloatingMic() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _startListeningToCentralMic,
            child: AnimatedBuilder(
              animation: _isListening ? _micWaveController : _pulseController,
              builder: (ctx, child) {
                final scale = _isListening
                    ? 1.0 + (_micWaveController.value * 0.12)
                    : 1.0 + (_pulseController.value * 0.04);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isListening
                            ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                            : [const Color(0xFF0284C7), const Color(0xFF0369A1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: _isListening
                            ? const Color(0xFFFCA5A5)
                            : const Color(0xFF38BDF8),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF0284C7))
                              .withValues(alpha: 0.5),
                          blurRadius: 18,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24, width: 0.8),
            ),
            child: Text(
              _isListening ? 'Listening... Speak now!' : 'Tap mic & speak',
              style: GoogleFonts.outfit(
                color: _isListening ? const Color(0xFFEF4444) : Colors.white70,
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
