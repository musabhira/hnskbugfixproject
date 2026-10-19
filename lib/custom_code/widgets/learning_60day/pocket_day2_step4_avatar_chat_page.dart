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

/// 💬 Chat Message Model for Day 2 Step 4 Spoken English
class Day2Step4ChatMessage {
  final String id;
  final bool isAvatar;
  final String avatarName;
  final String avatarIcon;
  final Color avatarColor;
  final String textEn;
  final String? textNative;
  final String? audioText;
  final String? targetSentenceHint;
  final String? targetSentenceHintMl;
  final List<Day2Step4InBubbleOption>? inBubbleOptions;
  final bool isVoiceMessage;

  Day2Step4ChatMessage({
    required this.id,
    required this.isAvatar,
    this.avatarName = 'CyberCat',
    this.avatarIcon = '🐱',
    this.avatarColor = const Color(0xFF0284C7),
    required this.textEn,
    this.textNative,
    this.audioText,
    this.targetSentenceHint,
    this.targetSentenceHintMl,
    this.inBubbleOptions,
    this.isVoiceMessage = false,
  });
}

class Day2Step4InBubbleOption {
  final String labelEn;
  final String labelNative;
  final String icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final bool isHighlighted;
  final VoidCallback onTap;

  Day2Step4InBubbleOption({
    required this.labelEn,
    required this.labelNative,
    required this.icon,
    this.backgroundColor = const Color(0xFF0F172A),
    this.borderColor = const Color(0xFF38BDF8),
    this.textColor = Colors.white,
    this.isHighlighted = false,
    required this.onTap,
  });
}

/// 🎙️ Day 2 Step 4: Spoken English Conversational Avatar Chat
/// Topic: "Where I Am From & Describing My Living Place"
///
/// Features addressing user audio directive:
/// 1. Exactly mirrors Day 1 Step 4 structure: 1-on-1 spoken conversational practice.
/// 2. User speaks into the microphone; reply appears as a pure WhatsApp-style Voice Note bubble (NO transcript text).
/// 3. Option button taps submit as User Text Bubbles (isVoiceMessage: false).
/// 4. When recording, displays a prominent Red SEND button with strict de-duplication guard.
/// 5. 100% Unique Day 2 Spoken Curriculum (NO duplicates from Day 1).
/// 6. Ambient BGM & TTS toggle in top bar.
class PocketDay2Step4AvatarChatPage extends StatefulWidget {
  final String? userId;
  final Function(int stepIndex)? onStepFinished;

  const PocketDay2Step4AvatarChatPage({
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
        builder: (_) => PocketDay2Step4AvatarChatPage(
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<PocketDay2Step4AvatarChatPage> createState() =>
      _PocketDay2Step4AvatarChatPageState();
}

class _PocketDay2Step4AvatarChatPageState
    extends State<PocketDay2Step4AvatarChatPage> with TickerProviderStateMixin {
  late final ScrollController _scrollController = ScrollController();
  late final FlutterTts _tts;
  late final stt.SpeechToText _speech;

  late final AnimationController _pulseController;
  late final AnimationController _waveController;

  final List<Day2Step4ChatMessage> _messages = [];

  bool _isSpeaking = false;
  bool _isSoundMuted = false;
  bool _isRecording = false;
  bool _isSubmittingVoice = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  String _spokenText = '';
  bool _speechAvailable = false;

  String _userName = 'Hira';
  int _currentDialogueIndex = 0;
  String _currentExpectedVoicePhrase = 'I am from Kerala';

  /// 🌟 100% Unique Day 2 Conversational Spoken English Exchanges
  static const List<Map<String, dynamic>> spokenDrills = [
    {
      'avatar': 'CyberCat',
      'icon': '🐱',
      'color': Color(0xFF0284C7),
      'questionEn': 'Hello! It is so nice to speak with you again today! Where are you from? 🌍',
      'questionMl': 'ഹലോ! ഇന്ന് വീണ്ടും സംസാരിക്കാൻ കഴിഞ്ഞതിൽ സന്തോഷം! നിങ്ങൾ എവിടെ നിന്നാണ്?',
      'targetReply': 'I am from Kerala.',
      'targetReplyMl': 'ഞാൻ കേരളത്തിൽ നിന്നാണ്.',
    },
    {
      'avatar': 'CyberCat',
      'icon': '🐱',
      'color': Color(0xFF0284C7),
      'questionEn': 'Kerala is such a beautiful place! Do you live in a city or a town? 🏙️',
      'questionMl': 'കേരളം വളരെ മനോഹരമായ നാടാണ്! നിങ്ങൾ നഗരത്തിലാണോ അതോ പട്ടണത്തിലാണോ താമസിക്കുന്നത്?',
      'targetReply': 'I live in a beautiful city.',
      'targetReplyMl': 'ഞാൻ മനോഹരമായ ഒരു നഗരത്തിലാണ് താമസിക്കുന്നത്.',
    },
    {
      'avatar': 'CyberCat',
      'icon': '🐱',
      'color': Color(0xFF0284C7),
      'questionEn': 'Tell me about your home. Who do you stay with? 👨‍👩‍👦',
      'questionMl': 'നിങ്ങളുടെ വീടിനെക്കുറിച്ച് പറയൂ. നിങ്ങൾ ആരുടെ കൂടെയാണ് താമസിക്കുന്നത്?',
      'targetReply': 'I stay with my family.',
      'targetReplyMl': 'ഞാൻ എന്റെ കുടുംബത്തോടൊപ്പമാണ് താമസിക്കുന്നത്.',
    },
    {
      'avatar': 'CyberCat',
      'icon': '🐱',
      'color': Color(0xFF0284C7),
      'questionEn': 'Do you like staying at home in the evening? 🏡',
      'questionMl': 'വൈകുന്നേരങ്ങളിൽ വീട്ടിൽ സമയം ചെലവഴിക്കാൻ ഇഷ്ടമാണോ?',
      'targetReply': 'My home is cozy and warm.',
      'targetReplyMl': 'എന്റെ വീട് സുഖകരവും സന്തോഷം നിറഞ്ഞതുമാണ്.',
    },
    {
      'avatar': 'CyberCat',
      'icon': '🐱',
      'color': Color(0xFF0284C7),
      'questionEn': 'Do you come home on time after work or study? ⏰',
      'questionMl': 'ജോലി അല്ലെങ്കിൽ പഠനം കഴിഞ്ഞ് കൃത്യസമയത്ത് വീട്ടിൽ എത്താറുണ്ടോ?',
      'targetReply': 'I reach home on time.',
      'targetReplyMl': 'ഞാൻ കൃത്യസമയത്ത് വീട്ടിൽ എത്താറുണ്ട്.',
    },
    {
      'avatar': 'CyberCat',
      'icon': '🐱',
      'color': Color(0xFF0284C7),
      'questionEn': 'You did wonderful spoken practice today! Have a great day ahead! ☀️',
      'questionMl': 'ഇന്ന് താങ്കൾ വളരെ നന്നായി സംസാരിച്ചു! നല്ലൊരു ദിവസം ആശംസിക്കുന്നു!',
      'targetReply': 'Thank you, see you tomorrow.',
      'targetReplyMl': 'നന്ദി, നാളെ കാണാം.',
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
      _startSpokenChatIntro();
    });
  }

  void _initAnimationControllers() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
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
          if (mounted) setState(() => _isRecording = false);
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isRecording = false);
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
    _recordingTimer?.cancel();
    _scrollController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
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
  // 🎙️ CONVERSATIONAL SPOKEN DRILLS FLOW
  // =========================================================================

  void _startSpokenChatIntro() {
    final welcomeEn =
        'Hello $_userName! 🎙️ Welcome to Day 2 Step 4: Spoken English Studio!\n\n'
        'Today we will practice talking about where you live and your home.\n'
        'Tap the mic at the bottom, speak clearly, and send your voice note!';
    final welcomeMl =
        'ഹലോ $_userName! 🎙️ ഡേ 2 സ്റ്റെപ്പ് 4 സ്പോക്കൺ ഇംഗ്ലീഷ് സ്റ്റുഡിയോയിലേക്ക് സ്വാഗതം!\n\n'
        'ഇന്ന് നമ്മൾ എവിടെ താമസിക്കുന്നു, വീട് എന്നിവയെക്കുറിച്ച് സംസാരിക്കും.\n'
        'താഴെയുള്ള മൈക്കിൽ തൊട്ട് ഉച്ചരിച്ച് വോയിസ് അയക്കൂ!';

    setState(() {
      _messages.clear();
      _messages.add(
        Day2Step4ChatMessage(
          id: 'spoken_welcome',
          isAvatar: true,
          textEn: welcomeEn,
          textNative: welcomeMl,
          audioText: 'Hello $_userName! Welcome to Day 2 Step 4 Spoken English Studio! Let\'s begin our conversation!',
        ),
      );
    });

    _speak('Hello $_userName! Welcome to Day 2 Step 4 Spoken English Studio! Let\'s begin our conversation!');
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      _sendCurrentAvatarQuestion();
    });
  }

  void _sendCurrentAvatarQuestion() {
    if (_currentDialogueIndex >= spokenDrills.length) {
      _showAllDrillsCompleted();
      return;
    }

    final drill = spokenDrills[_currentDialogueIndex];
    final qEn = drill['questionEn'] as String;
    final qMl = drill['questionMl'] as String;
    final target = drill['targetReply'] as String;
    final targetMl = drill['targetReplyMl'] as String;
    final icon = drill['icon'] as String;
    final color = drill['color'] as Color;

    _currentExpectedVoicePhrase = target;

    setState(() {
      _messages.add(
        Day2Step4ChatMessage(
          id: 'dialogue_$_currentDialogueIndex',
          isAvatar: true,
          avatarIcon: icon,
          avatarColor: color,
          textEn: qEn,
          textNative: qMl,
          audioText: qEn,
          targetSentenceHint: target,
          targetSentenceHintMl: targetMl,
        ),
      );
    });

    _speak(qEn);
    _scrollToBottom();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecordingAndSubmit();
    } else {
      await _startRecording();
    }
  }

  int _failedDrillAttempts = 0;

  Future<void> _startRecording() async {
    HapticFeedback.heavyImpact();
    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
      _spokenText = '';
    });

    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _isRecording) {
        setState(() => _recordingSeconds++);
      }
    });

    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    if (isMobile && _speechAvailable) {
      try {
        await _speech.listen(
          onResult: (result) {
            final words = result.recognizedWords.trim();
            if (words.isNotEmpty && mounted) {
              setState(() => _spokenText = words);
            }
          },
          listenOptions: stt.SpeechListenOptions(
            listenFor: const Duration(seconds: 20),
            pauseFor: const Duration(seconds: 4),
            partialResults: true,
            listenMode: stt.ListenMode.confirmation,
            cancelOnError: true,
          ),
        );
      } catch (_) {}
    }
  }

  Future<void> _stopRecordingAndSubmit() async {
    if (_isSubmittingVoice) return;
    _isSubmittingVoice = true;

    HapticFeedback.mediumImpact();
    _recordingTimer?.cancel();

    try {
      if (_speechAvailable) await _speech.stop();
    } catch (_) {}

    setState(() => _isRecording = false);

    final raw = _spokenText.trim();
    if (raw.isEmpty) {
      _isSubmittingVoice = false;
      _speak('I could not hear you clearly, $_userName. Tap the mic and speak aloud.');
      return;
    }

    final normalized = PocketSpeechNormalizer.normalize(raw);
    final finalVoiceText = normalized.isNotEmpty ? normalized : raw;

    // Add pure WhatsApp style Voice Note Bubble (NO raw transcript container)
    setState(() {
      _messages.add(
        Day2Step4ChatMessage(
          id: 'voice_${DateTime.now().millisecondsSinceEpoch}',
          isAvatar: false,
          textEn: finalVoiceText,
          isVoiceMessage: true,
        ),
      );
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 700), () {
      _isSubmittingVoice = false;
      if (!mounted) return;
      _onVoiceResponseReceived(finalVoiceText);
    });
  }

  void _onVoiceResponseReceived(String spokenResponse) {
    final drill = spokenDrills[_currentDialogueIndex.clamp(0, spokenDrills.length - 1)];
    final target = drill['targetReply'] as String;
    final targetMl = drill['targetReplyMl'] as String;
    final icon = drill['icon'] as String;
    final color = drill['color'] as Color;

    final isCorrect = PocketSpeechNormalizer.isFuzzyMatch(
      spokenResponse,
      target,
      thresholdPercentage: 35,
    );

    if (isCorrect || _failedDrillAttempts >= 1) {
      _failedDrillAttempts = 0;
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playCorrectSound();

      final praises = [
        'Very natural pronunciation! 🌟',
        'Spot on, $_userName! Excellent rhythm! 👏',
        'Brilliant speaking! Clear and fluent! 💎',
        'I loved your answer! Super confident! 🚀',
        'Wonderful progress! Keep it up! ✨',
        'Flawless delivery! High score! 🏆',
      ];
      final praiseEn = praises[_currentDialogueIndex % praises.length];

      setState(() {
        _messages.add(
          Day2Step4ChatMessage(
            id: 'praise_${DateTime.now().millisecondsSinceEpoch}',
            isAvatar: true,
            avatarIcon: '🐱',
            avatarColor: const Color(0xFF10B981),
            textEn: '$praiseEn\nYour English is flowing so well!',
            textNative: 'വളരെ നന്നായി സംസാരിച്ചു! താങ്കളുടെ ഉച്ചാരണം വളരെ മികച്ചതാണ്! 🌟',
            audioText: praiseEn,
          ),
        );
        _currentDialogueIndex++;
      });

      _speak(praiseEn);
      _scrollToBottom();

      Future.delayed(const Duration(milliseconds: 2000), () {
        if (!mounted) return;
        _sendCurrentAvatarQuestion();
      });
    } else {
      // Gentle correction for mistakes without breaking conversation
      _failedDrillAttempts++;
      HapticFeedback.lightImpact();

      final retryEn = 'Good try, $_userName! Let\'s say it like this:\n\n"$target"\n\nTap the mic below and try again! 🎙️';
      final retryMl = 'നല്ല ശ്രമം! നമുക്ക് ഒന്നുകൂടി പറഞ്ഞു നോക്കാം:\n"$targetMl"';

      setState(() {
        _messages.add(
          Day2Step4ChatMessage(
            id: 'spoken_retry_${DateTime.now().millisecondsSinceEpoch}',
            isAvatar: true,
            avatarIcon: icon,
            avatarColor: color,
            textEn: retryEn,
            textNative: retryMl,
            audioText: 'Good try, $_userName! Let\'s say it like this: $target. Try again!',
          ),
        );
      });

      _speak('Good try, $_userName! Let\'s say it like this: $target. Try again!');
      _scrollToBottom();
    }
  }

  void _showAllDrillsCompleted() {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playVictorySfx();

    setState(() {
      _messages.add(
        Day2Step4ChatMessage(
          id: 'step4_complete',
          isAvatar: true,
          avatarIcon: '🐱',
          avatarColor: const Color(0xFFFFD700),
          textEn:
              '🏆 CONGRATULATIONS, $_userName!\n\n'
              'You successfully completed all Day 2 Spoken English dialogues! You spoke fluently about where you live and your home.\n\n'
              '+75 POCKET SCORE AWARDED! 💎',
          textNative:
              'അഭിനന്ദനങ്ങൾ, $_userName! താങ്കൾ ഇന്നത്തെ എല്ലാ സ്പോക്കൺ സംഭാഷണങ്ങളും വിജയകരമായി പൂർത്തിയാക്കി!\n\n'
              '+75 പോയിന്റ് ലഭിച്ചു! 🌟',
          audioText: 'Congratulations $_userName! You completed Day 2 Step 4 Spoken English Studio! 75 points awarded!',
          inBubbleOptions: [
            Day2Step4InBubbleOption(
              labelEn: 'Step 5: Reading Room ➔',
              labelNative: 'സ്റ്റെപ്പ് 5: റീഡിംഗ് റൂം',
              icon: '📖',
              isHighlighted: true,
              backgroundColor: const Color(0xFF10B981),
              borderColor: const Color(0xFFFFD700),
              textColor: Colors.black,
              onTap: _completeStep4,
            ),
          ],
        ),
      );
    });

    _speak('Congratulations, $_userName! You finished Day 2 Step 4 Spoken English Studio!');
    _scrollToBottom();
  }

  Future<void> _completeStep4() async {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playCoinSound();

    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = widget.userId ?? 'guest';
      await prefs.setBool('pocket_day_${uid}_2_step_4_done', true);
    } catch (_) {}

    if (widget.onStepFinished != null) {
      widget.onStepFinished!(4);
    }
    if (mounted) {
      Navigator.pop(context);
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
                  colors: [Color(0xFF0284C7), Color(0xFF10B981)],
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
                    'CyberCat • Step 4',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Day 2: Spoken English Studio 🎙️',
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

            // Bottom Audio / Recording Bar
            _buildBottomSpeakingBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessage(Day2Step4ChatMessage msg) {
    if (!msg.isAvatar) {
      if (!msg.isVoiceMessage) {
        // User Text Message Bubble
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

      // Pure WhatsApp style Voice Note Bubble (NO transcript container)
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
                              final heights = [6, 14, 20, 16, 8, 18, 24, 14, 18, 10, 16, 22, 14, 8, 18, 12, 16, 8];
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
                              '0:03',
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

    // Avatar bubble with target prompt hint
    return Container(
      margin: const EdgeInsets.only(bottom: 18, right: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: msg.avatarColor,
            ),
            child: Center(
              child: Text(msg.avatarIcon, style: const TextStyle(fontSize: 18)),
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

                  // Target Sentence Box (Speaking prompt hint)
                  if (msg.targetSentenceHint != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.mic_none_rounded, color: Color(0xFFFFD700), size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'SPEAK THIS ANSWER:',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFFD700),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '"${msg.targetSentenceHint!}"',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (msg.targetSentenceHintMl != null)
                            Text(
                              msg.targetSentenceHintMl!,
                              style: GoogleFonts.notoSansMalayalam(
                                color: const Color(0xFF93C5FD),
                                fontSize: 11.5,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],

                  if (msg.inBubbleOptions != null && msg.inBubbleOptions!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...msg.inBubbleOptions!.map((opt) {
                      return InkWell(
                        onTap: opt.onTap,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: opt.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: opt.borderColor, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              opt.labelEn,
                              style: GoogleFonts.outfit(
                                color: opt.textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
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

  Widget _buildBottomSpeakingBar() {
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
                  _isRecording ? 'RECORDING VOICE...' : '🎙️ SPOKEN ENGLISH STUDIO',
                  style: GoogleFonts.inter(
                    color: _isRecording ? const Color(0xFFF87171) : const Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isRecording
                      ? 'Listening (${_recordingSeconds}s)... Tap SEND when finished 🎙️'
                      : 'Tap the mic to record your answer',
                  style: GoogleFonts.outfit(
                    color: _isRecording ? Colors.white : Colors.white70,
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
            onTap: _toggleRecording,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                if (_isRecording) {
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
                            alpha: 0.4 + (_waveController.value * 0.3),
                          ),
                          blurRadius: 12 + (_waveController.value * 8),
                          spreadRadius: _waveController.value * 3,
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
                          alpha: 0.3 + (_waveController.value * 0.3),
                        ),
                        blurRadius: 10 + (_waveController.value * 8),
                        spreadRadius: _waveController.value * 4,
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
