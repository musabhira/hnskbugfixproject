import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/contacts_name_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_mate_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_ranking_service.dart';
import 'package:pocket_mates_app/custom_code/services/poket_cosmos_allocation_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_robots_data.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';

class SuggestedMateItem {
  final String id;
  final String name;
  final String? avatarUrl;
  final int rank;
  final bool isRobot;
  final bool isAnimal;
  final int plotNumber;

  SuggestedMateItem({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.rank,
    this.isRobot = false,
    this.isAnimal = false,
    required this.plotNumber,
  });
}

/// 🤝 PocketMatesSuggestedGridCard
/// Renders an Instagram-style 4-card suggestion grid in Vibes/Homes feeds
/// for free users (prioritizing mutual phone contacts, then active learners & robots).
/// Each card includes Avatar, Name, Unique Rank, Plot Number, and 2 Action buttons:
/// [Mate] (Send Mate request) and [Attack] (Open Citadel Attack Profile).
class PocketMatesSuggestedGridCard extends StatefulWidget {
  final String currentUserId;
  final VoidCallback? onDismiss;

  const PocketMatesSuggestedGridCard({
    super.key,
    required this.currentUserId,
    this.onDismiss,
  });

  @override
  State<PocketMatesSuggestedGridCard> createState() =>
      _PocketMatesSuggestedGridCardState();
}

class _PocketMatesSuggestedGridCardState
    extends State<PocketMatesSuggestedGridCard> {
  List<SuggestedMateItem> _suggestedMates = [];
  final Set<String> _sentMateIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSuggestedMates();
  }

  Future<void> _loadSuggestedMates() async {
    final uid = widget.currentUserId.isNotEmpty
        ? widget.currentUserId
        : (SupaFlow.client.auth.currentUser?.id ?? '');
    final List<SuggestedMateItem> candidates = [];
    final Set<String> addedIds = {uid};

    try {
      // 1. Check already sent requests
      if (uid.isNotEmpty) {
        final pendingSent =
            await PocketMateService.getPendingSentRequestUserIds(uid);
        _sentMateIds.addAll(pendingSent);
      }

      // 2. Priority 1: Phone Contacts Sync candidates
      final syncedUserIds = ContactsNameService().allSyncedContactUserIds;
      for (final cUid in syncedUserIds) {
        if (cUid.isNotEmpty && !addedIds.contains(cUid)) {
          addedIds.add(cUid);
          final dName = ContactsNameService().getDisplayName(userId: cUid, fallbackName: 'Contact Mate');
          final gRank = await PocketRankingService.fetchUserGlobalRank(cUid);
          final cachedPlot =
              PoketCosmosAllocationService.instance.getCachedUserPlot(cUid);
          final pNum =
              cachedPlot?.plotNumber ?? ((cUid.hashCode.abs() % 25) + 1);

          candidates.add(SuggestedMateItem(
            id: cUid,
            name: dName,
            avatarUrl: null,
            rank: gRank > 0 ? gRank : ((cUid.hashCode.abs() % 100) + 1),
            isRobot: false,
            plotNumber: pNum,
          ));
          if (candidates.length >= 4) break;
        }
      }

      // 3. Priority 2: Active Global Leaderboard Learners from Supabase
      if (candidates.length < 4) {
        final leaderboard = await PocketRankingService.fetchGlobalLeaderboard();
        for (final entry in leaderboard) {
          final eId = entry.userId;
          if (eId.isNotEmpty && !addedIds.contains(eId)) {
            addedIds.add(eId);
            final cachedPlot =
                PoketCosmosAllocationService.instance.getCachedUserPlot(eId);
            final pNum =
                cachedPlot?.plotNumber ?? ((eId.hashCode.abs() % 25) + 1);

            candidates.add(SuggestedMateItem(
              id: eId,
              name: entry.name.isNotEmpty
                  ? entry.name
                  : PocketMateService.resolveRealUserName(userId: eId),
              avatarUrl: entry.profileImageUrl,
              rank: entry.globalRank > 0
                  ? entry.globalRank
                  : ((eId.hashCode.abs() % 50) + 1),
              isRobot: entry.isRobot,
              plotNumber: pNum,
            ));
            if (candidates.length >= 4) break;
          }
        }
      }

      // 4. Priority 3: Curated Pocket Robots & Animal Mentors
      if (candidates.length < 4) {
        final robots = PocketRobotService.getAllRobots();
        for (final bot in robots) {
          if (!addedIds.contains(bot.id)) {
            addedIds.add(bot.id);
            final isAnimal =
                PocketKidsRobotsData.getAnimalById(bot.id) != null;
            final rRank = await PocketRankingService.fetchUserGlobalRank(bot.id);
            final pNum = ((bot.id.hashCode.abs() % 25) + 1);

            candidates.add(SuggestedMateItem(
              id: bot.id,
              name: bot.name,
              avatarUrl: bot.avatarUrl,
              rank: rRank > 0 ? rRank : bot.level,
              isRobot: !isAnimal,
              isAnimal: isAnimal,
              plotNumber: pNum,
            ));
            if (candidates.length >= 4) break;
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading suggested mates grid: $e');
    }

    if (mounted) {
      setState(() {
        _suggestedMates = candidates.take(4).toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSendMateRequest(SuggestedMateItem item) async {
    HapticFeedback.mediumImpact();
    final uid = widget.currentUserId.isNotEmpty
        ? widget.currentUserId
        : (SupaFlow.client.auth.currentUser?.id ?? '');
    if (uid.isEmpty) return;

    setState(() {
      _sentMateIds.add(item.id);
    });

    final success = await PocketMateService.sendMateRequest(
      senderId: uid,
      receiverId: item.id,
      receiverName: item.name,
      contextType: 'vibes_suggestions',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Mate request sent to ${item.name}! 🤝'
                : 'Mate request recorded ⏳',
          ),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleAttackUser(SuggestedMateItem item) {
    HapticFeedback.selectionClick();
    PocketCitadelAttackPage.openForUser(
      context,
      userId: item.id,
      targetName: item.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 220,
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFD700)),
        ),
      );
    }

    if (_suggestedMates.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1320) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.group_add_rounded,
                  color: Color(0xFFFFD700),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suggested Mates 🤝',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'Expand your Pocket World circle',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16, color: Colors.white38),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  onPressed: widget.onDismiss,
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 2x2 Responsive Grid (Instagram Follow List style)
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _suggestedMates.map((item) {
                  return SizedBox(
                    width: cardWidth,
                    child: _buildMateCard(item, isDark),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMateCard(SuggestedMateItem item, bool isDark) {
    final isSent = _sentMateIds.contains(item.id);
    final String rankLabel;
    if (item.isAnimal) {
      rankLabel = 'Animal #${item.rank}';
    } else if (item.isRobot) {
      rankLabel = 'Robot #${item.rank}';
    } else {
      rankLabel = 'Global #${item.rank}';
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D2E) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          // Avatar with status
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFFFD700).withValues(alpha: 0.2),
            backgroundImage: (item.avatarUrl != null && item.avatarUrl!.isNotEmpty)
                ? NetworkImage(item.avatarUrl!)
                : null,
            child: (item.avatarUrl == null || item.avatarUrl!.isEmpty)
                ? Text(
                    item.name.isNotEmpty ? item.name[0].toUpperCase() : 'M',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 6),

          // Name
          Text(
            item.name,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),

          // Rank & Plot Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  rankLabel,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Plot #${item.plotNumber}',
                style: GoogleFonts.inter(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Action Buttons: [Mate] and [Attack]
          Row(
            children: [
              // Mate Button
              Expanded(
                child: SizedBox(
                  height: 28,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSent
                          ? const Color(0xFF334155)
                          : const Color(0xFFFFFC00),
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.zero,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: isSent ? null : () => _handleSendMateRequest(item),
                    child: Text(
                      isSent ? 'Sent ⏳' : 'Mate',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 10.5,
                        color: isSent ? Colors.white60 : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),

              // Attack Button
              Expanded(
                child: SizedBox(
                  height: 28,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444), width: 1),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _handleAttackUser(item),
                    child: Text(
                      'Attack ⚔️',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
