import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_voice_service.dart';
import 'pocket_fortress_defense_service.dart';

import 'curriculum_data/pocket_90day_chat_reply_data.dart';

/// 💬 Conversational Chat Reply Scenario Model
class ChatReplyScenario {
  final int id;
  final String avatarPrompt;
  final String avatarPromptMl;
  final String expectedReply;
  final String expectedReplyMl;
  final List<String> wordBank; // Target words + distractors
  final String topicTag;

  const ChatReplyScenario({
    required this.id,
    required this.avatarPrompt,
    required this.avatarPromptMl,
    required this.expectedReply,
    required this.expectedReplyMl,
    required this.wordBank,
    required this.topicTag,
  });
}

/// 💬 Interactive Chat Reply Builder Page (Step 9)
///
/// Features:
/// - Minimal, sleek WhatsApp-style interactive chat UI
/// - CyberCat sends natural conversational English questions (Greetings, Food, Learning, Location, Readiness)
/// - Bottom Word Bank where learner taps words in correct sequential order to formulate reply
/// - Error vibration & shake feedback if incorrect word is tapped (Sentence Builder mechanics)
/// - Correct word snaps into chat composer bar with tactile haptic and audio chime
/// - Sends into live chat thread upon sentence completion
class PocketChatReplyBuilderPage extends StatefulWidget {
  final int day;
  final String? userId;
  final Function(int)? onStepFinished;

  const PocketChatReplyBuilderPage({
    super.key,
    this.day = 1,
    this.userId,
    this.onStepFinished,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    String? userId,
    Function(int)? onStepFinished,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketChatReplyBuilderPage(
          day: day,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<PocketChatReplyBuilderPage> createState() =>
      _PocketChatReplyBuilderPageState();
}

class _PocketChatReplyBuilderPageState extends State<PocketChatReplyBuilderPage>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _shakeAnimController;

  int _currentScenarioIndex = 0;
  final List<Map<String, dynamic>> _chatHistory = []; // {'isUser': bool, 'text': String, 'ml': String}
  final List<String> _selectedWords = [];
  List<String> _shuffledWordBank = [];
  bool _isSpeaking = false;
  bool _isCompleted = false;
  String? _shakingWord;
  late final List<ChatReplyScenario> _scenarios;

  @override
  void initState() {
    super.initState();
    _scenarios = Pocket90DayChatReplyData.getScenariosForDay(widget.day);
    _initTts();

    _shakeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _loadCurrentScenario();
  }

  Future<void> _initTts() async {
    try {
      await PocketVoiceService.instance.configureOptimalFemaleVoice(_tts);
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
    } catch (_) {}
  }

  void _loadCurrentScenario() {
    if (_currentScenarioIndex >= _scenarios.length) {
      _finishAllScenarios();
      return;
    }

    final scenario = _scenarios[_currentScenarioIndex];
    final words = List<String>.from(scenario.wordBank)..shuffle(math.Random());

    setState(() {
      _selectedWords.clear();
      _shuffledWordBank = words;
      _chatHistory.add({
        'isUser': false,
        'text': scenario.avatarPrompt,
        'ml': scenario.avatarPromptMl,
        'tag': scenario.topicTag,
      });
    });

    _speak(scenario.avatarPrompt);
    _scrollToBottom();
  }

  Future<void> _speak(String text) async {
    try {
      setState(() => _isSpeaking = true);
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onWordTapped(String word) {
    if (_isCompleted) return;
    final scenario = _scenarios[_currentScenarioIndex];
    final expectedTokens = scenario.expectedReply.split(' ');
    final nextTargetIndex = _selectedWords.length;

    if (nextTargetIndex >= expectedTokens.length) return;

    final targetExpectedWord = expectedTokens[nextTargetIndex];

    // Check if tapped word matches next expected word (case-sensitive or exact token)
    if (word == targetExpectedWord) {
      // Correct word tapped!
      PocketGameSfx.instance.playSnapCorrect();
      setState(() {
        _selectedWords.add(word);
        _shuffledWordBank.remove(word);
      });

      // Check if full reply is completed!
      if (_selectedWords.length == expectedTokens.length) {
        _onReplyCompleted();
      }
    } else {
      // Incorrect word tapped! Trigger error vibration and shake
      PocketGameSfx.instance.playErrorBuzz();
      HapticFeedback.heavyImpact();
      setState(() {
        _shakingWord = word;
      });
      _shakeAnimController.forward(from: 0.0).then((_) {
        if (mounted) setState(() => _shakingWord = null);
      });
    }
  }

  void _onReplyCompleted() {
    final scenario = _scenarios[_currentScenarioIndex];
    PocketGameSfx.instance.playVictory();

    // Add to chat history
    setState(() {
      _chatHistory.add({
        'isUser': true,
        'text': scenario.expectedReply,
        'ml': scenario.expectedReplyMl,
      });
    });

    _speak(scenario.expectedReply);
    _scrollToBottom();

    // Advance to next after short pause
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() {
        _currentScenarioIndex++;
      });
      _loadCurrentScenario();
    });
  }

  Future<void> _finishAllScenarios() async {
    setState(() => _isCompleted = true);
    final uid = widget.userId ?? SupaFlow.client.auth.currentUser?.id;
    final prefs = await SharedPreferences.getInstance();

    // Record Step 9 completed in prefs
    final userKey = uid != null ? 'pocket_day_${uid}_${widget.day}_step_9_done' : null;
    if (userKey != null) await prefs.setBool(userKey, true);
    await prefs.setBool('pocket_day_guest_${widget.day}_step_9_done', true);

    await PocketFortressDefenseService.recordTrainingPoints(35, uid);
    widget.onStepFinished?.call(9);

    if (!mounted) return;
    _showCompletionModal();
  }

  void _showCompletionModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF10B981), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'CHAT MASTERED! 💬',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You formulated 5 natural conversational chat replies with word-bank precision!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF132238),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      '+35 POCKET SCORE AWARDED!',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'CONTINUE TO NEXT STEP ➔',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
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
    _tts.stop();
    _shakeAnimController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentScenario = (_currentScenarioIndex < _scenarios.length)
        ? _scenarios[_currentScenarioIndex]
        : _scenarios.last;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1118),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('💬', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  'Chat Reply',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              'Step 9 • Day ${widget.day}',
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚡', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  '${_currentScenarioIndex + 1} / ${_scenarios.length}',
                  style: GoogleFonts.robotoMono(
                    color: const Color(0xFF00E676),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Progress Indicator
            LinearProgressIndicator(
              value: (_currentScenarioIndex + 1) / _scenarios.length,
              minHeight: 4,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
            ),

            // Scrollable Chat Message Feed
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: _chatHistory.length,
                itemBuilder: (context, index) {
                  final msg = _chatHistory[index];
                  final isUser = msg['isUser'] as bool;
                  return _buildChatBubble(
                    text: msg['text'] as String,
                    ml: msg['ml'] as String,
                    isUser: isUser,
                    tag: msg['tag'] as String?,
                  );
                },
              ),
            ),

            // Interactive Composing & Word Bank Area
            if (!_isCompleted) ...[
              _buildReplyComposer(currentScenario),
              _buildWordBankArea(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble({
    required String text,
    required String ml,
    required bool isUser,
    String? tag,
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (tag != null && !isUser)
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isUser
                      ? [const Color(0xFF059669), const Color(0xFF10B981)]
                      : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: Border.all(
                  color: isUser
                      ? const Color(0xFF34D399)
                      : const Color(0xFF334155),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          text,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!isUser) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _speak(text),
                          child: Icon(
                            _isSpeaking
                                ? Icons.volume_up_rounded
                                : Icons.volume_down_rounded,
                            color: const Color(0xFF00E676),
                            size: 18,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (ml.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      ml,
                      style: GoogleFonts.inter(
                        color: isUser ? Colors.white70 : const Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📝 Dynamic Reply Composing Slot
  Widget _buildReplyComposer(ChatReplyScenario scenario) {
    final expectedTokens = scenario.expectedReply.split(' ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(
          top: BorderSide(color: Color(0xFF1E293B), width: 1.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YOUR REPLY • TAP WORDS IN ORDER:',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF00E676),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              if (_selectedWords.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      final removed = _selectedWords.removeLast();
                      _shuffledWordBank.add(removed);
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.undo_rounded, size: 14, color: Colors.white60),
                      const SizedBox(width: 3),
                      Text(
                        'Undo',
                        style: GoogleFonts.inter(color: Colors.white60, fontSize: 10),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Slots container
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 46),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1118),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _selectedWords.length == expectedTokens.length
                    ? const Color(0xFF10B981)
                    : const Color(0xFF334155),
                width: 1.2,
              ),
            ),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (_selectedWords.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'Tap the first word below to start typing...',
                      style: GoogleFonts.inter(color: Colors.white30, fontSize: 12),
                    ),
                  )
                else
                  for (final word in _selectedWords)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF065F46),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF34D399), width: 1.0),
                      ),
                      child: Text(
                        word,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 13,
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

  /// 🔤 Word Bank with Touch Chips
  Widget _buildWordBankArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
      color: const Color(0xFF0F172A),
      child: Wrap(
        spacing: 8,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: _shuffledWordBank.map((word) {
          final isShaking = _shakingWord == word;

          Widget chip = GestureDetector(
            onTap: () => _onWordTapped(word),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: isShaking ? const Color(0xFF7F1D1D) : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isShaking
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF475569),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isShaking ? const Color(0xFFEF4444) : Colors.black)
                        .withValues(alpha: 0.35),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                word,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );

          if (isShaking) {
            chip = AnimatedBuilder(
              animation: _shakeAnimController,
              builder: (context, child) {
                final offset = math.sin(_shakeAnimController.value * math.pi * 5) * 8.0;
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: child,
                );
              },
              child: chip,
            );
          }

          return chip;
        }).toList(),
      ),
    );
  }
}
