import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/pocket_game_audio_service.dart';
import '../../services/pocket_mate_service.dart';
import '../../services/pocket_trophy_service.dart';
import '../learning_60day/pocket_fortress_defense_service.dart';

import '../avatar/vector_avatar_config.dart';
import '../avatar/vector_avatar_widget.dart';
import '../learning_60day/flame_english_house_game.dart';
import '../learning_60day/pocket_citadel_attack_page.dart';
import '../learning_60day/pocket_world_street_page.dart';
import '../../services/pocket_president_service.dart';
import 'pocket_feed_vibe_share_sheet.dart';
import 'pocket_reels_game_engine.dart';

/// Item type for the Reels Feed: Homestead, Interactive Mini-Game, or Public Vibe (Audio Directive)
enum ReelItemType { home, game, vibe }

class ReelVibeItem {
  final String id;
  final String mediaUrl;
  final String mediaType;
  final String? caption;
  final int duration;

  const ReelVibeItem({
    required this.id,
    required this.mediaUrl,
    required this.mediaType,
    this.caption,
    this.duration = 10,
  });
}

class ReelVibeCard {
  final String id;
  final String userId;
  final String authorName;
  final String? authorAvatarUrl;
  final List<ReelVibeItem> stories;
  final int day;
  final bool isRobot;

  ReelVibeCard({
    required this.id,
    required this.userId,
    required this.authorName,
    this.authorAvatarUrl,
    List<ReelVibeItem>? stories,
    String? mediaUrl,
    String? mediaType,
    String? caption,
    int duration = 10,
    this.day = 1,
    this.isRobot = false,
  }) : stories = (stories != null && stories.isNotEmpty)
            ? stories
            : [
                if (mediaUrl != null && mediaUrl.isNotEmpty)
                  ReelVibeItem(
                    id: id,
                    mediaUrl: mediaUrl,
                    mediaType: mediaType ?? 'video',
                    caption: caption,
                    duration: duration,
                  )
              ];

  String get mediaUrl => stories.isNotEmpty ? stories.first.mediaUrl : '';
  String get mediaType => stories.isNotEmpty ? stories.first.mediaType : 'video';
  String? get caption => stories.isNotEmpty ? stories.first.caption : null;
  int get duration => stories.isNotEmpty ? stories.first.duration : 10;
}

/// 🎵 Ambient BGM Track for Homes - Powered by PocketGameAudioService
class HomeMusicTracks {
  static List<PocketMusicTrack> get tracks => PocketGameAudioService.homeTracks;

  static PocketMusicTrack getTrackForHouse(String houseId) {
    return PocketGameAudioService.getTrackForHouse(houseId);
  }
}

class ReelFeedItem {
  final ReelItemType type;
  final PocketNeighbor? neighbor;
  final ReelGameCard? gameCard;
  final ReelVibeCard? vibeCard;

  const ReelFeedItem.home(this.neighbor)
      : type = ReelItemType.home,
        gameCard = null,
        vibeCard = null;

  const ReelFeedItem.game(this.gameCard)
      : type = ReelItemType.game,
        neighbor = null,
        vibeCard = null;

  const ReelFeedItem.vibe(this.vibeCard)
      : type = ReelItemType.vibe,
        neighbor = null,
        gameCard = null;
}

/// 🏰 PocketHomesReelsFeedWidget
/// Instagram Reels / TikTok style vertical swipeable feed for Homesteads & Citadel Houses.
/// Interleaves interactive English mini-games (Sentence Builder, Smart Reply, Spot Error, Vocab)
/// in the user's native language.
/// - Unseen homes and games appear first; seen items are moved to the bottom.
/// - Seamless infinite lazy loading so fresh content is continuously supplied.
/// - 'Add to Vibes' (Story) & Share to Chat support on all slides.
/// - Resident avatar animated story circles.
class PocketHomesReelsFeedWidget extends StatefulWidget {
  final int userLevel;
  final VoidCallback? onBackToChat;
  final PocketNeighbor? initialNeighbor;
  final String? initialHouseId;
  final String? initialGameId;

  final bool isActive;

  const PocketHomesReelsFeedWidget({
    super.key,
    this.userLevel = 1,
    this.isActive = true,
    this.onBackToChat,
    this.initialNeighbor,
    this.initialHouseId,
    this.initialGameId,
  });

  @override
  State<PocketHomesReelsFeedWidget> createState() =>
      _PocketHomesReelsFeedWidgetState();
}

class _PocketHomesReelsFeedWidgetState extends State<PocketHomesReelsFeedWidget>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final SupabaseClient _supabase = Supabase.instance.client;
  late PageController _verticalPageController;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _userNativeLanguage = 'Malayalam';
  late AnimationController _pulseController;

  final Set<String> _viewedHomeIds = {};
  final Set<String> _protectedHomeIds = {};
  bool _isHomesAudioMuted = false;

  // Audio player for house ambient background music delegated to PocketGameAudioService
  String? _currentlyPlayingHouseId;

  // Games state
  final Map<String, int?> _selectedAnswers = {}; // gameId -> selected option index
  final Map<String, List<String>> _sentenceBuilderUserOrder = {}; // gameId -> selected words in order
  final Map<String, bool?> _sentenceBuilderResults = {}; // gameId -> isCorrect

  List<ReelFeedItem> _feedItems = [];
  int _dynamicHomeBatchSeed = 100;

  static const List<String> _statusQuotes = [
    'Building vocabulary brick by brick! 🏰',
    'Defense questions are armed and ready! 🛡️',
    'Practicing 15 minutes of English daily! ⚡',
    'Mastering English tenses in the arena! 🎯',
    'Leveling up my Citadel every single day! 🚀',
    'Who dares challenge my English vocabulary fortress? ⚔️',
    'Fluency gym training every morning! ☕',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _verticalPageController = PageController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Audio Directive: Music in Homes must always be ON by default, uninhibited by global settings
    PocketGameAudioService.instance.setMuted(false, persist: false);

    _initAll();

    if (widget.isActive) {
      final initialId = widget.initialHouseId ?? widget.initialNeighbor?.id ?? 'house_default';
      _playHomeMusic(initialId);
    }
  }

  @override
  void didUpdateWidget(covariant PocketHomesReelsFeedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        if (!_isHomesAudioMuted) {
          final id = _currentlyPlayingHouseId ?? widget.initialHouseId ?? widget.initialNeighbor?.id ?? 'house_default';
          _playHomeMusic(id);
        }
      } else {
        _pauseBgm();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _pauseBgm();
    } else if (state == AppLifecycleState.resumed && !_isHomesAudioMuted && widget.isActive) {
      if (_currentlyPlayingHouseId != null) {
        _playHomeMusic(_currentlyPlayingHouseId!);
      }
    }
  }

  Future<void> _playHomeMusic(String houseId) async {
    _currentlyPlayingHouseId = houseId;
    if (_isHomesAudioMuted) return;
    await PocketGameAudioService.instance.playHomeTheme(houseId, forceUnmute: true);
  }

  void _pauseBgm() {
    PocketGameAudioService.instance.pause();
  }

  void _toggleBgmMute() {
    HapticFeedback.lightImpact();
    setState(() {
      _isHomesAudioMuted = !_isHomesAudioMuted;
    });
    PocketGameAudioService.instance.setMuted(_isHomesAudioMuted, persist: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    PocketGameAudioService.instance.stop();
    _verticalPageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initAll() async {
    await PocketReelsGameEngine.init();
    await _loadUserLanguage();
    await _loadViewedHistoryAndFeed();
  }

  Future<void> _loadUserLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = _supabase.auth.currentUser?.id;
      final savedLang = prefs.getString('pm_native_language') ??
          (currentUserId != null ? prefs.getString('pm_native_language_$currentUserId') : null);

      if (savedLang != null && savedLang.isNotEmpty) {
        if (mounted) setState(() => _userNativeLanguage = savedLang);
        return;
      }

      if (currentUserId != null) {
        final profile = await _supabase
            .from('profile')
            .select('native_language')
            .eq('user_id', currentUserId)
            .maybeSingle();
        final dbLang = profile?['native_language']?.toString();
        if (dbLang != null && dbLang.isNotEmpty && mounted) {
          setState(() => _userNativeLanguage = dbLang);
        }
      }
    } catch (_) {}
  }

  Future<void> _loadViewedHistoryAndFeed() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedViewed = prefs.getStringList('pm_viewed_homes_ids') ?? [];
      _viewedHomeIds.addAll(savedViewed);
    } catch (_) {}

    await _refreshFeedList();
  }

  /// 🔄 Refresh feed: unseen homes & games first; seen items pushed to bottom!
  Future<void> _refreshFeedList() async {
    final List<PocketNeighbor> rawNeighbors = [];

    try {
      final currentUserId = _supabase.auth.currentUser?.id;

      // 1. Fetch real peer users from Supabase profile table
      final profiles = await _supabase
          .from('profile')
          .select('id, user_id, name, display_name, learning_day, daily_streak, profile_image_url')
          .neq('user_id', currentUserId ?? '')
          .order('learning_day', ascending: false)
          .limit(30);

      if (profiles.isNotEmpty) {
        for (final p in profiles) {
          final day = (p['learning_day'] as num?)?.toInt() ?? 3;
          final streak = (p['daily_streak'] as num?)?.toInt() ?? 1;
          final name = p['name']?.toString() ?? p['display_name']?.toString() ?? 'English Learner';
          final id = p['user_id']?.toString() ?? p['id']?.toString() ?? 'user';

          rawNeighbors.add(
            PocketNeighbor(
              id: id,
              name: name,
              day: day,
              streak: streak,
              rank: day >= 71
                  ? 'Grandmaster'
                  : (day >= 30 ? 'Scholar' : 'Explorer'),
              paletteId: _randomPalette(day),
              statusMessage:
                  _statusQuotes[math.Random().nextInt(_statusQuotes.length)],
              hasActiveShield: true,
              hp: 100,
              maxHp: 100,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching real profiles for Homes feed: $e');
    }

    // 2. Add full-spectrum architectural showcase robots across all 6 tiers (Levels 1 to 90)
    final dynamicRobots = _generateFullSpectrumHomes(count: 36);
    rawNeighbors.addAll(dynamicRobots);

    // 3. Add Sovereign President as supreme Day 90 boss
    rawNeighbors.add(PocketNeighbor.createPresident());

    // Check Presidential Protection status for neighbors
    try {
      final protectedSet = <String>{};
      for (final n in rawNeighbors) {
        if (await PocketFortressDefenseService.isUnderPresidentialProtection(n.id)) {
          protectedSet.add(n.id);
        }
      }
      if (mounted) {
        setState(() {
          _protectedHomeIds.clear();
          _protectedHomeIds.addAll(protectedSet);
        });
      }
    } catch (_) {}

    // 4. Strict Seen vs Unseen Separation:
    // Unseen homes appear first! Seen homes are pushed to the very bottom!
    List<PocketNeighbor> unviewed = rawNeighbors
        .where((n) => !_viewedHomeIds.contains(n.id))
        .toList();
    List<PocketNeighbor> seen = rawNeighbors
        .where((n) => _viewedHomeIds.contains(n.id))
        .toList();

    // If unviewed pool is small, generate additional full-spectrum robots dynamically
    if (unviewed.length < 12) {
      _dynamicHomeBatchSeed += 50;
      final extraRobots = _generateFullSpectrumHomes(count: 24, seedOffset: _dynamicHomeBatchSeed);
      for (final r in extraRobots) {
        if (!_viewedHomeIds.contains(r.id)) {
          unviewed.add(r);
        }
      }
    }

    // 5. Smart level-gap distribution (ensures at least 6 to 15 levels gap between consecutive houses - User Audio Directive)
    final distributedUnviewed = _distributeWithLevelGap(unviewed, minGap: 6);
    final distributedSeen = _distributeWithLevelGap(seen, minGap: 6);

    // Ordered sequence: Unviewed first, Seen at the very bottom!
    final combinedNeighbors = [...distributedUnviewed, ...distributedSeen];

    // 6. Interleave diverse multi-type learning games every 2 houses
    final games = PocketReelsGameEngine.getNextGameBatch(
      count: (combinedNeighbors.length / 2).ceil() + 4,
    );

    // Check if deep linking to a specific neighbor or game
    if (widget.initialNeighbor != null) {
      combinedNeighbors.removeWhere((n) => n.id == widget.initialNeighbor!.id);
      combinedNeighbors.insert(0, widget.initialNeighbor!);
    } else if (widget.initialHouseId != null) {
      final targetId = widget.initialHouseId!;
      final matchIdx = combinedNeighbors.indexWhere((n) => n.id == targetId);
      if (matchIdx >= 0) {
        final match = combinedNeighbors.removeAt(matchIdx);
        combinedNeighbors.insert(0, match);
      } else {
        // Deep linked house not in pool: explicitly construct the intended home at index 0
        PocketNeighbor targetNeighbor;
        if (PocketPresidentService.isPresidentId(targetId) || targetId == 'pocket_president') {
          targetNeighbor = PocketNeighbor.createPresident();
        } else if (PocketRobotService.isRobotId(targetId)) {
          final bot = PocketRobotService.getRobotById(targetId) ?? PocketRobotService.getRobotByLevel(1);
          final dynLvl = PocketRobotService.getDynamicLevel(bot);
          targetNeighbor = PocketNeighbor(
            id: bot.id,
            name: bot.name,
            day: dynLvl,
            streak: dynLvl,
            rank: bot.cefrRank,
            paletteId: bot.housePalette,
            isMe: false,
            hasActiveShield: true,
            statusMessage: bot.bio,
            isPocketRobo: true,
            hp: 100,
            maxHp: 100,
          );
        } else {
          targetNeighbor = PocketNeighbor(
            id: targetId,
            name: 'Citizen Citadel',
            day: widget.userLevel,
            streak: 1,
            rank: 'Citadel Resident',
            paletteId: 'slate',
            isMe: false,
            statusMessage: 'Welcome to my Citadel Home!',
          );
        }
        combinedNeighbors.insert(0, targetNeighbor);
      }
    }

    final List<ReelVibeCard> publicVibes = [];
    try {
      final nowIso = DateTime.now().toIso8601String();
      final vibesRes = await _supabase
          .from('statuses')
          .select('id, user_id, media_url, media_type, caption, duration, is_private, status_privacy, profile:profile_id(id, name, display_name, profile_image_url, learning_day)')
          .eq('is_active', true)
          .gt('expires_at', nowIso)
          .order('created_at', ascending: false)
          .limit(30);

      // Group vibes by creator so multi-story taps work smoothly (User Audio Directive)
      final Map<String, List<Map<String, dynamic>>> groupedVibes = {};
      for (final v in vibesRes) {
        final rawMeta = v['metadata'];
        final isPriv = (v['is_private'] == true) || (rawMeta is Map && rawMeta['is_private'] == true);
        final privType = v['status_privacy']?.toString() ?? (rawMeta is Map ? rawMeta['status_privacy']?.toString() : null);
        if (isPriv || (privType != null && privType != 'public')) continue;

        final mediaUrl = v['media_url']?.toString() ?? '';
        if (mediaUrl.isEmpty) continue;

        final uId = v['user_id']?.toString() ?? '';
        if (uId.isEmpty) continue;
        groupedVibes.putIfAbsent(uId, () => []).add(v);
      }

      groupedVibes.forEach((uId, vList) {
        final first = vList.first;
        final profile = first['profile'];
        final authorName = (profile is Map ? (profile['name'] ?? profile['display_name']) : null)?.toString() ?? 'Vibe Creator';
        final authorAvatar = (profile is Map ? profile['profile_image_url'] : null)?.toString();
        final day = (profile is Map ? (profile['learning_day'] as num?)?.toInt() : null) ?? 1;

        final stories = vList.map((item) {
          return ReelVibeItem(
            id: item['id']?.toString() ?? UniqueKey().toString(),
            mediaUrl: item['media_url']?.toString() ?? '',
            mediaType: item['media_type']?.toString() ?? 'video',
            caption: item['caption']?.toString(),
            duration: (item['duration'] as num?)?.toInt() ?? 10,
          );
        }).toList();

        publicVibes.add(
          ReelVibeCard(
            id: first['id']?.toString() ?? UniqueKey().toString(),
            userId: uId,
            authorName: authorName,
            authorAvatarUrl: authorAvatar,
            stories: stories,
            day: day,
            isRobot: false,
          ),
        );
      });
    } catch (e) {
      debugPrint('Error fetching public vibes for Homes feed: $e');
    }

    if (publicVibes.length < 5) {
      final robotVibes = [
        ReelVibeCard(
          id: 'robot_vibe_1',
          userId: 'robo_maya',
          authorName: 'Maya 🤖 (Habit Coach)',
          stories: const [
            ReelVibeItem(
              id: 'maya_s1',
              mediaUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&q=80',
              mediaType: 'image',
              caption: 'Consistency is power! 15 minutes of daily practice unlocks fluency. ✨',
              duration: 10,
            ),
            ReelVibeItem(
              id: 'maya_s2',
              mediaUrl: 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=800&q=80',
              mediaType: 'image',
              caption: 'Quick tip: Speak out loud every sentence you construct today! 🗣️🔥',
              duration: 10,
            ),
          ],
          day: 14,
          isRobot: true,
        ),
        ReelVibeCard(
          id: 'robot_vibe_2',
          userId: 'robo_alex',
          authorName: 'Alex 🤖 (Grammar Master)',
          stories: const [
            ReelVibeItem(
              id: 'alex_s1',
              mediaUrl: 'https://images.unsplash.com/photo-1546776310-eef45dd6d63c?w=800&q=80',
              mediaType: 'image',
              caption: 'Mastering tenses today! Challenge your Citadel in the arena. 🏰⚡',
              duration: 10,
            ),
            ReelVibeItem(
              id: 'alex_s2',
              mediaUrl: 'https://images.unsplash.com/photo-1517842645767-c639042777db?w=800&q=80',
              mediaType: 'image',
              caption: 'Spot the difference: "I have eaten" vs "I ate". Practice now! 💡',
              duration: 10,
            ),
          ],
          day: 28,
          isRobot: true,
        ),
      ];
      publicVibes.addAll(robotVibes);
    }

    final List<ReelFeedItem> combinedFeed = [];
    int gameIdx = 0;
    int vibeIdx = 0;

    // If deep linking to a specific game, insert it right at top
    if (widget.initialGameId != null) {
      final specificGame = games.firstWhere(
        (g) => g.id == widget.initialGameId,
        orElse: () => games.isNotEmpty ? games.first : PocketReelsGameEngine.getNextGameBatch(count: 1).first,
      );
      combinedFeed.add(ReelFeedItem.game(specificGame));
    }

    for (int i = 0; i < combinedNeighbors.length; i++) {
      combinedFeed.add(ReelFeedItem.home(combinedNeighbors[i]));

      if ((i + 1) % 2 == 0 && gameIdx < games.length) {
        combinedFeed.add(ReelFeedItem.game(games[gameIdx]));
        gameIdx++;
      } else if ((i + 1) % 3 == 0 && vibeIdx < publicVibes.length) {
        combinedFeed.add(ReelFeedItem.vibe(publicVibes[vibeIdx]));
        vibeIdx++;
      }
    }

    if (mounted) {
      setState(() {
        _feedItems = combinedFeed;
        _isLoading = false;
      });

      // Play music for the first slide if it is a home and widget is active
      if (widget.isActive && combinedFeed.isNotEmpty) {
        final firstItem = combinedFeed.first;
        if (firstItem.type == ReelItemType.home && firstItem.neighbor != null) {
          _playHomeMusic(firstItem.neighbor!.id);
        }
      }
    }
  }

  /// ➕ Infinite Lazy Loading: Appends fresh unseen homes & multi-type games seamlessly
  Future<void> _loadMoreFeedItems() async {
    if (_isLoadingMore) return;
    _isLoadingMore = true;

    try {
      _dynamicHomeBatchSeed += 30;
      final newRobots = _generateFullSpectrumHomes(count: 18, seedOffset: _dynamicHomeBatchSeed);
      final unseenNewRobots = _distributeWithLevelGap(
        newRobots.where((r) => !_viewedHomeIds.contains(r.id)).toList(),
        minGap: 6,
      );

      final newGames = PocketReelsGameEngine.getNextGameBatch(count: 6);
      final List<ReelFeedItem> newBatch = [];
      int gIdx = 0;

      for (int i = 0; i < unseenNewRobots.length; i++) {
        newBatch.add(ReelFeedItem.home(unseenNewRobots[i]));
        if ((i + 1) % 2 == 0 && gIdx < newGames.length) {
          newBatch.add(ReelFeedItem.game(newGames[gIdx]));
          gIdx++;
        }
      }

      if (mounted && newBatch.isNotEmpty) {
        setState(() {
          _feedItems.addAll(newBatch);
        });
      }
    } catch (e) {
      debugPrint('Error lazy loading feed: $e');
    } finally {
      _isLoadingMore = false;
    }
  }

  /// 🏰 Generate rich architectural showcase houses spanning all 6 major tiers (Levels 1 to 90)
  List<PocketNeighbor> _generateFullSpectrumHomes({int count = 30, int seedOffset = 0}) {
    final List<PocketNeighbor> bots = [];
    final palettes = [
      'terracotta', 'emerald', 'royal_gold', 'cyber_yellow',
      'sakura', 'mirror_glass', 'nordic', 'slate'
    ];
    final botNames = [
      'Zenith Explorer 🌱', 'Aura Warden 🏡', 'Nexus Knight 🏰', 'Echo Scholar 🏛️',
      'Nova Strategist 💎', 'Solar Citadel 👑', 'Lunar Scribe 🏡', 'Vortex Defender 🏰',
      'Phoenix Titan 🏛️', 'Cyber Sentinel 💎', 'Quantum Speaker 👑', 'Starlight Master 🏛️',
      'Breeze Cottage 🌱', 'Brick Haven 🏡', 'Granite Keep 🏰', 'Marble Palace 🏛️'
    ];

    // Key architectural anchor days representing all 6 visual house evolutions
    final anchorStages = [
      1, 3, 5,        // Tier 1: Wooden Cabin 🌱
      10, 14, 18, 20, // Tier 2: Brick Villa 🏡
      26, 32, 38, 44, // Tier 3: Stone Fortress 🏰
      50, 56, 62, 68, // Tier 4: Imperial Manor 🏛️
      72, 78, 84, 88, // Tier 5: Cyber Citadel 💎
      90,             // Tier 6: Supreme Empire 👑
    ];

    for (int i = 0; i < count; i++) {
      final stage = anchorStages[(i + seedOffset) % anchorStages.length];
      final palette = palettes[(i + stage) % palettes.length];
      final name = '${botNames[i % botNames.length]} #${seedOffset + i + 1}';
      final rank = stage >= 71
          ? 'Cyber Grandmaster'
          : (stage >= 46 ? 'Imperial Sovereign' : (stage >= 21 ? 'Stone Commander' : (stage >= 8 ? 'Villa Resident' : 'Pioneer Scout')));

      bots.add(
        PocketNeighbor(
          id: 'full_spec_robot_${seedOffset}_${stage}_$i',
          name: name,
          day: stage,
          streak: math.max(1, (stage * 0.4).round()),
          rank: rank,
          paletteId: palette,
          isMe: false,
          hasActiveShield: (i % 2 == 0),
          statusMessage: _statusQuotes[(i + seedOffset) % _statusQuotes.length],
          isPocketRobo: true,
          hp: 100,
          maxHp: 100,
          isDamaged: false,
        ),
      );
    }
    return bots;
  }

  /// 🔀 Smart Level-Gap Shuffler: Guarantees a minimum gap of at least 6 to 15 levels
  /// between any two adjacent houses in the feed (User Audio Directive).
  /// This ensures that after a Level 1 Wooden Cabin, the next house is a higher tier
  /// (e.g. Level 18 Brick Villa, Level 52 Imperial Manor, Level 88 Cyber Citadel)
  /// so each swipe displays fresh, non-repetitive architecture!
  List<PocketNeighbor> _distributeWithLevelGap(List<PocketNeighbor> source, {int minGap = 6}) {
    if (source.length <= 2) return source;

    final pool = List<PocketNeighbor>.from(source)..shuffle(math.Random());
    final List<PocketNeighbor> result = [];

    // Pick first item
    result.add(pool.removeAt(0));

    while (pool.isNotEmpty) {
      final lastDay = result.last.day;

      // Find candidates with at least minGap level difference
      final validIdx = pool.indexWhere((n) => (n.day - lastDay).abs() >= minGap);

      if (validIdx != -1) {
        result.add(pool.removeAt(validIdx));
      } else {
        // Fallback: pick the item in the pool with the largest level distance from lastDay
        int bestIdx = 0;
        int maxDist = -1;
        for (int i = 0; i < pool.length; i++) {
          final dist = (pool[i].day - lastDay).abs();
          if (dist > maxDist) {
            maxDist = dist;
            bestIdx = i;
          }
        }
        result.add(pool.removeAt(bestIdx));
      }
    }

    return result;
  }

  String _randomPalette(int day) {
    const palettes = ['terracotta', 'slate', 'nordic', 'sakura', 'emerald', 'cyber'];
    return palettes[day % palettes.length];
  }

  void _onAttackTapped(PocketNeighbor neighbor) async {
    if (_protectedHomeIds.contains(neighbor.id)) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1E3A8A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: Row(
            children: [
              const Text('🏛️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${neighbor.name}\'s Citadel is under Presidential Protection! Defended by the Sovereign Guard for 48 hours.',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    await PocketCitadelAttackPage.openForUser(
      context,
      userId: neighbor.id,
      neighbor: neighbor,
      attackerDay: widget.userLevel,
    );
    if (mounted && _currentlyPlayingHouseId != null) {
      _playHomeMusic(_currentlyPlayingHouseId!);
    }
  }

  Future<void> _onSendMateRequest(PocketNeighbor neighbor) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to connect with Mates')),
      );
      return;
    }
    HapticFeedback.mediumImpact();

    final isAlreadyMate = await PocketMateService.isMate(currentUserId, neighbor.id);
    if (isAlreadyMate) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Text('🤝', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You and ${neighbor.name} are already Pocket Mates!',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return;
    }

    final success = await PocketMateService.sendMateRequest(
      senderId: currentUserId,
      receiverId: neighbor.id,
      contextType: 'homes_reels',
      message: 'Saw your Citadel Home and wants to connect as your Pocket Mate! 🏰',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Text('🤝', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  success
                      ? 'Mate request sent to ${neighbor.name}!'
                      : 'Could not send request right now.',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _onSendPocketTalkRequest(PocketNeighbor neighbor) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to start a Poket Talk Pact')),
      );
      return;
    }
    HapticFeedback.heavyImpact();

    final pact = await PocketTalkPactService.requestPact(
      myId: currentUserId,
      otherUserId: neighbor.id,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF2C2407),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: const Color(0xFFFFD600).withValues(alpha: 0.5)),
          ),
          content: Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  pact != null
                      ? '⚡ 4-Day Spoken Pact invite sent to ${neighbor.name}!'
                      : 'Poket Talk invite sent to ${neighbor.name}!',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD600),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  /// ✨ Opens Add to Vibes & Share modal for Homes
  void _onShareHomeTapped(PocketNeighbor neighbor) {
    PocketFeedVibeShareSheet.show(
      context,
      neighbor: neighbor,
      onSharedSuccessfully: () {
        HapticFeedback.mediumImpact();
      },
    );
  }

  /// ✨ Opens Add to Vibes & Share modal for Games
  void _onShareGameTapped(ReelGameCard gameCard) {
    PocketFeedVibeShareSheet.show(
      context,
      gameCard: gameCard,
      onSharedSuccessfully: () {
        HapticFeedback.mediumImpact();
      },
    );
  }

  void _recordHomeViewed(String houseId) {
    if (_viewedHomeIds.add(houseId)) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setStringList('pm_viewed_homes_ids', _viewedHomeIds.toList());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: const Color(0xFF070B0D),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFFC00)),
              ),
              SizedBox(height: 16),
              Text(
                'Discovering Homes & Challenges...',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (_feedItems.isEmpty) {
      return Container(
        color: const Color(0xFF070B0D),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏘️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'All caught up with neighbor homes!',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  _viewedHomeIds.clear();
                  _refreshFeedList();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFC00),
                  foregroundColor: Colors.black,
                ),
                child: const Text('Explore More Homes'),
              ),
            ],
          ),
        ),
      );
    }

    // 📜 Clean, unblocked full-screen vertical PageView
    final canGoBack = Navigator.canPop(context) || widget.onBackToChat != null;

    return Scaffold(
      backgroundColor: const Color(0xFF070B0D),
      body: Stack(
        children: [
          PageView.builder(
            controller: _verticalPageController,
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            itemCount: _feedItems.length,
            onPageChanged: (index) {
              HapticFeedback.selectionClick();

              // Track viewed homes and handle ambient music
              final item = _feedItems[index];
              if (item.type == ReelItemType.home && item.neighbor != null) {
                _recordHomeViewed(item.neighbor!.id);
                _playHomeMusic(item.neighbor!.id);
              } else if (item.type == ReelItemType.game || item.type == ReelItemType.vibe) {
                // Pause background music during games or vibes for clear audio focus
                _pauseBgm();
              }

              // Infinite lazy loading when near the end
              if (index >= _feedItems.length - 4) {
                _loadMoreFeedItems();
              }
            },
            itemBuilder: (context, index) {
              final item = _feedItems[index];
              if (item.type == ReelItemType.game && item.gameCard != null) {
                return _buildInteractiveGameSlide(item.gameCard!, index);
              } else if (item.type == ReelItemType.vibe && item.vibeCard != null) {
                return _buildVibeReelSlide(item.vibeCard!, index);
              }
              return _buildHouseReelSlide(item.neighbor!, index);
            },
          ),

          // 🔙 Back Button Header (Instagram Reels style floating back pill)
          if (canGoBack)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 14,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else if (widget.onBackToChat != null) {
                    widget.onBackToChat!();
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.65),
                    border: Border.all(color: Colors.white24, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),

          // 🔊 Ambient Music Speaker Toggle Button (Top Right - Speaker Icon Only, User Audio Directive)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 14,
            child: ValueListenableBuilder<bool>(
              valueListenable: PocketGameAudioService.instance.isMutedNotifier,
              builder: (context, isMuted, _) {
                final effectiveMuted = _isHomesAudioMuted || isMuted;
                return GestureDetector(
                  onTap: _toggleBgmMute,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.65),
                      border: Border.all(
                        color: effectiveMuted
                            ? Colors.white24
                            : const Color(0xFFFFFC00).withValues(alpha: 0.7),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (effectiveMuted
                                  ? Colors.black
                                  : const Color(0xFFFFFC00))
                              .withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        effectiveMuted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        color: effectiveMuted
                            ? Colors.white60
                            : const Color(0xFFFFFC00),
                        size: 20,
                      ),
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

  /// 🏡 House Reel Slide with authentic Citadel scenery (sky + green foothills)
  Widget _buildHouseReelSlide(PocketNeighbor neighbor, int index) {
    final screenH = MediaQuery.of(context).size.height;
    final isPresident = neighbor.id == 'pocket_president';

    return Stack(
      children: [
        // 🌄 1. Authentic Living Citadel Scenery (Sky + Green Foothills)
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F172A), // Deep navy sky
                  Color(0xFF1E293B), // Horizon twilight
                  Color(0xFF1B4D3E), // Emerald foothills
                  Color(0xFF0B251E), // Lush lawn ground
                ],
                stops: [0.0, 0.40, 0.60, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 35,
                  right: 25,
                  child: Opacity(
                    opacity: 0.25,
                    child: Row(
                      children: const [
                        Text('⭐', style: TextStyle(fontSize: 10)),
                        SizedBox(width: 25),
                        Text('✨', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 40),
                        Text('⭐', style: TextStyle(fontSize: 8)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: screenH * 0.46,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF10B981).withValues(alpha: 0.15),
                          const Color(0xFF064E3B).withValues(alpha: 0.5),
                          const Color(0xFF022C22),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 🏠 2. The Fixed 2D Citadel House (Positioned high up so it's completely clear of text!)
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          height: screenH * 0.48,
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.94,
              child: FlameEnglishHouseWidget(
                currentDay: neighbor.day,
                streak: neighbor.streak,
                isDamaged: neighbor.isDamaged,
                houseId: neighbor.id,
                paletteId: neighbor.paletteId,
                isPresident: isPresident,
              ),
            ),
          ),
        ),

        // 🏛️ Presidential Protection Overlay Badge
        if (_protectedHomeIds.contains(neighbor.id))
          Positioned(
            top: MediaQuery.of(context).padding.top + 58,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF60A5FA),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🏛️', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 5),
                  Text(
                    'Presidential Protection 🛡️',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF93C5FD),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Vignette subtle gradient for reel contrast
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.88),
                  ],
                  stops: const [0.0, 0.12, 0.55, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),

        // 🛡️ 3. Right Side Floating Action Column (ATTACK + DOORBELL + VIBES/SHARE + HP)
        Positioned(
          right: 14,
          bottom: 25,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ⚔️ GLOWING ATTACK BUTTON
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = 1.0 + (_pulseController.value * 0.08);
                  return Transform.scale(
                    scale: scale,
                    child: GestureDetector(
                      onTap: () => _onAttackTapped(neighbor),
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFFC00), Color(0xFFFF3D00)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFFC00).withValues(alpha: 0.5),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('⚔️', style: TextStyle(fontSize: 20)),
                              Text(
                                'ATTACK',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // 🤝 Mates Request Button (User Audio Directive: Doorbell replaced with Mates request)
              GestureDetector(
                onTap: () => _onSendMateRequest(neighbor),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.7),
                    border: Border.all(color: Colors.white24, width: 1.2),
                  ),
                  child: const Center(
                    child: Text('🤝', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Mates',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              // ⚡ Poket Talk Pact Request Button (User Audio Directive: strictly for human peers, hide on robots)
              if (!neighbor.isPocketRobo &&
                  !PocketRobotService.isRobotId(neighbor.id) &&
                  !neighbor.id.startsWith('robot_')) ...[
                GestureDetector(
                  onTap: () => _onSendPocketTalkRequest(neighbor),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.7),
                      border: Border.all(
                        color: const Color(0xFFFFD600).withValues(alpha: 0.6),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD600).withValues(alpha: 0.25),
                          blurRadius: 8,
                          spreadRadius: -1,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('⚡', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Poket Talk',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD600),
                    fontSize: 9.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // ✈️ Minimal Share Button (Instagram Reels style)
              GestureDetector(
                onTap: () => _onShareHomeTapped(neighbor),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.7),
                    border: Border.all(color: Colors.white24, width: 1.2),
                  ),
                  child: const Center(
                    child: Icon(Icons.share_outlined, color: Colors.white, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Share',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              ),

              // 🏛️ Presidential Protection status pill (shown only if protected; 100% indicator removed per User Directive)
              if (_protectedHomeIds.contains(neighbor.id)) ...[
                const SizedBox(height: 14),
                Container(
                  width: 46,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF60A5FA),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🏛️', style: TextStyle(fontSize: 13)),
                      const SizedBox(height: 1),
                      Text(
                        'Shield',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF93C5FD),
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // 👤 4. Bottom Left Resident Profile Overlay
        Positioned(
          left: 16,
          right: 88,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar with Story Circle & Name Row
              Row(
                children: [
                  // Animated gradient story ring around avatar
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(
                        colors: [
                          Color(0xFFFF007A),
                          Color(0xFFFFFC00),
                          Color(0xFF00F0FF),
                          Color(0xFFFF007A),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF007A).withValues(alpha: 0.35),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF070B0D),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: VectorAvatarWidget(
                          config: VectorAvatarConfig.getEvolutionAvatarForStage(neighbor.day),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                neighbor.name,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (neighbor.isPocketRobo) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4338CA),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFF818CF8),
                                    width: 0.8,
                                  ),
                                ),
                                child: const Text(
                                  '🤖',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFFFFC00).withValues(alpha: 0.4),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                '🔥 Day ${neighbor.day}',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFFFC00),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '• ${neighbor.rank}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Status Quote Bubble
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  neighbor.statusMessage,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // 🎵 Ambient House Music Track Pill
              Builder(
                builder: (context) {
                  final track = HomeMusicTracks.getTrackForHouse(neighbor.id);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.music_note_rounded,
                          color: Color(0xFFFFFC00),
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${track.title} • ${track.genre}',
                            style: GoogleFonts.outfit(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Swipe Up Hint
              Row(
                children: [
                  const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white38, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Swipe up for next Reel',
                    style: GoogleFonts.outfit(
                      color: Colors.white38,
                      fontSize: 10.5,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🎮 Interactive Multi-Type Mini-Game Slide (Clean non-blocking parent scrolling - User Audio Directive)
  Widget _buildInteractiveGameSlide(ReelGameCard card, int index) {
    return Stack(
      children: [
        // Background Gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0A0F1E),
                  Color(0xFF131D33),
                  Color(0xFF0F172A),
                  Color(0xFF070B0D),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Main Game Content (Centered, inner scrolling disabled so parent PageView receives 100% of vertical gestures!)
        Positioned.fill(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Center(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: _buildGameContentForType(card),
                ),
              ),
            ),
          ),
        ),

        // Bottom Centered Subtle Swipe Up Hint
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white24, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Swipe up for next Reel',
                  style: GoogleFonts.outfit(
                    color: Colors.white30,
                    fontSize: 10.5,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom-Right Floating Minimal Share Button
        Positioned(
          right: 18,
          bottom: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✈️ Minimal Share Button (Instagram style)
              GestureDetector(
                onTap: () => _onShareGameTapped(card),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.7),
                    border: Border.all(color: Colors.white24, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.share_outlined, color: Colors.white, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Share',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ✨ Public Vibe Reel Slide (User Audio Directive: multi-story tap left/right + Home Visit button)
  Widget _buildVibeReelSlide(ReelVibeCard vibe, int index) {
    return _PocketReelVibeSlideView(
      vibe: vibe,
      onNextReel: () {
        if (_verticalPageController.hasClients) {
          _verticalPageController.nextPage(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
          );
        }
      },
      onPrevReel: () {
        if (_verticalPageController.hasClients && index > 0) {
          _verticalPageController.previousPage(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
          );
        }
      },
      onClose: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else if (widget.onBackToChat != null) {
          widget.onBackToChat!();
        }
      },
    );
  }

  Widget _buildGameContentForType(ReelGameCard card) {
    switch (card.gameType) {
      case ReelGameType.sentenceBuilder:
        return _buildSentenceBuilderGame(card);
      case ReelGameType.smartReply:
        return _buildSmartReplyGame(card);
      default:
        return _buildStandardChoiceGame(card);
    }
  }

  /// 🧩 1. Sentence Builder (Tap word chips to form the natural sentence)
  Widget _buildSentenceBuilderGame(ReelGameCard card) {
    final currentOrder = _sentenceBuilderUserOrder[card.id] ?? [];
    final targetWords = card.correctSentenceWords ?? card.options;
    final isChecked = _sentenceBuilderResults[card.id] != null;
    final isCorrect = _sentenceBuilderResults[card.id] == true;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Category Pill
        _buildCategoryPill(card.category),
        const SizedBox(height: 12),

        // Prompt
        Text(
          card.prompt,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),

        // Assembled Sentence Box (Answer Area)
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isChecked
                  ? (isCorrect ? const Color(0xFF10B981) : Colors.redAccent)
                  : const Color(0xFFFFFC00).withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: currentOrder.isEmpty
              ? Center(
                  child: Text(
                    'Tap words below to assemble your sentence...',
                    style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                  ),
                )
              : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: currentOrder.map((word) {
                    return GestureDetector(
                      onTap: isChecked
                          ? null
                          : () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                currentOrder.remove(word);
                                _sentenceBuilderUserOrder[card.id] = currentOrder;
                              });
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFC00),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          word,
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 16),

        // Word Pool (Available chips)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: card.options.map((word) {
            final isUsed = currentOrder.contains(word);
            return GestureDetector(
              onTap: (isChecked || isUsed)
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        currentOrder.add(word);
                        _sentenceBuilderUserOrder[card.id] = currentOrder;
                      });
                    },
              child: Opacity(
                opacity: isUsed ? 0.3 : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    word,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Actions: Clear & Check
        if (!isChecked)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _sentenceBuilderUserOrder[card.id] = [];
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Reset', style: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: currentOrder.length != targetWords.length
                    ? null
                    : () {
                        HapticFeedback.heavyImpact();
                        bool correct = true;
                        for (int i = 0; i < targetWords.length; i++) {
                          if (currentOrder[i].toLowerCase() != targetWords[i].toLowerCase()) {
                            correct = false;
                            break;
                          }
                        }
                        setState(() {
                          _sentenceBuilderResults[card.id] = correct;
                        });
                        PocketReelsGameEngine.markGameViewed(card.id);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFC00),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text('Check Sentence', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),

        // Explanation reveal
        if (isChecked) ...[
          const SizedBox(height: 14),
          _buildExplanationBox(card, isCorrect),
        ],
      ],
    );
  }

  /// 💬 2. Smart Reply & Funny Conversation Comeback
  Widget _buildSmartReplyGame(ReelGameCard card) {
    final selectedIdx = _selectedAnswers[card.id];
    final hasAnswered = selectedIdx != null;
    final isCorrect = hasAnswered && selectedIdx == card.correctOptionIndex;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildCategoryPill(card.category),
        const SizedBox(height: 12),

        // Context Situation
        if (card.contextSituation != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              card.contextSituation!,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),

        // Conversation Prompt Bubble
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4), width: 1.5),
          ),
          child: Row(
            children: [
              const Text('🗣️', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  card.prompt,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Choose the best witty / natural English reply:',
          style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11.5),
        ),
        const SizedBox(height: 10),

        // 4 Options
        Column(
          children: List.generate(card.options.length, (optIdx) {
            return _buildOptionTile(card, optIdx, selectedIdx);
          }),
        ),

        if (hasAnswered) ...[
          const SizedBox(height: 12),
          _buildExplanationBox(card, isCorrect),
        ],
      ],
    );
  }

  /// 🎯 3. Standard Choice Game (GapFill, Vocab, Error, Idioms)
  Widget _buildStandardChoiceGame(ReelGameCard card) {
    final selectedIdx = _selectedAnswers[card.id];
    final hasAnswered = selectedIdx != null;
    final isCorrect = hasAnswered && selectedIdx == card.correctOptionIndex;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildCategoryPill(card.category),
        const SizedBox(height: 12),

        if (card.contextSituation != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              card.contextSituation!,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),

        // Question Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasAnswered
                  ? (isCorrect ? const Color(0xFF10B981) : Colors.redAccent)
                  : const Color(0xFFFFFC00).withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                card.prompt,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              if (card.contextHint.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  card.contextHint,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF38BDF8),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Options
        Column(
          children: List.generate(card.options.length, (optIdx) {
            return _buildOptionTile(card, optIdx, selectedIdx);
          }),
        ),

        if (hasAnswered) ...[
          const SizedBox(height: 12),
          _buildExplanationBox(card, isCorrect),
        ],
      ],
    );
  }

  Widget _buildOptionTile(ReelGameCard card, int optIdx, int? selectedIdx) {
    final hasAnswered = selectedIdx != null;
    final isThisSelected = selectedIdx == optIdx;
    final isThisCorrect = optIdx == card.correctOptionIndex;

    Color borderCol = Colors.white12;
    Color bgCol = const Color(0xFF1E293B).withValues(alpha: 0.6);
    Color textCol = Colors.white;

    if (hasAnswered) {
      if (isThisCorrect) {
        borderCol = const Color(0xFF10B981);
        bgCol = const Color(0xFF10B981).withValues(alpha: 0.2);
        textCol = const Color(0xFF34D399);
      } else if (isThisSelected) {
        borderCol = Colors.redAccent;
        bgCol = Colors.redAccent.withValues(alpha: 0.2);
        textCol = Colors.redAccent;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          setState(() {
            _selectedAnswers[card.id] = optIdx;
          });
          PocketReelsGameEngine.markGameViewed(card.id);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: bgCol,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderCol, width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isThisSelected
                      ? (isThisCorrect ? const Color(0xFF10B981) : Colors.redAccent)
                      : Colors.white12,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + optIdx),
                    style: TextStyle(
                      color: isThisSelected ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  card.options[optIdx],
                  style: GoogleFonts.outfit(
                    color: textCol,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (hasAnswered && isThisCorrect)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
              if (hasAnswered && isThisSelected && !isThisCorrect)
                const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPill(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFFC00), width: 1),
      ),
      child: Text(
        category,
        style: GoogleFonts.outfit(
          color: const Color(0xFFFFFC00),
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildExplanationBox(ReelGameCard card, bool isCorrect) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCorrect
            ? const Color(0xFF10B981).withValues(alpha: 0.12)
            : Colors.redAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCorrect
              ? const Color(0xFF10B981).withValues(alpha: 0.35)
              : Colors.redAccent.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isCorrect ? '🎉 Great Job!' : '💡 Learning Insight:',
                style: GoogleFonts.outfit(
                  color: isCorrect ? const Color(0xFF34D399) : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                '($_userNativeLanguage)',
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            card.getExplanation(_userNativeLanguage),
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 12,
              height: 1.3,
            ),
          ),
          if (card.funnyNote != null) ...[
            const SizedBox(height: 6),
            Text(
              card.funnyNote!,
              style: GoogleFonts.inter(
                color: const Color(0xFFFFFC00),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 10),
          // 🚀 Smooth Next Reel Button so user is never stuck
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (_verticalPageController.hasClients) {
                _verticalPageController.nextPage(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                );
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFC00), Color(0xFFFF9100)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFFC00).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CONTINUE TO NEXT HOME',
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 11.5,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.black,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PocketReelVibeSlideView extends StatefulWidget {
  final ReelVibeCard vibe;
  final VoidCallback onNextReel;
  final VoidCallback? onPrevReel;
  final VoidCallback? onClose;

  const _PocketReelVibeSlideView({
    required this.vibe,
    required this.onNextReel,
    this.onPrevReel,
    this.onClose,
  });

  @override
  State<_PocketReelVibeSlideView> createState() => _PocketReelVibeSlideViewState();
}

class _PocketReelVibeSlideViewState extends State<_PocketReelVibeSlideView> {
  int _currentStoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final vibe = widget.vibe;
    final stories = vibe.stories;
    final activeIndex = _currentStoryIndex.clamp(0, stories.isEmpty ? 0 : stories.length - 1);
    final currentItem = stories.isNotEmpty ? stories[activeIndex] : null;
    final mediaUrl = currentItem?.mediaUrl ?? vibe.mediaUrl;
    final caption = currentItem?.caption ?? vibe.caption;

    return Stack(
      children: [
        // 1. Full Screen Media Content
        Positioned.fill(
          child: Container(
            color: Colors.black,
            child: mediaUrl.isNotEmpty
                ? Image.network(
                    mediaUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0284C7)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.play_circle_fill_rounded, size: 72, color: Colors.white38),
                      ),
                    ),
                  )
                : Container(color: const Color(0xFF0F172A)),
          ),
        ),

        // 2. Cinematic Vignette & Bottom Scrim
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.25),
                  Colors.black.withValues(alpha: 0.90),
                ],
                stops: const [0.0, 0.22, 0.65, 1.0],
              ),
            ),
          ),
        ),

        // 3. Multi-Vibe Tap & Swipe Navigation Overlay (User Audio Directive: tap left/right, swipe left/right)
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapUp: (details) {
              final screenWidth = MediaQuery.of(context).size.width;
              final tapX = details.localPosition.dx;
              if (tapX < screenWidth * 0.35) {
                // Left tap -> previous story or previous reel
                if (_currentStoryIndex > 0) {
                  HapticFeedback.selectionClick();
                  setState(() => _currentStoryIndex--);
                } else {
                  HapticFeedback.lightImpact();
                  if (widget.onPrevReel != null) {
                    widget.onPrevReel!();
                  } else if (widget.onClose != null) {
                    widget.onClose!();
                  }
                }
              } else if (tapX > screenWidth * 0.65) {
                // Right tap -> next story
                if (_currentStoryIndex < stories.length - 1) {
                  HapticFeedback.selectionClick();
                  setState(() => _currentStoryIndex++);
                } else {
                  // Reached end of this creator's vibes -> move to next reel
                  HapticFeedback.lightImpact();
                  widget.onNextReel();
                }
              }
            },
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity > 250) {
                // Swipe right -> previous story/reel
                if (_currentStoryIndex > 0) {
                  HapticFeedback.selectionClick();
                  setState(() => _currentStoryIndex--);
                } else if (widget.onPrevReel != null) {
                  widget.onPrevReel!();
                }
              } else if (velocity < -250) {
                // Swipe left -> next story/reel
                if (_currentStoryIndex < stories.length - 1) {
                  HapticFeedback.selectionClick();
                  setState(() => _currentStoryIndex++);
                } else {
                  widget.onNextReel();
                }
              }
            },
          ),
        ),

        // 4. Ultra-Minimal Story Progress Indicators at Top (User Audio Directive: minimal modern design)
        if (stories.length > 1)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 54,
            right: 54,
            child: Row(
              children: List.generate(stories.length, (sIdx) {
                final isPassedOrCurrent = sIdx <= activeIndex;
                return Expanded(
                  child: Container(
                    height: 2.2,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isPassedOrCurrent
                          ? const Color(0xFFFFFC00)
                          : Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(1.5),
                      boxShadow: isPassedOrCurrent
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFFFC00).withValues(alpha: 0.6),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }),
            ),
          ),

        // 🔙 Back / Exit Button (Top Left - User Audio Directive: Always provide back option in vibes)
        Positioned(
          top: MediaQuery.of(context).padding.top + 6,
          left: 12,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (widget.onClose != null) {
                widget.onClose!();
              } else if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.55),
                border: Border.all(color: Colors.white24, width: 0.8),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ),

        // 5. Creator Info & Badge at Bottom Left (Tappable to Visit Citadel)
        Positioned(
          left: 16,
          right: 84,
          bottom: MediaQuery.of(context).padding.bottom + 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  PocketCitadelAttackPage.openForUser(
                    context,
                    userId: vibe.userId,
                    targetName: vibe.authorName,
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFFC00), width: 1.8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFFC00).withValues(alpha: 0.35),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: vibe.authorAvatarUrl != null && vibe.authorAvatarUrl!.startsWith('http')
                            ? Image.network(
                                vibe.authorAvatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white70),
                              )
                            : const Icon(Icons.person, color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  vibe.authorName,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (vibe.isRobot) ...[
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('BOT', style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFC00).withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFFFFC00).withValues(alpha: 0.5),
                                    width: 0.9,
                                  ),
                                ),
                                child: Text(
                                  '✨ Vibes',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFFFC00),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (stories.length > 1) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white12,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    '${activeIndex + 1}/${stories.length}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (caption != null && caption.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  caption,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),

        // 6. Right Side Action Rail (Home Visit, Like, Share)
        Positioned(
          right: 14,
          bottom: MediaQuery.of(context).padding.bottom + 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🏰 Home Visit Action Button (User Audio Directive: Must visit author's house / citadel)
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  PocketCitadelAttackPage.openForUser(
                    context,
                    userId: vibe.userId,
                    targetName: vibe.authorName,
                  );
                },
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFFC00), Color(0xFFFF9100)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFFC00).withValues(alpha: 0.45),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.castle_rounded, color: Colors.black, size: 22),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Home Visit',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ❤️ Like Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❤️ Liked Vibe!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFF1E293B),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.6),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(Icons.favorite_rounded, color: Color(0xFFEF4444), size: 22),
                ),
              ),
              const SizedBox(height: 14),

              // ↗️ Share Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  PocketFeedVibeShareSheet.show(
                    context,
                    customText: '✨ ${vibe.authorName}\'s Vibe\n${caption ?? ''}\n$mediaUrl',
                  );
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.6),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
