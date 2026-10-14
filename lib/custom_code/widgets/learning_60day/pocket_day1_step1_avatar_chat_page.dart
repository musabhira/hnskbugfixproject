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
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_voice_service.dart';
import 'pocket_pronunciation_evaluator.dart';
import 'games/pocket_alphabet_balloon_sky_game_page.dart';
import 'curriculum_data/day1_az_and_300vocab_data.dart';
import 'pocket_fortress_defense_service.dart';

/// 💬 Chat Message Model with Embedded In-Bubble Choices & Voice Metadata
class Step1ChatMessage {
  final String id;
  final bool isAvatar;
  final String textEn;
  final String textNative;
  final String? audioText;
  final Widget? cardContent;
  final List<Step1InBubbleOption>? inBubbleOptions;
  final String? speakThisPrompt;
  final bool isVoiceMessage;
  final DateTime timestamp;

  Step1ChatMessage({
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
class Step1InBubbleOption {
  final String labelEn;
  final String labelNative;
  final String? icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final bool isHighlightedAnswer;
  final VoidCallback onTap;

  const Step1InBubbleOption({
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

/// 🐱 Step 1: Voice-First Conversational Avatar Chat for English Alphabet
///
/// Implemented according to User Malayalam Audio Directives:
/// 1. Immediately auto-starts speech on entering Step 1.
/// 2. NO Play or Pause button at the top/bubble header (it is already auto-playing).
///    ONLY a single Speaker mute/unmute button right next to CyberCat's name.
/// 3. Greeting: "Hi Hira! I am CyberCat 🐱. Shall we learn the English Alphabet (ABCD) today?"
///    (Strictly no "Pocket Tutor" anywhere).
/// 4. In-Bubble Divider & Distinct Answer:
///    Inside the bubble, below a divider, the answer is displayed with a DISTINCT
///    highlighted color (so learner instantly recognizes it as the answer to speak/tap).
/// 5. Initial Diagnostic:
///    User can say or tap "YES" (I know ABCD -> skip to Level 2) or "NO" (Teach me ABCD).
/// 6. Learning Mode Selection:
///    When learner chooses "NO", CyberCat asks:
///    - 🎈 Play Fun Balloon Pop Game! (ബലൂൺ പൊട്ടിച്ചു പഠിക്കാം!)
///    - 🗣️ Speaking & Chat Practice! (സംസാരിച്ചു പഠിക്കാം!)
/// 7. Interactive Balloon Pop Game:
///    Floating colorful balloons with letters (A, B, C, D...).
///    Tapping pops the balloon with burst animation, speaks "A for Apple! 🍎",
///    and reveals word, sound, and Malayalam translation!
/// 8. Cross-Platform Microphone (Windows, Android, iOS):
///    Safely handles speech recognition on Android & iOS, and on Windows desktop
///    gracefully runs voice simulation with audio waves so user NEVER gets an error!
class PocketDay1Step1AvatarChatPage extends StatefulWidget {
  final String? userId;
  final Function(int stepIndex)? onStepFinished;

  const PocketDay1Step1AvatarChatPage({
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
        builder: (_) => PocketDay1Step1AvatarChatPage(
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<PocketDay1Step1AvatarChatPage> createState() =>
      _PocketDay1Step1AvatarChatPageState();
}

class _PocketDay1Step1AvatarChatPageState
    extends State<PocketDay1Step1AvatarChatPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final FlutterTts _tts;
  late final stt.SpeechToText _speech;
  late final AnimationController _pulseController;
  late final AnimationController _micWaveController;
  late final AnimationController _balloonFloatController;

  final List<Step1ChatMessage> _messages = [];

  bool _isSpeaking = false;
  bool _isSoundMuted = false;
  bool _isListening = false;
  bool _isAnalyzing = false;
  bool _speechAvailable = false;

  String _userName = 'Hira'; // Default learner name as instructed in user audio
  String _nativeLanguage = 'Malayalam';
  String _currentExpectedVoicePhrase = 'Yes or No';
  int _currentLetterIndex = 0; // 0 to 25 for A-Z

  // 🎈 Balloon Game State
  final Set<String> _poppedLetters = {};
  String? _lastPoppedLetter;

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

    _balloonFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _initUserName();
    _initTts();
    _initSpeechRecognizer();
    _nativeLanguage = PocketLanguageService.currentLanguage;

    // 🎵 Ensure background music plays softly on load
    PocketGameAudioService.instance.playAmbientAppTheme();
    PocketGameAudioService.instance.setVolume(0.16);

    // Auto-start speech immediately upon opening Step 1
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
    _userName = 'Hira'; // Audio directive: "Hi Hira, I am CyberCat..."
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

  /// Cross-Platform Safe Speech Recognizer Init:
  /// Prevents crashes and MissingPluginException on Windows Desktop or Web
  Future<void> _initSpeechRecognizer() async {
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (!isMobile) {
      // Windows Desktop or Web: use graceful simulated voice engine
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
    _balloonFloatController.dispose();
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

  /// Single Speaker button next to CyberCat: Mutes/Unmutes speech
  void _toggleSpeaker() {
    HapticFeedback.lightImpact();
    setState(() {
      _isSoundMuted = !_isSoundMuted;
    });
    if (_isSoundMuted) {
      _tts.stop();
      _isSpeaking = false;
    } else {
      // Re-speak last avatar prompt
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
        _scrollController.position.maxScrollExtent + 240,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  // =========================================================================
  // 🎙️ CONVERSATION FLOW ENGINE (In-Bubble & Voice-First)
  // =========================================================================

  /// Phase 1: Greeting & Initial Diagnostic Check
  void _startWelcomeDiagnosticFlow() {
    final promptEn =
        'Hi $_userName! I am CyberCat 🐱. Shall we learn the English Alphabet (ABCD) today?';
    final promptMl =
        'ഹായ് $_userName! ഞാൻ സൈബർ ക്യാറ്റ് 🐱. നമുക്കിന്ന് ഇംഗ്ലീഷ് ആൽഫബെറ്റ് (ABCD) പഠിച്ചാലോ?';

    _currentExpectedVoicePhrase = 'Yes or No';
    _currentLetterIndex = 0;

    setState(() {
      _messages.clear();
      _messages.add(
        Step1ChatMessage(
          id: 'welcome_diag',
          isAvatar: true,
          textEn: promptEn,
          textNative: promptMl,
          audioText:
              'Hi $_userName! I am CyberCat. Shall we learn the English Alphabet today?',
          speakThisPrompt: 'Speak or Tap the Answer:',
          inBubbleOptions: [
            Step1InBubbleOption(
              labelEn: '✅ YES, LET\'S LEARN ABCD!',
              labelNative: 'പഠിക്കാം! 🔤',
              icon: '✅',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF047857), // Distinct Emerald Green
              borderColor: const Color(0xFF34D399),
              textColor: Colors.white,
              onTap: () => _handleVoiceSubmission(
                voiceText: 'Yes',
                action: _onUserWantsToLearnAlphabet,
              ),
            ),
            Step1InBubbleOption(
              labelEn: '⚡ SKIP TO LEVEL 2',
              labelNative: 'അറിയാം (Next Level) ➔',
              icon: '⚡',
              isHighlightedAnswer: false,
              backgroundColor: const Color(0xFF1E293B),
              borderColor: Colors.white24,
              textColor: const Color(0xFFFFD700),
              onTap: () => _handleVoiceSubmission(
                voiceText: 'Skip to Level 2',
                action: _onUserAlreadyKnowsAlphabet,
              ),
            ),
          ],
        ),
      );
    });

    _speak('Hi $_userName! I am CyberCat. Shall we learn the English Alphabet today?');
    _scrollToBottom();
  }

  /// Branch A: User Already Knows Alphabet -> Instant Skip to Level 2
  void _onUserAlreadyKnowsAlphabet() {
    final replyEn =
        'Awesome, $_userName! 🎉 You already know the alphabet! Step 1 is complete! Let\'s drive to Level 2: Vocabulary Words! 🚗';
    final replyMl =
        'വളരെ നല്ലത്, $_userName! നിങ്ങൾക്ക് അക്ഷരങ്ങൾ അറിയാവുന്നതിനാൽ Step 1 പൂർത്തിയായി. നമുക്ക് ലെവൽ 2-ലേക്ക് പോകാം!';

    _currentExpectedVoicePhrase = 'Proceed to Level 2';

    setState(() {
      _messages.add(
        Step1ChatMessage(
          id: 'avatar_congrats_skip',
          isAvatar: true,
          textEn: replyEn,
          textNative: replyMl,
          audioText:
              'Awesome, $_userName! You already know the alphabet. Step 1 is complete! Let\'s drive to Level 2!',
          speakThisPrompt: 'Tap below to exit & drive to Level 2 🚗',
          inBubbleOptions: [
            Step1InBubbleOption(
              labelEn: '🚗 PROCEED TO LEVEL 2 (NEXT) ➔',
              labelNative: 'ലെവൽ 2-ലേക്ക് ഡ്രൈവ് ചെയ്യാം',
              icon: '🏎️',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFFFFD700),
              textColor: Colors.white,
              onTap: _completeStep1AndDriveToLevel2,
            ),
          ],
        ),
      );
    });

    _speak('Awesome, $_userName! Step 1 is complete! Let\'s drive to Level 2!');
    _scrollToBottom();
  }

  /// Branch B: User wants to learn -> Ask Learning Preference (Balloon Game or Speaking Chat)
  void _onUserWantsToLearnAlphabet() {
    final replyEn =
        'Fantastic, $_userName! Would you like to learn by playing a game or by speaking in chat? 🎈🗣️';
    final replyMl =
        'ഗംഭീരം, $_userName! നമുക്ക് ഗെയിം കളിച്ച് പഠിക്കണോ, അതോ സംസാരിച്ച് പഠിക്കണോ?';

    _currentExpectedVoicePhrase = 'Balloon Game or Speaking';

    setState(() {
      _messages.add(
        Step1ChatMessage(
          id: 'learning_preference_choice',
          isAvatar: true,
          textEn: replyEn,
          textNative: replyMl,
          audioText:
              'Fantastic, $_userName! Would you like to play the Balloon Pop game, or practice speaking in chat?',
          speakThisPrompt: 'Choose your learning style:',
          inBubbleOptions: [
            Step1InBubbleOption(
              labelEn: '🎈 PLAY BALLOON GAME',
              labelNative: 'ബലൂൺ പൊട്ടിച്ചു പഠിക്കാം! 💥',
              icon: '🎈',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF9333EA), // Vibrant Purple
              borderColor: const Color(0xFFC084FC),
              textColor: Colors.white,
              onTap: () => _handleVoiceSubmission(
                voiceText: 'Game',
                action: _startBalloonGameMode,
              ),
            ),
            Step1InBubbleOption(
              labelEn: '🗣️ SPEAKING CHAT',
              labelNative: 'സംസാരിച്ചു പഠിക്കാം! 🎙️',
              icon: '🗣️',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF0284C7), // Vibrant Cyan Blue
              borderColor: const Color(0xFF38BDF8),
              textColor: Colors.white,
              onTap: () => _handleVoiceSubmission(
                voiceText: 'Speaking',
                action: _startTeachingLettersSequence,
              ),
            ),
          ],
        ),
      );
    });

    _speak('Would you like to play the Balloon Pop game, or practice speaking in chat?');
    _scrollToBottom();
  }

  // =========================================================================
  // 🎈 BALLOON POP GAME MODE (User Audio Directive!)
  // "ഗെയിം ആണെന്നുണ്ടെങ്കിൽ അടിപൊളിയായിട്ട് ബലൂണുകൾ ഇങ്ങനെ ഓരോരോ ABCDകൾ പോകുന്നുണ്ടാകും.
  //  അതിൽ A... A for Apple! ബലൂൺ പൊട്ടിക്കുക! B, B for Ball..."
  // =========================================================================

  void _startBalloonGameMode() {
    _currentLetterIndex = 0;
    _currentExpectedVoicePhrase = 'Balloon Quest';

    final replyEn =
        '🎈 Ready for the Balloon Sky Pop Adventure, $_userName?\n\n'
        'Tap the button below to launch into the open sky! Pop floating A-Z balloons, hear phonics, and repeat words to master the alphabet! 🌟';
    final replyMl =
        '$_userName, ആകാശത്തേക്ക് പറന്നുയരുന്ന ബലൂണുകൾ പൊട്ടിച്ച് A-Z പഠിക്കാം!\n\n'
        'താഴെയുള്ള ബട്ടണിൽ ടാപ്പ് ചെയ്ത് ഫുൾ-സ്ക്രീൻ ബലൂൺ ഗെയിമിലേക്ക് പോകൂ! 🎈⛅';

    setState(() {
      _messages.add(
        Step1ChatMessage(
          id: 'balloon_sky_launch_card',
          isAvatar: true,
          textEn: replyEn,
          textNative: replyMl,
          audioText:
              'Ready for the Balloon Sky Pop Adventure, $_userName? Tap the button below to launch into the open sky!',
          cardContent: _buildBalloonSkyLaunchCard(),
          speakThisPrompt: 'Tap below to launch Full-Screen Balloon Game 🎈',
          inBubbleOptions: [
            Step1InBubbleOption(
              labelEn: '🚀 START BALLOON SKY POP ADVENTURE 🎈',
              labelNative: 'ഫുൾ-സ്ക്രീൻ ഗെയിം ആരംഭിക്കുക ➔',
              icon: '🎈',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFFFFD700),
              textColor: Colors.white,
              onTap: _launchBalloonSkyGame,
            ),
            Step1InBubbleOption(
              labelEn: '🗣️ SWITCH TO SPEAKING CHAT',
              labelNative: 'സംസാരിച്ചു പഠിക്കുന്നതിലേക്ക് മാറ്റുക',
              icon: '💬',
              isHighlightedAnswer: false,
              backgroundColor: const Color(0xFF1E293B),
              borderColor: const Color(0xFF38BDF8),
              textColor: const Color(0xFF7DD3FC),
              onTap: _startTeachingLettersSequence,
            ),
          ],
        ),
      );
    });

    _speak('Ready for the Balloon Sky Pop Adventure, $_userName? Tap the button below to launch into the open sky!');
    _scrollToBottom();
  }

  Future<void> _launchBalloonSkyGame() async {
    HapticFeedback.heavyImpact();
    await _tts.stop();
    setState(() => _isSpeaking = false);

    await PocketAlphabetBalloonSkyGamePage.show(
      context,
      userId: widget.userId,
      onCompleted: () {
        if (!mounted) return;
        _showFinalCompletionDialogue();
      },
    );
  }

  Widget _buildBalloonSkyLaunchCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0C4A6E), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.35),
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
                  color: Color(0xFF0284C7),
                  shape: BoxShape.circle,
                ),
                child: const Text('🎈', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BALLOON SKY POP ARENA ⛅',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Full-Screen 2D Atmosphere • 26 Letters',
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
                _buildSkyFeatureBullet(
                  '⛅',
                  'Sky, Sun, Clouds & Floating Balloons',
                  'ആകാശത്തേക്ക് പൊങ്ങിപ്പോകുന്ന വർണ്ണ ബലൂണുകൾ',
                ),
                const SizedBox(height: 8),
                _buildSkyFeatureBullet(
                  '💥',
                  'Tap to Pop with Real Phonics Audio',
                  'ബലൂൺ പൊട്ടിച്ച് വാക്കും അക്ഷരവും കേൾക്കാം',
                ),
                const SizedBox(height: 8),
                _buildSkyFeatureBullet(
                  '🎙️',
                  'Speech Practice with Down-Arrow Guide',
                  'പച്ച ആരോ സൂചിപ്പിക്കുന്ന മൈക്കിലൂടെ ഉച്ചരിച്ചു പഠിക്കുക',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _launchBalloonSkyGame,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
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
                    'CLICK TO LAUNCH GAME 🎈',
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

  Widget _buildSkyFeatureBullet(String emoji, String titleEn, String titleMl) {
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

  Widget _buildBalloonPopGameCard() {
    final letters = Day1AlphabetData.lettersAtoZ;
    final balloonColors = [
      const Color(0xFFEF4444), // Red
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Pink
      const Color(0xFF06B6D4), // Cyan
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
        border: Border.all(color: const Color(0xFFC084FC).withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9333EA).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game Header
          Row(
            children: [
              const Text('🎈', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ABCD Balloon Pop Arena',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Popped: ${_poppedLetters.length} / 26 Letters 🏆',
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
                  'TAP TO POP 💥',
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

          // Last Popped Banner (if any)
          if (_lastPoppedLetter != null) ...[
            Builder(builder: (ctx) {
              final activeItem = letters.firstWhere(
                (l) => l['letter'] == _lastPoppedLetter,
                orElse: () => letters.first,
              );
              final ltr = activeItem['letter'] ?? 'A';
              final wrd = activeItem['word'] ?? 'Apple';
              final em = activeItem['emoji'] ?? '🍎';
              final snd = activeItem['sound'] ?? '';
              final ml = activeItem['meaning']?['ml'] ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                ),
                child: Row(
                  children: [
                    Text(em, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💥 POPPED! "$ltr for $wrd" ($snd)',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ml,
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded,
                          color: Color(0xFFFFD700), size: 20),
                      onPressed: () => _speak('$ltr for $wrd. $snd.'),
                    ),
                  ],
                ),
              );
            }),
          ],

          // Floating Balloons Grid
          SizedBox(
            height: 320,
            child: AnimatedBuilder(
              animation: _balloonFloatController,
              builder: (ctx, _) {
                final screenW = MediaQuery.of(context).size.width;
                final cols = screenW > 380 ? 4 : 3;
                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: letters.length,
                  itemBuilder: (c, i) {
                    final item = letters[i];
                    final ltr = item['letter']?.toString() ?? '';
                    final wrd = item['word']?.toString() ?? '';
                    final em = item['emoji']?.toString() ?? '';
                    final snd = item['sound']?.toString() ?? '';
                    final isPopped = _poppedLetters.contains(ltr);
                    final color = balloonColors[i % balloonColors.length];

                    // Gentle floating bob
                    final floatOffset = (i % 2 == 0)
                        ? _balloonFloatController.value * 4.0
                        : (1.0 - _balloonFloatController.value) * 4.0;

                    return Transform.translate(
                      offset: Offset(0, isPopped ? 0 : -floatOffset),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          setState(() {
                            _poppedLetters.add(ltr);
                            _lastPoppedLetter = ltr;
                            _currentExpectedVoicePhrase = '$ltr for $wrd';
                          });
                          _speak('$ltr for $wrd!');

                          // If completed all 26
                          if (_poppedLetters.length >= 26) {
                            _showFinalCompletionDialogue();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: isPopped
                                ? const LinearGradient(
                                    colors: [Color(0xFF334155), Color(0xFF1E293B)],
                                  )
                                : LinearGradient(
                                    colors: [
                                      color.withValues(alpha: 0.95),
                                      color.withValues(alpha: 0.7),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(22),
                              topRight: Radius.circular(22),
                              bottomLeft: Radius.circular(22),
                              bottomRight: Radius.circular(22),
                            ),
                            border: Border.all(
                              color: isPopped
                                  ? const Color(0xFF10B981)
                                  : Colors.white.withValues(alpha: 0.8),
                              width: isPopped ? 1.0 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isPopped ? Colors.black : color)
                                    .withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Balloon highlight shine
                              if (!isPopped)
                                Positioned(
                                  top: 5,
                                  left: 8,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isPopped ? '💥 $ltr' : ltr,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    isPopped ? wrd : em,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
  // 🗣️ SPEAKING CHAT MODE (Full 26 Letters)
  // =========================================================================

  void _startTeachingLettersSequence() {
    _currentLetterIndex = 0;
    _presentLetterAtCurrentIndex();
  }

  /// Presents the current letter from A-Z with visual card & in-bubble answer
  void _presentLetterAtCurrentIndex() {
    final letters = Day1AlphabetData.lettersAtoZ;
    if (_currentLetterIndex >= letters.length) {
      _showFinalCompletionDialogue();
      return;
    }

    final item = letters[_currentLetterIndex];
    final letter = item['letter']?.toString() ?? 'A';
    final word = item['word']?.toString() ?? 'Apple';
    final sound = item['sound']?.toString() ?? '';
    final emoji = item['emoji']?.toString() ?? '🍎';
    final voicePhrase = item['voice']?.toString() ?? '$letter for $word';
    final meaningMl = item['meaning']?['ml']?.toString() ?? '';
    final exampleEn = item['exampleEn']?.toString() ?? '';
    final exampleMl = item['exampleMl']?.toString() ?? '';

    _currentExpectedVoicePhrase = '$letter for $word';

    final replyEn = '$letter! $emoji\nRepeat after me: "$letter for $word"';
    final replyMl = '$letter! $emoji എന്റെ കൂടെ പറയൂ: "$letter for $word"';

    setState(() {
      _messages.add(
        Step1ChatMessage(
          id: 'teach_letter_$letter',
          isAvatar: true,
          textEn: replyEn,
          textNative: replyMl,
          audioText: '$letter! Repeat after me: $letter for $word!',
          speakThisPrompt: 'Speak into mic or tap below 👇',
          inBubbleOptions: [
            Step1InBubbleOption(
              labelEn: '🎙️ SAY: "$letter for $word" $emoji',
              labelNative: 'മൈക്കിലൂടെ പറയൂ അല്ലെങ്കിൽ ഇവിടെ ടാപ്പ് ചെയ്യൂ',
              icon: emoji,
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF1E3A8A),
              borderColor: const Color(0xFF38BDF8),
              textColor: const Color(0xFFE0F2FE),
              onTap: () => _handleVoiceSubmission(
                voiceText: '$letter for $word $emoji',
                action: _advanceToNextLetter,
              ),
            ),
            Step1InBubbleOption(
              labelEn: '⚡ SKIP TO LEVEL 2 ➔',
              labelNative: 'നേരിട്ട് ലെവൽ 2-ലേക്ക് പോകാം',
              icon: '⚡',
              isHighlightedAnswer: false,
              backgroundColor: const Color(0xFF1E293B),
              borderColor: Colors.white24,
              textColor: const Color(0xFFFFD700),
              onTap: _completeStep1AndDriveToLevel2,
            ),
          ],
        ),
      );
    });

    _speak('$letter! Repeat after me: $letter for $word!');
    _scrollToBottom();
  }

  void _advanceToNextLetter() {
    _currentLetterIndex++;
    if (_currentLetterIndex < Day1AlphabetData.lettersAtoZ.length) {
      _presentLetterAtCurrentIndex();
    } else {
      _showFinalCompletionDialogue();
    }
  }

  void _showFinalCompletionDialogue() {
    final replyEn =
        'Congratulations, $_userName! 🏆 You spoke and learned the letters with CyberCat! Step 1 is completed! Let\'s drive to Level 2! 🚗';
    final replyMl =
        'അഭിനന്ദനങ്ങൾ, $_userName! 🏆 നിങ്ങൾ അക്ഷരങ്ങൾ സംസാരിച്ചു പഠിച്ചു! Step 1 പൂർത്തിയായി. രണ്ടാമത്തെ ലെവലിലേക്ക് വണ്ടി ഓടിച്ചു പോകാം!';

    _currentExpectedVoicePhrase = 'Drive to Level 2';

    setState(() {
      _messages.add(
        Step1ChatMessage(
          id: 'congrats_final',
          isAvatar: true,
          textEn: replyEn,
          textNative: replyMl,
          audioText:
              'Congratulations, $_userName! You completed Step 1! Step 2 Vocabulary is now unlocked. Let\'s drive to Level 2!',
          speakThisPrompt: 'Tap below to exit to mountain map & drive to Level 2 🚗',
          inBubbleOptions: [
            Step1InBubbleOption(
              labelEn: '🚗 DRIVE TO LEVEL 2 (NEXT) ➔',
              labelNative: 'പുറത്തേക്ക് പോയി വണ്ടി ലെവൽ 2-ലേക്ക് ഡ്രൈവ് ചെയ്യും',
              icon: '🏎️',
              isHighlightedAnswer: true,
              backgroundColor: const Color(0xFF047857),
              borderColor: const Color(0xFFFFD700),
              textColor: Colors.white,
              onTap: _completeStep1AndDriveToLevel2,
            ),
            Step1InBubbleOption(
              labelEn: '🔠 BROWSE FULL A-Z ALPHABET (26 LETTERS)',
              labelNative: 'ബാക്കി എല്ലാ അക്ഷരങ്ങളും കേൾക്കുക',
              icon: '📚',
              isHighlightedAnswer: false,
              backgroundColor: const Color(0xFF1E293B),
              borderColor: const Color(0xFF38BDF8),
              textColor: const Color(0xFF7DD3FC),
              onTap: _showFullAlphabetBottomSheet,
            ),
          ],
        ),
      );
    });

    _speak('Congratulations, $_userName! You completed Step 1! Let\'s drive to Level 2!');
    _scrollToBottom();
  }

  /// Handles voice input submission (either from floating mic or in-bubble answer card)
  void _handleVoiceSubmission({
    required String voiceText,
    required VoidCallback action,
  }) {
    HapticFeedback.mediumImpact();
    PocketGameAudioService.instance.playCoinSound();

    setState(() {
      _isAnalyzing = false;
      _messages.add(
        Step1ChatMessage(
          id: 'user_voice_${DateTime.now().millisecondsSinceEpoch}',
          isAvatar: false,
          textEn: voiceText,
          isVoiceMessage: true,
        ),
      );
    });
    _scrollToBottom();

    // 600ms natural conversational pause before avatar replies
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      action();
    });
  }

  /// Cross-Platform Safe Voice Microphone Input (Windows Desktop, Android, iOS):
  /// Never crashes or throws an unhandled error on Windows!
  void _onMicButtonPressed() async {
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
      // Windows Desktop, Web, or Mic unavailable:
      // Graceful fallback simulation
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

  /// Evaluates learner's spoken input against current expectation and provides immediate corrective feedback
  void _processSpokenText(String spokenText) {
    // 1. First greeting step: checking for yes (knows) vs no (wants to learn)
    if (_messages.length <= 1) {
      final lower = spokenText.toLowerCase();
      if (lower.contains('no') || lower.contains('learn') || lower.contains('not') || lower.contains('teach')) {
        _handleVoiceSubmission(
          voiceText: spokenText,
          action: _onUserWantsToLearnAlphabet,
        );
      } else if (lower.contains('yes') || lower.contains('know') || lower.contains('skip') || lower.contains('next')) {
        _handleVoiceSubmission(
          voiceText: spokenText,
          action: _onUserAlreadyKnowsAlphabet,
        );
      } else {
        // Did not say yes or no clearly
        _showMisunderstoodDialogue(
          spokenText: spokenText,
          expectedText: 'Yes or No',
          tip: 'Please clearly say "Yes" if you know ABCD, or "No" if you want to learn! 😊',
          tipMl: 'ദയവായി ABCD അറിയാമെങ്കിൽ "Yes" എന്നും, പഠിക്കണമെങ്കിൽ "No" എന്നും പറയൂ! 😊',
        );
      }
      return;
    }

    // 2. Preference step: checking for game vs speaking
    if (_currentExpectedVoicePhrase.contains('Game or Speaking')) {
      final lower = spokenText.toLowerCase();
      if (lower.contains('game') || lower.contains('balloon') || lower.contains('play')) {
        _handleVoiceSubmission(
          voiceText: spokenText,
          action: _startBalloonGameMode,
        );
      } else if (lower.contains('speak') || lower.contains('chat') || lower.contains('repeat')) {
        _handleVoiceSubmission(
          voiceText: spokenText,
          action: _startTeachingLettersSequence,
        );
      } else {
        _showMisunderstoodDialogue(
          spokenText: spokenText,
          expectedText: 'Game or Speaking',
          tip: 'Say "Game" to pop balloons, or "Speaking" to practice in chat!',
          tipMl: '"Game" എന്ന് പറഞ്ഞാൽ ബലൂൺ ഗെയിം കളിക്കാം, "Speaking" എന്ന് പറഞ്ഞാൽ ചാറ്റിൽ സംസാരിക്കാം!',
        );
      }
      return;
    }

    // 3. Letter drill evaluation: check pronunciation of target letter phrase
    final evaluation = PocketPronunciationEvaluator.evaluate(
      targetSentence: _currentExpectedVoicePhrase,
      spokenText: spokenText,
    );

    final cleanTarget = _currentExpectedVoicePhrase.toLowerCase().replaceAll(RegExp(r"[^\w'\s]"), '').trim();
    final cleanSpoken = spokenText.toLowerCase().replaceAll(RegExp(r"[^\w'\s]"), '').trim();

    // Word contains target letter or target word
    final isMatch = evaluation.accuracyPercentage >= 50 ||
        cleanSpoken.contains(cleanTarget) ||
        cleanTarget.contains(cleanSpoken);

    if (isMatch) {
      // Correct! Advance
      _handleVoiceSubmission(
        voiceText: spokenText,
        action: _advanceToNextLetter,
      );
    } else {
      // Incorrect pronunciation - Do NOT advance! Show error & let learner retry
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playIncorrectSound();

      setState(() {
        _isAnalyzing = false;
        _messages.add(
          Step1ChatMessage(
            id: 'user_voice_err_${DateTime.now().millisecondsSinceEpoch}',
            isAvatar: false,
            textEn: spokenText,
            isVoiceMessage: true,
          ),
        );

        final focus = evaluation.focusWords.join(', ');
        _messages.add(
          Step1ChatMessage(
            id: 'correction_${DateTime.now().millisecondsSinceEpoch}',
            isAvatar: true,
            textEn: 'Not quite! You said: "$spokenText"\nExpected: "$_currentExpectedVoicePhrase"${focus.isNotEmpty ? "\n\n💡 Focus on: $focus" : ""}',
            textNative: 'പറഞ്ഞത് ശരിയായില്ല! നിങ്ങൾ പറഞ്ഞത്: "$spokenText"\nശരിയായത്: "$_currentExpectedVoicePhrase"\nഒന്നുകൂടി മൈക്കിൽ പറഞ്ഞു നോക്കൂ! 🎙️',
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
      _isAnalyzing = false;
      _messages.add(
        Step1ChatMessage(
          id: 'user_voice_${DateTime.now().millisecondsSinceEpoch}',
          isAvatar: false,
          textEn: spokenText,
          isVoiceMessage: true,
        ),
      );
      _messages.add(
        Step1ChatMessage(
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
      if (_currentExpectedVoicePhrase.toLowerCase().contains('no')) {
        return _onUserWantsToLearnAlphabet;
      } else {
        return _onUserAlreadyKnowsAlphabet;
      }
    } else if (_currentLetterIndex < Day1AlphabetData.lettersAtoZ.length) {
      return _advanceToNextLetter;
    } else {
      return _showFinalCompletionDialogue;
    }
  }

  /// Completion action: Saves progress, triggers map driving animation to Step 2
  Future<void> _completeStep1AndDriveToLevel2() async {
    HapticFeedback.heavyImpact();
    await _tts.stop();
    try {
      if (_speechAvailable) await _speech.stop();
    } catch (_) {}

    final uid = widget.userId ?? SupaFlow.client.auth.currentUser?.id;
    final prefs = await SharedPreferences.getInstance();
    final key = 'pocket_day_${uid ?? "guest"}_1_step_1_done';
    await prefs.setBool(key, true);

    if (uid != null && uid.isNotEmpty) {
      await PocketFortressDefenseService.recordTrainingPoints(30, uid);
    }

    if (mounted) {
      widget.onStepFinished?.call(1);
      Navigator.pop(context);
    }
  }

  // =========================================================================
  // 🎨 UI WIDGET BUILDERS
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
        // 130px bottom padding gives safe clearance so the floating mic never obscures messages
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 130),
        itemCount: _messages.length,
        itemBuilder: (ctx, index) {
          final msg = _messages[index];
          return _buildChatMessageItem(msg);
        },
      ),
      // User Audio Directive: Floating Action Button in the Center with Safe Height
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
          // Back button
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

          // Title & Step Indicator (Strictly NO "Pocket Tutor")
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'DAY 1 • STEP 1',
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

          // A-Z Full View Button
          IconButton(
            icon: const Icon(Icons.grid_view_rounded,
                color: Color(0xFF38BDF8), size: 22),
            tooltip: 'Browse All 26 Letters',
            onPressed: _showFullAlphabetBottomSheet,
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

          // Sound Toggle Button (Speaker on/off)
          IconButton(
            icon: Icon(
              _isSoundMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: _isSoundMuted ? Colors.white38 : const Color(0xFFFFD700),
              size: 22,
            ),
            tooltip: _isSoundMuted ? 'Unmute Speaker' : 'Mute Speaker',
            onPressed: _toggleSpeaker,
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessageItem(Step1ChatMessage msg) {
    if (msg.isAvatar) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar Mascot Icon
            GestureDetector(
              onTap: () {
                if (msg.audioText != null) _speak(msg.audioText!);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isSpeaking
                        ? const Color(0xFF10B981)
                        : const Color(0xFFFFD700),
                    width: 1.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: VectorAvatarWidget(
                    config: VectorAvatarConfig.defaultConfig,
                    size: 40,
                    showAura: false,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Avatar Speech Bubble with In-Bubble Options
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                    topLeft: Radius.circular(4),
                  ),
                  border: Border.all(
                    color: _isSpeaking
                        ? const Color(0xFF10B981).withValues(alpha: 0.7)
                        : const Color(0xFF38BDF8).withValues(alpha: 0.35),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row with CyberCat & Single Speaker Mute Button
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'CyberCat 🐱',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF7DD3FC),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),

                        // Single Speaker Toggle Button (Right next to CyberCat)
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            if (_isSpeaking) {
                              _tts.stop();
                              setState(() {
                                _isSpeaking = false;
                                _isSoundMuted = true;
                              });
                            } else if (_isSoundMuted) {
                              setState(() => _isSoundMuted = false);
                              if (msg.audioText != null) _speak(msg.audioText!);
                            } else {
                              _tts.stop();
                              setState(() {
                                _isSpeaking = false;
                                _isSoundMuted = true;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _isSpeaking
                                  ? const Color(0xFFEF4444).withValues(alpha: 0.22)
                                  : (_isSoundMuted
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : const Color(0xFF10B981).withValues(alpha: 0.18)),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _isSpeaking
                                    ? const Color(0xFFEF4444)
                                    : (_isSoundMuted
                                        ? Colors.white24
                                        : const Color(0xFF10B981).withValues(alpha: 0.6)),
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
                                  size: 14,
                                  color: _isSpeaking
                                      ? const Color(0xFFF87171)
                                      : (_isSoundMuted
                                          ? Colors.white60
                                          : const Color(0xFFFFD700)),
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
                                            ? Colors.white60
                                            : const Color(0xFF34D399)),
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
                    const SizedBox(height: 8),

                    // English Message Text
                    Text(
                      msg.textEn,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),

                    // Native Translation Subtitle Box
                    if (msg.textNative.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🇮🇳', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                msg.textNative,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFFEF08A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Interactive Card (e.g. Balloon Arena or Letter Visual Card)
                    if (msg.cardContent != null) ...[
                      const SizedBox(height: 10),
                      msg.cardContent!,
                    ],

                    // -------------------------------------------------------------
                    // 🔘 IN-BUBBLE DIVIDER & DISTINCT ANSWER (User Audio Directive!)
                    // -------------------------------------------------------------
                    if (msg.inBubbleOptions != null &&
                        msg.inBubbleOptions!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white24, height: 1.0),
                      const SizedBox(height: 10),

                      // Label for Answer section
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '💡 ANSWER (SPEAK OR TAP)',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFD700),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // In-Bubble Tap Options with Distinct Highlight Color
                      for (final opt in msg.inBubbleOptions!) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: opt.onTap,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 11),
                                decoration: BoxDecoration(
                                  color: opt.backgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: opt.borderColor,
                                    width: opt.isHighlightedAnswer ? 2.0 : 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: opt.backgroundColor
                                          .withValues(alpha: 0.45),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    if (opt.icon != null) ...[
                                      Text(opt.icon!,
                                          style: const TextStyle(fontSize: 18)),
                                      const SizedBox(width: 10),
                                    ],
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            opt.labelEn,
                                            style: GoogleFonts.outfit(
                                              color: opt.textColor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          if (opt.labelNative.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              opt.labelNative,
                                              style: GoogleFonts.inter(
                                                color: opt.textColor
                                                    .withValues(alpha: 0.85),
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      opt.isHighlightedAnswer
                                          ? Icons.mic_rounded
                                          : Icons.arrow_forward_rounded,
                                      color: opt.textColor.withValues(alpha: 0.9),
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // User Message Bubble (Right-aligned, with Voice Soundwave badge)
      return Padding(
        padding: const EdgeInsets.only(bottom: 14, left: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                  border: Border.all(color: const Color(0xFF34D399), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.mic_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
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
  }

  /// 🔤 Visual Letter Showcase Card
  Widget _buildLetterVisualCard({
    required String letter,
    required String sound,
    required String word,
    required String meaningMl,
    required String emoji,
    required String exampleEn,
    required String exampleMl,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Large Letter Badge
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  letter,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Sound & Word
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'Sound: $sound',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFFFD700),
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 5),
                        Text(
                          '$letter for $word',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      meaningMl,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF93C5FD),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Speaker Pronounce Button
              IconButton(
                icon: const Icon(Icons.volume_up_rounded,
                    color: Color(0xFFFFD700), size: 24),
                tooltip: 'Pronounce $letter',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _speak('$letter for $word. $sound.');
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '💬 "$exampleEn" ($exampleMl)',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎙️ Central Floating Mic Button with Safe Area Height
  /// User Audio Directive: "സെന്റർ ആവണം ബട്ടൺ വന്നിട്ട് സംസാരിക്കുന്ന മൈക്ക് ബട്ടൺ വന്നിട്ട് ഫ്ലോട്ടിങ് ആക്ഷൻ ബട്ടൺ സെന്റർ കൊടുക്കില്ലേ...
  /// കുറച്ചു ഹൈറ്റിൽ കൊടുക്കണം, സേഫ് ഏരിയ ഇട്ടിട്ട്. അതിൽ പറയേണ്ടത് എന്താണെന്നുള്ളത് അത് മേലെ കൊടുക്കണം: 'Say: ...'"
  Widget _buildCentralFloatingMic() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Prompt banner above mic: "Say: ..."
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isListening
                  ? const Color(0xFFEF4444)
                  : const Color(0xFFFFD700).withValues(alpha: 0.8),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: (_isListening
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFFFD700))
                    .withValues(alpha: 0.3),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening
                      ? const Color(0xFFEF4444)
                      : (_isAnalyzing
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF10B981)),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                _isListening
                    ? 'LISTENING... Speak now'
                    : (_isAnalyzing
                        ? 'ANALYZING VOICE...'
                        : 'Say: "$_currentExpectedVoicePhrase"'),
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),

        // Glowing Central Floating Action Mic Button
        GestureDetector(
          onTap: _onMicButtonPressed,
          child: AnimatedBuilder(
            animation: _isListening ? _micWaveController : _pulseController,
            builder: (context, _) {
              final scale = _isListening
                  ? 1.0 + (_micWaveController.value * 0.15)
                  : 1.0;
              final glow = _isListening
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF10B981);

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _isListening
                          ? [const Color(0xFFDC2626), const Color(0xFFEF4444)]
                          : [const Color(0xFF059669), const Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white, width: 2.2),
                    boxShadow: [
                      BoxShadow(
                        color: glow.withValues(alpha: 0.55),
                        blurRadius: 18,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 📚 Full 26 Letters Modal Bottom Sheet
  void _showFullAlphabetBottomSheet() {
    final letters = Day1AlphabetData.lettersAtoZ;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('🔤', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    'Full English Alphabet (26 Letters)',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 380,
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: letters.length,
                  itemBuilder: (c, i) {
                    final item = letters[i];
                    final ltr = item['letter']?.toString() ?? '';
                    final w = item['word']?.toString() ?? '';
                    final em = item['emoji']?.toString() ?? '';
                    final snd = item['sound']?.toString() ?? '';

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _speak('$ltr for $w. $snd.');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ltr,
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFD700),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$em $w',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
