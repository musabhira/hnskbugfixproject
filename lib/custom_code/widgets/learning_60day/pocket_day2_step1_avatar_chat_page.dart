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
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_voice_service.dart';
import 'pocket_fortress_defense_service.dart';

/// 💬 Chat Message Model with Embedded In-Bubble Choices & Voice Metadata
class Day2ChatMessage {
  final String id;
  final bool isAvatar;
  final String textEn;
  final String textNative;
  final String? audioText;
  final Widget? cardContent;
  final List<Day2InBubbleOption>? inBubbleOptions;
  final String? speakThisPrompt;
  final bool isVoiceMessage;
  final DateTime timestamp;

  Day2ChatMessage({
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

/// 🔘 In-Bubble Option Button (Positioned strictly inside avatar bubble under divider)
class Day2InBubbleOption {
  final String labelEn;
  final String labelNative;
  final String? icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final bool isHighlightedAnswer;
  final VoidCallback onTap;

  const Day2InBubbleOption({
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

/// 🐱 Day 2 Step 1: Voice-First Conversational Avatar Chat
/// Topic: "Where I Am From & Locations" + "Present State of Being (am / is / are)"
///
/// Follows User Audio Directives:
/// 1. Immediately auto-starts speech on entering Day 2 Step 1.
/// 2. NO Play or Pause button at the top header; ONLY a single Speaker mute/unmute button next to CyberCat's name.
/// 3. In-bubble divider with distinct highlighted answer options below it.
/// 4. Explains am, is, are, live in, stay at with clear examples and Malayalam subtitles.
/// 5. Pronunciation drills with prominent "SPEAK THIS ALOUD 👇" box and centered floating mic button.
/// 6. Cross-platform speech safety for mobile and web/desktop.
class PocketDay2Step1AvatarChatPage extends StatefulWidget {
  final String? userId;
  final Function(int stepIndex)? onStepFinished;

  const PocketDay2Step1AvatarChatPage({
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
        builder: (_) => PocketDay2Step1AvatarChatPage(
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<PocketDay2Step1AvatarChatPage> createState() =>
      _PocketDay2Step1AvatarChatPageState();
}

class _PocketDay2Step1AvatarChatPageState
    extends State<PocketDay2Step1AvatarChatPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final FlutterTts _tts;
  late final stt.SpeechToText _speech;
  late final AnimationController _pulseController;
  late final AnimationController _micWaveController;

  final List<Day2ChatMessage> _messages = [];

  bool _isSpeaking = false;
  bool _isSoundMuted = false;
  bool _isListening = false;
  bool _speechAvailable = false;

  String _userName = 'Learner';
  String _currentExpectedVoicePhrase = 'Yes';
  int _drillIndex = 0;

  // Drills for Day 2
  final List<Map<String, String>> _drills = [
    {
      'en': 'I am from Kerala.',
      'ml': 'ഞാൻ കേരളത്തിൽ നിന്നാണ്.',
      'rule': 'Subject: I -> am',
    },
    {
      'en': 'I live in a beautiful city.',
      'ml': 'ഞാൻ മനോഹരമായ ഒരു നഗരത്തിലാണ് താമസിക്കുന്നത്.',
      'rule': 'Action: live in (നഗരത്തിൽ താമസിക്കുന്നു)',
    },
    {
      'en': 'He is at home right now.',
      'ml': 'അവൻ ഇപ്പോൾ വീട്ടിലുണ്ട്.',
      'rule': 'Subject: He -> is (at home)',
    },
    {
      'en': 'They are in Kochi.',
      'ml': 'അവർ കൊച്ചിയിലാണ്.',
      'rule': 'Subject: They -> are (in location)',
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

    _initUserName();
    _initTts();
    _initSpeechRecognizer();

    // 🎵 Soft background music
    PocketGameAudioService.instance.playAmbientAppTheme();
    PocketGameAudioService.instance.setVolume(0.16);

    // Auto-start speech immediately upon opening Day 2 Step 1
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
  // 🎙️ CONVERSATION FLOW (Day 2: Where I Am From & Locations)
  // =========================================================================

  /// Phase 1: Greeting & Diagnostic Check
  void _startWelcomeDiagnosticFlow() {
    final promptEn =
        'Hi $_userName! Welcome to Day 2! 🌟 Today we learn Where I Am From & Locations: how to use am, is, and are with in and at. Shall we start?';
    final promptMl =
        'ഹായ് $_userName! ഡേ 2 ലേക്ക് സ്വാഗതം! 🌟 നാടും സ്ഥലങ്ങളും വ്യക്തമായി പറയാൻ am, is, are, in, at എന്നിവ എങ്ങനെ ഉപയോഗിക്കാമെന്ന് നമുക്ക് പഠിക്കാം. തുടങ്ങാം അല്ലേ?';

    _currentExpectedVoicePhrase = 'Yes';

    setState(() {
      _messages.clear();
      _messages.add(
        Day2ChatMessage(
          id: 'day2_welcome',
          isAvatar: true,
          textEn: promptEn,
          textNative: promptMl,
          audioText:
              'Hi $_userName! Welcome to Day 2! Today we learn Where I Am From and Locations. Shall we start?',
          speakThisPrompt: 'Speak or Tap to begin:',
          inBubbleOptions: [
            Day2InBubbleOption(
              labelEn: '✅ YES, TEACH ME DAY 2!',
              labelNative: 'പഠിക്കാം! 🌟',
              icon: '✅',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF047857), // Distinct Emerald Green
              borderColor: const Color(0xFF34D399),
              textColor: Colors.white,
              onTap: () => _handleVoiceSubmission(
                voiceText: 'Yes',
                action: _onUserWantsToLearnDay2,
              ),
            ),
            Day2InBubbleOption(
              labelEn: '⚡ I ALREADY KNOW THIS (TEST ME)',
              labelNative: 'അറിയാം (നേരിട്ട് പരീക്ഷിക്കാം) ➔',
              icon: '⚡',
              isHighlightedAnswer: false,
              backgroundColor: const Color(0xFF1E293B),
              borderColor: Colors.white24,
              textColor: const Color(0xFFFFD700),
              onTap: () => _handleVoiceSubmission(
                voiceText: 'Test me',
                action: _startDay2MiniQuiz,
              ),
            ),
          ],
        ),
      );
    });

    _speak('Hi $_userName! Welcome to Day 2! Today we learn Where I Am From and Locations. Shall we start?');
    _scrollToBottom();
  }

  /// Phase 2: Teach Grammar Blueprint & Rules
  void _onUserWantsToLearnDay2() {
    final textEn =
        'Great, $_userName! 🚀 Remember this golden rule:\n\n'
        '• I + am ➔ "I am from Kerala."\n'
        '• He / She / It + is ➔ "He is at home."\n'
        '• We / You / They + are ➔ "They are in Kochi."\n\n'
        '⚠️ Never drop the "to be" verb in English!\n'
        '❌ Don\'t say: "I from Kerala"\n'
        '✅ Always say: "I am from Kerala!"';

    final textMl =
        '$_userName, ഈ മൂന്ന് കാര്യങ്ങൾ എപ്പോഴും ഓർക്കുക:\n\n'
        '• ഞാൻ (I) പറയുമ്പോൾ: I am from Kerala. (am വിട്ടുപോകരുത്!)\n'
        '• അവൻ / അവൾ (He / She) പറയുമ്പോൾ: He is at home.\n'
        '• ഞങ്ങൾ / അവർ (We / They) പറയുമ്പോൾ: They are in Kochi.\n\n'
        'മലയാളത്തിൽ "ഞാൻ നാട്ടിലാണ്" എന്ന് പറയാം. എന്നാൽ ഇംഗ്ലീഷിൽ എപ്പോഴും "I am at home" എന്ന് തന്നെ പറയണം!';

    _currentExpectedVoicePhrase = 'I am from Kerala';

    setState(() {
      _messages.add(
        Day2ChatMessage(
          id: 'day2_rule_card',
          isAvatar: true,
          textEn: textEn,
          textNative: textMl,
          audioText:
              'Remember this golden rule: I am from Kerala. He is at home. They are in Kochi. Never drop am, is, or are!',
          cardContent: _buildBlueprintVisualCard(),
          speakThisPrompt: 'Ready to speak aloud? Tap below! 👇',
          inBubbleOptions: [
            Day2InBubbleOption(
              labelEn: '🗣️ START SPEAKING DRILLS ➔',
              labelNative: 'സംസാരിച്ചു പ്രാക്ടീസ് ചെയ്യാം! 🎙️',
              icon: '🎙️',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFF34D399),
              textColor: Colors.white,
              onTap: () => _handleVoiceSubmission(
                voiceText: 'Start Drills',
                action: _startNextDrill,
              ),
            ),
          ],
        ),
      );
    });

    _speak('Remember this golden rule: I am from Kerala. He is at home. They are in Kochi.');
    _scrollToBottom();
  }

  Widget _buildBlueprintVisualCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌴', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                'DAY 2 SPOKEN BLUEPRINT',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildRuleRow('I + am', '"I am from Kerala."', 'ഞാൻ കേരളത്തിൽ നിന്നാണ്'),
          const Divider(color: Colors.white12, height: 16),
          _buildRuleRow('He / She + is', '"He is at home."', 'അവൻ വീട്ടിലാണ്'),
          const Divider(color: Colors.white12, height: 16),
          _buildRuleRow('We / They + are', '"They are in Kochi."', 'അവർ കൊച്ചിയിലാണ്'),
        ],
      ),
    );
  }

  Widget _buildRuleRow(String subject, String en, String ml) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                subject,
                style: GoogleFonts.firaCode(
                  color: const Color(0xFF7DD3FC),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                en,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            ml,
            style: GoogleFonts.notoSansMalayalam(
              color: Colors.white60,
              fontSize: 11.5,
            ),
          ),
        ),
      ],
    );
  }

  /// Phase 3: Interactive Speaking Drills
  void _startNextDrill() {
    if (_drillIndex >= _drills.length) {
      _startDay2MiniQuiz();
      return;
    }

    final drill = _drills[_drillIndex];
    final target = drill['en']!;
    final ml = drill['ml']!;
    final rule = drill['rule']!;

    _currentExpectedVoicePhrase = target;

    final promptEn =
        'Drill ${_drillIndex + 1} of ${_drills.length}:\n'
        'Speak this sentence aloud into the mic below! 👇\n\n'
        '"$target"';

    final promptMl =
        'പരിശീലനം ${_drillIndex + 1}/${_drills.length}:\n'
        'ഈ വാചകം മൈക്കിലൂടെ ഉറക്കെ പറയൂ! ($ml)';

    setState(() {
      _messages.add(
        Day2ChatMessage(
          id: 'drill_$_drillIndex',
          isAvatar: true,
          textEn: promptEn,
          textNative: promptMl,
          audioText: 'Please say: $target',
          cardContent: _buildDrillCard(target, ml, rule),
          speakThisPrompt: 'SPEAK THIS ALOUD 👇',
          inBubbleOptions: [
            Day2InBubbleOption(
              labelEn: '🗣️ "$target"',
              labelNative: 'ടാപ്പ് ചെയ്ത് പറയാം',
              icon: '🎙️',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFF34D399),
              textColor: Colors.white,
              onTap: () => _handleVoiceSubmission(
                voiceText: target,
                action: _onDrillPassed,
              ),
            ),
          ],
        ),
      );
    });

    _speak('Please say: $target');
    _scrollToBottom();
  }

  Widget _buildDrillCard(String target, String ml, String rule) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '🎯 $rule',
              style: GoogleFonts.inter(
                color: const Color(0xFF34D399),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '"$target"',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            ml,
            style: GoogleFonts.notoSansMalayalam(
              color: const Color(0xFF94A3B8),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _onDrillPassed() {
    HapticFeedback.mediumImpact();
    PocketGameAudioService.instance.playCorrectSound();

    _drillIndex++;
    if (_drillIndex < _drills.length) {
      _startNextDrill();
    } else {
      _startDay2MiniQuiz();
    }
  }

  /// Phase 4: Quick In-Bubble Mini Quiz
  void _startDay2MiniQuiz() {
    final promptEn =
        'Awesome speech work, $_userName! 👏 Let\'s do a quick 2-question quiz to lock in your Day 2 mastery!\n\n'
        'Question 1: Which is the correct way to say "ഞാൻ വീട്ടിലാണ്"?';
    final promptMl =
        'ഗംഭീരം, $_userName! രണ്ട് ചെറിയ ചോദ്യങ്ങൾ കൂടി ചെയ്ത് ഉറപ്പിക്കാം.\n\n'
        'ചോദ്യം 1: "ഞാൻ വീട്ടിലാണ്" എന്ന് എങ്ങനെ പറയും?';

    _currentExpectedVoicePhrase = 'I am at home';

    setState(() {
      _messages.add(
        Day2ChatMessage(
          id: 'day2_q1',
          isAvatar: true,
          textEn: promptEn,
          textNative: promptMl,
          audioText: 'Question 1: How do you say: I am at home?',
          speakThisPrompt: 'Choose the correct answer:',
          inBubbleOptions: [
            Day2InBubbleOption(
              labelEn: '✅ "I am at home."',
              labelNative: 'ശരിയായ ഉത്തരം ⭐',
              icon: '✅',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFF34D399),
              textColor: Colors.white,
              onTap: () => _handleVoiceSubmission(
                voiceText: 'I am at home',
                action: _onQuizQ1Correct,
              ),
            ),
            Day2InBubbleOption(
              labelEn: '❌ "I home."',
              labelNative: 'തെറ്റ് (am ഇല്ല)',
              icon: '❌',
              isHighlightedAnswer: false,
              backgroundColor: const Color(0xFF1E293B),
              borderColor: Colors.white24,
              textColor: Colors.white70,
              onTap: () {
                _speak('Oops! Never drop the verb am. Say: I am at home.');
              },
            ),
          ],
        ),
      );
    });

    _speak('Question 1: How do you say: I am at home?');
    _scrollToBottom();
  }

  void _onQuizQ1Correct() {
    PocketGameAudioService.instance.playCorrectSound();
    HapticFeedback.heavyImpact();

    final promptEn =
        'Spot on! 🎉 Question 2: Fill in the blank:\n\n'
        '"They ___ in Kochi right now."';
    final promptMl =
        'നന്നായി! ചോദ്യം 2: വിട്ടുപോയ വാക്ക് പൂരിപ്പിക്കുക:\n\n'
        '"They ___ in Kochi right now."';

    _currentExpectedVoicePhrase = 'are';

    setState(() {
      _messages.add(
        Day2ChatMessage(
          id: 'day2_q2',
          isAvatar: true,
          textEn: promptEn,
          textNative: promptMl,
          audioText: 'Question 2: They blank in Kochi. Is it are, is, or am?',
          speakThisPrompt: 'Choose the correct word:',
          inBubbleOptions: [
            Day2InBubbleOption(
              labelEn: '✅ "are" (They are in Kochi)',
              labelNative: 'ശരിയായ ഉത്തരം 🌟',
              icon: '✅',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFF34D399),
              textColor: Colors.white,
              onTap: () => _handleVoiceSubmission(
                voiceText: 'are',
                action: _completeStep1Day2,
              ),
            ),
            Day2InBubbleOption(
              labelEn: '❌ "is"',
              labelNative: 'തെറ്റ്',
              icon: '❌',
              isHighlightedAnswer: false,
              backgroundColor: const Color(0xFF1E293B),
              borderColor: Colors.white24,
              textColor: Colors.white70,
              onTap: () {
                _speak('Remember: They takes are, not is!');
              },
            ),
          ],
        ),
      );
    });

    _speak('Question 2: They blank in Kochi. Is it are, or is?');
    _scrollToBottom();
  }

  /// Phase 5: Step 1 Completion & Road Unlock
  Future<void> _completeStep1Day2() async {
    PocketGameAudioService.instance.playVictorySfx();
    HapticFeedback.heavyImpact();

    final uid = widget.userId ?? SupaFlow.client.auth.currentUser?.id;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pocket_day_${uid ?? "guest"}_2_step_1_completed', true);
      await PocketFortressDefenseService.recordTrainingPoints(25, uid);
    } catch (_) {}

    final replyEn =
        'CONGRATULATIONS, $_userName! 🏆🎉\n\n'
        'You have mastered Day 2 Step 1: Where I Am From & Locations!\n'
        '+25 XP & Fortress Defense Shield Points Awarded! 🛡️⚡\n\n'
        'Step 2: Vocabulary Drive is now unlocked on the open road! 🚗💨';

    final replyMl =
        'അഭിനന്ദനങ്ങൾ, $_userName! 🏆\n\n'
        'നിങ്ങൾ ഡേ 2 ലെ Step 1 വിജയകരമായി പൂർത്തിയാക്കി!\n'
        '+25 XP നൽകി. റോഡിലേക്ക് മടങ്ങി Step 2 വൊക്കാബുലറി ഡ്രൈവ് ആരംഭിക്കാം!';

    setState(() {
      _messages.add(
        Day2ChatMessage(
          id: 'day2_completed',
          isAvatar: true,
          textEn: replyEn,
          textNative: replyMl,
          audioText:
              'Congratulations, $_userName! You have mastered Day 2 Step 1. Let us proceed to Step 2!',
          speakThisPrompt: 'Tap below to return to the road: 👇',
          inBubbleOptions: [
            Day2InBubbleOption(
              labelEn: '🚗 PROCEED TO STEP 2: VOCAB DRIVE ➔',
              labelNative: 'റോഡിലേക്ക് മടങ്ങുക ➔',
              icon: '🏎️',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFFFFD700),
              textColor: Colors.white,
              onTap: () {
                widget.onStepFinished?.call(1);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    });

    _speak('Congratulations, $_userName! You have mastered Day 2 Step 1. Let us proceed to Step 2!');
    _scrollToBottom();
  }

  // =========================================================================
  // 🎙️ VOICE SUBMISSION ENGINE
  // =========================================================================

  void _handleVoiceSubmission({
    required String voiceText,
    required VoidCallback action,
  }) {
    HapticFeedback.selectionClick();

    setState(() {
      _messages.add(
        Day2ChatMessage(
          id: 'user_reply_${DateTime.now().millisecondsSinceEpoch}',
          isAvatar: false,
          textEn: voiceText,
          textNative: '',
          isVoiceMessage: true,
        ),
      );
    });

    _scrollToBottom();
    Future.delayed(const Duration(milliseconds: 280), action);
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) {
      // Safe fallback on desktop / web
      _handleVoiceSubmission(
        voiceText: _currentExpectedVoicePhrase,
        action: _onDrillPassed,
      );
      return;
    }

    try {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          final words = result.recognizedWords.trim();
          if (words.isNotEmpty && result.finalResult) {
            setState(() => _isListening = false);
            _handleVoiceSubmission(
              voiceText: words,
              action: _onDrillPassed,
            );
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.confirmation,
          cancelOnError: true,
        ),
      );
    } catch (_) {
      setState(() => _isListening = false);
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
            // CyberCat Avatar
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'CyberCat',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // 🔊 Single Speaker Mute/Unmute button right next to CyberCat's name
                      GestureDetector(
                        onTap: _toggleSpeaker,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _isSoundMuted
                                ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                                : const Color(0xFF10B981).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isSoundMuted
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                            color: _isSoundMuted
                                ? const Color(0xFFF87171)
                                : const Color(0xFF34D399),
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Day 2 • Concept Room (Step 1/7)',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚡', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  'DAY 2',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat message list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatMessageItem(msg);
              },
            ),
          ),

          // Bottom Bar with prominent floating mic
          _buildBottomActionMicBar(),
        ],
      ),
    );
  }

  Widget _buildChatMessageItem(Day2ChatMessage msg) {
    if (!msg.isAvatar) {
      // User voice bubble
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF047857), Color(0xFF065F46)],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
            border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mic_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 8),
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
      );
    }

    // Avatar bubble with divider and distinct answers
    return Container(
      margin: const EdgeInsets.only(bottom: 18, right: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
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
                  // English Prompt
                  Text(
                    msg.textEn,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                    ),
                  ),
                  if (msg.textNative.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      msg.textNative,
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

                  // Distinct Answer Options inside bubble under divider
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
                              boxShadow: opt.isHighlightedAnswer
                                  ? [
                                      BoxShadow(
                                        color: opt.borderColor.withValues(alpha: 0.25),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                if (opt.icon != null) ...[
                                  Text(opt.icon!, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        opt.labelEn,
                                        style: GoogleFonts.outfit(
                                          color: opt.textColor,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      if (opt.labelNative.isNotEmpty)
                                        Text(
                                          opt.labelNative,
                                          style: GoogleFonts.notoSansMalayalam(
                                            color: opt.textColor.withValues(alpha: 0.7),
                                            fontSize: 11,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: opt.textColor.withValues(alpha: 0.6),
                                  size: 13,
                                ),
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

  Widget _buildBottomActionMicBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: const Border(top: BorderSide(color: Colors.white12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TARGET PHRASE:',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '"$_currentExpectedVoicePhrase"',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF38BDF8),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Centered floating action mic
          GestureDetector(
            onTap: _isListening ? () => _speech.stop() : _startListening,
            child: AnimatedBuilder(
              animation: _micWaveController,
              builder: (context, child) {
                return Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _isListening
                          ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                          : [const Color(0xFF10B981), const Color(0xFF059669)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF10B981))
                            .withValues(
                          alpha: 0.3 + (_micWaveController.value * 0.3),
                        ),
                        blurRadius: 10 + (_micWaveController.value * 8),
                        spreadRadius: _micWaveController.value * 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.stop_rounded : Icons.mic_rounded,
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
