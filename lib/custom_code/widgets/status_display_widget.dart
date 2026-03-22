// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:pocket_mates_app/custom_code/widgets/verified_switch_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocket_mates_app/custom_code/widgets/gallery_profile_search_page.dart'; // Import for Gallery Detail Page
import 'package:video_compress/video_compress.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io' as io;
import 'package:video_player/video_player.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:pocket_mates_app/custom_code/widgets/share_content_screen.dart';
import 'package:pocket_mates_app/custom_code/widgets/drawing_academy_home_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/poster_designer/template_gallery_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/bulk_sender/bulk_sender_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/poki_games_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/nearby_users_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/chess_game_page.dart';

class StatusDisplayWidget extends StatefulWidget {
  final String currentUserId;
  final String currentProfileId;
  final double? width;
  final double? height;
  final bool isVertical;
  final VoidCallback? onStatusUploaded;

  const StatusDisplayWidget({
    super.key,
    required this.currentUserId,
    required this.currentProfileId,
    this.width,
    this.height,
    this.isVertical = false,
    this.onStatusUploaded,
    this.searchQuery = '',
  });

  final String searchQuery;

  @override
  State<StatusDisplayWidget> createState() => _StatusDisplayWidgetState();
}

class _StatusDisplayWidgetState extends State<StatusDisplayWidget>
    with TickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _statuses = [];
  List<Map<String, dynamic>> _followingStatuses = [];
  List<Map<String, dynamic>> _publicStatuses = [];
  bool _isLoading = true;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, initialIndex: 1, vsync: this);
    _tabController!.addListener(() {
      if (!_tabController!.indexIsChanging) {
        setState(() {});
      }
    });
    _loadCachedStatuses();
    _loadStatusesOptimized();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadCachedStatuses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString =
          prefs.getString('cached_statuses_${widget.currentUserId}');
      if (cachedString != null) {
        final List<dynamic> decoded = jsonDecode(cachedString);
        setState(() {
          _followingStatuses = List<Map<String, dynamic>>.from(decoded);
          // Assuming public might be similar, or we can just populate both for offline
          _publicStatuses = List<Map<String, dynamic>>.from(decoded);
          _statuses = _followingStatuses;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading cached statuses: $e');
    }
  }

  Future<void> _saveStatusesToCache(List<Map<String, dynamic>> statuses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'cached_statuses_${widget.currentUserId}', jsonEncode(statuses));
    } catch (e) {
      debugPrint('Error saving statuses to cache: $e');
    }
  }

  Future<void> _checkAndDeleteExpiredStatuses() async {
    try {
      final now = DateTime.now().toIso8601String();

      final expiredStatuses = await supabase
          .from('statuses')
          .select('id, media_url, profile_id')
          .lt('expires_at', now)
          .eq('is_active', true);

      for (var status in expiredStatuses) {
        try {
          final statusId = status['id'];
          final mediaUrl = status['media_url'];
          final profileId = status['profile_id'];

          // Extract file path from media URL
          final fileName = mediaUrl.split('/').last;
          final filePath = '$profileId/$fileName';

          // Delete from storage
          await supabase.storage.from('statuses').remove([filePath]);

          // Delete from statuses table (cascades delete)
          await supabase.from('statuses').delete().eq('id', statusId);

          debugPrint('Auto-deleted expired status: $statusId');
        } catch (e) {
          debugPrint('Error deleting expired status: $e');
        }
      }
    } catch (e) {
      debugPrint('Error checking expired statuses: $e');
    }
  }

  Future<void> _loadStatusesOptimized() async {
    try {
      _checkAndDeleteExpiredStatuses(); // Run in background to not block loading

      // 1. Fetch user's groups to filter group mentions
      final myGroupsRes = await supabase
          .from('group_members')
          .select('group_id, groups(id, name, group_image_url)')
          .eq('profile_id', widget.currentProfileId);
      final myGroupIds =
          List<String>.from(myGroupsRes.map((e) => e['group_id'].toString()));
      final groupsMap = {
        for (var g in myGroupsRes) g['group_id'].toString(): g['groups']
      };

      // 2. Fetch following list using Auth ID
      final followingRes = await supabase
          .from('follows')
          .select('followed_id')
          .eq('follower_id', widget.currentUserId);
      final followingIds = List<String>.from(
          followingRes.map((e) => e['followed_id'].toString()));

      // 3. Optimized Single Query with Join - include user_id for follow check
      final response = await supabase
          .from('statuses')
          .select(
              '*, profile:profile_id(id, name, profile_image_url, user_id), thought:thought_id(*, user:users!user_id(profile:profile!user_id(name, profile_image_url)))')
          .eq('is_active', true)
          .gt('expires_at', DateTime.now().toIso8601String())
          .order('created_at',
              ascending: true); // Show oldest first for story timeline

      final List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(response);

      // 4. Grouping logic
      final Map<String, Map<String, dynamic>> followingGroups = {};
      final Map<String, Map<String, dynamic>> publicGroups = {};
      final Map<String, Map<String, dynamic>> communityVibeBuckets = {};

      for (var status in data) {
        final profile = status['profile'];
        final profileId = status['profile_id'];
        final profUserId = profile['user_id']?.toString();
        final gid = status['mentioned_group_id'];

        if (profile == null) continue;

        final bool isFollowing = followingIds.contains(profUserId) ||
            profUserId == widget.currentUserId;

        // 1. Process as Personal Status (for Friends/Following and Public)
        // Public shows EVERYONE
        if (!publicGroups.containsKey(profileId)) {
          publicGroups[profileId] = {
            'profile': profile,
            'statuses': [],
            'is_own': profUserId == widget.currentUserId,
            'is_group': false,
          };
        }
        publicGroups[profileId]!['statuses'].add(status);

        // Friends/Following shows only those followed
        if (isFollowing) {
          if (!followingGroups.containsKey(profileId)) {
            followingGroups[profileId] = {
              'profile': profile,
              'statuses': [],
              'is_own': profUserId == widget.currentUserId,
              'is_group': false,
            };
          }
          followingGroups[profileId]!['statuses'].add(status);
        }

        // 2. Process as Community Mention (if applicable)
        if (gid != null) {
          final gidStr = gid.toString();
          if (myGroupIds.contains(gidStr)) {
            if (!communityVibeBuckets.containsKey(gidStr)) {
              final groupData = groupsMap[gidStr];
              communityVibeBuckets[gidStr] = {
                'profile': {
                  'id': gidStr,
                  'name': groupData?['name'] ?? 'Unnamed Group',
                  'profile_image_url': groupData?['group_image_url'],
                },
                'statuses': [],
                'is_own': false,
                'is_group': true,
              };
            }
            communityVibeBuckets[gidStr]!['statuses'].add(status);
          }
        }
      }

      // 5. Combine and Sort
      final List<Map<String, dynamic>> followingList = [
        ...followingGroups.values,
        ...communityVibeBuckets.values
      ];
      final List<Map<String, dynamic>> publicList =
          publicGroups.values.toList();

      final sortingFunc = (Map<String, dynamic> a, Map<String, dynamic> b) {
        if (a['is_own'] == true && b['is_own'] != true) return -1;
        if (a['is_own'] != true && b['is_own'] == true) return 1;
        // Since we fetch ascending: true, statuses.last is the NEWEST
        final aTime = (a['statuses'] as List).last['created_at'];
        final bTime = (b['statuses'] as List).last['created_at'];
        return DateTime.parse(bTime).compareTo(DateTime.parse(aTime));
      };

      followingList.sort(sortingFunc);
      publicList.sort(sortingFunc);

      // Cache the following list (primary view)
      _saveStatusesToCache(followingList);

      if (mounted) {
        setState(() {
          _followingStatuses = followingList;
          _publicStatuses = publicList;
          _statuses = followingList; // Default list
          _isLoading = false;
        });
        _precacheAllStatuses();
      }
    } catch (e) {
      debugPrint('Error loading statuses: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _precacheAllStatuses() async {
    for (var group in _statuses) {
      final statuses = group['statuses'] as List;
      // Cache the first few statuses of each user for instant load
      for (var i = 0; i < statuses.length && i < 3; i++) {
        final status = statuses[i];
        final url = status['media_url'];
        if (url != null) {
          try {
            // Download and cache file specifically
            await DefaultCacheManager().downloadFile(url);

            // Also standard precache for images
            if (status['media_type'] == 'image') {
              if (mounted) {
                precacheImage(CachedNetworkImageProvider(url), context);
              }
            }
          } catch (e) {
            debugPrint('Error caching file $url: $e');
          }
        }
      }
    }
  }

  void _openStatusViewer(int initialIndex, List<Map<String, dynamic>> list) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatusViewerWrapper(
          allStatusGroups: list,
          initialGroupIndex: initialIndex,
          currentUserId: widget.currentUserId,
          currentProfileId: widget.currentProfileId,
        ),
      ),
    );
  }

  void _openStatusUpload() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatusUploadWidget(
          userId: widget.currentUserId,
          profileId: widget.currentProfileId,
        ),
      ),
    );

    if (result == true) {
      _loadStatusesOptimized();
      widget.onStatusUploaded?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVertical) {
      return Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            minHeight: 200,
            maxHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            children: [
              _buildCategorySelector(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStatusList(_publicStatuses, isGrid: true),
                    _buildStatusList(_followingStatuses, isGrid: false),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        height: 120,
        child: _isLoading
            ? _buildShimmerLoading()
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: _followingStatuses.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) return _buildAddStatusButton();
                  final statusGroup = _followingStatuses[index - 1];
                  return _buildStatusItem(statusGroup, index - 1, true);
                },
              ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildCategoryButton('Public', 0)),
          Expanded(child: _buildCategoryButton('Friends', 1)),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String label, int index) {
    bool isSelected = _tabController?.index == index;
    return GestureDetector(
      onTap: () {
        _tabController?.animateTo(index);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellow : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: isSelected ? Colors.black : Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusList(List<Map<String, dynamic>> statusData,
      {required bool isGrid}) {
    final filteredData = statusData.where((group) {
      if (widget.searchQuery.isEmpty) return true;
      final name = group['profile']?['name']?.toString().toLowerCase() ?? '';
      return name.contains(widget.searchQuery.toLowerCase());
    }).toList();

    if (_isLoading) return _buildVerticalShimmer();
    if (filteredData.isEmpty && !widget.isVertical) {
      return const SizedBox.shrink();
    }

    if (isGrid && widget.isVertical) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.trending_up,
                            color: Colors.blueAccent, size: 24),
                        const SizedBox(height: 8),
                        Text('Trending',
                            style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        Text('Viral Vibes',
                            style: GoogleFonts.outfit(
                                color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.greenAccent, size: 24),
                        const SizedBox(height: 8),
                        Text('Nearby',
                            style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        Text('Local Vibes',
                            style: GoogleFonts.outfit(
                                color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredData.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                final statusGroup = filteredData[index];
                return _buildGridStatusItem(statusGroup, index, filteredData);
              },
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredData.length + (widget.isVertical ? 1 : 0),
      itemBuilder: (context, index) {
        if (widget.isVertical && index == 0) return _buildAddStatusButton();
        final actualIndex = widget.isVertical ? index - 1 : index;
        if (actualIndex < 0) return const SizedBox.shrink();

        final statusGroup = filteredData[actualIndex];
        return _buildStatusItem(statusGroup, actualIndex, false,
            listOverride: filteredData);
      },
    );
  }

  Widget _buildGridStatusItem(Map<String, dynamic> statusGroup, int index,
      List<Map<String, dynamic>> list) {
    final profile = statusGroup['profile'];
    final statuses = statusGroup['statuses'] as List;
    final lastStatus = statuses.last; // Show newest update in preview
    final mediaUrl = lastStatus['media_url'];
    final mediaType = lastStatus['media_type'];
    final thumbnailUrl = lastStatus['thumbnail_url'];

    return GestureDetector(
      onTap: () => _openStatusViewer(index, list),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Media Preview
            if (mediaType == 'image')
              CachedNetworkImage(
                imageUrl: mediaUrl,
                fit: BoxFit.cover,
              )
            else if (mediaType == 'video' && thumbnailUrl != null)
              CachedNetworkImage(
                imageUrl: thumbnailUrl,
                fit: BoxFit.cover,
              )
            else if (mediaType == 'thought')
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF262626), Color(0xFF1A1A1A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.format_quote_rounded,
                        color: Colors.yellow, size: 24),
                    const SizedBox(height: 8),
                    Text(
                      lastStatus['caption'] ?? '',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFCC2B5E), Color(0xFF753A88)],
                  ),
                ),
                child: const Icon(Icons.text_format, color: Colors.white70),
              ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            // Profile Info
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: profile['profile_image_url'] != null
                        ? CachedNetworkImageProvider(
                            profile['profile_image_url'])
                        : null,
                    child: profile['profile_image_url'] == null
                        ? const Icon(Icons.person, size: 12)
                        : null,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      profile['name'] ?? 'Unknown',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildVerticalShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Shimmer.fromColors(
          baseColor: Colors.white.withValues(alpha: 0.05),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 140,
                    height: 14,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 6,
      itemBuilder: (context, index) => Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Shimmer.fromColors(
          baseColor: Colors.white.withValues(alpha: 0.05),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
              ),
              const SizedBox(height: 8),
              Container(
                width: 50,
                height: 10,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddStatusButton() {
    if (widget.isVertical) {
      return InkWell(
        onTap: _openStatusUpload,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Colors.yellow.withValues(alpha: 0.3), width: 1),
            color: Colors.yellow.withValues(alpha: 0.05),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_circle_outline_rounded,
                  color: Colors.yellow, size: 20),
              const SizedBox(width: 12),
              Text(
                'Add',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _openStatusUpload,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.yellow.withValues(alpha: 0.3), width: 1),
                color: Colors.yellow.withValues(alpha: 0.05),
              ),
              child:
                  const Icon(Icons.add_rounded, size: 28, color: Colors.yellow),
            ),
            const SizedBox(height: 8),
            Text(
              'Add',
              style: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(Map<String, dynamic> statusGroup, int index,
      bool isHorizontal, // Added parameter
      {List<Map<String, dynamic>>? listOverride}) {
    final profile = statusGroup['profile'];
    final isOwn = statusGroup['is_own'] ?? false;
    final isGroup = statusGroup['is_group'] ?? false;
    final name = profile['name'] ?? 'Unknown';
    final profileImageUrl = profile['profile_image_url'];
    final statuses = statusGroup['statuses'] as List;
    final lastStatus = statuses.first;
    final createdAt = DateTime.parse(lastStatus['created_at']);
    final timeString = timeago.format(createdAt, locale: 'en_short');
    final activeList =
        listOverride ?? (isHorizontal ? _followingStatuses : _statuses);

    if (!isHorizontal) {
      return InkWell(
        onTap: () => _openStatusViewer(index, activeList),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              _buildAvatarWithRing(profileImageUrl, name, 64, isGroup: isGroup),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isOwn ? 'My Vibes' : name,
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                        isGroup
                            ? 'Community Vibe • $timeString'
                            : (isOwn
                                ? 'Share a Vibe • $timeString'
                                : timeString),
                        style: GoogleFonts.outfit(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _openStatusViewer(index, activeList),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            _buildAvatarWithRing(profileImageUrl, name, 72, isGroup: isGroup),
            const SizedBox(height: 2),
            Text(isOwn ? 'My Vibes' : name,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarWithRing(String? url, String name, double size,
      {bool isGroup = false}) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isGroup
            ? const LinearGradient(
                colors: [
                  Color(0xFF833AB4), // Purple
                  Color(0xFFF77737), // Orange
                  Color(0xFFFCAF45), // Yellow
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              )
            : const LinearGradient(
                colors: [
                  Color(0xFFFFB703),
                  Color(0xFFFB8500),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration:
            const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
        child: ClipOval(
          child: url != null
              ? CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: const Color(0xFF1A1A1A)),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.person, color: Colors.white24),
                )
              : Container(
                  color: const Color(0xFF262626),
                  child: Center(
                    child: Text(name[0].toUpperCase(),
                        style: GoogleFonts.outfit(
                            fontSize: size * 0.4,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
        ),
      ),
    );
  }
}

class StatusViewerWrapper extends StatefulWidget {
  final List<Map<String, dynamic>> allStatusGroups;
  final int initialGroupIndex;
  final String currentUserId;
  final String currentProfileId;
  final bool isFromGroup;

  const StatusViewerWrapper({
    super.key,
    required this.allStatusGroups,
    required this.initialGroupIndex,
    required this.currentUserId,
    required this.currentProfileId,
    this.isFromGroup = false,
  });

  @override
  State<StatusViewerWrapper> createState() => _StatusViewerWrapperState();
}

class _StatusViewerWrapperState extends State<StatusViewerWrapper> {
  late int _currentGroupIndex;

  @override
  void initState() {
    super.initState();
    _currentGroupIndex = widget.initialGroupIndex;
    _preloadAdjacentGroups();
  }

  void _preloadAdjacentGroups() {
    // Pre-cache images/videos for next and previous groups
    if (_currentGroupIndex < widget.allStatusGroups.length - 1) {
      _preCacheFirstStatusOfGroup(_currentGroupIndex + 1);
    }
    if (_currentGroupIndex > 0) {
      _preCacheFirstStatusOfGroup(_currentGroupIndex - 1);
    }
  }

  void _preCacheFirstStatusOfGroup(int index) {
    try {
      final statuses = widget.allStatusGroups[index]['statuses'] as List;
      if (statuses.isNotEmpty) {
        final firstStatus = statuses.first;
        if (firstStatus['media_type'] == 'image') {
          precacheImage(
              CachedNetworkImageProvider(firstStatus['media_url']), context);
        } else if (firstStatus['media_type'] == 'video') {
          // Warm up the video by initializing it in background
          final controller = VideoPlayerController.networkUrl(
              Uri.parse(firstStatus['media_url']));
          controller.initialize().then((_) {
            // Once initialized, it's in the underlying OS cache for this URL
            controller.dispose();
          });
        }
      }
    } catch (e) {
      debugPrint('Pre-cache error: $e');
    }
  }

  void _goToNextGroup() {
    if (_currentGroupIndex < widget.allStatusGroups.length - 1) {
      setState(() {
        _currentGroupIndex++;
      });
      _preloadAdjacentGroups();
    } else {
      Navigator.pop(context);
    }
  }

  void _goToPreviousGroup() {
    if (_currentGroupIndex > 0) {
      setState(() {
        _currentGroupIndex--;
      });
      _preloadAdjacentGroups();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatusViewerScreen(
      key: ValueKey(_currentGroupIndex),
      statusGroup: widget.allStatusGroups[_currentGroupIndex],
      currentUserId: widget.currentUserId,
      currentProfileId: widget.currentProfileId,
      onNextGroup: _goToNextGroup,
      onPreviousGroup: _goToPreviousGroup,
    );
  }
}

class StatusViewerScreen extends StatefulWidget {
  final Map<String, dynamic> statusGroup;
  final String currentUserId;
  final String currentProfileId;
  final VoidCallback onNextGroup;
  final VoidCallback onPreviousGroup;

  const StatusViewerScreen({
    super.key,
    required this.statusGroup,
    required this.currentUserId,
    required this.currentProfileId,
    required this.onNextGroup,
    required this.onPreviousGroup,
  });

  @override
  State<StatusViewerScreen> createState() => _StatusViewerScreenState();
}

class _StatusViewerScreenState extends State<StatusViewerScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _progressController;
  late AnimationController _transitionController;
  final supabase = Supabase.instance.client;

  VideoPlayerController? _currentVideoController;
  VideoPlayerController? _preloadedVideoController;
  bool _isPreloadedVideoReady = false;
  bool _isCurrentVideoReady = false;
  bool _isPaused = false;
  double _dragPosition = 0.0;

  int _currentViewCount = 0;
  List<Map<String, dynamic>> _currentViewers = [];
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _checkAndDeleteExpiredStatuses();
    _initializeViewer();
  }

  Future<void> _initializeViewer() async {
    await _loadWatchProgress();
    _startCurrentStatus();
  }

  Future<void> _saveWatchProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final targetProfileId = widget.statusGroup['profile']['id'];
      final key = 'status_progress_${widget.currentUserId}_$targetProfileId';
      await prefs.setInt(key, _currentIndex);
    } catch (e) {
      debugPrint('Error saving watch progress: $e');
    }
  }

  Future<void> _loadWatchProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final targetProfileId = widget.statusGroup['profile']['id'];
      final key = 'status_progress_${widget.currentUserId}_$targetProfileId';
      final savedIndex = prefs.getInt(key);
      if (savedIndex != null) {
        final statuses = widget.statusGroup['statuses'] as List;
        if (savedIndex < statuses.length) {
          setState(() {
            _currentIndex = savedIndex;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading watch progress: $e');
    }
  }

  @override
  void dispose() {
    _preloadedVideoController?.dispose();
    _progressController.dispose();
    _transitionController.dispose();
    _currentVideoController?.dispose();
    super.dispose();
  }

  Future<void> _loadLikeStatus(String statusId) async {
    try {
      final response = await supabase
          .from('status_likes')
          .select()
          .eq('status_id', statusId)
          .eq('user_id', widget.currentUserId)
          .maybeSingle();

      final likesCount = await supabase
          .from('status_likes')
          .select()
          .eq('status_id', statusId)
          .count(CountOption.exact);

      setState(() {
        _isLiked = response != null;
        _likeCount = likesCount.count;
      });
    } catch (e) {
      debugPrint('Error loading like status: $e');
    }
  }

  Future<void> _toggleLike(String statusId) async {
    try {
      if (_isLiked) {
        await supabase
            .from('status_likes')
            .delete()
            .eq('status_id', statusId)
            .eq('user_id', widget.currentUserId);
      } else {
        await supabase.from('status_likes').insert({
          'status_id': statusId,
          'user_id': widget.currentUserId,
          'profile_id': widget.currentProfileId,
        });
      }

      setState(() {
        _isLiked = !_isLiked;
        _likeCount += _isLiked ? 1 : -1;
      });
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
  }

  Future<void> _startCurrentStatus() async {
    final statuses = widget.statusGroup['statuses'] as List;
    if (_currentIndex >= statuses.length) return;

    final status = statuses[_currentIndex];

    // If we have a preloaded video for this status, use it
    if (status['media_type'] == 'video' &&
        _preloadedVideoController != null &&
        _isPreloadedVideoReady) {
      await _currentVideoController?.dispose();
      _currentVideoController = _preloadedVideoController;
      _isCurrentVideoReady = true;
      _preloadedVideoController = null;
      _isPreloadedVideoReady = false;
    } else {
      // Normal initialization
      await _currentVideoController?.dispose();
      _currentVideoController = null;
      _isCurrentVideoReady = false;

      if (status['media_type'] == 'video') {
        try {
          // Play from cache if possible
          final file =
              await DefaultCacheManager().getSingleFile(status['media_url']);
          _currentVideoController = VideoPlayerController.file(file);

          await _currentVideoController!.initialize();
          if (mounted) {
            setState(() {
              _isCurrentVideoReady = true;
            });
          }
        } catch (e) {
          debugPrint('Video play error: $e');
          // Fallback to network if cache fails
          _currentVideoController = VideoPlayerController.networkUrl(
            Uri.parse(status['media_url']),
          );
          try {
            await _currentVideoController!.initialize();
            if (mounted) setState(() => _isCurrentVideoReady = true);
          } catch (e2) {
            debugPrint('Video fallback error: $e2');
          }
        }
      }
    }

    _progressController.reset();

    if (status['media_type'] == 'video' && _currentVideoController != null) {
      await _currentVideoController!.play();
      final duration = _currentVideoController!.value.duration;
      _progressController.duration = duration;
      _progressController.forward(from: 0);
      _currentVideoController!.addListener(_onVideoProgress);
    } else {
      final duration = status['duration'] ?? 5;
      _progressController.duration = Duration(seconds: duration);
      _progressController.forward(from: 0);
    }

    _progressController.addListener(_onProgressUpdate);

    await _markStatusAsViewed(status['id']);
    await _loadViewCount(status['id']);
    await _loadLikeStatus(status['id']);

    // Preload next status
    _preloadNextStatus();
  }

  Future<void> _preloadNextStatus() async {
    final statuses = widget.statusGroup['statuses'] as List;

    // Clean up existing preloaded video
    await _preloadedVideoController?.dispose();
    _preloadedVideoController = null;
    _isPreloadedVideoReady = false;

    if (_currentIndex + 1 < statuses.length) {
      final nextStatus = statuses[_currentIndex + 1];
      if (nextStatus['media_type'] == 'video') {
        try {
          final file = await DefaultCacheManager()
              .getSingleFile(nextStatus['media_url']);
          _preloadedVideoController = VideoPlayerController.file(file);

          await _preloadedVideoController!.initialize();
          _isPreloadedVideoReady = true;
          debugPrint('Next video preloaded from cache successfully');
        } catch (e) {
          debugPrint('Error preloading next video: $e');
          // Fallback
          _preloadedVideoController = VideoPlayerController.networkUrl(
            Uri.parse(nextStatus['media_url']),
          );
          try {
            await _preloadedVideoController!.initialize();
            _isPreloadedVideoReady = true;
          } catch (e2) {
            _isPreloadedVideoReady = false;
          }
        }
      } else if (nextStatus['media_type'] == 'image') {
        precacheImage(
          CachedNetworkImageProvider(nextStatus['media_url']),
          context,
        );
      }
    }

    // Also precache the 2nd next image if possible for even faster transitions
    if (_currentIndex + 2 < statuses.length) {
      final nextNextStatus = statuses[_currentIndex + 2];
      if (nextNextStatus['media_type'] == 'image') {
        precacheImage(
          CachedNetworkImageProvider(nextNextStatus['media_url']),
          context,
        );
      }
    }
  }

  Future<void> _checkAndDeleteExpiredStatuses() async {
    try {
      final now = DateTime.now().toIso8601String();

      final expiredStatuses = await supabase
          .from('statuses')
          .select('id, media_url, profile_id')
          .lt('expires_at', now)
          .eq('is_active', true);

      for (var status in expiredStatuses) {
        try {
          final statusId = status['id'];
          final mediaUrl = status['media_url'];
          final profileId = status['profile_id'];

          if (mediaUrl != null && mediaUrl.toString().isNotEmpty) {
            final fileName = mediaUrl.split('/').last;
            final filePath = '$profileId/$fileName';
            await supabase.storage.from('statuses').remove([filePath]);
          }
          await supabase.from('statuses').delete().eq('id', statusId);

          debugPrint('Auto-deleted expired status: $statusId');
        } catch (e) {
          debugPrint('Error deleting expired status: $e');
        }
      }
    } catch (e) {
      debugPrint('Error checking expired statuses: $e');
    }
  }

  void _onVideoProgress() {
    if (_currentVideoController != null &&
        _currentVideoController!.value.position >=
            _currentVideoController!.value.duration) {
      _goToNext();
    }
  }

  void _onProgressUpdate() {
    if (_progressController.status == AnimationStatus.completed &&
        _currentVideoController == null) {
      _goToNext();
    }
  }

  Future<void> _markStatusAsViewed(String statusId) async {
    try {
      // Check if already viewed
      final existingView = await supabase
          .from('status_views')
          .select()
          .eq('status_id', statusId)
          .eq('viewer_user_id', widget.currentUserId)
          .maybeSingle();

      // Only insert if not already viewed
      if (existingView == null) {
        await supabase.from('status_views').insert({
          'status_id': statusId,
          'viewer_user_id': widget.currentUserId,
          'viewer_profile_id': widget.currentProfileId,
        });

        // Increment view count
        await supabase.rpc('increment_status_views', params: {
          'status_id': statusId,
        });
      }
    } catch (e) {
      debugPrint('Error marking viewed: $e');
    }
  }

  Future<void> _loadViewCount(String statusId) async {
    try {
      // Get view count
      final response = await supabase
          .from('statuses')
          .select('views_count')
          .eq('id', statusId)
          .single();

      setState(() {
        _currentViewCount = response['views_count'] ?? 0;
      });
    } catch (e) {
      debugPrint('Error loading view count: $e');
    }
  }

  Future<void> _loadViewers(String statusId) async {
    try {
      // Get all viewers with their profile info
      final response = await supabase.from('status_views').select('''
          created_at,
          viewer_profile_id,
          profile!status_views_viewer_profile_id_fkey (
            id,
            name,
            profile_image_url,
            user_id
          )
        ''').eq('status_id', statusId).order('created_at', ascending: false);

      // Get all likes for this status
      final likesResponse = await supabase
          .from('status_likes')
          .select('profile_id')
          .eq('status_id', statusId);

      final likedProfileIds =
          likesResponse.map((like) => like['profile_id'] as String).toSet();

      setState(() {
        _currentViewers = List<Map<String, dynamic>>.from(response);
      });

      // Show viewers bottom sheet with likes info
      _showViewersSheet(statusId, likedProfileIds);
    } catch (e) {
      debugPrint('Error loading viewers: $e');
    }
  }

  void _showViewersSheet(String statusId, Set<String> likedProfileIds) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Viewed by $_currentViewCount ${_currentViewCount == 1 ? 'person' : 'people'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: _currentViewers.isEmpty
                    ? const Center(
                        child: Text(
                          'No views yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _currentViewers.length,
                        itemBuilder: (context, index) {
                          final viewer = _currentViewers[index];
                          final profile = viewer['profile'];
                          final viewerProfileId = viewer['viewer_profile_id'];
                          final isLiked =
                              likedProfileIds.contains(viewerProfileId);
                          final timeAgo = _getTimeAgo(viewer['created_at']);

                          return ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VerfiedSwitchPage(
                                    userId: profile['user_id'] ?? '',
                                  ),
                                ),
                              );
                            },
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[800],
                              backgroundImage:
                                  profile['profile_image_url'] != null
                                      ? CachedNetworkImageProvider(
                                          profile['profile_image_url'])
                                      : null,
                              child: profile['profile_image_url'] == null
                                  ? Text(
                                      (profile['name'] ?? 'U')[0].toUpperCase(),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    )
                                  : null,
                            ),
                            title: Text(
                              profile['name'] ?? 'Unknown',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              timeAgo,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                            trailing: isLiked
                                ? const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 20,
                                  )
                                : null,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _goToNext() {
    final statuses = widget.statusGroup['statuses'] as List;

    _currentVideoController?.removeListener(_onVideoProgress);
    _progressController.removeListener(_onProgressUpdate);

    if (_currentIndex < statuses.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _saveWatchProgress();
      _startCurrentStatus();
    } else {
      widget.onNextGroup();
    }
  }

  void _goToPrevious() {
    _currentVideoController?.removeListener(_onVideoProgress);
    _progressController.removeListener(_onProgressUpdate);

    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _saveWatchProgress();
      _startCurrentStatus();
    } else {
      widget.onPreviousGroup();
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });

    if (_currentVideoController != null && _isCurrentVideoReady) {
      if (_isPaused) {
        _currentVideoController!.pause();
        _progressController.stop();
      } else {
        _currentVideoController!.play();
        _progressController.forward();
      }
    } else {
      if (_isPaused) {
        _progressController.stop();
      } else {
        _progressController.forward();
      }
    }
  }

  Future<void> _deleteStatus(String statusId, String mediaUrl) async {
    try {
      // Extract file path from media URL
      final fileName = mediaUrl.split('/').last;
      final filePath = '${widget.currentProfileId}/$fileName';

      // Delete from storage
      await supabase.storage.from('statuses').remove([filePath]);

      // Delete from statuses table (cascades to status_views and status_likes)
      await supabase.from('statuses').delete().eq('id', statusId);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status deleted')),
        );
      }
    } catch (e) {
      debugPrint('Error deleting status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete status')),
      );
    }
  }

  void _showDeleteConfirmation(String statusId, String mediaUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Status?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This status will be permanently deleted.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteStatus(statusId, mediaUrl);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statuses = widget.statusGroup['statuses'] as List;
    final currentStatus = statuses[_currentIndex];
    final profile = widget.statusGroup['profile'];
    final isOwnStatus = widget.statusGroup['is_own'] ?? false;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            _dragPosition += details.primaryDelta! / size.width;
            _dragPosition = _dragPosition.clamp(-1.0, 1.0);
          });
        },
        onHorizontalDragEnd: (details) {
          if (_dragPosition > 0.3) {
            _goToPrevious();
          } else if (_dragPosition < -0.3) {
            _goToNext();
          }
          setState(() {
            _dragPosition = 0.0;
          });
        },
        onTapUp: (details) {
          final tapX = details.globalPosition.dx;
          // Side tapping navigation (Instagram style)
          if (tapX < size.width * 0.33) {
            _goToPrevious();
          } else if (tapX > size.width * 0.66) {
            _goToNext();
          } else {
            _togglePause();
          }
        },
        child: Stack(
          children: [
            // Status Content with Swipe Effect
            Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_dragPosition * 0.5),
              alignment: Alignment.center,
              child: Container(
                color: Colors.black,
                child: Center(
                  child: _buildMediaContent(currentStatus),
                ),
              ),
            ),

            // Drag Indicator
            if (_dragPosition.abs() > 0.1)
              Positioned.fill(
                child: Container(
                  color:
                      Colors.black.withValues(alpha: 0.3 * _dragPosition.abs()),
                  child: Center(
                    child: Icon(
                      _dragPosition > 0
                          ? Icons.arrow_back_ios_rounded
                          : Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 60,
                    ),
                  ),
                ),
              ),

            // Top Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 12,
                  right: 12,
                  bottom: 8,
                ),
                child: Column(
                  children: [
                    // Progress Bars
                    Row(
                      children: List.generate(statuses.length, (index) {
                        return Expanded(
                          child: Container(
                            height: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, child) {
                                double value = 0.0;
                                if (index < _currentIndex) {
                                  value = 1.0;
                                } else if (index == _currentIndex) {
                                  value = _progressController.value;
                                }
                                return FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    // Profile Info with View Count
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey[800],
                          backgroundImage: profile['profile_image_url'] != null
                              ? CachedNetworkImageProvider(
                                  profile['profile_image_url'])
                              : null,
                          child: profile['profile_image_url'] == null
                              ? Text(
                                  (profile['name'] ?? 'U')[0].toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            children: [
                              if (widget.statusGroup['is_group'] == true) ...[
                                Text(
                                  profile['name'] ?? 'Group',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(Icons.chevron_right,
                                      color: Colors.white38, size: 14),
                                ),
                              ],
                              Text(
                                currentStatus['profile']?['name'] ?? 'Unknown',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getTimeAgo(currentStatus['created_at']),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Group Mention Tag
                        if (currentStatus['mentioned_group_id'] != null)
                          FutureBuilder(
                            future: supabase
                                .from('groups')
                                .select('name')
                                .eq('id', currentStatus['mentioned_group_id'])
                                .maybeSingle(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data == null)
                                return const SizedBox.shrink();
                              final gName = snapshot.data!['name'] ?? '';
                              return _buildMentionTag(
                                  gName, Icons.groups_rounded);
                            },
                          ),
                        // User Mention Tag
                        if (currentStatus['mentioned_profile_id'] != null)
                          FutureBuilder(
                            future: supabase
                                .from('profile')
                                .select('name')
                                .eq('id', currentStatus['mentioned_profile_id'])
                                .maybeSingle(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data == null)
                                return const SizedBox.shrink();
                              final pName = snapshot.data!['name'] ?? '';
                              return _buildMentionTag(pName, Icons.person);
                            },
                          ),
                        const Spacer(),
                        // View Count (Only show for own status)
                        if (isOwnStatus)
                          GestureDetector(
                            onTap: () => _loadViewers(currentStatus['id']),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.visibility,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$_currentViewCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Caption
            if (currentStatus['caption'] != null &&
                currentStatus['caption'].toString().isNotEmpty &&
                currentStatus['media_type'] != 'text')
              Positioned(
                bottom: 30,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentStatus['caption'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            Positioned(
              bottom: 8, // distance from bottom
              left: 8, // distance from left
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _toggleLike(currentStatus['id']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isLiked ? Icons.favorite : Icons.favorite_border,
                            color: _isLiked ? Colors.red : Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$_likeCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      _togglePause(); // Pause while sharing
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShareContentScreen(
                            contentToShare:
                                currentStatus['media_type'] == 'text' ||
                                        currentStatus['media_type'] == 'thought'
                                    ? (currentStatus['caption'] ?? '')
                                    : (currentStatus['media_url'] ?? ''),
                            contentId:
                                currentStatus['thought_id']?.toString() ??
                                    currentStatus['gallery_id']?.toString(),
                            contentType: currentStatus['thought_id'] != null
                                ? 'thought'
                                : (currentStatus['gallery_id'] != null
                                    ? 'gallery'
                                    : (currentStatus['media_type'] == 'image' ||
                                            currentStatus['media_type'] ==
                                                'video'
                                        ? 'gallery'
                                        : 'text')),
                            currentUserId: widget.currentUserId,
                          ),
                        ),
                      ).then((_) {
                        _togglePause(); // Resume when returning
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Share',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isOwnStatus)
              Positioned(
                bottom: 8, // distance from bottom
                right: 8, // distance from right
                child: IconButton(
                  onPressed: () => _showDeleteConfirmation(
                    currentStatus['id'],
                    currentStatus['media_url'],
                  ),
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            // Pause Overlay
            if (_isPaused)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pause,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent(Map<String, dynamic> status) {
    Widget content;

    if (status['media_type'] == 'thought') {
      final thoughtData = status['thought'];
      final profile = (thoughtData != null &&
              thoughtData['user']?['profile'] is List &&
              (thoughtData['user']['profile'] as List).isNotEmpty)
          ? thoughtData['user']['profile'][0]
          : (thoughtData != null ? thoughtData['profile'] ?? {} : {});

      final authorName = profile['name'] ?? 'User';
      final String? authorAvatar = profile['profile_image_url'];
      final thoughtContent =
          (thoughtData != null && thoughtData['content'] != null)
              ? thoughtData['content']
              : (status['caption'] ?? status['content'] ?? '');

      content = Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              borderRadius: BorderRadius.circular(24),
              border:
                  Border.all(color: Colors.yellow.withOpacity(0.2), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.yellow.withOpacity(0.5), width: 1.5),
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.black,
                        backgroundImage: authorAvatar != null
                            ? CachedNetworkImageProvider(authorAvatar)
                            : null,
                        child: authorAvatar == null
                            ? Text(authorName[0].toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.yellow,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16))
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authorName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            'Shared a thought',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Opacity(
                      opacity: 0.3,
                      child: Icon(Icons.format_quote_rounded,
                          color: Colors.yellow, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  thoughtContent,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (status['media_type'] == 'tool') {
      final metadata = status['metadata'] ?? {};
      final title = metadata['title'] ?? 'Tool';
      final description = metadata['description'] ?? '';

      content = Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(30),
              border:
                  Border.all(color: Colors.yellow.withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.yellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.apps, color: Colors.black, size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Similar logic to _navigateToTool in WhatsAppGroupChat
                    _navigateToToolFromStatus(title);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Open Tool'),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (status['media_type'] == 'text') {
      content = Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFCC2B5E), Color(0xFF753A88)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Text(
            status['caption'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (status['media_type'] == 'image') {
      content = CachedNetworkImage(
        imageUrl: status['media_url'],
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        memCacheWidth: 1080, // Optimized for status viewing
        placeholder: (context, url) => Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 50),
              SizedBox(height: 8),
              Text('Failed to load image',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    } else {
      // Video
      if (_currentVideoController != null && _isCurrentVideoReady) {
        content = Container(
          color: Colors.black,
          child: Center(
            child: AspectRatio(
              aspectRatio: _currentVideoController!.value.aspectRatio,
              child: VideoPlayer(_currentVideoController!),
            ),
          ),
        );
      } else {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        );
      }
    }

    // Wrap with Gallery Link logic if applicable
    if (status['gallery_id'] != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          content,
          Positioned(
            bottom: 120, // Above caption/reply area
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => _navigateToGalleryDetail(status['gallery_id']),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.yellow.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Details',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.black, size: 14),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return content;
  }

  void _navigateToToolFromStatus(String title) {
    // Implement navigation matching WhatsAppGroupChat
    Widget? page;
    switch (title) {
      case 'Poster Designer':
        page = const TemplateGalleryPage();
        break;
      case 'Bulk Sender':
        page = const BulkSenderPage();
        break;
      case 'Poki Games':
        page = const PokiGamesPage();
        break;
      case 'Drawing Academy':
        page = const DrawingAcademyHomePage();
        break;
      case 'Travel Radar':
        page = const NearbyUsersPage();
        break;
      case 'Nearby Profiles':
        page = const NearbyUsersPage();
        break;
      case 'Chess':
        page = const ChessMatchmakingPage();
        break;
    }
    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
    }
  }

  Future<void> _navigateToGalleryDetail(String galleryId) async {
    try {
      // Fetch gallery item details
      final response = await supabase
          .from('gallery_with_comments_view') // content_view logic
          .select()
          .eq('gallery_id', galleryId)
          .single(); // Assuming ID exists

      if (!mounted) return;

      final item = Map<String, dynamic>.from(response);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GalleryDetailsprofilePage(
            item: item,
            allItems: [item], // Single item list
            initialIndex: 0,
            bgColor: Colors.black,
            bgtextcolor: Colors.white,
            buttoncolorcode: const Color(0xFFF58529), // Example theme
            buttontextcolor: Colors.white,
            userid: widget.currentUserId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load post: $e')),
      );
    }
  }

  String _getTimeAgo(String dateTimeStr) {
    final dateTime = DateTime.parse(dateTimeStr);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}

Widget _buildMentionTag(String name, IconData icon) {
  return Container(
    margin: const EdgeInsets.only(left: 8),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.yellow.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(12),
      border:
          Border.all(color: Colors.yellow.withValues(alpha: 0.4), width: 0.5),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.yellow, size: 14),
        const SizedBox(width: 4),
        Text(
          name,
          style: const TextStyle(
              color: Colors.yellow, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

class StatusUploadWidget extends StatefulWidget {
  final String userId;
  final String profileId;
  final String? sharedContent;
  final String? sharedContentType; // 'text' or 'gallery' (image url)
  final String? sharedContentId; // gallery_id
  final Map<String, dynamic>? sharedMetadata;

  const StatusUploadWidget({
    super.key,
    required this.userId,
    required this.profileId,
    this.sharedContent,
    this.sharedContentType,
    this.sharedContentId,
    this.sharedMetadata,
  });

  @override
  State<StatusUploadWidget> createState() => _StatusUploadWidgetState();
}

class _StatusUploadWidgetState extends State<StatusUploadWidget> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();
  bool _isUploading = false;
  bool _isCompressingImage = false;
  double _uploadProgress = 0.0;
  String? _selectedGroupId;
  String? _selectedGroupName;
  String? _selectedProfileId;
  String? _selectedProfileName;
  String? _selectedMentionUserId;
  VideoPlayerController? _videoPreviewController;
  final supabase = Supabase.instance.client;
  bool _isSharingMode = false;

  // Local overrides for picked content
  String? _localSharedContent;
  String? _localSharedContentType;
  String? _localSharedContentId;
  Map<String, dynamic>? _localSharedMetadata;
  XFile? _localPickedFile;
  String? _localPickedMediaType;

  @override
  void initState() {
    super.initState();
    if (widget.sharedContent != null) {
      _isSharingMode = true;
      // Pre-fill caption if text mode, specifically if it's strictly text content
      if (widget.sharedContentType == 'text' ||
          widget.sharedContentType == 'thought') {
        _captionController.text = widget.sharedContent!;
      }
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _videoPreviewController?.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image != null) {
        _showCaptionDialog(image, 'image');
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (video != null) {
        await _initVideoPreview(video);
        _showCaptionDialog(video, 'video');
      }
    } catch (e) {
      _showErrorSnackBar('Error picking video: $e');
    }
  }

  Future<void> _initVideoPreview(XFile file) async {
    try {
      if (_videoPreviewController != null) {
        await _videoPreviewController!.dispose();
      }

      if (kIsWeb) {
        _videoPreviewController = VideoPlayerController.network(file.path);
      } else {
        _videoPreviewController =
            VideoPlayerController.file(io.File(file.path));
      }

      await _videoPreviewController!.initialize();
      await _videoPreviewController!.setLooping(true);
      await _videoPreviewController!.play();
      setState(() {});
    } catch (e) {
      debugPrint('Error initializing video preview: $e');
    }
  }

  void _showThoughtPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2C34),
      builder: (context) {
        return FutureBuilder(
          future: supabase
              .from('threads')
              .select()
              .eq('user_id', widget.userId)
              .order('created_at', ascending: false)
              .limit(20),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final List thoughts = snapshot.data as List? ?? [];
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Share a Thought',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: thoughts.length,
                    itemBuilder: (context, index) {
                      final t = thoughts[index];
                      return ListTile(
                        leading:
                            const Icon(Icons.lightbulb, color: Colors.yellow),
                        title: Text(t['content'] ?? '',
                            maxLines: 2,
                            style: const TextStyle(color: Colors.white)),
                        onTap: () {
                          setState(() {
                            _localSharedContent = t['content'];
                            _localSharedContentType = 'thought';
                            _localSharedContentId = t['id'].toString();
                            _isSharingMode = true;
                            _captionController.text = t['content'];
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showGalleryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2C34),
      builder: (context) {
        return FutureBuilder(
          future: supabase
              .from('gallery')
              .select()
              .eq('user_id', widget.userId)
              .order('created_at', ascending: false)
              .limit(20),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final List items = snapshot.data as List? ?? [];
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Share from Gallery',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _localSharedContent = item['image_url'];
                            _localSharedContentType = 'gallery';
                            _localSharedContentId = item['id'].toString();
                            _localSharedMetadata = {
                              'title': item['title'],
                              'description': item['description']
                            };
                            _isSharingMode = true;
                          });
                          Navigator.pop(context);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: item['image_url'] ?? '',
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showToolPicker() {
    final tools = [
      {'title': 'Poster Designer', 'description': 'Create amazing posters'},
      {'title': 'Bulk Sender', 'description': 'Send messages in bulk'},
      {'title': 'Poki Games', 'description': 'Play games with mates'},
      {'title': 'Drawing Academy', 'description': 'Learn to draw'},
      {'title': 'Travel Radar', 'description': 'Explore nearby places'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2C34),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Tools to Share',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
          ...tools.map((t) => ListTile(
                leading: const Icon(Icons.construction, color: Colors.yellow),
                title: Text(t['title']!,
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(t['description']!,
                    style: const TextStyle(color: Colors.grey)),
                onTap: () {
                  setState(() {
                    _localSharedContent = t['title'];
                    _localSharedContentType = 'tool';
                    _localSharedMetadata = t;
                    _isSharingMode = true;
                    _captionController.text = t['title']!;
                  });
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showCaptionDialog(XFile file, String mediaType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _buildEditorUI(file: file, mediaType: mediaType, isModal: true),
      ),
    );
  }

  Widget _buildEditorUI({
    XFile? file,
    String? mediaType,
    bool isModal = false,
  }) {
    // Local overrides
    final sContent = _localSharedContent ?? widget.sharedContent;
    final sType = _localSharedContentType ?? widget.sharedContentType;
    final sId = _localSharedContentId ?? widget.sharedContentId;
    final sMetadata = _localSharedMetadata ?? widget.sharedMetadata;

    // Determine content widget
    Widget contentWidget;
    if (_localPickedFile != null || file != null) {
      final actualFile = _localPickedFile ?? file;
      final actualType = _localPickedMediaType ?? mediaType;

      contentWidget = FutureBuilder(
        future: actualFile!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (actualType == 'image') {
              return Image.memory(snapshot.data as Uint8List,
                  fit: BoxFit.contain);
            } else {
              if (_videoPreviewController != null &&
                  _videoPreviewController!.value.isInitialized) {
                return Center(
                  child: AspectRatio(
                    aspectRatio: _videoPreviewController!.value.aspectRatio,
                    child: VideoPlayer(_videoPreviewController!),
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      );
    } else if (sType == 'thought' && sMetadata != null) {
      final name = sMetadata['name'] ?? 'User';
      final avatar = sMetadata['profile_image_url'];
      final time = sMetadata['created_at'];
      final createdAt = time != null ? DateTime.parse(time) : DateTime.now();

      contentWidget = Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF000000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: avatar != null
                        ? CachedNetworkImageProvider(avatar)
                        : null,
                    child: avatar == null ? Text(name[0].toUpperCase()) : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                        Text(
                          timeago.format(createdAt, locale: 'en_short'),
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                sContent!,
                style: const TextStyle(
                    color: Colors.white, fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.favorite_border,
                      size: 16, color: Colors.white.withOpacity(0.4)),
                  const SizedBox(width: 12),
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 16, color: Colors.white.withOpacity(0.4)),
                  const SizedBox(width: 12),
                  Icon(Icons.send_rounded,
                      size: 16, color: Colors.white.withOpacity(0.4)),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (sType == 'tool') {
      contentWidget = Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.white),
            const SizedBox(height: 24),
            Text(
              sContent!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Shared Tool',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    } else if (sType == 'gallery') {
      contentWidget = CachedNetworkImage(
        imageUrl: sContent!,
        fit: BoxFit.contain,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
      );
    } else if (sType == 'text') {
      contentWidget = Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFCC2B5E), Color(0xFF753A88)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        child: Text(
          sContent!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else if (sContent != null) {
      contentWidget = CachedNetworkImage(
        imageUrl: sContent,
        fit: BoxFit.contain,
      );
    } else {
      contentWidget = const SizedBox();
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        if (isModal)
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: contentWidget,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: InkWell(
            onTap: _showMentionSelection,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      (_selectedGroupId != null || _selectedProfileId != null)
                          ? Colors.yellow.withValues(alpha: 0.5)
                          : Colors.white10,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _selectedGroupId != null
                        ? Icons.groups_rounded
                        : (_selectedProfileId != null
                            ? Icons.person
                            : Icons.alternate_email_rounded),
                    size: 16,
                    color:
                        (_selectedGroupId != null || _selectedProfileId != null)
                            ? Colors.yellow
                            : Colors.white60,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedGroupName ??
                        (_selectedProfileName ?? 'Mention Mates or Groups'),
                    style: TextStyle(
                      color: (_selectedGroupId != null ||
                              _selectedProfileId != null)
                          ? Colors.yellow
                          : Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_selectedGroupId != null ||
                      _selectedProfileId != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGroupId = null;
                          _selectedGroupName = null;
                          _selectedProfileId = null;
                          _selectedProfileName = null;
                        });
                      },
                      child: const Icon(Icons.close,
                          size: 14, color: Colors.yellow),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              if (sType != 'text')
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _captionController,
                      style: GoogleFonts.inter(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Add a vibe caption...',
                        hintStyle:
                            TextStyle(color: Colors.white38, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                )
              else
                const Spacer(),
              const SizedBox(width: 12),
              InkWell(
                onTap: () {
                  if (_localPickedFile != null || file != null) {
                    Navigator.pop(context);
                    _uploadStatus(_localPickedFile ?? file!,
                        _localPickedMediaType ?? mediaType!);
                  } else if (sContent != null) {
                    _postSharedStatusWithParams(
                        sContent, sType!, sId, sMetadata);
                  } else {
                    // Nothing to send
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                      color: Colors.yellow, shape: BoxShape.circle),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.black, size: 24),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<Uint8List> _compressImage(Uint8List imageBytes) async {
    try {
      img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw Exception('Unable to decode image');
      }

      int maxWidth = 1200;
      int maxHeight = 1200;

      int newWidth = originalImage.width;
      int newHeight = originalImage.height;

      if (originalImage.width > maxWidth || originalImage.height > maxHeight) {
        double aspectRatio = originalImage.width / originalImage.height;

        if (originalImage.width > originalImage.height) {
          newWidth = maxWidth;
          newHeight = (maxWidth / aspectRatio).round();
        } else {
          newHeight = maxHeight;
          newWidth = (maxHeight * aspectRatio).round();
        }
      }

      img.Image resizedImage;
      if (newWidth != originalImage.width ||
          newHeight != originalImage.height) {
        resizedImage = img.copyResize(
          originalImage,
          width: newWidth,
          height: newHeight,
          interpolation: img.Interpolation.linear,
        );
      } else {
        resizedImage = originalImage;
      }

      List<int> compressedBytes = img.encodeJpg(
        resizedImage,
        quality: 85,
      );

      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return imageBytes;
    }
  }

  Future<Uint8List> _compressImageFile(XFile imageFile) async {
    try {
      setState(() {
        _isCompressingImage = true;
      });

      Uint8List fileBytes = await imageFile.readAsBytes();
      final compressedBytes = await _compressImage(fileBytes);

      setState(() {
        _isCompressingImage = false;
      });

      return compressedBytes;
    } catch (e) {
      setState(() {
        _isCompressingImage = false;
      });
      debugPrint('Error compressing image file: $e');
      return await imageFile.readAsBytes();
    }
  }

  Future<void> _showMentionSelection() async {
    String innerSearch = '';

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return DefaultTabController(
            length: 2,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mention Mates or Groups',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) =>
                          setModalState(() => innerSearch = val),
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: Colors.white38),
                        prefixIcon: Icon(Icons.search, color: Colors.white38),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const TabBar(
                    indicatorColor: Colors.yellow,
                    labelColor: Colors.yellow,
                    unselectedLabelColor: Colors.white60,
                    tabs: [
                      Tab(text: 'Groups'),
                      Tab(text: 'Mates'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildGroupMentionList(innerSearch),
                        _buildPersonMentionList(innerSearch),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildGroupMentionList(String query) {
    return FutureBuilder(
      future: supabase.rpc('get_my_groups_v2', params: {
        'p_user_id': widget.userId,
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        List data = [];
        if (snapshot.hasData && snapshot.data != null) {
          data = snapshot.data as List;
        } else {
          // Fallback to manual query
          return FutureBuilder(
            future: supabase.from('group_members').select('''
              group_id,
              groups!inner (id, name, group_image_url)
            ''').eq('user_id', widget.userId),
            builder: (context, innerSnapshot) {
              if (innerSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final innerData = (innerSnapshot.data as List?) ?? [];
              return _buildFilteredGroupList(innerData, query);
            },
          );
        }
        return _buildFilteredGroupList(data, query);
      },
    );
  }

  Widget _buildFilteredGroupList(List data, String query) {
    final filtered = data.where((item) {
      final group = item['groups'] ?? item;
      final name = (group['name'] ?? '').toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    if (filtered.isEmpty) {
      return const Center(
          child: Text('No matching groups',
              style: TextStyle(color: Colors.white70)));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final group = item['groups'] ?? item;
        final groupId = group['id'];
        final groupName = group['name'] ?? 'Unnamed Group';
        final groupImg = group['group_image_url'];

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: groupImg != null ? NetworkImage(groupImg) : null,
            child: groupImg == null ? const Icon(Icons.group) : null,
          ),
          title: Text(groupName, style: const TextStyle(color: Colors.white)),
          trailing: _selectedGroupId == groupId
              ? const Icon(Icons.check_circle, color: Colors.yellow)
              : null,
          onTap: () {
            setState(() {
              _selectedGroupId = groupId;
              _selectedGroupName = groupName;
              _selectedProfileId = null;
              _selectedProfileName = null;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildPersonMentionList(String query) {
    return FutureBuilder(
      future: supabase
          .from('profile')
          .select('id, user_id, name, profile_image_url')
          .neq('id', widget.profileId) // Don't mention yourself
          .ilike('name', '%$query%')
          .limit(20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = (snapshot.data as List?) ?? [];
        if (data.isEmpty) {
          return const Center(
              child: Text('No mates found',
                  style: TextStyle(color: Colors.white70)));
        }
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final profile = data[index];
            final profileId = profile['id'];
            final name = profile['name'] ?? 'Mate';
            final imgUrl = profile['profile_image_url'];

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: imgUrl != null ? NetworkImage(imgUrl) : null,
                child: imgUrl == null ? const Icon(Icons.person) : null,
              ),
              title: Text(name, style: const TextStyle(color: Colors.white)),
              trailing: _selectedProfileId == profileId
                  ? const Icon(Icons.check_circle, color: Colors.yellow)
                  : null,
              onTap: () {
                setState(() {
                  _selectedProfileId = profileId;
                  _selectedProfileName = name;
                  _selectedMentionUserId = profile['user_id'];
                  _selectedGroupId = null;
                  _selectedGroupName = null;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  Future<io.File?> _compressVideoFile(String filePath) async {
    if (kIsWeb) {
      debugPrint('Video compression not supported on web');
      return null;
    }

    try {
      setState(() {
        _uploadProgress = 0.1;
      });

      final MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        filePath,
        quality: VideoQuality
            .HighestQuality, // Increased quality for clearer status videos
        deleteOrigin: false,
        includeAudio: true,
      );

      if (mediaInfo != null && mediaInfo.file != null) {
        return mediaInfo.file;
      }
      return io.File(filePath);
    } catch (e) {
      debugPrint('Error compressing video: $e');
      return io.File(filePath);
    }
  }

  Future<io.File?> _generateVideoThumbnail(String videoPath) async {
    if (kIsWeb) {
      return null;
    }

    try {
      final thumbnail = await VideoCompress.getFileThumbnail(
        videoPath,
        quality: 50,
      );
      return thumbnail;
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
      return null;
    }
  }

  Future<void> _uploadStatus(XFile file, String mediaType) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      Uint8List bytesToUpload;
      String? thumbnailUrl;
      int duration = 5;

      String fileExt;
      if (file.name.contains('.')) {
        fileExt = file.name.split('.').last.toLowerCase();
      } else {
        fileExt = mediaType == 'image' ? 'jpg' : 'mp4';
      }

      if (mediaType == 'image') {
        bytesToUpload = await _compressImageFile(file);
        fileExt = 'jpg';
        setState(() => _uploadProgress = 0.3);
      } else {
        if (kIsWeb) {
          bytesToUpload = await file.readAsBytes();
        } else {
          final compressedVideo = await _compressVideoFile(file.path);
          if (compressedVideo != null) {
            bytesToUpload = await compressedVideo.readAsBytes();

            final thumbnail =
                await _generateVideoThumbnail(compressedVideo.path);
            if (thumbnail != null) {
              final thumbnailBytes = await thumbnail.readAsBytes();
              thumbnailUrl =
                  await _uploadBytes(thumbnailBytes, 'thumbnail', 'jpg');
            }
          } else {
            bytesToUpload = await file.readAsBytes();
          }
        }

        setState(() => _uploadProgress = 0.5);
      }

      final mediaUrl = await _uploadBytes(bytesToUpload, mediaType, fileExt);

      setState(() => _uploadProgress = 0.8);

      final statusData = {
        'user_id': widget.userId,
        'profile_id': widget.profileId,
        'media_type': mediaType,
        'media_url': mediaUrl,
        'thumbnail_url': thumbnailUrl,
        'caption': _captionController.text.trim().isEmpty
            ? null
            : _captionController.text.trim(),
        'duration': duration,
        'expires_at':
            DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
        'mentioned_group_id': _selectedGroupId,
        'mentioned_profile_id': _selectedProfileId,
        'is_active': true, // Ensure it's active so it shows up
      };

      await supabase.from('statuses').insert(statusData);

      // Post mention notifications
      await _sendMentionNotifications(mediaUrl, mediaType);

      setState(() => _uploadProgress = 1.0);

      _captionController.clear();

      if (mounted) {
        debugPrint('################ STATUS UPLOAD SUCCESS ################');
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Status uploaded!'),
            backgroundColor: Colors.yellow,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showErrorSnackBar('Error uploading status: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  Future<void> _postSharedStatusWithParams(String content, String type,
      String? contentId, Map<String, dynamic>? metadata) async {
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.5;
    });

    try {
      final mediaType = type == 'thought'
          ? 'thought'
          : (type == 'gallery' ? 'image' : (type == 'tool' ? 'tool' : 'text'));

      String? caption;
      String? mediaUrl;

      if (mediaType == 'text') {
        caption = content;
        mediaUrl = null;
      } else if (mediaType == 'thought') {
        caption = _captionController.text.trim().isNotEmpty
            ? _captionController.text.trim()
            : content;
        mediaUrl = null;
      } else if (mediaType == 'tool') {
        caption = _captionController.text.trim().isNotEmpty
            ? _captionController.text.trim()
            : content;
        mediaUrl = null;
      } else {
        // Image (Gallery share)
        mediaUrl = content;
        caption = _captionController.text.trim().isEmpty
            ? null
            : _captionController.text.trim();
      }

      final finalMetadata = <String, dynamic>{
        if (metadata != null) ...metadata,
        if (contentId != null && contentId.isNotEmpty && type != 'thought' && type != 'gallery') 
          'content_id': contentId,
        if (type != 'thought' && type != 'gallery' && type.isNotEmpty) 
          'content_type': type,
      };

      await supabase.from('statuses').insert({
        'user_id': widget.userId,
        'profile_id': widget.profileId,
        'media_type': mediaType,
        'metadata': finalMetadata.isEmpty ? null : finalMetadata,
        'media_url': mediaUrl,
        'thumbnail_url': null,
        'caption': caption,
        'duration': 5,
        'expires_at':
            DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
        'mentioned_group_id': _selectedGroupId,
        'mentioned_profile_id': _selectedProfileId,
        'is_active': true,
        if (contentId != null && contentId.isNotEmpty) ...{
          if (type == 'thought')
            'thought_id': int.tryParse(contentId.toString()) ?? contentId
          else if (type == 'gallery')
            'gallery_id': int.tryParse(contentId.toString()) ?? contentId
        }
      });

      // Post mention notifications
      await _sendMentionNotifications(mediaUrl, mediaType);

      setState(() => _uploadProgress = 1.0);

      if (mounted) {
        debugPrint('################ STATUS UPLOAD SUCCESS ################');
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
              content: Text('Status uploaded!'),
              backgroundColor: Colors.yellow),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showErrorSnackBar('Error sharing status: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  Future<void> _sendMentionNotifications(
      String? mediaUrl, String mediaType) async {
    if (_selectedGroupId == null && _selectedProfileId == null) return;

    try {
      // Fetch sender name for better notification
      final profileRes = await supabase
          .from('profile')
          .select('name')
          .eq('id', widget.profileId)
          .maybeSingle();
      final senderName = profileRes?['name'] ?? 'Someone';

      final metadata = {
        'status_media_url': mediaUrl,
        'media_type': mediaType,
        'sender_name': senderName,
      };

      final messageText = mediaType == 'thought'
          ? '$senderName shared a new Thought Vibe and mentioned you!'
          : '$senderName shared a new Vibe and mentioned you!';

      // 1. Group Mention
      if (_selectedGroupId != null) {
        await supabase.from('group_messages').insert({
          'group_id': _selectedGroupId,
          'sender_id': widget.userId,
          'message_type': 'status_mention',
          'message_text': messageText,
          'metadata': metadata,
        });
      }

      // 2. Profile Mention (Personal DM)
      if (_selectedProfileId != null && _selectedMentionUserId != null) {
        final Map<String, dynamic> messageData = {
          'sender_id': widget.userId,
          'receiver_id': _selectedMentionUserId,
          'content': messageText,
          'message_text': messageText,
          'updated_at': DateTime.now().toIso8601String(),
          'is_read': false,
          'message_type': 'status_mention',
          'metadata': metadata,
        };

        await supabase.from('messages').insert(messageData);

        // Update conversation record
        final existingConv = await supabase
            .from('conversations')
            .select('id, unread_count')
            .or('and(user1_id.eq.${widget.userId},user2_id.eq.$_selectedMentionUserId),and(user1_id.eq.$_selectedMentionUserId,user2_id.eq.${widget.userId})')
            .maybeSingle();

        if (existingConv != null) {
          await supabase.from('conversations').update({
            'last_message': messageText,
            'last_message_time': DateTime.now().toIso8601String(),
            'last_sender_id': widget.userId,
            'unread_count': (existingConv['unread_count'] ?? 0) + 1,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', existingConv['id']);
        } else {
          await supabase.from('conversations').insert({
            'user1_id': widget.userId,
            'user2_id': _selectedMentionUserId,
            'last_message': messageText,
            'last_message_time': DateTime.now().toIso8601String(),
            'last_sender_id': widget.userId,
            'unread_count': 1,
          });
        }
      }
    } catch (e) {
      debugPrint('Error sending mention notifications: $e');
    }
  }

  Future<String> _uploadBytes(
      Uint8List bytes, String type, String fileExt) async {
    final fileName =
        '${widget.userId}/${DateTime.now().millisecondsSinceEpoch}_$type.$fileExt';

    String contentType;
    if (type == 'image' || type == 'thumbnail') {
      switch (fileExt.toLowerCase()) {
        case 'jpg':
        case 'jpeg':
          contentType = 'image/jpeg';
          break;
        case 'png':
          contentType = 'image/png';
          break;
        case 'gif':
          contentType = 'image/gif';
          break;
        case 'webp':
          contentType = 'image/webp';
          break;
        default:
          contentType = 'image/jpeg';
      }
    } else if (type == 'video') {
      switch (fileExt.toLowerCase()) {
        case 'mp4':
          contentType = 'video/mp4';
          break;
        case 'mov':
          contentType = 'video/quicktime';
          break;
        case 'avi':
          contentType = 'video/x-msvideo';
          break;
        case 'webm':
          contentType = 'video/webm';
          break;
        default:
          contentType = 'video/mp4';
      }
    } else {
      contentType = 'application/octet-stream';
    }

    await supabase.storage.from('statuses').uploadBinary(
          fileName,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType,
          ),
        );

    final url = supabase.storage.from('statuses').getPublicUrl(fileName);
    return url;
  }

  void _showErrorSnackBar(String message) {
    debugPrint('################ STATUS UPLOAD ERROR ################');
    debugPrint(message);
    debugPrint('#####################################################');
    if (mounted) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Add to Vibes',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            if (_isUploading || _isCompressingImage)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                      value: _isCompressingImage ? null : _uploadProgress,
                      color: Colors.yellow),
                  const SizedBox(height: 20),
                  Text(
                      _isCompressingImage
                          ? 'Optimizing...'
                          : 'Sharing Vibes...',
                      style: const TextStyle(color: Colors.yellow)),
                ],
              ),
            )
          else if (_isSharingMode)
            _buildEditorUI()
          else
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const Icon(Icons.auto_awesome,
                      size: 80, color: Colors.yellow),
                  const SizedBox(height: 24),
                  const Text('What\'s on your mind?',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    child: Text(
                        'Share a photo, video, thought or tool with your mates.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildUploadOption(
                          icon: Icons.image_rounded,
                          label: 'Gallery',
                          color: Colors.pink,
                          onTap: _pickImage,
                        ),
                        _buildUploadOption(
                          icon: Icons.videocam_rounded,
                          label: 'Video',
                          color: Colors.orange,
                          onTap: _pickVideo,
                        ),
                        _buildUploadOption(
                          icon: Icons.lightbulb_outline,
                          label: 'Thought',
                          color: Colors.amber,
                          onTap: _showThoughtPicker,
                        ),
                        _buildUploadOption(
                          icon: Icons.grid_view_rounded,
                          label: 'Shop',
                          color: Colors.teal,
                          onTap: _showGalleryPicker,
                        ),
                        _buildUploadOption(
                          icon: Icons.construction_rounded,
                          label: 'Tool',
                          color: Colors.deepOrange,
                          onTap: _showToolPicker,
                        ),
                        _buildUploadOption(
                          icon: Icons.text_fields_rounded,
                          label: 'Text',
                          color: Colors.blue,
                          onTap: () {
                            setState(() {
                              _localSharedContent = 'Type something...';
                              _localSharedContentType = 'text';
                              _isSharingMode = true;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
        ],
      ),
    ));
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(label,
                style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
