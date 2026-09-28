import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../avatar/vector_avatar_config.dart';
import '../avatar/vector_avatar_widget.dart';
import '../learning_60day/pocket_world_street_page.dart';
import 'pocket_reels_game_engine.dart';

class PocketFeedVibeShareSheet extends StatefulWidget {
  final PocketNeighbor? neighbor;
  final ReelGameCard? gameCard;
  final String? customText;
  final String? thoughtId;
  final VoidCallback? onSharedSuccessfully;

  const PocketFeedVibeShareSheet({
    super.key,
    this.neighbor,
    this.gameCard,
    this.customText,
    this.thoughtId,
    this.onSharedSuccessfully,
  }) : assert(
            neighbor != null ||
                gameCard != null ||
                customText != null,
            'Either neighbor, gameCard, or customText must be provided');

  static Future<void> show(
    BuildContext context, {
    PocketNeighbor? neighbor,
    ReelGameCard? gameCard,
    String? customText,
    String? thoughtId,
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
        customText: customText,
        thoughtId: thoughtId,
        onSharedSuccessfully: onSharedSuccessfully,
      ),
    );
  }

  @override
  State<PocketFeedVibeShareSheet> createState() =>
      _PocketFeedVibeShareSheetState();
}

class _PocketFeedVibeShareSheetState extends State<PocketFeedVibeShareSheet> {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isPostingVibe = false;
  List<Map<String, dynamic>> _userGroups = [];
  List<Map<String, dynamic>> _recentMates = [];
  Map<String, dynamic>? _currentUserProfile;
  bool _isLoadingGroups = true;
  bool _isLoadingMates = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const List<Color> _instagramStoryGradient = [
    Color(0xFF833AB4), // Purple
    Color(0xFFC13584), // Magenta
    Color(0xFFE1306C), // Deep Pink
    Color(0xFFFD1D1D), // Crimson
    Color(0xFFF77737), // Coral
    Color(0xFFFFDC80), // Warm Gold
  ];

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserProfile();
    _fetchUserGroups();
    _fetchRecentMates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static bool _isEnglishHub(Map<String, dynamic> group) {
    final name = (group['group_name'] ?? group['name'] ?? '')
        .toString()
        .toLowerCase()
        .replaceAll(RegExp(r'[\s_\-]+'), '');
    return name.contains('englishhub') || name.contains('englishclub');
  }

  Future<void> _fetchCurrentUserProfile() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return;
      final res = await _supabase
          .from('profile')
          .select('id, name, display_name, profile_image_url')
          .eq('user_id', currentUserId)
          .maybeSingle();
      if (res != null && mounted) {
        setState(() => _currentUserProfile = res);
      }
    } catch (_) {}
  }

  Future<void> _fetchRecentMates() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        if (mounted) setState(() => _isLoadingMates = false);
        return;
      }

      final conversations = await _supabase
          .from('conversations')
          .select('user1_id, user2_id, updated_at')
          .or('user1_id.eq.$currentUserId,user2_id.eq.$currentUserId')
          .order('updated_at', ascending: false)
          .limit(25);

      final userIds = <String>{};
      for (final conv in (conversations as List)) {
        final u1 = conv['user1_id']?.toString();
        final u2 = conv['user2_id']?.toString();
        if (u1 != null && u1 != currentUserId && u1.isNotEmpty) {
          userIds.add(u1);
        }
        if (u2 != null && u2 != currentUserId && u2.isNotEmpty) {
          userIds.add(u2);
        }
      }

      if (userIds.isNotEmpty) {
        final profiles = await _supabase
            .from('profile')
            .select('user_id, name, display_name, profile_image_url')
            .inFilter('user_id', userIds.toList());

        if (mounted) {
          setState(() {
            _recentMates = List<Map<String, dynamic>>.from(profiles as List);
            _isLoadingMates = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingMates = false);
      }
    } catch (e) {
      debugPrint('Error fetching mates for share sheet: $e');
      if (mounted) setState(() => _isLoadingMates = false);
    }
  }

  Future<void> _fetchUserGroups() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        if (mounted) setState(() => _isLoadingGroups = false);
        return;
      }

      // 1. Fetch user joined groups
      try {
        final membersResponse = await _supabase.from('group_members').select('''
              group_id,
              groups!inner (
                id,
                name,
                group_name,
                icon_url,
                group_image_url
              )
            ''').eq('user_id', currentUserId).eq('is_active', true).limit(15);

        if (membersResponse.isNotEmpty) {
          final loaded = (membersResponse as List)
              .map((item) {
                final group = item['groups'];
                return {
                  'id': group['id'],
                  'group_name': group['name'] ?? group['group_name'] ?? 'Group',
                  'icon_url': group['group_image_url'] ?? group['icon_url'],
                };
              })
              .where((g) => !_isEnglishHub(g)) // NEVER expose English Hub to share thoughts/homes
              .toList();

          if (mounted) {
            setState(() {
              _userGroups = List<Map<String, dynamic>>.from(loaded);
              _isLoadingGroups = false;
            });
            return;
          }
        }
      } catch (_) {}

      // Fallback: active general groups (strictly excluding English Hub)
      final groups = await _supabase
          .from('groups')
          .select('id, group_name, icon_url, member_count')
          .order('updated_at', ascending: false)
          .limit(12);

      if (mounted) {
        final filteredFallback = (groups as List)
            .cast<Map<String, dynamic>>()
            .where((g) => !_isEnglishHub(g))
            .take(8)
            .toList();
        setState(() {
          _userGroups = filteredFallback;
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
    } else if (widget.gameCard != null) {
      return 'Share English Game Challenge 🎯';
    }
    return 'Share Thought 💭';
  }

  String get _shareText {
    if (widget.neighbor != null) {
      final n = widget.neighbor!;
      return 'Check out ${n.name}\'s Citadel Home in Pocket Mates! 🏰 Level: Day ${n.day} • Rank: ${n.rank} • "${n.statusMessage}"\nJoin me in learning fluent English daily: https://pocketmates.app';
    } else if (widget.gameCard != null) {
      final g = widget.gameCard!;
      return '🎯 Pocket Mates Challenge (${g.category}):\n"${g.prompt}"\nCan you solve this? Practice English with me: https://pocketmates.app';
    }
    return widget.customText ?? '';
  }

  /// ⚡ Instant 1-Tap "Add to Vibes" (Instagram-style Story)
  Future<void> _instantAddToVibes() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      _showToast('Please log in to add to your Vibes!');
      return;
    }

    setState(() => _isPostingVibe = true);
    HapticFeedback.heavyImpact();

    try {
      final profileRes = _currentUserProfile ??
          await _supabase
              .from('profile')
              .select('id, name, display_name, profile_image_url')
              .eq('user_id', currentUserId)
              .maybeSingle();

      final profileId = profileRes?['id']?.toString() ?? currentUserId;
      final userName = profileRes?['name']?.toString() ??
          profileRes?['display_name']?.toString() ??
          'Learner';

      final Map<String, dynamic> metadata = {
        'source': widget.neighbor != null
            ? 'homes_reels_feed'
            : (widget.gameCard != null ? 'game_challenge' : 'thought_feed'),
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
        captionText =
            '🏰 Exploring ${n.name}\'s Citadel (Day ${n.day})!\n"${n.statusMessage}"';
      } else if (widget.gameCard != null) {
        final g = widget.gameCard!;
        metadata['item_type'] = 'game_challenge';
        metadata['game_id'] = g.id;
        metadata['category'] = g.category;
        metadata['prompt'] = g.prompt;
        metadata['options'] = g.options;
        captionText =
            '🎯 English Challenge of the Day!\n${g.category}: ${g.prompt}';
      } else {
        metadata['item_type'] = 'thought';
        if (widget.thoughtId != null) metadata['thought_id'] = widget.thoughtId;
        captionText = widget.customText ?? '';
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
        'expires_at': now.add(const Duration(hours: 12)).toIso8601String(),
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

  /// 💬 Share directly into a Personal Chat / Mate
  Future<void> _shareToMate(String mateUserId, String mateName) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    HapticFeedback.mediumImpact();
    Navigator.pop(context);

    try {
      final Map<String, dynamic> metadata = {
        'shared_from': widget.neighbor != null
            ? 'homes_feed'
            : (widget.gameCard != null ? 'game_challenge' : 'thought_feed'),
      };

      if (widget.neighbor != null) {
        metadata['type'] = 'home_preview';
        metadata['neighbor_id'] = widget.neighbor!.id;
        metadata['neighbor_name'] = widget.neighbor!.name;
        metadata['day'] = widget.neighbor!.day;
      } else if (widget.gameCard != null) {
        metadata['type'] = 'game_challenge';
        metadata['category'] = widget.gameCard!.category;
        metadata['prompt'] = widget.gameCard!.prompt;
      } else {
        metadata['type'] = 'thought';
        if (widget.thoughtId != null) metadata['thought_id'] = widget.thoughtId;
      }

      final nowStr = DateTime.now().toIso8601String();
      await _supabase.from('messages').insert({
        'sender_id': currentUserId,
        'receiver_id': mateUserId,
        'content': _shareText,
        'message_text': _shareText,
        'message_type': 'thought',
        'is_read': false,
        'metadata': metadata,
        'updated_at': nowStr,
        'created_at': nowStr,
      });

      // Update or create conversation
      final existingConv = await _supabase
          .from('conversations')
          .select('id, unread_count')
          .or('and(user1_id.eq.$currentUserId,user2_id.eq.$mateUserId),and(user1_id.eq.$mateUserId,user2_id.eq.$currentUserId)')
          .maybeSingle();

      if (existingConv != null) {
        await _supabase.from('conversations').update({
          'last_message': _shareText,
          'last_message_time': nowStr,
          'last_sender_id': currentUserId,
          'unread_count': (existingConv['unread_count'] ?? 0) + 1,
          'updated_at': nowStr,
        }).eq('id', existingConv['id']);
      } else {
        await _supabase.from('conversations').insert({
          'user1_id': currentUserId,
          'user2_id': mateUserId,
          'last_message': _shareText,
          'last_message_time': nowStr,
          'last_sender_id': currentUserId,
          'unread_count': 1,
          'created_at': nowStr,
          'updated_at': nowStr,
        });
      }

      _showSuccessToast('Sent to $mateName! 🚀');
      widget.onSharedSuccessfully?.call();
    } catch (e) {
      _showToast('Failed to send: $e');
    }
  }

  /// 💬 Share directly into a Chat Group (Strictly non-English Hub)
  Future<void> _shareToGroup(String groupId, String groupName) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    if (_isEnglishHub({'group_name': groupName})) {
      _showToast('English Hub is reserved for learning workouts.');
      return;
    }

    HapticFeedback.mediumImpact();
    Navigator.pop(context);

    try {
      final Map<String, dynamic> metadata = {
        'shared_from': widget.neighbor != null
            ? 'homes_feed'
            : (widget.gameCard != null ? 'game_challenge' : 'thought_feed'),
      };

      if (widget.neighbor != null) {
        metadata['type'] = 'home_preview';
        metadata['neighbor_id'] = widget.neighbor!.id;
        metadata['neighbor_name'] = widget.neighbor!.name;
        metadata['day'] = widget.neighbor!.day;
      } else if (widget.gameCard != null) {
        metadata['type'] = 'game_challenge';
        metadata['category'] = widget.gameCard!.category;
        metadata['prompt'] = widget.gameCard!.prompt;
      } else {
        metadata['type'] = 'thought';
        if (widget.thoughtId != null) metadata['thought_id'] = widget.thoughtId;
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
            const Icon(Icons.check_circle_rounded,
                color: Colors.greenAccent, size: 20),
            const SizedBox(width: 8),
            Expanded(
                child: Text(message,
                    style: GoogleFonts.outfit(color: Colors.white))),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();
    final filteredMates = _recentMates.where((m) {
      if (query.isEmpty) return true;
      final name =
          (m['name'] ?? m['display_name'] ?? '').toString().toLowerCase();
      return name.contains(query);
    }).toList();

    final filteredGroups = _userGroups.where((g) {
      if (query.isEmpty) return true;
      final name =
          (g['group_name'] ?? g['name'] ?? '').toString().toLowerCase();
      return name.contains(query);
    }).toList();

    final userAvatarUrl = _currentUserProfile?['profile_image_url']?.toString();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
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
      child: SingleChildScrollView(
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
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white54, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 🎴 Preview Card
            _buildSharePreviewCard(),
            const SizedBox(height: 16),

            // 📸 INSTAGRAM STYLE "ADD TO STORY / VIBES" BANNER CARD
            GestureDetector(
              onTap: _isPostingVibe ? null : _instantAddToVibes,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF833AB4).withValues(alpha: 0.22),
                      const Color(0xFFFD1D1D).withValues(alpha: 0.18),
                      const Color(0xFFF77737).withValues(alpha: 0.16),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFD1D1D).withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFD1D1D).withValues(alpha: 0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Instagram Story Ring Avatar with '+' Badge
                    Stack(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          padding: const EdgeInsets.all(2.5),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: _instagramStoryGradient,
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                            ),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF0F172A),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: userAvatarUrl != null && userAvatarUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: userAvatarUrl,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => const Icon(
                                        Icons.auto_awesome,
                                        color: Color(0xFFFFDC80),
                                        size: 22,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.auto_awesome,
                                      color: Color(0xFFFFDC80),
                                      size: 22,
                                    ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0095F6), // Instagram Plus Blue
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF0F172A), width: 1.8),
                            ),
                            child: const Center(
                              child: Icon(Icons.add, color: Colors.white, size: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Add to Vibes',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: _instagramStoryGradient),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '24h Story',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Share as your daily status for friends to view',
                            style: GoogleFonts.inter(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _isPostingVibe
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFFC00), Color(0xFFFFB700)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Share',
                              style: GoogleFonts.outfit(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // SECONDARY ACTION: Share Outside
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _shareExternal,
                icon: const Icon(Icons.share_outlined,
                    size: 17, color: Colors.white70),
                label: Text(
                  'Share Outside (WhatsApp, Instagram, etc.)',
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🔍 SEARCH INPUT
            Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search mates or groups...',
                  hintStyle:
                      GoogleFonts.inter(color: Colors.white38, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Colors.white38, size: 19),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white38, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 9),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 💬 SECTION 1: MATES / CHATS (Instagram Stories Style Row)
            Row(
              children: [
                const Icon(Icons.person_rounded,
                    size: 15, color: Color(0xFFFFFC00)),
                const SizedBox(width: 6),
                Text(
                  'SEND TO MATES',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (_isLoadingMates)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              SizedBox(
                height: 88,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  // +1 for the Instagram "Your Story" circle at index 0!
                  itemCount: filteredMates.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, idx) {
                    // Index 0: Instagram-style "Your Story" button
                    if (idx == 0) {
                      return GestureDetector(
                        onTap: _isPostingVibe ? null : _instantAddToVibes,
                        child: SizedBox(
                          width: 68,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    padding: const EdgeInsets.all(2.5),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: _instagramStoryGradient,
                                        begin: Alignment.bottomLeft,
                                        end: Alignment.topRight,
                                      ),
                                    ),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF0F172A),
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: userAvatarUrl != null && userAvatarUrl.isNotEmpty
                                            ? CachedNetworkImage(
                                                imageUrl: userAvatarUrl,
                                                fit: BoxFit.cover,
                                                errorWidget: (_, __, ___) => const Icon(
                                                  Icons.auto_awesome,
                                                  color: Color(0xFFFFDC80),
                                                  size: 20,
                                                ),
                                              )
                                            : const Icon(
                                                Icons.auto_awesome,
                                                color: Color(0xFFFFDC80),
                                                size: 20,
                                              ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0095F6),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: const Color(0xFF0F172A),
                                            width: 1.8),
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.add,
                                            color: Colors.white, size: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Your Story',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFFFC00),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final mate = filteredMates[idx - 1];
                    final mateId = mate['user_id']?.toString() ?? '';
                    final mateName = mate['name']?.toString() ??
                        mate['display_name']?.toString() ??
                        'Mate';
                    final avatarUrl = mate['profile_image_url']?.toString();

                    return GestureDetector(
                      onTap: () => _shareToMate(mateId, mateName),
                      child: SizedBox(
                        width: 68,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFFFFFC00)
                                        .withValues(alpha: 0.6),
                                    width: 1.5),
                                color: const Color(0xFF1E293B),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: avatarUrl != null && avatarUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: avatarUrl,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) => Center(
                                          child: Text(
                                            mateName.isNotEmpty
                                                ? mateName[0].toUpperCase()
                                                : '?',
                                            style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          mateName.isNotEmpty
                                              ? mateName[0].toUpperCase()
                                              : '?',
                                          style: GoogleFonts.outfit(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              mateName,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
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
            const SizedBox(height: 16),

            // 👥 SECTION 2: GROUPS (English Hub completely excluded!)
            Row(
              children: [
                const Icon(Icons.group_rounded,
                    size: 15, color: Color(0xFF38BDF8)),
                const SizedBox(width: 6),
                Text(
                  'SEND TO GROUP CHAT',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (_isLoadingGroups)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (filteredGroups.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _searchQuery.isNotEmpty
                      ? 'No groups found matching "$_searchQuery"'
                      : 'No other groups found.',
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                ),
              )
            else
              SizedBox(
                height: 84,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredGroups.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, idx) {
                    final grp = filteredGroups[idx];
                    final gId = grp['id']?.toString() ?? '';
                    final gName = grp['group_name']?.toString() ??
                        grp['name']?.toString() ??
                        'Group';
                    final iconUrl = grp['icon_url']?.toString();

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
                                  colors: [
                                    Color(0xFF38BDF8),
                                    Color(0xFF6366F1)
                                  ],
                                ),
                                border: Border.all(
                                    color: Colors.white24, width: 1.2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: iconUrl != null && iconUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: iconUrl,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) =>
                                            const Center(
                                          child: Text('💬',
                                              style: TextStyle(fontSize: 20)),
                                        ),
                                      )
                                    : const Center(
                                        child: Text('💬',
                                            style: TextStyle(fontSize: 20)),
                                      ),
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
                    style:
                        GoogleFonts.inter(color: Colors.white60, fontSize: 11),
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
    } else if (widget.gameCard != null) {
      final g = widget.gameCard!;
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
    } else {
      // Thought Card Preview
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Thought',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF38BDF8),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                const Text('💭', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.customText ?? '',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }
  }
}
