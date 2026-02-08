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

class StatusDisplayWidget extends StatefulWidget {
  final String currentUserId;
  final String currentProfileId;
  final double? width;
  final double? height;
  final bool isVertical;

  const StatusDisplayWidget({
    super.key,
    required this.currentUserId,
    required this.currentProfileId,
    this.width,
    this.height,
    this.isVertical = false,
  });

  @override
  State<StatusDisplayWidget> createState() => _StatusDisplayWidgetState();
}

class _StatusDisplayWidgetState extends State<StatusDisplayWidget> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _statuses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCachedStatuses();
    _loadStatusesOptimized();
  }

  Future<void> _loadCachedStatuses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString =
          prefs.getString('cached_statuses_${widget.currentUserId}');
      if (cachedString != null) {
        final List<dynamic> decoded = jsonDecode(cachedString);
        setState(() {
          _statuses = List<Map<String, dynamic>>.from(decoded);
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
      await _checkAndDeleteExpiredStatuses();

      // Optimized Single Query with Join
      final response = await supabase
          .from('statuses')
          .select('*, profile:profile_id(id, name, profile_image_url)')
          .eq('is_active', true)
          .gt('expires_at', DateTime.now().toIso8601String())
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(response);

      // Grouping logic
      final Map<String, Map<String, dynamic>> groupedStatuses = {};

      for (var status in data) {
        final profile = status['profile'];
        final profileId = status['profile_id'];

        if (profile != null) {
          if (!groupedStatuses.containsKey(profileId)) {
            groupedStatuses[profileId] = {
              'profile': profile,
              'statuses': [],
              'is_own': profileId == widget.currentProfileId,
            };
          }
          groupedStatuses[profileId]!['statuses'].add(status);
        }
      }

      final List<Map<String, dynamic>> combinedData =
          groupedStatuses.values.toList();
      combinedData.sort((a, b) {
        // Own status comes first
        if (a['is_own'] == true && b['is_own'] != true) return -1;
        if (a['is_own'] != true && b['is_own'] == true) return 1;

        // Then sort by most recent status
        final aTime = (a['statuses'] as List).first['created_at'];
        final bTime = (b['statuses'] as List).first['created_at'];
        return DateTime.parse(bTime).compareTo(DateTime.parse(aTime));
      });

      // Cache the result
      _saveStatusesToCache(combinedData);

      if (mounted) {
        setState(() {
          _statuses = combinedData;
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

  void _precacheAllStatuses() {
    for (var group in _statuses) {
      final statuses = group['statuses'] as List;
      if (statuses.isNotEmpty) {
        final firstStatus = statuses.first;
        if (firstStatus['media_type'] == 'image') {
          precacheImage(
            CachedNetworkImageProvider(firstStatus['media_url']),
            context,
          );
        } else if (firstStatus['media_type'] == 'video') {
          // Warm up video URL (some players handle this better if called early)
          VideoPlayerController.networkUrl(Uri.parse(firstStatus['media_url']))
            ..initialize().then((_) {
              // Just initialize and dispose to warm up cache if supported by OS
            });
        }
      }
    }
  }

  void _openStatusViewer(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatusViewerWrapper(
          allStatusGroups: _statuses,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: widget.isVertical
          ? (_isLoading
              ? _buildVerticalShimmer()
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _statuses.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) return _buildAddStatusButton();
                    final statusGroup = _statuses[index - 1];
                    return _buildStatusItem(statusGroup, index - 1);
                  },
                ))
          : Container(
              height: 120,
              child: _isLoading
                  ? _buildShimmerLoading()
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      itemCount: _statuses.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) return _buildAddStatusButton();
                        final statusGroup = _statuses[index - 1];
                        return _buildStatusItem(statusGroup, index - 1);
                      },
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
          baseColor: Colors.white.withOpacity(0.05),
          highlightColor: Colors.white.withOpacity(0.1),
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
          baseColor: Colors.white.withOpacity(0.05),
          highlightColor: Colors.white.withOpacity(0.1),
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
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.yellow.withOpacity(0.2),
                          Colors.yellow.withOpacity(0.05),
                        ],
                      ),
                      border: Border.all(
                          color: Colors.yellow.withOpacity(0.3), width: 1),
                    ),
                    child: const Icon(Icons.add_rounded,
                        size: 26, color: Colors.yellow),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Colors.yellow, shape: BoxShape.circle),
                      child:
                          const Icon(Icons.add, size: 14, color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Vibes',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Share your moment',
                      style: GoogleFonts.outfit(
                          color: Colors.white.withOpacity(0.5), fontSize: 13)),
                ],
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
            Stack(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.03),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.1), width: 1),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.yellow.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_rounded,
                          size: 24, color: Colors.yellow),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                        color: Colors.yellow, shape: BoxShape.circle),
                    child: const Icon(Icons.add, size: 14, color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text('Your Vibe',
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(Map<String, dynamic> statusGroup, int index) {
    final profile = statusGroup['profile'];
    final isOwn = statusGroup['is_own'] ?? false;
    final name = profile['name'] ?? 'Unknown';
    final profileImageUrl = profile['profile_image_url'];
    final statuses = statusGroup['statuses'] as List;
    final lastStatus = statuses.first;
    final createdAt = DateTime.parse(lastStatus['created_at']);
    final timeString = timeago.format(createdAt, locale: 'en_short');

    if (widget.isVertical) {
      return InkWell(
        onTap: () => _openStatusViewer(index),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              _buildAvatarWithRing(profileImageUrl, name, 64),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isOwn ? 'My Status' : name,
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(timeString,
                        style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.5),
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
      onTap: () => _openStatusViewer(index),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            _buildAvatarWithRing(profileImageUrl, name, 72),
            const SizedBox(height: 2),
            Text(isOwn ? 'My Status' : name,
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

  Widget _buildAvatarWithRing(String? url, String name, double size) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
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
  int _totalStatusesViewed = 0;
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
        _likeCount = likesCount.count ?? 0;
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
        _currentVideoController = VideoPlayerController.networkUrl(
          Uri.parse(status['media_url']),
        );

        try {
          await _currentVideoController!.initialize();
          if (mounted) {
            setState(() {
              _isCurrentVideoReady = true;
            });
          }
        } catch (e) {
          debugPrint('Video error: $e');
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
        _preloadedVideoController = VideoPlayerController.networkUrl(
          Uri.parse(nextStatus['media_url']),
        );
        try {
          await _preloadedVideoController!.initialize();
          _isPreloadedVideoReady = true;
          debugPrint('Next video preloaded successfully');
        } catch (e) {
          debugPrint('Error preloading next video: $e');
          _isPreloadedVideoReady = false;
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

          final fileName = mediaUrl.split('/').last;
          final filePath = '$profileId/$fileName';

          await supabase.storage.from('statuses').remove([filePath]);
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

    _totalStatusesViewed++;

    // Show ad every 3rd status (at 3, 6, 9, etc.)
    if (_totalStatusesViewed % 3 == 0) {
      _showAdContainer();
      return;
    }

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

  void _showAdContainer() {
    _progressController.stop();
    _currentVideoController?.pause();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Material(
        color: Colors.black,
        child: Stack(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.yellow[700]!, Colors.orange[700]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellow.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.handshake,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'HandSkill Community',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Join our amazing community\nand connect with others!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Continue to next status
                        final statuses = widget.statusGroup['statuses'] as List;
                        if (_currentIndex < statuses.length - 1) {
                          setState(() {
                            _currentIndex++;
                          });
                          _startCurrentStatus();
                        } else {
                          widget.onNextGroup();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.orange[700],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
          if (tapX < size.width * 0.3) {
            _goToPrevious();
          } else if (tapX > size.width * 0.7) {
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
                  color: Colors.black.withOpacity(0.3 * _dragPosition.abs()),
                  child: Center(
                    child: Icon(
                      _dragPosition > 0
                          ? Icons.arrow_back_ios_rounded
                          : Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withOpacity(0.7),
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
                      Colors.black.withOpacity(0.8),
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
                              color: Colors.white.withOpacity(0.3),
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
                              Text(
                                profile['name'] ?? 'Unknown',
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
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                color: Colors.black.withOpacity(0.5),
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
                    color: Colors.black.withOpacity(0.6),
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
              child: GestureDetector(
                onTap: () => _toggleLike(currentStatus['id']),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
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
                    color: Colors.black.withOpacity(0.5),
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

    if (status['media_type'] == 'text') {
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
      return GestureDetector(
        onTap: () => _navigateToGalleryDetail(status['gallery_id']),
        child: Stack(
          fit: StackFit.expand,
          children: [
            content,
            Positioned(
              bottom: 100, // Above caption/reply area
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Tap to view post',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios,
                          color: Colors.white, size: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return content;
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

class StatusUploadWidget extends StatefulWidget {
  final String userId;
  final String profileId;
  final String? sharedContent;
  final String? sharedContentType; // 'text' or 'gallery' (image url)
  final String? sharedContentId; // gallery_id

  const StatusUploadWidget({
    super.key,
    required this.userId,
    required this.profileId,
    this.sharedContent,
    this.sharedContentType,
    this.sharedContentId,
  });

  @override
  State<StatusUploadWidget> createState() => _StatusUploadWidgetState();
}

class _StatusUploadWidgetState extends State<StatusUploadWidget> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();
  bool _isUploading = false;
  bool _isCompressingImage = false;
  double _uploadProgress = 0.0;
  String? _selectedGroupId;
  String? _selectedGroupName;
  VideoPlayerController? _videoPreviewController;
  final supabase = Supabase.instance.client;
  bool _isSharingMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.sharedContent != null) {
      _isSharingMode = true;
      // Pre-fill caption if text mode, specifically if it's strictly text content
      if (widget.sharedContentType == 'text') {
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

  void _showCaptionDialog(XFile file, String mediaType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
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
    // Determine content widget
    Widget contentWidget;
    if (file != null) {
      contentWidget = FutureBuilder(
        future: file.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (mediaType == 'image') {
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
    } else if (widget.sharedContent != null) {
      if (widget.sharedContentType == 'text') {
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
            widget.sharedContent!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        );
      } else {
        // Gallery/URL
        contentWidget = CachedNetworkImage(
          imageUrl: widget.sharedContent!,
          fit: BoxFit.contain,
          errorWidget: (context, url, error) => const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(height: 8),
              Text('Could not load image',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        );
      }
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
            onTap: _showGroupSelection,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedGroupId != null
                      ? Colors.yellow.withOpacity(0.5)
                      : Colors.white10,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.group_add_rounded,
                    size: 16,
                    color: _selectedGroupId != null
                        ? Colors.yellow
                        : Colors.white60,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedGroupName ?? 'Mention a Group',
                    style: TextStyle(
                      color: _selectedGroupId != null
                          ? Colors.yellow
                          : Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_selectedGroupId != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGroupId = null;
                          _selectedGroupName = null;
                        });
                      },
                      child:
                          const Icon(Icons.close, size: 14, color: Colors.red),
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
              if (widget.sharedContentType != 'text')
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
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
                  if (file != null) {
                    Navigator.pop(context);
                    _uploadStatus(file, mediaType!);
                  } else {
                    _postSharedStatus();
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

  Future<void> _showGroupSelection() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Group to Mention',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder(
                    future: supabase.rpc('get_my_groups_v2', params: {
                      'p_user_id': widget.userId,
                    }),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        // Fallback to manual query if RPC fails
                        return FutureBuilder(
                          future: supabase.from('group_members').select('''
                            group_id,
                            groups!inner (
                              id,
                              name,
                              group_image_url
                            )
                          ''').eq('user_id', widget.userId),
                          builder: (context, innerSnapshot) {
                            if (innerSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            final data = innerSnapshot.data as List?;
                            if (data == null || data.isEmpty) {
                              return const Center(
                                  child: Text('No groups found',
                                      style: TextStyle(color: Colors.white70)));
                            }
                            return _buildGroupList(data, setModalState);
                          },
                        );
                      }
                      final data = snapshot.data as List?;
                      if (data == null || data.isEmpty) {
                        return const Center(
                            child: Text('No groups found',
                                style: TextStyle(color: Colors.white70)));
                      }
                      return _buildGroupList(data, setModalState);
                    },
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildGroupList(List data, StateSetter setModalState) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
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
            });
            Navigator.pop(context);
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
        quality: VideoQuality.MediumQuality,
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

      await supabase.from('statuses').insert({
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
      });

      setState(() => _uploadProgress = 1.0);

      _captionController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
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
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  Future<void> _postSharedStatus() async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.5;
    });

    try {
      final mediaType =
          widget.sharedContentType == 'gallery' ? 'image' : 'text';
      // If text, the shared content IS the caption.
      // If image, caption is from controller.
      String? caption;
      String? mediaUrl;

      if (mediaType == 'text') {
        caption = widget.sharedContent;
        mediaUrl = '';
      } else {
        // Image
        mediaUrl = widget.sharedContent;
        caption = _captionController.text.trim().isEmpty
            ? null
            : _captionController.text.trim();
      }

      await supabase.from('statuses').insert({
        'user_id': widget.userId,
        'profile_id': widget.profileId,
        'media_type': mediaType,
        'media_url': mediaUrl,
        'thumbnail_url': null,
        'caption': caption,
        'gallery_id': widget.sharedContentId,
        'duration': 5,
        'expires_at':
            DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
        'mentioned_group_id': _selectedGroupId,
      });

      setState(() => _uploadProgress = 1.0);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status uploaded!'),
            backgroundColor: Colors.yellow,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showErrorSnackBar('Error sharing status: $e');
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Column(
              children: [
                const Spacer(),
                const Icon(Icons.auto_awesome, size: 80, color: Colors.yellow),
                const SizedBox(height: 24),
                const Text('What\'s on your mind?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  child: Text(
                      'Share a photo or video with your mates. It will disappear in 24 hours.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildUploadOption(
                          icon: Icons.image_rounded,
                          label: 'Gallery',
                          color: Colors.yellow,
                          onTap: _pickImage,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildUploadOption(
                          icon: Icons.videocam_rounded,
                          label: 'Video',
                          color: Colors.yellow,
                          onTap: _pickVideo,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
        ],
      ),
    );
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
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
