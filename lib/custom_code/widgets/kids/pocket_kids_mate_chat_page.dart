import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';

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

            // Bottom Composer Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Gift Star Button
                  GestureDetector(
                    onTap: _sendStarGift,
                    child: Container(
                      width: 44,
                      height: 44,
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
                      child: const Text('⭐', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Text Field
                  Expanded(
                    child: Container(
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
                          hintText: 'Type or choose a phrase...',
                          hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Voice Message Button (English Only)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      _sendMessage('🎙️ Spoken English Voice Note: "Great job practicing with me today!" 🌟');
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.mic_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Send Button
                  GestureDetector(
                    onTap: () => _sendMessage(_textController.text),
                    child: Container(
                      width: 44,
                      height: 44,
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
                        size: 20,
                      ),
                    ),
                  ),
                ],
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(msg.senderAvatar, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isMe
                    ? const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isMe ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: isMe ? null : Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
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
                        color: isMe ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '⭐ STAR GIFT ⭐',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: isMe ? Colors.white : const Color(0xFFB45309),
                          letterSpacing: 1,
                        ),
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
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isMe ? Colors.white : const Color(0xFF0F172A),
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // TTS Read Aloud Icon
                      GestureDetector(
                        onTap: () => _speak(msg.text),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.white.withValues(alpha: 0.25)
                                : const Color(0xFFE2E8F0),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.volume_up_rounded,
                            size: 14,
                            color: isMe ? Colors.white : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(PocketKidsService.kidAvatar, style: const TextStyle(fontSize: 18)),
            ),
          ],
        ],
      ),
    );
  }
}
