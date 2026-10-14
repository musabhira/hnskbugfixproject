import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pocket_90day_spoken_simulator_data.dart';
import '../pocket_fortress_defense_service.dart';
import '../pocket_pronunciation_evaluator.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_voice_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';

/// 🎙️ Pocket Spoken English Avatar Simulator Page
///
/// Implements the User's Audio Directive:
/// - Dedicated Spoken English step in every single day (Days 1 to 90).
/// - Modeled after the Onboarding Avatar: Avatar speaks aloud with TTS speech,
///   asking questions and contextual dialogue prompts.
/// - Below, clean interactive response bubbles (chips) are displayed.
/// - Learners tap or speak aloud to send their answer back.
/// - 20 unique conversational exchanges per day (90 Days × 20 = 1,800 total unique dialogues).
/// - Non-complicated, minimal, beautiful mobile-first UI with zero clutter.
class PocketSpokenAvatarSimulatorPage extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;

  const PocketSpokenAvatarSimulatorPage({
    super.key,
    required this.day,
    this.onCompleted,
  });

  static Future<bool?> launch(BuildContext context, {required int day, VoidCallback? onCompleted}) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PocketSpokenAvatarSimulatorPage(
          day: day,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketSpokenAvatarSimulatorPage> createState() => _PocketSpokenAvatarSimulatorPageState();
}

class _ChatMessageItem {
  final bool isAvatar;
  final String text;
  final String? translationMl;
  final String? tip;

  _ChatMessageItem({
    required this.isAvatar,
    required this.text,
    this.translationMl,
    this.tip,
  });
}

class _PocketSpokenAvatarSimulatorPageState extends State<PocketSpokenAvatarSimulatorPage>
    with SingleTickerProviderStateMixin {
  late DaySpokenSimulatorPlan _plan;
  int _currentIndex = 0; // 0 to 19 (for 20 exchanges)
  int _earnedXp = 0;
  bool _isSpeaking = false;
  bool _isCompleted = false;

  bool _isRecording = false;
  String _spokenText = '';
  String? _speechError;
  int _recordingSeconds = 0;
  Timer? _recordTimer;
  stt.SpeechToText? _speech;
  bool _speechAvailable = false;

  final List<_ChatMessageItem> _chatHistory = [];
  final ScrollController _scrollController = ScrollController();
  FlutterTts? _flutterTts;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _plan = Pocket90DaySpokenSimulatorData.getPlanForDay(widget.day);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initTts();
    _initSpeechRecognizer();
    _startExchange(0);
  }

  Future<void> _initSpeechRecognizer() async {
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (!isMobile) {
      _speechAvailable = false;
      return;
    }
    try {
      _speech = stt.SpeechToText();
      final available = await _speech!.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted && _isRecording) {
              setState(() => _isRecording = false);
            }
          }
        },
        onError: (_) {
          if (mounted && _isRecording) {
            setState(() => _isRecording = false);
          }
        },
      );
      if (mounted) setState(() => _speechAvailable = available);
    } catch (_) {
      if (mounted) setState(() => _speechAvailable = false);
    }
  }

  Future<void> _initTts() async {
    try {
      _flutterTts = FlutterTts();
      if (_flutterTts != null) {
        await PocketVoiceService.instance.configureOptimalFemaleVoice(_flutterTts!);
      }

      _flutterTts?.setStartHandler(() {
        if (mounted) setState(() => _isSpeaking = true);
      });
      _flutterTts?.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
      _flutterTts?.setErrorHandler((_) {
        if (mounted) setState(() => _isSpeaking = false);
      });
    } catch (_) {}
  }

  Future<void> _speakText(String text) async {
    if (_flutterTts == null) return;
    try {
      await _flutterTts?.stop();
      await _flutterTts?.speak(text);
    } catch (_) {}
  }

  void _startExchange(int index) {
    if (index >= _plan.exchanges.length) {
      _handleCompleted();
      return;
    }

    final exchange = _plan.exchanges[index];
    setState(() {
      _currentIndex = index;
      _chatHistory.add(
        _ChatMessageItem(
          isAvatar: true,
          text: exchange.avatarPrompt,
          translationMl: exchange.avatarPromptMl,
          tip: exchange.speechTip,
        ),
      );
    });

    _speakText(exchange.avatarPrompt);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _onSelectResponse(String optionText) async {
    HapticFeedback.lightImpact();

    setState(() {
      _earnedXp += 10;
      _chatHistory.add(
        _ChatMessageItem(
          isAvatar: false,
          text: optionText,
        ),
      );
    });

    _scrollToBottom();
    await _speakText(optionText);

    // Short natural pause before avatar replies
    await Future.delayed(const Duration(milliseconds: 900));

    if (mounted) {
      if (_currentIndex + 1 < _plan.exchanges.length) {
        _startExchange(_currentIndex + 1);
      } else {
        _handleCompleted();
      }
    }
  }

  Future<void> _handleCompleted() async {
    if (_isCompleted) return;
    setState(() => _isCompleted = true);

    HapticFeedback.heavyImpact();
    final prefs = await SharedPreferences.getInstance();
    final dayKey = 'pocket_mission_day_${widget.day}';
    await prefs.setBool('${dayKey}_spoken_simulator', true);

    await PocketFortressDefenseService.recordTrainingPoints(150);

    widget.onCompleted?.call();

    if (!mounted) return;
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF10B981), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                blurRadius: 28,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF10B981),
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 16),
              Text(
                'Day ${widget.day} Dialogue Mastered! 🎙️',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '20 Real-World Conversational Exchanges Completed',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF10B981),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your mouth and speech reflexes are warmed up! Muscle memory compounds with every dialogue.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, color: Colors.amberAccent, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '+$_earnedXp XP & Fluency Points',
                      style: GoogleFonts.outfit(
                        color: Colors.amberAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'CONTINUE ROADMAP ➔',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
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

  Future<void> _toggleRecording(String targetPhrase) async {
    if (_isCompleted) return;

    if (!_isRecording) {
      HapticFeedback.heavyImpact();
      setState(() {
        _isRecording = true;
        _spokenText = '';
        _recordingSeconds = 0;
      });

      _recordTimer?.cancel();
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted && _isRecording) {
          setState(() => _recordingSeconds++);
        }
      });

      final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
      if (isMobile && _speechAvailable && _speech != null) {
        try {
          await _speech!.listen(
            onResult: (result) {
              if (mounted && _isRecording) {
                setState(() => _spokenText = result.recognizedWords);
              }
            },
            listenOptions: stt.SpeechListenOptions(
              listenFor: const Duration(seconds: 20),
              pauseFor: const Duration(seconds: 3),
              partialResults: true,
              listenMode: stt.ListenMode.confirmation,
            ),
          );
        } catch (_) {}
      }
    } else {
      // STOP recording & submit!
      HapticFeedback.heavyImpact();
      _recordTimer?.cancel();

      final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
      if (isMobile && _speechAvailable && _speech != null) {
        try {
          await _speech!.stop();
        } catch (_) {}
      }

      setState(() => _isRecording = false);

      final normalizedSpk = PocketSpeechNormalizer.normalize(_spokenText);
      final cleanSpk = normalizedSpk.isNotEmpty ? normalizedSpk : PocketSpeechNormalizer.clean(_spokenText);

      if (cleanSpk.isEmpty) {
        PocketGameAudioService.instance.playIncorrectSound();
        setState(() {
          _speechError = 'Microphone did not detect your voice.\nPlease tap the mic and speak: "$targetPhrase"';
        });
        await _speakText('Please speak into the mic: $targetPhrase');
        return;
      }

      final isMatch = PocketSpeechNormalizer.isMatch(
        spokenText: _spokenText,
        targetSentence: targetPhrase,
        thresholdPercentage: 40,
      );

      final evalResult = PocketPronunciationEvaluator.evaluate(
        targetSentence: targetPhrase,
        spokenText: _spokenText,
      );

      if (!isMatch && evalResult.accuracyPercentage < 40) {
        PocketGameAudioService.instance.playIncorrectSound();
        final focus = evalResult.focusWords.take(2).join(', ');
        setState(() {
          _speechError = 'You said: "$_spokenText"\nExpected: "$targetPhrase"${focus.isNotEmpty ? "\nFocus on: $focus" : ""}';
        });
        await _speakText('Not quite right. Please say: $targetPhrase');
        return;
      }

      // Passed!
      PocketGameAudioService.instance.playCorrectSound();
      setState(() {
        _speechError = null;
      });

      await _onSelectResponse(normalizedSpk.isNotEmpty ? normalizedSpk : _spokenText.trim());
    }
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    try {
      if (_speechAvailable) _speech?.stop();
    } catch (_) {}
    _flutterTts?.stop();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentExchange = _currentIndex < _plan.exchanges.length
        ? _plan.exchanges[_currentIndex]
        : null;

    final progress = (_currentIndex + 1) / _plan.exchanges.length.toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Day ${widget.day} • Spoken Simulator 🎙️',
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              _plan.topicTitle,
              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF38BDF8), fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: Colors.amberAccent, size: 16),
                const SizedBox(width: 4),
                Text(
                  '+$_earnedXp XP',
                  style: GoogleFonts.outfit(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Line & Exchange Counter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF0B1220),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Exchange ${_currentIndex + 1} of ${_plan.exchanges.length}',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}% Done',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF10B981),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 5,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                    ),
                  ),
                ],
              ),
            ),

            // Top Avatar Presence Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0E1726),
                border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
              ),
              child: Row(
                children: [
                  ScaleTransition(
                    scale: _isSpeaking ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isSpeaking ? const Color(0xFF38BDF8) : Colors.transparent)
                                .withValues(alpha: 0.5),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🧑‍🏫', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Coach Sarah',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (_isSpeaking)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'SPEAKING 🔊',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF10B981),
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _plan.scenarioContext,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (currentExchange != null)
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8), size: 22),
                      tooltip: 'Replay audio',
                      onPressed: () => _speakText(currentExchange.avatarPrompt),
                    ),
                ],
              ),
            ),

            // Chat Timeline
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                itemCount: _chatHistory.length,
                itemBuilder: (context, idx) {
                  final msg = _chatHistory[idx];
                  if (msg.isAvatar) {
                    return _buildAvatarBubble(msg);
                  } else {
                    return _buildUserBubble(msg);
                  }
                },
              ),
            ),

            // Bottom Interactive Response Choices (Like Onboarding Avatar)
            if (!_isCompleted && currentExchange != null)
              _buildResponseOptionsSheet(currentExchange),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarBubble(_ChatMessageItem msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
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
            child: const Center(child: Text('🧑‍🏫', style: TextStyle(fontSize: 16))),
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
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.text,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      if (msg.translationMl != null && msg.translationMl!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          msg.translationMl!,
                          style: GoogleFonts.notoSansMalayalam(
                            color: Colors.white60,
                            fontSize: 11.5,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (msg.tip != null && msg.tip!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded, color: Colors.amberAccent, size: 12),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          msg.tip!,
                          style: GoogleFonts.inter(
                            color: Colors.amberAccent,
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserBubble(_ChatMessageItem msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF10B981)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      msg.text,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.check_rounded, color: Colors.white, size: 16),
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
              color: Color(0xFF10B981),
            ),
            child: const Center(child: Text('🗣️', style: TextStyle(fontSize: 15))),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseOptionsSheet(SpokenDialogueExchange exchange) {
    final targetPhrase = exchange.responseOptions[exchange.bestResponseIndex.clamp(0, exchange.responseOptions.length - 1)];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 📢 PROMINENT BOLD SPEAK PROMPT CARD (User Audio Directive: "bond aakki ezhuthi kaanikkanam!")
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _isRecording ? const Color(0xFFEF4444) : const Color(0xFFFFD700),
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_isRecording ? const Color(0xFFEF4444) : const Color(0xFFFFD700)).withValues(alpha: 0.25),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.record_voice_over_rounded, color: Color(0xFF38BDF8), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'SPEAK THIS ALOUD 👇',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF38BDF8),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Bold Target Phrase
                Text(
                  '"$targetPhrase"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                    height: 1.3,
                  ),
                ),

                // Live Recording Feedback
                if (_isRecording) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEF4444), width: 1),
                    ),
                    child: Row(
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
                          'RECORDING 00:${_recordingSeconds.toString().padLeft(2, '0')}',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFCA5A5),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _spokenText.isNotEmpty ? '“$_spokenText”' : 'Listening... Speak aloud now',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: _spokenText.isNotEmpty ? const Color(0xFFFFD700) : Colors.white60,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (_speechError != null && !_isRecording)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEF4444)),
                      ),
                      child: Text(
                        _speechError!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFFCA5A5),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 🎙️ Centered Floating Mic Action Button
          GestureDetector(
            onTap: () => _toggleRecording(targetPhrase),
            child: ScaleTransition(
              scale: _isRecording ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _isRecording
                        ? [const Color(0xFFEF4444), const Color(0xFFB91C1C)]
                        : [const Color(0xFF059669), const Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: _isRecording ? const Color(0xFFFCA5A5) : const Color(0xFFFFD700),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isRecording ? const Color(0xFFEF4444) : const Color(0xFF10B981)).withValues(alpha: 0.5),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _isRecording ? 'Tap red button to STOP & send' : 'Tap mic & speak aloud',
            style: GoogleFonts.inter(
              color: _isRecording ? const Color(0xFFFCA5A5) : Colors.white70,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          // Quick Tap Options Divider & Chips (for alternative tap answering)
          Row(
            children: [
              const Expanded(child: Divider(color: Colors.white12)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'OR TAP TO ANSWER',
                  style: GoogleFonts.outfit(
                    color: Colors.white38,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: Colors.white12)),
            ],
          ),
          const SizedBox(height: 8),

          ...exchange.responseOptions.map((opt) {
            final isPrimary = opt == targetPhrase;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onSelectResponse(opt),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isPrimary
                          ? const Color(0xFF10B981).withValues(alpha: 0.12)
                          : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPrimary
                            ? const Color(0xFF10B981).withValues(alpha: 0.6)
                            : Colors.white10,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(isPrimary ? '⭐' : '💬', style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            opt,
                            style: GoogleFonts.outfit(
                              color: isPrimary ? const Color(0xFFD1FAE5) : Colors.white70,
                              fontSize: 13,
                              fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: isPrimary ? const Color(0xFF10B981) : Colors.white24,
                          size: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
