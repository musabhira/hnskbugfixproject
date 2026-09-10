import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';
import 'package:pocket_mates_app/custom_code/widgets/ads/pocket_ad_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_mate_service.dart';
import 'package:pocket_mates_app/custom_code/services/anonymous_match_service.dart';

/// Omegle-Style Anonymous 1-on-1 Text Match with Animated Radar & Quick Skip
class AnonymousEnglishChatPage extends StatefulWidget {
  const AnonymousEnglishChatPage({super.key});

  @override
  State<AnonymousEnglishChatPage> createState() => _AnonymousEnglishChatPageState();
}

class _AnonymousEnglishChatPageState extends State<AnonymousEnglishChatPage>
    with SingleTickerProviderStateMixin {
  final _supabase = SupaFlow.client;
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AnonymousMatchService _matchService = AnonymousMatchService();

  late AnimationController _radarController;

  bool _isSearching = true;
  String _radarStatus = '📡 Scanning matchmaking pool for active strangers...';
  int _onlineCount = 28;

  AnonymousPeer? _matchedPeer;
  bool _isPeerTyping = false;

  final List<Map<String, dynamic>> _messages = [];
  bool _requestSent = false;
  bool _isMutualPocketMate = false;

  String _currentIcebreaker = '';

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _onlineCount = _matchService.getEstimatedOnlineCount();
    _currentIcebreaker = _matchService.getRandomIcebreaker();
    _startMatchmaking();
  }

  @override
  void dispose() {
    _radarController.dispose();
    _msgController.dispose();
    _scrollController.dispose();
    _matchService.leave();
    super.dispose();
  }

  Future<void> _startMatchmaking() async {
    setState(() {
      _isSearching = true;
      _radarStatus = '📡 Scanning matchmaking pool for active strangers...';
      _matchedPeer = null;
      _messages.clear();
      _requestSent = false;
      _isMutualPocketMate = false;
      _isPeerTyping = false;
      _currentIcebreaker = _matchService.getRandomIcebreaker();
      _onlineCount = _matchService.getEstimatedOnlineCount();
    });

    final myId = _supabase.auth.currentUser?.id ?? 'guest_${math.Random().nextInt(99999)}';

    // My temporary avatar
    final myAvatar = VectorAvatarConfig.getEvolutionAvatarForStage(15);
    final myMoniker = _matchService.getRandomMoniker();

    try {
      final peer = await _matchService.searchAndMatch(
        myUserId: myId,
        myAvatarConfig: myAvatar,
        myMoniker: myMoniker,
        onStatusUpdate: (status) {
          if (mounted) setState(() => _radarStatus = status);
        },
      );

      if (!mounted) return;

      // Check if already mutual pocket mate
      final prefs = await SharedPreferences.getInstance();
      final pocketList = prefs.getStringList('pocket_mates_$myId') ?? [];
      final isPocket = pocketList.contains(peer.peerId);

      // Automatic Connection as requested by user
      HapticFeedback.mediumImpact();

      // Listen to real-time room channel if live peer
      if (peer.isLivePeer) {
        _matchService.subscribeToRoom(
          roomId: peer.roomId,
          onMessageReceived: (payload) {
            final senderId = payload['sender_id']?.toString();
            if (senderId != myId) {
              if (mounted) {
                setState(() {
                  _messages.add({
                    'isMe': false,
                    'text': payload['text']?.toString() ?? '',
                    'time': DateTime.now(),
                  });
                });
                _scrollToBottom();
              }
            }
          },
        );
      }

      setState(() {
        _matchedPeer = peer;
        _isMutualPocketMate = isPocket;
        _isSearching = false;

        // Welcome banner
        _messages.add({
          'isSystem': true,
          'text': '🎭 Matched with ${peer.moniker}!\nSay hi and start a friendly conversation. Tap "Next" anytime to match with someone new.',
          'time': DateTime.now(),
        });
      });
    } catch (e) {
      debugPrint('Matchmaking error: $e');
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();
    HapticFeedback.lightImpact();

    setState(() {
      _messages.add({
        'isMe': true,
        'text': text,
        'time': DateTime.now(),
      });
    });

    _scrollToBottom();

    final myId = _supabase.auth.currentUser?.id ?? 'guest';
    final currentPeer = _matchedPeer;
    if (currentPeer == null) return;

    if (currentPeer.isLivePeer) {
      // Broadcast to live peer via Supabase Realtime
      await _matchService.sendRoomMessage(
        roomId: currentPeer.roomId,
        senderId: myId,
        text: text,
      );
    } else {
      // Dynamic community peer simulation for instant, fluid interactivity
      setState(() => _isPeerTyping = true);

      final replyDelay = 1200 + math.Random().nextInt(1400);
      Timer(Duration(milliseconds: replyDelay), () {
        if (!mounted || _matchedPeer?.peerId != currentPeer.peerId) return;

        final contextualReplies = _generateSmartReply(text);
        setState(() {
          _isPeerTyping = false;
          _messages.add({
            'isMe': false,
            'text': contextualReplies,
            'time': DateTime.now(),
          });
        });
        _scrollToBottom();
      });
    }
  }

  String _generateSmartReply(String userMsg) {
    final lower = userMsg.toLowerCase();
    if (lower.contains('hi') || lower.contains('hello') || lower.contains('hey')) {
      final list = [
        "Hey! How's your day going so far?",
        "Hello! Great to connect with you here.",
        "Hey there! Where in the world are you from?",
      ];
      list.shuffle();
      return list.first;
    }
    if (lower.contains('how are you') || lower.contains('sup')) {
      return "I'm doing great! Just exploring Pocket Mates. How about yourself?";
    }
    if (lower.contains('where') || lower.contains('place') || lower.contains('from')) {
      return "I'm checking in from Kerala! What about you?";
    }
    if (lower.contains('what do you do') || lower.contains('job') || lower.contains('study')) {
      return "I love learning new things and chatting with people. What are you passionate about?";
    }
    final defaultReplies = [
      "That is super interesting! Tell me more about it.",
      "Totally agree with you on that. How did you get into that?",
      "Nice! I was actually thinking about the exact same thing earlier today.",
      "Haha that's awesome. Pocket Mates is full of cool surprises!",
      "I feel you! By the way, what kind of movies or music are you into?",
      "That's really cool! Have you been on Pocket Mates for long?",
    ];
    defaultReplies.shuffle();
    return defaultReplies.first;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _skipToNextPartner() async {
    HapticFeedback.selectionClick();
    _matchService.leave();

    // Show brief ad if required for free tier
    await PocketAdService().showVideoAd(
      context: context,
      placementTitle: 'Next Stranger Match',
    );

    _startMatchmaking();
  }

  Future<void> _sendPocketMateRequest() async {
    final myId = _supabase.auth.currentUser?.id;
    final peerUserId = _matchedPeer?.peerId ?? '';
    if (myId == null || peerUserId.isEmpty) return;

    HapticFeedback.mediumImpact();
    setState(() => _requestSent = true);

    String myName = 'Anonymous Mate';
    try {
      final pRes = await _supabase.from('profile').select('name').eq('user_id', myId).maybeSingle();
      if (pRes != null && pRes['name'] != null) {
        myName = pRes['name'];
      }
    } catch (_) {}

    await PocketMateService.sendMateRequest(
      senderId: myId,
      receiverId: peerUserId,
      senderName: myName,
      message: 'Matched from Anonymous Chat! Wants to add you to their Pocket Mates.',
      contextType: 'anonymous_chat',
    );

    await PocketMateService.addMate(myId, peerUserId);

    if (mounted) {
      setState(() => _isMutualPocketMate = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFFC00)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '🤝 Mate Request Sent! Once accepted, they will appear in your Mates tab.',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openPermanentChat() {
    final peerUserId = _matchedPeer?.peerId ?? '';
    if (peerUserId.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WhatsAppGroupChat(
          groupId: 'p:$peerUserId',
          groupName: _matchedPeer?.moniker ?? 'Pocket Mate',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090A10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F111A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isSearching
            ? Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Anonymous Radar',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  if (_matchedPeer != null) ...[
                    VectorAvatarWidget(config: _matchedPeer!.avatarConfig, size: 38),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                _matchedPeer?.moniker ?? 'Anonymous Mate',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'ONLINE',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF10B981),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '🔒 100% Private • Stranger',
                          style: GoogleFonts.inter(color: Colors.white54, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        actions: [
          if (!_isSearching)
            // Omegle "Next" Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: ElevatedButton.icon(
                onPressed: _skipToNextPartner,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFC00),
                  foregroundColor: Colors.black,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.skip_next_rounded, size: 18, color: Colors.black),
                label: Text(
                  'Next',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12.5),
                ),
              ),
            ),
        ],
      ),
      body: _isSearching ? _buildRadarSearchBody() : _buildChatRoomBody(),
    );
  }

  /// Visual Radar Screen with expanding concentric ripples & live counter
  Widget _buildRadarSearchBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Live online strangers counter badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2438),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
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
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$_onlineCount Strangers Online Now',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Radar Concentric Animation
          SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _radarController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(240, 240),
                      painter: _RadarConcentricPainter(progress: _radarController.value),
                    );
                  },
                ),
                // Glowing Center Avatar
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF141724),
                    border: Border.all(color: const Color(0xFFFFFC00), width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFFC00).withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🎭', style: TextStyle(fontSize: 34)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Dynamic Status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _radarStatus,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 100% Privacy Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_rounded, color: Color(0xFFFFFC00), size: 14),
                const SizedBox(width: 6),
                Text(
                  '100% Privacy • Avatar & Moniker Only',
                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Cancel button
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24),
              foregroundColor: Colors.white70,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: Text(
              'Cancel Search',
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  /// Live Chat Room Body
  Widget _buildChatRoomBody() {
    return Column(
      children: [
        // Top Stranger Privacy & Add Mate Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF121522),
            border: Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '⚡ Stranger Chat • Zero Limits',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Mutual Add to Pocket Mates Button
              if (_isMutualPocketMate)
                GestureDetector(
                  onTap: _openPermanentChat,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF10B981)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Pocket Mates',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: _sendPocketMateRequest,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFC00),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_add_rounded, color: Colors.black, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          _requestSent ? 'Request Sent' : 'Add Mate',
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Message List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_isPeerTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length && _isPeerTyping) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2235),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_matchedPeer?.moniker ?? "Stranger"} is typing...',
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 11.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final msg = _messages[index];
              final isSystem = msg['isSystem'] == true;
              final isMe = msg['isMe'] == true;

              if (isSystem) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1E30),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    msg['text'] ?? '',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                );
              }

              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFFFFFC00) : const Color(0xFF1E2235),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    msg['text'] ?? '',
                    style: GoogleFonts.inter(
                      color: isMe ? Colors.black : Colors.white,
                      fontSize: 13.5,
                      fontWeight: isMe ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Quick Icebreaker Suggestion Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          color: const Color(0xFF0F111A),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIcebreaker = _matchService.getRandomIcebreaker();
                  });
                  HapticFeedback.selectionClick();
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2438),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('🎲', style: TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _msgController.text = _currentIcebreaker;
                  },
                  child: Text(
                    _currentIcebreaker,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: const Color(0xFFFFFC00),
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, color: Colors.white38, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  _msgController.text = _currentIcebreaker;
                },
              ),
            ],
          ),
        ),

        // Bottom Message Input
        Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
          decoration: const BoxDecoration(
            color: Color(0xFF0F111A),
            border: Border(top: BorderSide(color: Colors.white10)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1E30),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: TextField(
                    controller: _msgController,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Type message to stranger...',
                      hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFC00),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.black, size: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom painter rendering expanding concentric radar ripples
class _RadarConcentricPainter extends CustomPainter {
  final double progress;

  _RadarConcentricPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    const ringCount = 3;
    for (int i = 0; i < ringCount; i++) {
      final ringProgress = (progress + (i / ringCount)) % 1.0;
      final currentRadius = ringProgress * maxRadius;
      final opacity = (1.0 - ringProgress).clamp(0.0, 1.0) * 0.5;

      final paint = Paint()
        ..color = const Color(0xFFFFFC00).withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, currentRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarConcentricPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
