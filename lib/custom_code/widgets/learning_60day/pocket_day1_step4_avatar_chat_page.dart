import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';

/// 💬 Chat Message Model for Step 4 Spoken English
class Step4ChatMessage {
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
  final List<Step4InBubbleOption>? inBubbleOptions;
  final bool isVoiceMessage;
  final String? voiceTranscript;

  Step4ChatMessage({
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
    this.voiceTranscript,
  });
}

class Step4InBubbleOption {
  final String labelEn;
  final String labelNative;
  final String icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final bool isHighlighted;
  final VoidCallback onTap;

  Step4InBubbleOption({
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

/// 🎙️ Step 4: Spoken English Conversational Chat Page
///
/// User Audio Directives:
/// 1. Natural conversation flow without shortcut answer buttons that bypass speaking.
/// 2. The child speaks into the microphone; their reply appears as a realistic Voice Note bubble (like WhatsApp/Instagram).
/// 3. Continuous ambient background music (BGM) with BGM toggle & TTS toggle in the top bar.
/// 4. Friendly, warm, natural TTS voice configuration.
/// 5. Simple, encouraging beginner-friendly questions.
/// 6. Fully responsive text wrapping with zero clipping or overflow.
class PocketDay1Step4AvatarChatPage extends StatefulWidget {
  final String? userId;
  final Function(int stepIndex)? onStepFinished;

  const PocketDay1Step4AvatarChatPage({
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
        builder: (_) => PocketDay1Step4AvatarChatPage(
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<PocketDay1Step4AvatarChatPage> createState() =>
      _PocketDay1Step4AvatarChatPageState();
}

class _PocketDay1Step4AvatarChatPageState
    extends State<PocketDay1Step4AvatarChatPage> with TickerProviderStateMixin {
  late final ScrollController _scrollController = ScrollController();
  late final FlutterTts _tts;
  late final stt.SpeechToText _speech;

  late final AnimationController _pulseController;
  late final AnimationController _waveController;

  final List<Step4ChatMessage> _messages = [];

  bool _isSpeaking = false;
  bool _isSoundMuted = false;
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  String _spokenText = '';
  bool _speechAvailable = false;

  String _userName = 'Hira';
  int _currentDialogueIndex = 0;
  String _currentExpectedVoicePhrase = 'I am fine';

  // 🗣️ Super simple, encouraging Day 1 beginner spoken drills (Avatar: CyberCat only)
  static const List<Map<String, dynamic>> spokenDrills = [
    {
      'avatar': 'CyberCat',
      'icon': '🐱',
      'color': Color(0xFF0284C7),
      'questionEn': 'Hello! How are you feeling today? 🌅',
      'questionMl': 'ഹലോ! ഇന്ന് സുഖമാണോ?',
      'targetReply': 'I am fine, thank you.',
      'targetReplyMl': 'എനിക്ക് സുഖമാണ്, നന്ദി.',
    },
    {
      'avatar': 'CyberCat',
      'icon': '🐱',
      'color': Color(0xFF0284C7),
      'questionEn': 'What is your name, my friend? 🤝',
      'questionMl': 'നിന്റെ പേരെന്താണ്?',
      'targetReply': 'My name is Alex.',
      'targetReplyMl': 'എന്റെ പേര് അലക്സ് എന്നാണ്.',
    },
    {
      'avatar': 'CyberCat',
      'icon': '🐱',
      'color': Color(0xFF0284C7),
      'questionEn': 'Are you a student? 🎒',
      'questionMl': 'നീ ഒരു വിദ്യാർത്ഥിയാണോ?',
      'targetReply': 'Yes, I am a student.',
      'targetReplyMl': 'അതെ, ഞാൻ ഒരു വിദ്യാർത്ഥിയാണ്.',
    },
    {
      'avatar': 'CyberCat',
      'icon': '🐱',
      'color': Color(0xFF0284C7),
      'questionEn': 'Do you like sweet green grapes? 🍇',
      'questionMl': 'നിനക്ക് മധുരമുള്ള മുന്തിരി ഇഷ്ടമാണോ?',
      'targetReply': 'Yes, I like grapes.',
      'targetReplyMl': 'അതെ, എനിക്ക് മുന്തിരി ഇഷ്ടമാണ്.',
    },
    {
      'avatar': 'CyberCat',
      'icon': '🐱',
      'color': Color(0xFF0284C7),
      'questionEn': 'Are you feeling thirsty? 💧',
      'questionMl': 'നിനക്ക് ദാഹിക്കുന്നുണ്ടോ?',
      'targetReply': 'Yes, please give me water.',
      'targetReplyMl': 'അതെ, എനിക്ക് വെള്ളം തരൂ.',
    },
    {
      'avatar': 'CyberCat',
      'icon': '🐱',
      'color': Color(0xFF0284C7),
      'questionEn': 'What is on your study table? 📖',
      'questionMl': 'നിന്റെ മേശപ്പുറത്ത് എന്താണുള്ളത്?',
      'targetReply': 'This is a book.',
      'targetReplyMl': 'ഇത് ഒരു പുസ്തകമാണ്.',
    },
    {
      'avatar': 'CyberCat',
      'icon': '🐱',
      'color': Color(0xFF0284C7),
      'questionEn': 'You spoke very well today! Have a great day! ☀️',
      'questionMl': 'നീ ഇന്ന് വളരെ നന്നായി സംസാരിച്ചു! നല്ലൊരു ദിവസം ആശംസിക്കുന്നു!',
      'targetReply': 'Thank you, goodbye!',
      'targetReplyMl': 'നന്ദി, വീണ്ടും കാണാം!',
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
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.44); // Natural conversational rate
      await _tts.setPitch(1.05); // Friendly, clear teacher pitch

      // Try selecting a natural high-quality en-US voice
      final voices = await _tts.getVoices;
      if (voices is List) {
        final naturalVoice = voices.firstWhere(
          (v) =>
              (v['name']?.toString().toLowerCase().contains('natural') == true ||
               v['name']?.toString().toLowerCase().contains('sfg') == true ||
               v['name']?.toString().toLowerCase().contains('female') == true) &&
              v['locale']?.toString().startsWith('en') == true,
          orElse: () => null,
        );
        if (naturalVoice != null && naturalVoice is Map) {
          await _tts.setVoice({
            "name": naturalVoice['name'].toString(),
            "locale": naturalVoice['locale'].toString(),
          });
        }
      }

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
        _scrollController.position.maxScrollExtent + 280,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  // =========================================================================
  // 🎙️ SPOKEN CONVERSATION FLOW (No shortcut buttons during drills!)
  // =========================================================================

  void _startSpokenChatIntro() {
    final introEn =
        'Welcome to Step 4: Spoken English Chat, $_userName! 🎙️\n\n'
        'We learn spoken English by speaking! Tap the Start button below to begin.';
    final introMl =
        'സ്റ്റെപ്പ് 4: സ്പോക്കൺ ഇംഗ്ലീഷ് ചാറ്റിലേക്ക് സ്വാഗതം, $_userName! 🎙️\n\n'
        'ഇംഗ്ലീഷ് സംസാരിച്ചു തന്നെ പഠിക്കാം! താഴെയുള്ള ബട്ടൺ ടാപ്പ് ചെയ്ത് ആരംഭിക്കാം!';

    _currentExpectedVoicePhrase = 'Start Speaking';

    setState(() {
      _messages.clear();
      _messages.add(
        Step4ChatMessage(
          id: 'spoken_intro',
          isAvatar: true,
          avatarName: 'CyberCat',
          avatarIcon: '🐱',
          avatarColor: const Color(0xFF0284C7),
          textEn: introEn,
          textNative: introMl,
          audioText: 'Welcome to Step 4: Spoken English Chat! Let\'s speak English together!',
          inBubbleOptions: [
            Step4InBubbleOption(
              labelEn: '🎙️ START SPEAKING PRACTICE ➔',
              labelNative: 'സംഭാഷണം ആരംഭിക്കുക',
              icon: '🚀',
              isHighlighted: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFF34D399),
              textColor: Colors.white,
              onTap: _sendNextSpokenDrill,
            ),
          ],
        ),
      );
    });

    _speak('Welcome to Step 4: Spoken English Chat! Let\'s speak English together!');
    _scrollToBottom();
  }

  void _sendNextSpokenDrill() {
    if (_currentDialogueIndex >= spokenDrills.length) {
      _showSpokenCompletionDialogue();
      return;
    }

    final drill = spokenDrills[_currentDialogueIndex];
    final avatar = drill['avatar'] as String;
    final icon = drill['icon'] as String;
    final color = drill['color'] as Color;
    final qEn = drill['questionEn'] as String;
    final qMl = drill['questionMl'] as String;
    final target = drill['targetReply'] as String;
    final targetMl = drill['targetReplyMl'] as String;

    _currentExpectedVoicePhrase = target;

    // 🛑 Note: As explicitly instructed by user, DO NOT add answer buttons inside bubble!
    setState(() {
      _messages.add(
        Step4ChatMessage(
          id: 'spoken_drill_$_currentDialogueIndex',
          isAvatar: true,
          avatarName: avatar,
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

  void _handleUserVoiceSubmission(String voiceText) {
    HapticFeedback.mediumImpact();
    PocketGameAudioService.instance.playCoinSound();

    // 🟢 Posts as realistic WhatsApp/Instagram-style Voice Note Message on the right!
    setState(() {
      _messages.add(
        Step4ChatMessage(
          id: 'user_voice_${DateTime.now().millisecondsSinceEpoch}',
          isAvatar: false,
          textEn: voiceText,
          isVoiceMessage: true,
          voiceTranscript: voiceText,
        ),
      );
    });
    _scrollToBottom();

    // Natural conversation pause before avatar replies
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _handleSpokenAnswerSuccess();
    });
  }

  void _handleSpokenAnswerSuccess() {
    _currentDialogueIndex++;

    final praises = [
      'Well said! Perfect tone and confidence! 🌟',
      'Excellent pronunciation! 👏',
      'Very natural English! Keep going! 🚀',
      'Spot on! That sounded so fluent! ✨',
      'Awesome reply! 💯',
    ];
    final praiseEn = praises[_currentDialogueIndex % praises.length];
    final praiseMl = 'വളരെ മികച്ച ഉച്ചാരണം! അഭിനന്ദനങ്ങൾ!';

    final drill = spokenDrills[(_currentDialogueIndex - 1).clamp(0, spokenDrills.length - 1)];
    final avatar = drill['avatar'] as String;
    final icon = drill['icon'] as String;
    final color = drill['color'] as Color;

    setState(() {
      _messages.add(
        Step4ChatMessage(
          id: 'spoken_praise_$_currentDialogueIndex',
          isAvatar: true,
          avatarName: avatar,
          avatarIcon: icon,
          avatarColor: color,
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
      _sendNextSpokenDrill();
    });
  }

  void _showSpokenCompletionDialogue() {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playCoinSound();

    final replyEn =
        '🎉 BRILLIANT CONVERSATION, $_userName!\n\n'
        'You spoke every sentence into the mic with confidence! Step 4 is complete!\n\n'
        'Now let\'s proceed to Step 5: Reading Room! 📖';
    final replyMl =
        'ഗംഭീരം, $_userName! നിങ്ങൾ എല്ലാ സംഭാഷണങ്ങളും മൈക്കിലൂടെ ഉറക്കെ പറഞ്ഞു പരിശീലിച്ചു!\n\n'
        'ഇനി നമുക്ക് സ്റ്റെപ്പ് 5: റീഡിംഗ് റൂമിലേക്ക് കടക്കാം! 📖';

    _currentExpectedVoicePhrase = 'Proceed to Step 5';

    setState(() {
      _messages.add(
        Step4ChatMessage(
          id: 'spoken_finish',
          isAvatar: true,
          avatarName: 'CyberCat',
          avatarIcon: '🐱',
          avatarColor: const Color(0xFF0284C7),
          textEn: replyEn,
          textNative: replyMl,
          audioText: 'Brilliant conversation, $_userName! You completed Step 4! Now let\'s go to Step 5 Reading Room!',
          inBubbleOptions: [
            Step4InBubbleOption(
              labelEn: '📖 PROCEED TO STEP 5: READING ROOM ➔',
              labelNative: 'സ്റ്റെപ്പ് 5-ലേക്ക് പോകാം',
              icon: '🚀',
              isHighlighted: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFFFFD700),
              textColor: Colors.white,
              onTap: _completeStep4AndProceedToStep5,
            ),
          ],
        ),
      );
    });

    _speak('Brilliant conversation, $_userName! You completed Step 4! Now let\'s go to Step 5 Reading Room!');
    _scrollToBottom();
  }

  void _completeStep4AndProceedToStep5() {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playCoinSound();

    if (widget.onStepFinished != null) {
      widget.onStepFinished!(4);
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

  void _cancelRecording() async {
    HapticFeedback.lightImpact();
    _recordingTimer?.cancel();
    try {
      if (_speechAvailable) await _speech.stop();
    } catch (_) {}
    setState(() {
      _isRecording = false;
      _recordingSeconds = 0;
      _spokenText = '';
    });
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
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Text('🎙️', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'STEP 4: SPOKEN ENGLISH CHAT',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Interactive Voice Practice',
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

  Widget _buildMessageItem(Step4ChatMessage msg) {
    if (msg.isAvatar) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: msg.avatarColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: msg.avatarColor, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(msg.avatarIcon, style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 3),
                Text(
                  msg.avatarName,
                  style: GoogleFonts.outfit(color: Colors.white60, fontSize: 9.5, fontWeight: FontWeight.bold),
                ),
              ],
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
                        // Target sentence guidance banner (informative, NOT a clickable cheat button)
                        if (msg.targetSentenceHint != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.mic_none_rounded, color: Color(0xFFFFD700), size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Speak into the mic:',
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFFFFD700),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '"${msg.targetSentenceHint!}"',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    height: 1.3,
                                  ),
                                ),
                                if (msg.targetSentenceHintMl != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    msg.targetSentenceHintMl!,
                                    style: GoogleFonts.inter(
                                      color: Colors.white60,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
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
                        children: [8, 16, 22, 14, 26, 18, 24, 12, 20, 10, 16, 22, 10].map((h) {
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
                        '0:03',
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

    if (_isRecording) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF8B5CF6), width: 1.8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: _cancelRecording,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'RECORDING ($mins:$secs)',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFEF4444),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _spokenText.isNotEmpty
                        ? '🎙️ "$_spokenText"'
                        : 'Say: "$_currentExpectedVoicePhrase"',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _startListeningToCentralMic,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.6),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SEND',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.send_rounded, color: Colors.white, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

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
                'Speak: ',
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
              ),
              Flexible(
                child: Text(
                  '"$_currentExpectedVoicePhrase"',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Tap mic below to record your voice',
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 10.5),
          ),
          const SizedBox(height: 8),
          Center(
            child: GestureDetector(
              onTap: _startListeningToCentralMic,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.55),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mic_rounded,
                      color: Colors.white,
                      size: 28,
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
