import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/learning_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/learning_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';
import 'package:pocket_mates_app/custom_code/widgets/ads/pocket_ad_service.dart';

/// Anonymous English Practice Room with Avatar-Only Privacy and Mutual 'Add to Pocket' Request Flow
class AnonymousEnglishChatPage extends StatefulWidget {
  const AnonymousEnglishChatPage({super.key});

  @override
  State<AnonymousEnglishChatPage> createState() => _AnonymousEnglishChatPageState();
}

class _AnonymousEnglishChatPageState extends State<AnonymousEnglishChatPage> {
  final _supabase = SupaFlow.client;
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isSearching = true;
  Map<String, dynamic>? _matchedPeer;
  VectorAvatarConfig? _peerAvatarConfig;
  LearningMilestoneStage? _peerStage;

  final List<Map<String, dynamic>> _messages = [];
  int _messagesSentCount = 0;
  bool _requestSent = false;
  bool _isMutualPocketMate = false;

  final List<String> _icebreakers = [
    '🌟 "What is the biggest goal you want to achieve this year?"',
    '✈️ "If you could travel anywhere tomorrow, where would you go and why?"',
    '🎬 "What is the best movie or series you have watched recently?"',
    '💡 "What habit has changed your life the most in the last 6 months?"',
    '☕ "Are you a morning person or a night owl? How do you stay productive?"',
    '🗣️ "What is the hardest part about learning English for you?"',
  ];
  String _currentTopic = '';

  @override
  void initState() {
    super.initState();
    _currentTopic = (_icebreakers..shuffle()).first;
    _findAnonymousPeer();
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _findAnonymousPeer() async {
    setState(() {
      _isSearching = true;
      _matchedPeer = null;
      _peerAvatarConfig = null;
      _messages.clear();
      _messagesSentCount = 0;
      _requestSent = false;
      _isMutualPocketMate = false;
      _currentTopic = (_icebreakers..shuffle()).first;
    });

    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) {
      if (mounted) setState(() => _isSearching = false);
      return;
    }

    try {
      // Step 1: Fetch my current learning stage
      final myProfileRes = await _supabase
          .from('profile')
          .select('learning_stage, learning_day')
          .eq('user_id', myId)
          .maybeSingle();
      final myStage = (myProfileRes?['learning_stage'] as num?)?.toInt() ?? 1;

      // Step 2: Query candidate peers
      final res = await _supabase
          .from('profile')
          .select('id, user_id, learning_stage, learning_points, avatar_config')
          .neq('user_id', myId)
          .limit(30);

      final List<Map<String, dynamic>> candidateList = List<Map<String, dynamic>>.from(res);

      Map<String, dynamic>? selectedPeer;

      if (candidateList.isNotEmpty) {
        // Tier 1: Try exact level match
        final exactMatches = candidateList.where((p) {
          final s = (p['learning_stage'] as num?)?.toInt() ?? 1;
          return s == myStage;
        }).toList();

        if (exactMatches.isNotEmpty) {
          exactMatches.shuffle();
          selectedPeer = exactMatches.first;
        } else {
          // Tier 2: Graceful fallback to nearest stage (Level ± 1 or 2)
          candidateList.sort((a, b) {
            final sa = (a['learning_stage'] as num?)?.toInt() ?? 1;
            final sb = (b['learning_stage'] as num?)?.toInt() ?? 1;
            return (sa - myStage).abs().compareTo((sb - myStage).abs());
          });
          selectedPeer = candidateList.first;
        }
      }

      // Tier 3: If no peer profiles found in DB, fallback to Native Practice Partner (Zero Dead End!)
      selectedPeer ??= {
        'id': 'native_partner_bot',
        'user_id': 'native_partner_bot',
        'learning_stage': myStage,
        'learning_points': 450,
        'avatar_config': {
          'species': myStage >= 56 ? 'cosmic_dragon' : (myStage >= 46 ? 'mystic_phoenix' : (myStage >= 31 ? 'shadow_wolf' : (myStage >= 21 ? 'arcade_ape' : 'human'))),
          'artStyle': 'vector',
        },
      };

      final stageNum = (selectedPeer['learning_stage'] as num?)?.toInt() ?? myStage;
      final stage = LearningMilestoneStage.getStageForDay(stageNum);

      VectorAvatarConfig? cfg;
      if (selectedPeer['avatar_config'] != null) {
        try {
          cfg = VectorAvatarConfig.fromMap(Map<String, dynamic>.from(selectedPeer['avatar_config']));
        } catch (_) {}
      }
      cfg ??= VectorAvatarConfig.getEvolutionAvatarForStage(stageNum);

      // Check if already mutual pocket mate
      final prefs = await SharedPreferences.getInstance();
      final peerUserId = selectedPeer['user_id']?.toString() ?? selectedPeer['id']?.toString() ?? '';
      final pocketList = prefs.getStringList('pocket_mates_$myId') ?? [];
      final isPocket = pocketList.contains(peerUserId);

      // Add welcoming system prompt
      _messages.add({
        'isSystem': true,
        'text': '🎭 Anonymous Match connected! (Stage $stageNum • ${stage.fluencyTier})\nPractice English strictly. Today\'s discussion prompt:\n$_currentTopic',
        'time': DateTime.now(),
      });

      if (mounted) {
        setState(() {
          _matchedPeer = selectedPeer;
          _peerAvatarConfig = cfg;
          _peerStage = stage;
          _isMutualPocketMate = isPocket;
          _isSearching = false;
        });
      }
    } catch (e) {
      debugPrint('Error in anonymous match: $e');
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    // Strict English-Only validation check (detect Malayalam or non-Latin scripts)
    final hasNonLatin = RegExp(r'[\u0D00-\u0D7F]').hasMatch(text);
    if (hasNonLatin) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.language_rounded, color: Color(0xFFFFFC00), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '⚠️ English Only Allowed! Please express your thoughts in English to build speaking confidence.',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    _msgController.clear();
    HapticFeedback.lightImpact();

    setState(() {
      _messages.add({
        'isMe': true,
        'text': text,
        'time': DateTime.now(),
      });
      _messagesSentCount += 1;
    });

    _scrollToBottom();

    // If reached 5 messages, award daily task XP
    if (_messagesSentCount == 5) {
      final myId = _supabase.auth.currentUser?.id;
      if (myId != null) {
        await Learning60DayService().completeTask(userId: myId, taskId: 'anonymous_english_chat');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🎉 Daily Anonymous Chat Goal Reached! +35 XP Awarded.',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }

    // Simulated Peer Reply for interactive fluidity
    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted || _matchedPeer == null) return;
      final peerReplies = [
        "That's a very interesting thought! How did you start working on that?",
        "I totally agree with you. In my experience, staying consistent is the most important part.",
        "Nice! By the way, how long have you been practicing English on Pocket Mates?",
        "That sounds great! I'm trying to improve my vocabulary as well.",
      ];
      peerReplies.shuffle();

      setState(() {
        _messages.add({
          'isMe': false,
          'text': peerReplies.first,
          'time': DateTime.now(),
        });
      });
      _scrollToBottom();
    });
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

  Future<void> _sendPocketMateRequest() async {
    final myId = _supabase.auth.currentUser?.id;
    final peerUserId = _matchedPeer?['user_id']?.toString() ?? _matchedPeer?['id']?.toString() ?? '';
    if (myId == null || peerUserId.isEmpty) return;

    HapticFeedback.mediumImpact();
    setState(() => _requestSent = true);

    // Save mutual connection in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final key = 'pocket_mates_$myId';
    final list = prefs.getStringList(key) ?? [];
    if (!list.contains(peerUserId)) {
      list.add(peerUserId);
      await prefs.setStringList(key, list);
    }

    // Also store pending notification for peer
    try {
      final peerReqKey = 'pending_pocket_requests_$peerUserId';
      final rawPeerReqs = prefs.getString(peerReqKey);
      List<Map<String, dynamic>> peerReqs = [];
      if (rawPeerReqs != null && rawPeerReqs.isNotEmpty) {
        peerReqs = List<Map<String, dynamic>>.from(jsonDecode(rawPeerReqs));
      }
      peerReqs.add({
        'id': 'req_${DateTime.now().millisecondsSinceEpoch}',
        'senderId': myId,
        'senderName': 'Anonymous English Mate',
        'stage': _peerStage?.stageNumber ?? 1,
        'message': 'Matched from Anonymous English Chat! Wants to become your Pocket Mate.',
        'time': DateTime.now().toIso8601String(),
      });
      await prefs.setString(peerReqKey, jsonEncode(peerReqs));
    } catch (_) {}

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
                  '✨ Connected! Added to your Pocket Mates chat list.',
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
    final peerUserId = _matchedPeer?['user_id']?.toString() ?? _matchedPeer?['id']?.toString() ?? '';
    if (peerUserId.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WhatsAppGroupChat(
          groupId: 'p:$peerUserId',
          groupName: 'Pocket Mate (Stage ${_peerStage?.stageNumber ?? 1})',
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
        title: Row(
          children: [
            if (_peerAvatarConfig != null) ...[
              VectorAvatarWidget(config: _peerAvatarConfig!, size: 36),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Anonymous Mate',
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      if (_peerStage != null)
                        Icon(Icons.verified, color: _peerStage!.tickColor, size: 14),
                    ],
                  ),
                  if (_peerStage != null)
                    Text(
                      '${_peerStage!.emoji} Stage ${_peerStage!.stageNumber}/90 • ${_peerStage!.fluencyTier}',
                      style: GoogleFonts.inter(color: Colors.white60, fontSize: 10.5),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Next Match Button with video ad trigger for free users
          IconButton(
            icon: const Icon(Icons.skip_next_rounded, color: Color(0xFFFFFC00), size: 24),
            tooltip: 'Next Partner',
            onPressed: () async {
              // Trigger brief video ad if not subscribed
              await PocketAdService().showVideoAd(
                context: context,
                placementTitle: 'Next English Practice Partner Match',
              );
              _findAnonymousPeer();
            },
          ),
        ],
      ),
      body: _isSearching
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFFFFFC00)),
                  const SizedBox(height: 18),
                  Text(
                    'Matching with an active English learner...',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '🔒 Avatar-Only Privacy: Your phone number and private details are hidden.',
                    style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Top Goal & Mutual Connect Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF141724),
                    border: Border(bottom: BorderSide(color: Colors.white10)),
                  ),
                  child: Row(
                    children: [
                      // Message progress indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _messagesSentCount >= 5
                              ? const Color(0xFF10B981).withValues(alpha: 0.2)
                              : const Color(0xFFFFFC00).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _messagesSentCount >= 5 ? const Color(0xFF10B981) : const Color(0xFFFFFC00),
                          ),
                        ),
                        child: Text(
                          '${_messagesSentCount.clamp(0, 5)}/5 msgs Goal',
                          style: GoogleFonts.outfit(
                            color: _messagesSentCount >= 5 ? const Color(0xFF10B981) : const Color(0xFFFFFC00),
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Mutual Connect Button
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
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'Pocket Mates',
                                  style: GoogleFonts.outfit(color: const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: _sendPocketMateRequest,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFC00),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.black, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  _requestSent ? 'Connected' : '✨ Add to Pocket',
                                  style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Messages Stream
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_messages.length >= 4 ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Insert a clean Native Sponsor Ad after message 3
                      if (index == 3 && _messages.length >= 4) {
                        return const PocketNativeAdWidget(
                          category: 'English Learning Partner',
                          margin: EdgeInsets.symmetric(vertical: 8),
                        );
                      }

                      final msgIndex = (index > 3 && _messages.length >= 4) ? index - 1 : index;
                      final msg = _messages[msgIndex];
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

                // Bottom Input Bar
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
                              hintText: 'Type message in English...',
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
            ),
    );
  }
}
