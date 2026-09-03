import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/learning_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/learning_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';
import 'package:pocket_mates_app/custom_code/widgets/ads/pocket_ad_service.dart';

/// Interactive 1-on-1 English Practice Matchmaker connecting learners by their 90-Day Stage
class StagePeerMatchmakerPage extends StatefulWidget {
  const StagePeerMatchmakerPage({super.key});

  @override
  State<StagePeerMatchmakerPage> createState() => _StagePeerMatchmakerPageState();
}

class _StagePeerMatchmakerPageState extends State<StagePeerMatchmakerPage> {
  final _supabase = SupaFlow.client;
  bool _isLoading = true;
  UserLearningProgress? _myProgress;
  List<Map<String, dynamic>> _matchedPeers = [];
  Set<String> _pocketMateIds = {};
  int _chatsCompletedToday = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final prog = await Learning60DayService().fetchProgress(myId);
    final prefs = await SharedPreferences.getInstance();
    
    // Load Pocket Mates IDs
    final pocketMatesList = prefs.getStringList('pocket_mates_$myId') ?? [];
    _pocketMateIds = pocketMatesList.toSet();

    // Load today's chat goal progress
    final now = DateTime.now();
    final todayChatKey = 'chat_goals_${myId}_${now.year}_${now.month}_${now.day}';
    _chatsCompletedToday = prefs.getInt(todayChatKey) ?? 0;

    // Fetch peer learners with profile info
    try {
      final res = await _supabase
          .from('profile')
          .select('id, user_id, name, shop_name, slug, profile_image_url, verified, bio, learning_day, learning_stage, learning_points, learning_streak, avatar_config')
          .neq('user_id', myId)
          .limit(20);

      final List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(res);

      // Sort by stage proximity to user's stage
      list.sort((a, b) {
        final aStage = (a['learning_stage'] as num?)?.toInt() ?? 1;
        final bStage = (b['learning_stage'] as num?)?.toInt() ?? 1;
        final myStage = prog.currentStage;
        return (aStage - myStage).abs().compareTo((bStage - myStage).abs());
      });

      if (mounted) {
        setState(() {
          _myProgress = prog;
          _matchedPeers = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading peer matchmaker: $e');
      if (mounted) {
        setState(() {
          _myProgress = prog;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleAddToPocket(String peerUserId, String peerName) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    final key = 'pocket_mates_$myId';
    final currentList = prefs.getStringList(key) ?? [];

    final isAlreadyPocket = _pocketMateIds.contains(peerUserId);
    if (isAlreadyPocket) {
      currentList.remove(peerUserId);
      _pocketMateIds.remove(peerUserId);
    } else {
      currentList.add(peerUserId);
      _pocketMateIds.add(peerUserId);
    }

    await prefs.setStringList(key, currentList);
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(isAlreadyPocket ? Icons.remove_circle_outline : Icons.star_rounded, color: const Color(0xFFFFFC00)),
              const SizedBox(width: 8),
              Text(
                isAlreadyPocket ? 'Removed $peerName from Pocket Mates' : '✨ Added $peerName to your Pocket Mates!',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _startPeerChat(Map<String, dynamic> peer) async {
    final myId = _supabase.auth.currentUser?.id;
    final peerUserId = peer['user_id']?.toString() ?? peer['id']?.toString() ?? '';
    final peerName = peer['name']?.toString() ?? 'Pocket Mate';
    final peerImage = peer['profile_image_url']?.toString();

    // Increment today's chat count
    if (myId != null) {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final todayChatKey = 'chat_goals_${myId}_${now.year}_${now.month}_${now.day}';
      _chatsCompletedToday += 1;
      await prefs.setInt(todayChatKey, _chatsCompletedToday);

      // Award daily task completion
      await Learning60DayService().completeTask(userId: myId, taskId: 'english_chat_session');
    }

    if (!mounted) return;

    // Show video ad for free users before establishing connection (bypassed if subscribed)
    final adSuccess = await PocketAdService().showVideoAd(
      context: context,
      placementTitle: '1-on-1 English Practice Match',
    );
    if (!adSuccess && mounted) return;

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WhatsAppGroupChat(
            groupId: 'p:$peerUserId',
            groupName: peerName,
            groupImage: peerImage,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final myStage = _myProgress?.activeStage ?? LearningMilestoneStage.getStageForDay(1);

    return Scaffold(
      backgroundColor: const Color(0xFF090A10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F111A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text('⚡', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              '1-on-1 English Match',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFFFFC00), size: 22),
            tooltip: 'Refresh Mates',
            onPressed: () {
              HapticFeedback.lightImpact();
              _loadData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFFC00)))
          : RefreshIndicator(
              color: const Color(0xFFFFFC00),
              backgroundColor: const Color(0xFF141724),
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                // User's Active Stage Match Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: myStage.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: myStage.buttonColor.withValues(alpha: 0.5), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                          border: Border.all(color: myStage.buttonColor.withValues(alpha: 0.6)),
                        ),
                        child: Text(myStage.emoji, style: const TextStyle(fontSize: 26)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'YOUR CURRENT LEVEL',
                              style: GoogleFonts.outfit(
                                color: myStage.buttonColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 10.5,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Stage ${myStage.stageNumber}/90: ${myStage.stageName}',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${myStage.fluencyTier} • Matching with peers nearby',
                              style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Today's Chat Goal Tracker
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141724),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFFFFFC00), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily 1-on-1 English Goal',
                              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              'Chat with 2 English Mates today • +30 XP',
                              style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _chatsCompletedToday >= 2
                              ? const Color(0xFF10B981).withValues(alpha: 0.2)
                              : const Color(0xFFFFFC00).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _chatsCompletedToday >= 2
                                ? const Color(0xFF10B981)
                                : const Color(0xFFFFFC00),
                          ),
                        ),
                        child: Text(
                          '$_chatsCompletedToday/2 Done',
                          style: GoogleFonts.outfit(
                            color: _chatsCompletedToday >= 2 ? const Color(0xFF10B981) : const Color(0xFFFFFC00),
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Section Header
                Row(
                  children: [
                    const Text('👥', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      'DISCOVER STAGE MATES',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Peer List
                if (_matchedPeers.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    child: Text(
                      'Searching for online mates at your stage...',
                      style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
                    ),
                  )
                else
                  ..._matchedPeers.map((peer) {
                    final peerUserId = peer['user_id']?.toString() ?? peer['id']?.toString() ?? '';
                    final peerName = peer['name']?.toString() ?? 'Pocket Mate';
                    final peerSlug = peer['slug']?.toString();
                    final peerImage = peer['profile_image_url']?.toString();
                    final stageNum = (peer['learning_stage'] as num?)?.toInt() ?? 1;
                    final peerStage = LearningMilestoneStage.getStageForDay(stageNum);
                    final isPocketMate = _pocketMateIds.contains(peerUserId);

                    VectorAvatarConfig? avatarConfig;
                    if (peer['avatar_config'] != null) {
                      try {
                        avatarConfig = VectorAvatarConfig.fromMap(Map<String, dynamic>.from(peer['avatar_config']));
                      } catch (_) {}
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141724),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isPocketMate ? const Color(0xFFFFFC00).withValues(alpha: 0.5) : Colors.white10,
                          width: isPocketMate ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: peerStage.buttonColor, width: 2),
                            ),
                            child: avatarConfig != null
                                ? VectorAvatarWidget(config: avatarConfig, size: 50)
                                : CircleAvatar(
                                    radius: 25,
                                    backgroundColor: const Color(0xFF222533),
                                    backgroundImage: (peerImage != null && peerImage.isNotEmpty)
                                        ? CachedNetworkImageProvider(peerImage)
                                        : null,
                                    child: (peerImage == null || peerImage.isEmpty)
                                        ? const Icon(Icons.person, color: Colors.white54, size: 26)
                                        : null,
                                  ),
                          ),
                          const SizedBox(width: 12),

                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        peerName,
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(Icons.verified, color: peerStage.tickColor, size: 14),
                                  ],
                                ),
                                if (peerSlug != null && peerSlug.isNotEmpty) ...[
                                  Text(
                                    '@$peerSlug',
                                    style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: peerStage.buttonColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${peerStage.emoji} Stage ${peerStage.stageNumber}/90 • ${peerStage.fluencyTier}',
                                    style: GoogleFonts.outfit(
                                      color: peerStage.buttonColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 9.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Actions
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () => _startPeerChat(peer),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFC00),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '💬 Chat',
                                    style: GoogleFonts.outfit(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () => _toggleAddToPocket(peerUserId, peerName),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isPocketMate ? const Color(0xFFFFFC00).withValues(alpha: 0.2) : Colors.white10,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isPocketMate ? const Color(0xFFFFFC00) : Colors.white24,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isPocketMate ? Icons.star_rounded : Icons.star_border_rounded,
                                        color: isPocketMate ? const Color(0xFFFFFC00) : Colors.white70,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        isPocketMate ? 'Pocket' : '+Pocket',
                                        style: GoogleFonts.outfit(
                                          color: isPocketMate ? const Color(0xFFFFFC00) : Colors.white70,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
    );
  }
}
