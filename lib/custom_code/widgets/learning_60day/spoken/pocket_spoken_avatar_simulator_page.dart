import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pocket_90day_spoken_simulator_data.dart';
import '../pocket_fortress_defense_service.dart';

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
    _startExchange(0);
  }

  Future<void> _initTts() async {
    try {
      _flutterTts = FlutterTts();
      await _flutterTts?.setLanguage('en-US');
      await _flutterTts?.setSpeechRate(0.46); // Natural conversational cadence
      await _flutterTts?.setVolume(1.0);
      await _flutterTts?.setPitch(1.0);

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

  @override
  void dispose() {
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TAP OR SPEAK YOUR RESPONSE 👇',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF38BDF8),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.mic_none_rounded, color: Colors.white38, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Voice Repetition',
                    style: GoogleFonts.inter(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...exchange.responseOptions.map((opt) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onSelectResponse(opt),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('💬', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            opt,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.send_rounded, color: Color(0xFF38BDF8), size: 16),
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
