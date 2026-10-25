import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';

/// 💬 Child-Safe Gamified Mate Chat & Friendly Talk Page
/// Allows kids to practice Spoken English and communicate with their Mates
/// using pre-approved spoken phrase chips, TTS voice read-aloud, and star gifts.
/// 100% isolated from adult chats and adult telephony.
class PocketKidsMateChatPage extends StatefulWidget {
  final KidMate mate;

  const PocketKidsMateChatPage({
    super.key,
    required this.mate,
  });

  static Future<void> open(BuildContext context, {required KidMate mate}) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKidsMateChatPage(mate: mate),
      ),
    );
  }

  @override
  State<PocketKidsMateChatPage> createState() => _PocketKidsMateChatPageState();
}

class _PocketKidsMateChatPageState extends State<PocketKidsMateChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _tts = FlutterTts();

  List<KidMessage> _messages = [];
  bool _isSpeaking = false;

  final List<String> _selectedWords = [];
  bool _useKeyboardMode = false;

  static const List<String> _quickPhrases = [
    "Hello Mate! 👋",
    "High five! ✋",
    "Let's practice English! 🌟",
    "How are you today? 😊",
    "Good morning sunshine! ☀️",
    "You are doing amazing! 🚀",
    "I love our adventures! 🎈",
    "Great job, champion! 🏆",
    "See you on the trail! 🏔️",
  ];

  static const List<String> _kidWordBank = [
    "Hello", "Mate", "I", "am", "happy", "you", "are", "great", "let's", "play",
    "English", "is", "fun", "my", "good", "friend", "champion", "star",
    "see", "soon", "thank", "nice", "to", "meet", "how", "today"
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadMessages();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.3);
      await _tts.setSpeechRate(0.42);
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
    } catch (_) {}
  }

  void _loadMessages() {
    _messages = List.from(
      PocketKidsService.getMessagesForMate(
        widget.mate.id,
        mateName: widget.mate.name,
        mateAvatar: widget.mate.avatar,
      ),
    );
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

  Future<void> _speak(String text) async {
    try {
      setState(() => _isSpeaking = true);
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  Future<void> _sendMessage(String text, {bool isStarGift = false}) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    _textController.clear();
    setState(() {
      _selectedWords.clear();
    });

    final sent = await PocketKidsService.sendMessageToMate(
      mateId: widget.mate.id,
      text: cleanText,
      isStarGift: isStarGift,
    );

    setState(() {
      _messages.add(sent);
    });
    _scrollToBottom();

    // Auto-read own message in cheerful tone
    _speak(cleanText);

    // Friendly buddy simulated response after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () async {
      if (!mounted) return;
      final reply = await PocketKidsService.generateAutoMateReply(
        mateId: widget.mate.id,
        mateName: widget.mate.name,
        mateAvatar: widget.mate.avatar,
      );
      if (reply != null && mounted) {
        setState(() {
          _messages.add(reply);
        });
        _scrollToBottom();
        _speak(reply.text);
      }
    });
  }

  void _sendStarGift() {
    _sendMessage("⭐ Here is a golden Star for being a great mate! ⭐", isStarGift: true);
  }

  @override
  void dispose() {
    _tts.stop();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4), // Warm mint meadow
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFEF08A), Color(0xFFFDE047)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFEAB308), width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.mate.avatar,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.mate.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Day ${widget.mate.dayLevel} Mate • Online',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Text('🎒', style: TextStyle(fontSize: 20)),
            tooltip: 'Poket Gang',
            onPressed: () {
              HapticFeedback.mediumImpact();
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  title: Row(
                    children: [
                      const Text('🎒 ', style: TextStyle(fontSize: 22)),
                      Text(
                        'Poket Gang',
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  content: Text(
                    'Invite ${widget.mate.name} to your Poket Gang to practice Spoken English together!',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('LATER', style: TextStyle(color: Colors.white60)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: const Color(0xFF78350F),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _sendMessage('Hey ${widget.mate.name}! Want to join my Poket Gang? 🎒✨');
                      },
                      child: const Text('INVITE TO GANG ➔'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              _isSpeaking ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
              color: const Color(0xFF10B981),
            ),
            tooltip: 'Audio Playback Active',
            onPressed: () {
              if (_isSpeaking) {
                _tts.stop();
                setState(() => _isSpeaking = false);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Safe Notice Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFDCFCE7),
              child: Row(
                children: const [
                  Text('🛡️', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Friendly Kids Talk: Practice Spoken English with your Mates safely!',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),

            // Quick Spoken English Chips
            Container(
              height: 46,
              color: Colors.white,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                scrollDirection: Axis.horizontal,
                itemCount: _quickPhrases.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final phrase = _quickPhrases[idx];
                  return ActionChip(
                    backgroundColor: const Color(0xFFFEF3C7),
                    side: const BorderSide(color: Color(0xFFF59E0B), width: 1.2),
                    label: Text(
                      phrase,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB45309),
                      ),
                    ),
                    onPressed: () => _sendMessage(phrase),
                  );
                },
              ),
            ),

            // Bottom Composer & Word Bank Bar (Child-Friendly Chip Based)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sentence Preview / Input Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          // Gift Star Button
                          GestureDetector(
                            onTap: _sendStarGift,
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Text('⭐', style: TextStyle(fontSize: 19)),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Sentence Builder Display or Text Field
                          Expanded(
                            child: _useKeyboardMode
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: TextField(
                                      controller: _textController,
                                      textInputAction: TextInputAction.send,
                                      onSubmitted: (txt) => _sendMessage(txt),
                                      decoration: const InputDecoration(
                                        hintText: 'Type an English message...',
                                        hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 11),
                                      ),
                                    ),
                                  )
                                : Container(
                                    constraints: const BoxConstraints(minHeight: 42),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: _selectedWords.isNotEmpty
                                            ? const Color(0xFF38BDF8)
                                            : const Color(0xFFE2E8F0),
                                        width: 1.5,
                                      ),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: _selectedWords.isEmpty
                                        ? Text(
                                            'Tap words below to chat 🧩',
                                            style: GoogleFonts.outfit(
                                              fontSize: 12.5,
                                              color: const Color(0xFF94A3B8),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )
                                        : Wrap(
                                            spacing: 4,
                                            runSpacing: 4,
                                            children: _selectedWords.asMap().entries.map((entry) {
                                              return GestureDetector(
                                                onTap: () {
                                                  HapticFeedback.lightImpact();
                                                  setState(() {
                                                    _selectedWords.removeAt(entry.key);
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF0284C7),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        entry.value,
                                                        style: GoogleFonts.outfit(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 3),
                                                      const Icon(Icons.close_rounded, size: 12, color: Colors.white70),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                  ),
                          ),
                          const SizedBox(width: 6),

                          // Clear / Backspace button (in word bank mode)
                          if (!_useKeyboardMode && _selectedWords.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                setState(() {
                                  _selectedWords.removeLast();
                                });
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFFCA5A5)),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.backspace_rounded, size: 16, color: Color(0xFFEF4444)),
                              ),
                            ),

                          // Toggle Keyboard / Word Bank Mode
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _useKeyboardMode = !_useKeyboardMode;
                              });
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                _useKeyboardMode ? Icons.widgets_rounded : Icons.keyboard_rounded,
                                size: 18,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Send Button
                          GestureDetector(
                            onTap: () {
                              final textToSend = _useKeyboardMode
                                  ? _textController.text
                                  : _selectedWords.join(' ');
                              _sendMessage(textToSend);
                            },
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.35),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 19,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Word Bank Chips Panel (Child Friendly - Never struggle with typing)
                    if (!_useKeyboardMode)
                      Container(
                        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            top: BorderSide(color: Color(0xFFF1F5F9)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'WORD BANK 🔤 (Tap words in order)',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF64748B),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                if (_selectedWords.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      setState(() => _selectedWords.clear());
                                    },
                                    child: Text(
                                      'Clear All',
                                      style: GoogleFonts.outfit(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFEF4444),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _kidWordBank.map((word) {
                                return GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    PocketGameAudioService.instance.playPopSound();
                                    setState(() {
                                      _selectedWords.add(word);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xFFBAE6FD),
                                        width: 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF0284C7).withValues(alpha: 0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      word,
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFF0369A1),
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(KidMessage msg) {
    final isMe = msg.isFromMe;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF38BDF8), width: 1.8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                    blurRadius: 6,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(msg.senderAvatar, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _speak(msg.text);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isMe
                      ? const LinearGradient(
                          colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(22),
                    topRight: const Radius.circular(22),
                    bottomLeft: Radius.circular(isMe ? 22 : 6),
                    bottomRight: Radius.circular(isMe ? 6 : 22),
                  ),
                  border: Border.all(
                    color: isMe ? const Color(0xFFFCD34D) : const Color(0xFFBAE6FD),
                    width: 1.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isMe ? const Color(0xFFF59E0B) : const Color(0xFF0284C7))
                          .withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (msg.isStarGift) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '⭐ STAR COOKIE GIFT 🍪',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            msg.text,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isMe
                                  ? const Color(0xFF78350F)
                                  : const Color(0xFF0F172A),
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Cheerful Voice Note Sound Wave
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: isMe
                                ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                                : const Color(0xFF38BDF8).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.volume_up_rounded,
                            size: 14,
                            color: isMe
                                ? const Color(0xFFB45309)
                                : const Color(0xFF0284C7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    blurRadius: 6,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                PocketKidsService.kidAvatar.isNotEmpty ? PocketKidsService.kidAvatar : '🦁',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
