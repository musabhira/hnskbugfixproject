import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../avatar/vector_avatar_config.dart';
import '../avatar/vector_avatar_widget.dart';
import '../learning_60day/pocket_world_street_page.dart';
import 'pocket_reels_game_engine.dart';

/// 🌟 Modal bottom sheet to Share Homes or Learning Games to Vibes (Story), Chats, & Outside
class PocketFeedVibeShareSheet extends StatefulWidget {
  final PocketNeighbor? neighbor;
  final ReelGameCard? gameCard;
  final VoidCallback? onSharedSuccessfully;

  const PocketFeedVibeShareSheet({
    super.key,
    this.neighbor,
    this.gameCard,
    this.onSharedSuccessfully,
  }) : assert(neighbor != null || gameCard != null, 'Either neighbor or gameCard must be provided');

  static Future<void> show(
    BuildContext context, {
    PocketNeighbor? neighbor,
    ReelGameCard? gameCard,
    VoidCallback? onSharedSuccessfully,
  }) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PocketFeedVibeShareSheet(
        neighbor: neighbor,
        gameCard: gameCard,
        onSharedSuccessfully: onSharedSuccessfully,
      ),
    );
  }

  @override
  State<PocketFeedVibeShareSheet> createState() => _PocketFeedVibeShareSheetState();
}

class _PocketFeedVibeShareSheetState extends State<PocketFeedVibeShareSheet> {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isPostingVibe = false;
  List<Map<String, dynamic>> _userGroups = [];
  bool _isLoadingGroups = true;

  @override
  void initState() {
    super.initState();
    _fetchUserGroups();
  }

  Future<void> _fetchUserGroups() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        if (mounted) setState(() => _isLoadingGroups = false);
        return;
      }

      // Fetch top 5 active English learning groups
      final groups = await _supabase
          .from('groups')
          .select('id, group_name, icon_url, member_count')
          .order('updated_at', ascending: false)
          .limit(6);

      if (mounted) {
        setState(() {
          _userGroups = List<Map<String, dynamic>>.from(groups);
          _isLoadingGroups = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingGroups = false);
    }
  }

  String get _title {
    if (widget.neighbor != null) {
      return 'Share ${widget.neighbor!.name}\'s Home 🏰';
    }
    return 'Share English Game Challenge 🎯';
  }

  String get _shareText {
    if (widget.neighbor != null) {
      final n = widget.neighbor!;
      return 'Check out ${n.name}\'s Citadel Home in Pocket Mates! 🏰 Level: Day ${n.day} • Rank: ${n.rank} • "${n.statusMessage}"\nJoin me in learning fluent English daily: https://pocketmates.app';
    } else {
      final g = widget.gameCard!;
      return '🎯 Pocket Mates Challenge (${g.category}):\n"${g.prompt}"\nCan you solve this? Practice English with me: https://pocketmates.app';
    }
  }

  /// ⚡ Instant 1-Tap "Add to Vibes" (Story)
  Future<void> _instantAddToVibes() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      _showToast('Please log in to add to your Vibes!');
      return;
    }

    setState(() => _isPostingVibe = true);
    HapticFeedback.heavyImpact();

    try {
      final profileRes = await _supabase
          .from('profile')
          .select('id, name, display_name, profile_image_url')
          .eq('user_id', currentUserId)
          .maybeSingle();

      final profileId = profileRes?['id']?.toString() ?? currentUserId;
      final userName = profileRes?['name']?.toString() ?? profileRes?['display_name']?.toString() ?? 'Learner';

      final Map<String, dynamic> metadata = {
        'source': 'homes_reels_feed',
        'is_shared_vibe': true,
        'user_name': userName,
      };

      String captionText;
      if (widget.neighbor != null) {
        final n = widget.neighbor!;
        metadata['item_type'] = 'home_showcase';
        metadata['resident_name'] = n.name;
        metadata['resident_day'] = n.day;
        metadata['resident_streak'] = n.streak;
        metadata['resident_rank'] = n.rank;
        metadata['house_id'] = n.id;
        metadata['palette_id'] = n.paletteId;
        metadata['is_damaged'] = n.isDamaged;
        metadata['status_message'] = n.statusMessage;
        captionText = '🏰 Exploring ${n.name}\'s Citadel (Day ${n.day})!\n"${n.statusMessage}"';
      } else {
        final g = widget.gameCard!;
        metadata['item_type'] = 'game_challenge';
        metadata['game_id'] = g.id;
        metadata['category'] = g.category;
        metadata['prompt'] = g.prompt;
        metadata['options'] = g.options;
        captionText = '🎯 English Challenge of the Day!\n${g.category}: ${g.prompt}';
      }

      final now = DateTime.now();
      await _supabase.from('statuses').insert({
        'user_id': currentUserId,
        'profile_id': profileId,
        'media_type': 'thought',
        'media_url': '',
        'caption': captionText,
        'metadata': metadata,
        'created_at': now.toIso8601String(),
        'expires_at': now.add(const Duration(hours: 24)).toIso8601String(),
      });

      if (mounted) {
        Navigator.pop(context);
        _showSuccessToast('✨ Added to your Vibes!');
        widget.onSharedSuccessfully?.call();
      }
    } catch (e) {
      debugPrint('Error instant sharing to vibes: $e');
      if (mounted) {
        _showToast('Could not post to Vibes: $e');
      }
    } finally {
      if (mounted) setState(() => _isPostingVibe = false);
    }
  }



  /// 💬 Share directly into a Chat Group
  Future<void> _shareToGroup(String groupId, String groupName) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    HapticFeedback.mediumImpact();
    Navigator.pop(context);

    try {
      final Map<String, dynamic> metadata = {
        'shared_from': 'homes_feed',
      };

      if (widget.neighbor != null) {
        metadata['type'] = 'home_preview';
        metadata['neighbor_id'] = widget.neighbor!.id;
        metadata['neighbor_name'] = widget.neighbor!.name;
        metadata['day'] = widget.neighbor!.day;
      } else {
        metadata['type'] = 'game_challenge';
        metadata['category'] = widget.gameCard!.category;
        metadata['prompt'] = widget.gameCard!.prompt;
      }

      await _supabase.from('group_messages').insert({
        'group_id': groupId,
        'sender_id': currentUserId,
        'message_text': _shareText,
        'message_type': 'thought',
        'metadata': metadata,
      });

      await _supabase.from('groups').update({
        'last_message': _shareText,
        'last_message_time': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', groupId);

      _showSuccessToast('Sent to $groupName! 💬');
      widget.onSharedSuccessfully?.call();
    } catch (e) {
      _showToast('Failed to send to group: $e');
    }
  }

  /// 🔗 External System Share
  void _shareExternal() {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    SharePlus.instance.share(ShareParams(text: _shareText, subject: _title));
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: GoogleFonts.outfit(color: Colors.white))),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0xFFFFFC00), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Text('✨', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 🎴 Preview Card
          _buildSharePreviewCard(),
          const SizedBox(height: 20),

          // ⚡ PRIMARY ACTION: ADD TO VIBES
          GestureDetector(
            onTap: _isPostingVibe ? null : _instantAddToVibes,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFC00), Color(0xFFFFB700)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFFC00).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: _isPostingVibe
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: Colors.black, size: 19),
                          const SizedBox(width: 8),
                          Text(
                            'Add to Vibes',
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // SECONDARY ACTION: Share Outside
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _shareExternal,
              icon: const Icon(Icons.share_outlined, size: 18, color: Colors.white70),
              label: Text(
                'Share Outside',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 💬 SEND TO CHAT / GROUPS SECTION
          Text(
            'SEND TO GROUP CHAT',
            style: GoogleFonts.outfit(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),

          if (_isLoadingGroups)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_userGroups.isEmpty)
            Text(
              'No active groups found. Join an English study group to share!',
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
            )
          else
            SizedBox(
              height: 82,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _userGroups.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, idx) {
                  final grp = _userGroups[idx];
                  final gId = grp['id']?.toString() ?? '';
                  final gName = grp['group_name']?.toString() ?? 'Group';

                  return GestureDetector(
                    onTap: () => _shareToGroup(gId, gName),
                    child: SizedBox(
                      width: 68,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
                              ),
                              border: Border.all(color: Colors.white24, width: 1.2),
                            ),
                            child: const Center(
                              child: Text('💬', style: TextStyle(fontSize: 20)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            gName,
                            style: GoogleFonts.outfit(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
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
    );
  }

  /// Preview snippet for what will be posted
  Widget _buildSharePreviewCard() {
    if (widget.neighbor != null) {
      final n = widget.neighbor!;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0F172A),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: VectorAvatarWidget(
                  config: VectorAvatarConfig.getEvolutionAvatarForStage(n.day),
                  size: 44,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.name,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '🔥 Day ${n.day} • ${n.rank}',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFFC00),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    n.statusMessage,
                    style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Text('🏰', style: TextStyle(fontSize: 26)),
          ],
        ),
      );
    } else {
      final g = widget.gameCard!;
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    g.category,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFFC00),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                const Text('🎮', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              g.prompt,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }
  }
}
