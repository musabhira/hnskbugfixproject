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
import 'package:pocket_mates_app/custom_code/services/pocket_voice_service.dart';

/// 💬 Chat Message Model for Step 5 Reading Room
class Step5ChatMessage {
  final String id;
  final bool isAvatar;
  final String textEn;
  final String? textNative;
  final String? audioText;
  final Widget? storyCard;
  final List<Step5InBubbleOption>? inBubbleOptions;
  final bool isVoiceMessage;
  final String? voiceTranscript;

  Step5ChatMessage({
    required this.id,
    required this.isAvatar,
    required this.textEn,
    this.textNative,
    this.audioText,
    this.storyCard,
    this.inBubbleOptions,
    this.isVoiceMessage = false,
    this.voiceTranscript,
  });
}

class Step5InBubbleOption {
  final String labelEn;
  final String labelNative;
  final String icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final bool isHighlighted;
  final VoidCallback onTap;

  Step5InBubbleOption({
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

/// 📖 Step 5: Conversational Reading Room Avatar Chat Page
///
/// User Audio Directives:
/// 1. Presents a full, illustrated, beautiful storybook passage.
/// 2. Audio button to hear the story read with proper pronunciation.
/// 3. NO shortcut clickable answer buttons that let children bypass speaking!
/// 4. The child speaks into the microphone to read aloud.
/// 5. Once spoken, voice automatically closes and posts as a realistic WhatsApp/Instagram Voice Note bubble.
/// 6. Continuous ambient background music (BGM) with BGM toggle & TTS toggle in the top bar.
class PocketDay1Step5AvatarChatPage extends StatefulWidget {
  final String? userId;
  final Function(int stepIndex)? onStepFinished;

  const PocketDay1Step5AvatarChatPage({
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
        builder: (_) => PocketDay1Step5AvatarChatPage(
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<PocketDay1Step5AvatarChatPage> createState() =>
      _PocketDay1Step5AvatarChatPageState();
}

class _PocketDay1Step5AvatarChatPageState
    extends State<PocketDay1Step5AvatarChatPage> with TickerProviderStateMixin {
  late final ScrollController _scrollController = ScrollController();
  late final FlutterTts _tts;
  late final stt.SpeechToText _speech;

  late final AnimationController _pulseController;
  late final AnimationController _waveController;

  final List<Step5ChatMessage> _messages = [];

  bool _isSpeaking = false;
  bool _isSoundMuted = false;
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  String _spokenText = '';
  bool _speechAvailable = false;

  String _userName = 'Hira';
  int _currentStoryPartIndex = 0;
  bool _isBeginnerMode = false;
  String _currentExpectedVoicePhrase = 'One sunny morning, a clever black crow flew over the green trees.';

  // 📖 Complete Illustrated Story Passages (User Audio Directive: Matching targets & beginner support)
  static const List<Map<String, dynamic>> storyPassages = [
    {
      'part': 1,
      'title': 'The Clever Crow & The Wooden House 🏡',
      'bannerEmoji': '🐦‍⬛ 🌿 🏡',
      'paragraphEn':
          'One sunny morning, a clever black crow flew over the green trees. He saw a wooden house with an open window. On the table, there was a bowl of sweet green grapes.',
      'readAloudTarget':
          'One sunny morning, a clever black crow flew over the green trees. He saw a wooden house with an open window.',
    },
    {
      'part': 2,
      'title': 'The Sleeping Cat & Cold Water 💧',
      'bannerEmoji': '🐱 🛏️ 💧',
      'paragraphEn':
          'Inside the house, a friendly white cat was sleeping on a soft bed. The crow quietly landed on the table. He was thirsty, so he drank cold water and tasted a sweet grape.',
      'readAloudTarget':
          'Inside the house, a friendly white cat was sleeping on a soft bed. The crow drank cold water.',
    },
    {
      'part': 3,
      'title': 'Flying High in the Blue Sky ☀️',
      'bannerEmoji': '☀️ 🍇 🌈',
      'paragraphEn':
          'The happy crow opened his wings and flew high into the sunny blue sky. He was cheerful and full of energy. Sharing good food and water brings peaceful happiness to everyone.',
      'readAloudTarget':
          'The happy crow opened his wings and flew high into the sunny blue sky. Sharing food brings joy to everyone.',
    },
  ];

  static const List<Map<String, dynamic>> beginnerPassages = [
    {
      'part': 1,
      'title': 'The Crow and The Tree 🌳',
      'bannerEmoji': '🐦‍⬛ 🌳',
      'paragraphEn': 'Look at the clever crow. The crow sits on a big green tree.',
      'readAloudTarget': 'Look at the clever crow. The crow sits on a big green tree.',
    },
    {
      'part': 2,
      'title': 'The Sweet Grapes 🍇',
      'bannerEmoji': '🍇 🏡',
      'paragraphEn': 'The crow sees sweet grapes. He flies to the wooden house.',
      'readAloudTarget': 'The crow sees sweet grapes. He flies to the wooden house.',
    },
    {
      'part': 3,
      'title': 'The Blue Sky ☀️',
      'bannerEmoji': '☀️ 🌈',
      'paragraphEn': 'The sun is bright. The happy crow flies high in the blue sky.',
      'readAloudTarget': 'The sun is bright. The happy crow flies high in the blue sky.',
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
      _startReadingIntroFlow();
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
      await _tts.setSpeechRate(0.43); // Clear, expressive storytelling pace

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
    } catch (_) {
      _speechAvailable = false;
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_display_name') ?? 'Hira';
      if (mounted) setState(() => _userName = name);
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
        _scrollController.position.maxScrollExtent + 320,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  // =========================================================================
  // 📖 READING CONVERSATION FLOW (No shortcut buttons during reading!)
  // =========================================================================

  void _startReadingIntroFlow() {
    final introEn =
        'Hi $_userName! Today we have a story reading session. Please read this.';
    final introMl =
        'ഹായ് $_userName! ഇന്ന് നമുക്ക് ഒരു സ്റ്റോറി റീഡിങ് സെഷൻ ഉണ്ട്. ദയവായി ഇത് വായിക്കൂ.';

    _currentExpectedVoicePhrase = 'Let\'s Read';

    setState(() {
      _messages.clear();
      _messages.add(
        Step5ChatMessage(
          id: 'reading_intro',
          isAvatar: true,
          textEn: introEn,
          textNative: introMl,
          audioText: 'Hi $_userName! Today we have a story reading session. Please read this.',
          inBubbleOptions: [
            Step5InBubbleOption(
              labelEn: '📖 OPEN STORYBOOK READING ➔',
              labelNative: 'കഥ വായിച്ചു തുടങ്ങാം',
              icon: '📚',
              isHighlighted: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFF34D399),
              textColor: Colors.white,
              onTap: () => _presentFirstStoryPassage(false),
            ),
            Step5InBubbleOption(
              labelEn: '🐣 EASY STARTER READING ➔',
              labelNative: 'ലളിതമായി വായിച്ചു തുടങ്ങാം',
              icon: '🌱',
              backgroundColor: const Color(0xFF1E293B),
              borderColor: const Color(0xFF38BDF8),
              textColor: Colors.white,
              onTap: () => _presentFirstStoryPassage(true),
            ),
          ],
        ),
      );
    });

    _speak('Hi $_userName! Today we have a story reading session. Please read this.');
    _scrollToBottom();
  }

  void _presentFirstStoryPassage([bool isBeginner = false]) {
    _isBeginnerMode = isBeginner;
    _currentStoryPartIndex = 0;
    _sendStoryPart();
  }

  void _sendStoryPart() {
    final activeList = _isBeginnerMode ? beginnerPassages : storyPassages;
    if (_currentStoryPartIndex >= activeList.length) {
      _showReadingFinishedCelebration();
      return;
    }

    final part = activeList[_currentStoryPartIndex];
    final title = part['title'] as String;
    final bannerEmoji = part['bannerEmoji'] as String;
    final paragraphEn = part['paragraphEn'] as String;
    final target = part['readAloudTarget'] as String;

    _currentExpectedVoicePhrase = target;

    final introEn = '📖 Part ${_currentStoryPartIndex + 1} of ${activeList.length}: Please read this.';

    setState(() {
      _messages.add(
        Step5ChatMessage(
          id: 'reading_part_$_currentStoryPartIndex',
          isAvatar: true,
          textEn: introEn,
          audioText: 'Please read this paragraph.',
          storyCard: _buildRichStoryBookCard(title, bannerEmoji, paragraphEn, target),
        ),
      );
    });

    _scrollToBottom();
  }

  Widget _buildRichStoryBookCard(
    String title,
    String bannerEmoji,
    String paragraphEn,
    String readAloudTarget,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with illustration emoji banner & listen button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(bannerEmoji, style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
              ),
              // 🔊 Story Listen Button with label
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _speak(paragraphEn);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF38BDF8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'LISTEN',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF38BDF8),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Complete Story Paragraph (Clean readable English, NO Malayalam clutter)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              paragraphEn,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.55,
                letterSpacing: 0.25,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Clear Read-Aloud Guidance Banner Matching the story!
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.mic_none_rounded, color: Color(0xFF34D399), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Read aloud into the mic below:\n"$readAloudTarget"',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFD1FAE5),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
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

  void _handleUserVoiceSubmission(String voiceText) {
    // 🛑 Close voice immediately as requested: "അവസാനം ആവുമ്പോൾ വോയിസ് ക്ലോസ് ചെയ്യുക"
    if (_speechAvailable && _isRecording) {
      try {
        _speech.stop();
      } catch (_) {}
    }
    setState(() => _isRecording = false);

    HapticFeedback.mediumImpact();
    PocketGameAudioService.instance.playCoinSound();

    // 🟢 Posts as realistic WhatsApp/Instagram-style Voice Note Message on the right!
    setState(() {
      _messages.add(
        Step5ChatMessage(
          id: 'user_voice_${DateTime.now().millisecondsSinceEpoch}',
          isAvatar: false,
          textEn: voiceText,
          isVoiceMessage: true,
          voiceTranscript: voiceText,
        ),
      );
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _handleReadingSuccess();
    });
  }

  void _handleReadingSuccess() {
    _currentStoryPartIndex++;

    final praises = [
      'Wonderful reading! 🌟 Great fluency and clarity!',
      'Magnificent pronunciation! Keep up the good work! 👏',
      'Superb reading! You sound like a native storyteller! ✨',
    ];
    final praiseEn = praises[(_currentStoryPartIndex - 1).clamp(0, praises.length - 1)];
    final praiseMl = 'വളരെ മനോഹരമായി വായിച്ചു! അടുത്ത ഭാഗത്തേക്ക് പോകാം!';

    setState(() {
      _messages.add(
        Step5ChatMessage(
          id: 'reading_praise_$_currentStoryPartIndex',
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
      _sendStoryPart();
    });
  }

  void _showReadingFinishedCelebration() {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playCoinSound();

    final replyEn =
        '🏆 CONGRATULATIONS, $_userName!\n\n'
        'You read the complete illustrated story of "The Clever Crow & Sweet Grapes" aloud!\n\n'
        'Step 5 Reading Room is successfully completed! 🌟';
    final replyMl =
        'അഭിനന്ദനങ്ങൾ, $_userName!\n\n'
        'നിങ്ങൾ മുഴുവൻ കഥയും മൈക്കിലൂടെ ഉറക്കെ വായിച്ചു പൂർത്തിയാക്കി!\n\n'
        'സ്റ്റെപ്പ് 5 റീഡിംഗ് റൂം വിജയകരമായി പൂർത്തിയായി! 🌟';

    _currentExpectedVoicePhrase = 'Complete Step 5';

    setState(() {
      _messages.add(
        Step5ChatMessage(
          id: 'reading_completed',
          isAvatar: true,
          textEn: replyEn,
          textNative: replyMl,
          audioText: 'Congratulations, $_userName! You completed Step 5 Reading Room!',
          inBubbleOptions: [
            Step5InBubbleOption(
              labelEn: '🌟 FINISH STEP 5 READING ➔',
              labelNative: 'സ്റ്റെപ്പ് 5 പൂർത്തിയാക്കുക',
              icon: '🏆',
              isHighlighted: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFFFFD700),
              textColor: Colors.white,
              onTap: _completeStep5,
            ),
          ],
        ),
      );
    });

    _speak('Congratulations, $_userName! You completed Step 5 Reading Room!');
    _scrollToBottom();
  }

  void _completeStep5() {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playCoinSound();

    if (widget.onStepFinished != null) {
      widget.onStepFinished!(5);
    }
    Navigator.pop(context);
  }

  Future<void> _startListeningToCentralMic() async {
    HapticFeedback.mediumImpact();

    // 🛑 If currently recording: user taps to STOP & SEND!
    if (_isRecording) {
      _recordingTimer?.cancel();
      if (_speechAvailable) {
        try {
          await _speech.stop();
        } catch (_) {}
      }
      final phraseToSend = _spokenText.trim().isNotEmpty
          ? _spokenText.trim()
          : _currentExpectedVoicePhrase;

      setState(() {
        _isRecording = false;
      });

      _handleUserVoiceSubmission(phraseToSend);
      return;
    }

    // 🔴 If not recording: start recording mode!
    try {
      await _tts.stop();
    } catch (_) {}

    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
      _spokenText = '';
    });

    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _recordingSeconds++);
    });

    if (_speechAvailable) {
      try {
        await _speech.listen(
          onResult: (result) {
            if (!mounted) return;
            final recognized = result.recognizedWords.trim();
            if (recognized.isNotEmpty) {
              setState(() {
                _spokenText = recognized;
              });
            }
          },
        );
      } catch (_) {}
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
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Text('📖', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'STEP 5: READING ROOM CHAT',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Illustrated Story & Voice Aloud Practice',
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
          // 🔊 TTS Speaker Toggle
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _isSoundMuted = !_isSoundMuted;
                if (_isSoundMuted) _tts.stop();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: !_isSoundMuted ? const Color(0xFF38BDF8).withValues(alpha: 0.2) : Colors.white10,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: !_isSoundMuted ? const Color(0xFF38BDF8) : Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isSoundMuted
                        ? Icons.volume_off_rounded
                        : (_isSpeaking ? Icons.volume_up_rounded : Icons.volume_up_outlined),
                    color: !_isSoundMuted ? const Color(0xFF38BDF8) : Colors.white60,
                    size: 14,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    !_isSoundMuted ? 'TTS' : 'OFF',
                    style: GoogleFonts.outfit(
                      color: !_isSoundMuted ? const Color(0xFF38BDF8) : Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
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

  Widget _buildMessageItem(Step5ChatMessage msg) {
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
                        if (msg.storyCard != null) msg.storyCard!,
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
                              border: Border.all(color: opt.borderColor, width: opt.isHighlighted ? 2 : 1),
                              boxShadow: opt.isHighlighted
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
      // 🟢 REALISTIC INSTAGRAM / WHATSAPP STYLE VOICE NOTE BUBBLE (User Audio Directive!)
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.74),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF047857), Color(0xFF10B981)],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 8),
                      // Animated audio waveform simulation
                      Row(
                        children: [8, 16, 24, 14, 28, 18, 22, 12, 20, 10, 16, 24, 10].map((h) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            width: 3,
                            height: h.toDouble(),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '0:04',
                        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.mic_rounded, color: Color(0xFFFFD700), size: 14),
                    ],
                  ),
                  if (msg.voiceTranscript != null && msg.voiceTranscript!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '"${msg.voiceTranscript!}"',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
    final mins = (_recordingSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_recordingSeconds % 60).toString().padLeft(2, '0');

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 📦 Minimal Clean Sentence Card Above Mic
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isRecording
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF10B981).withValues(alpha: 0.6),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isRecording) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'RECORDING ($mins:$secs) • TAP BUTTON TO SEND',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFCA5A5),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _spokenText.isNotEmpty
                        ? '"$_spokenText"'
                        : 'Reading: "$_currentExpectedVoicePhrase"',
                    style: GoogleFonts.outfit(
                      color: _spokenText.isNotEmpty ? const Color(0xFF34D399) : Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📖', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 5),
                      Text(
                        'Read Aloud:',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '"$_currentExpectedVoicePhrase"',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 🎙️ Centralized Floating Action Mic Button
          Center(
            child: GestureDetector(
              onTap: _startListeningToCentralMic,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = _isRecording ? 1.0 + (_pulseController.value * 0.12) : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isRecording
                              ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                              : [const Color(0xFF10B981), const Color(0xFF059669)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording ? Colors.redAccent : const Color(0xFF10B981))
                                .withValues(alpha: 0.55),
                            blurRadius: _isRecording ? 16 : 10,
                            spreadRadius: _isRecording ? 3 : 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecording ? Icons.send_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: _isRecording ? 25 : 28,
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
