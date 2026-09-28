import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pocket_robot_service.dart';

/// 🎵 Pocket Music Track Metadata
class PocketMusicTrack {
  final String id;
  final String title;
  final String genre;
  final String url;
  final String mood; // 'happy', 'arcade', 'battle', 'cozy', 'epic'

  const PocketMusicTrack({
    required this.id,
    required this.title,
    required this.genre,
    required this.url,
    this.mood = 'happy',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'genre': genre,
        'url': url,
        'mood': mood,
      };

  factory PocketMusicTrack.fromMap(Map<String, dynamic> map) {
    return PocketMusicTrack(
      id: map['id']?.toString() ?? 'track_unknown',
      title: map['title']?.toString() ?? 'Game Vibe Beat',
      genre: map['genre']?.toString() ?? 'Casual Game',
      url: map['url']?.toString() ?? '',
      mood: map['mood']?.toString() ?? 'happy',
    );
  }
}

/// 🎮 Central Game Background Audio & Sound Engine for Pocket Mates
/// Powered by Supabase Storage 'music' Bucket.
/// Features:
/// 1. 🏡 Ambient App & Homes BGM - Joyful, happy, relaxing background music.
/// 2. ⚔️ Citadel Battle & Attack Mode - Energetic, upbeat arcade loops.
/// 3. 📸 Robot Vibes & Stories - Attached music playback from Supabase storage.
/// 4. 🔄 Anti-Boredom Smart Shuffle Loop - Continuously cycles songs without repeating recently played tracks!
/// 5. 🔇 Global Mute / Unmute state persistent across app sessions.
class PocketGameAudioService with WidgetsBindingObserver {
  static final PocketGameAudioService _instance =
      PocketGameAudioService._internal();
  static PocketGameAudioService get instance => _instance;

  PocketGameAudioService._internal() {
    _init();
  }

  static const String _kPrefMuteKey = 'game_bgm_muted_pref';
  static const double kDefaultBgmVolume = 0.28;
  static const double kBattleBgmVolume = 0.38;

  static const String _kSupabaseStorageBase =
      'https://gswhynuabdspnwudltth.supabase.co/storage/v1/object/public/music/';

  AudioPlayer? _player;
  String? _currentTrackUrl;
  String? _currentTrackTitle;
  bool _isDisposed = false;
  Completer<void>? _initCompleter;

  // Anti-boredom queue: records last 6 played track IDs to prevent immediate repeats
  final List<String> _recentlyPlayedIds = [];
  final math.Random _random = math.Random();

  /// Global reactive notifier for mute status (used by Mute/Unmute buttons across screens)
  final ValueNotifier<bool> isMutedNotifier = ValueNotifier<bool>(false);

  /// Global reactive notifier for current track title
  final ValueNotifier<String?> currentTrackNotifier =
      ValueNotifier<String?>(null);
  String? get currentTrackTitle => _currentTrackTitle;

  /// Global reactive notifier for whether audio is actively playing
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);

  Future<void> _init() async {
    if (_initCompleter != null) return _initCompleter!.future;
    _initCompleter = Completer<void>();
    WidgetsBinding.instance.addObserver(this);
    try {
      final prefs = await SharedPreferences.getInstance();
      final isMuted = prefs.getBool(_kPrefMuteKey) ?? false;
      isMutedNotifier.value = isMuted;

      _player = AudioPlayer();
      await _player?.setReleaseMode(ReleaseMode.stop);
      await _player?.setVolume(isMuted ? 0.0 : kDefaultBgmVolume);

      // Listen for playback completion to auto-chain next shuffle track (no boredom!)
      _player?.onPlayerComplete.listen((_) {
        playNextShuffleTrack();
      });

      _player?.onPlayerStateChanged.listen((state) {
        isPlayingNotifier.value = (state == PlayerState.playing);
      });

      // Background discover dynamic music from Supabase storage
      _fetchDynamicMusicFromSupabase();

      _initCompleter?.complete();
    } catch (e) {
      debugPrint('⚠️ PocketGameAudioService init error: $e');
      _initCompleter?.complete();
    }
  }

  Future<void> _ensureInitialized() async {
    if (_initCompleter != null) {
      await _initCompleter!.future;
    } else {
      await _init();
    }
  }

  /// Automatically discovers newly uploaded tracks from Supabase storage 'music' bucket
  Future<void> _fetchDynamicMusicFromSupabase() async {
    try {
      final supabase = Supabase.instance.client;
      final fileList = await supabase.storage.from('music').list();
      if (fileList.isNotEmpty) {
        debugPrint(
            '🎵 Discovered ${fileList.length} music tracks from Supabase storage!');
      }
    } catch (e) {
      debugPrint('Supabase music list notice: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _player?.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (!isMutedNotifier.value && _currentTrackUrl != null) {
        _player?.resume();
      }
    }
  }

  // =========================================================================
  // 🎼 MASTER TRACK REPERTOIRE (SUPABASE STORAGE BUCKET 'music')
  // =========================================================================

  /// 🏡 Homes & Reels & App Ambient Tracks (Happy, Cozy, Chill, Relaxing)
  static final List<PocketMusicTrack> homeTracks = [
    PocketMusicTrack(
      id: 'supa_whistler',
      title: 'Happy Whistler 🌾',
      genre: 'Uplifting Acoustic',
      url: '${_kSupabaseStorageBase}kaazoom-the-happy-whistler-1-min-edit-532435.mp3',
      mood: 'happy',
    ),
    PocketMusicTrack(
      id: 'supa_hiphop_fun',
      title: 'Fun Energy Hop ⚡',
      genre: 'Uplifting Chill Hop',
      url:
          '${_kSupabaseStorageBase}white_records-fun-background-hip-hop-short-music-27-sec-energetic-vlog-music-148916.mp3',
      mood: 'happy',
    ),
    PocketMusicTrack(
      id: 'supa_sailor',
      title: 'Pocket Town Sailor ⛵',
      genre: 'Cozy Acoustic',
      url: '${_kSupabaseStorageBase}nojisuma-sailor-256509.mp3',
      mood: 'cozy',
    ),
    PocketMusicTrack(
      id: 'supa_stardust',
      title: 'Dancing in the Stardust ✨',
      genre: 'Dreamy Pop',
      url:
          '${_kSupabaseStorageBase}freesoundserver-dancing-in-the-stardust-free-music-no-copyright-203603.mp3',
      mood: 'happy',
    ),
    PocketMusicTrack(
      id: 'supa_relaxing',
      title: 'Fireside Relaxation ☕',
      genre: 'Chill Ambient',
      url: '${_kSupabaseStorageBase}andriig-relaxing-relaxing-music-572285.mp3',
      mood: 'cozy',
    ),
    PocketMusicTrack(
      id: 'supa_lullaby',
      title: 'Peaceful Citadel Stroll 🌸',
      genre: 'Warm Acoustic Lullaby',
      url: '${_kSupabaseStorageBase}live_art-lullaby-160470.mp3',
      mood: 'cozy',
    ),
    PocketMusicTrack(
      id: 'supa_free_musica',
      title: 'Sunny Day Joy 🎸',
      genre: 'Latin Acoustic Pop',
      url:
          '${_kSupabaseStorageBase}tudo_free-music-free-musica-free-musica-no-copyright-musicas-gratuita-294095.mp3',
      mood: 'happy',
    ),
    PocketMusicTrack(
      id: 'supa_rain_relax',
      title: 'Gentle Rain Sleep 🌧️',
      genre: 'Rain Nature Ambient',
      url:
          '${_kSupabaseStorageBase}karim_alaoui-gentle-rain-sounds-for-relaxation-and-sleep-585942.mp3',
      mood: 'cozy',
    ),
    PocketMusicTrack(
      id: 'supa_slice_rain',
      title: 'Lofi Rain Study 📖',
      genre: 'Chill Lofi Beats',
      url: '${_kSupabaseStorageBase}slicebeats-rain-7508.mp3',
      mood: 'cozy',
    ),
  ];

  /// ⚔️ Battle & Attack Mode Tracks (Energetic, Arcade, Epic, Quirky)
  static final List<PocketMusicTrack> attackTracks = [
    PocketMusicTrack(
      id: 'supa_gaming_beat',
      title: 'Citadel Gaming Arena 🎮',
      genre: 'Electronic Arcade',
      url:
          '${_kSupabaseStorageBase}mfcc-gaming-game-video-game-music-522352.mp3',
      mood: 'battle',
    ),
    PocketMusicTrack(
      id: 'supa_loop_13',
      title: 'Fortress Battle Drums ⚔️',
      genre: 'Cinematic Battle Loop',
      url:
          '${_kSupabaseStorageBase}xtremefreddy-game-music-loop-13-147206.mp3',
      mood: 'battle',
    ),
    PocketMusicTrack(
      id: 'supa_loop_19',
      title: 'Boss Raid Heavy Beat 🔥',
      genre: 'Energetic Boss Battle',
      url:
          '${_kSupabaseStorageBase}xtremefreddy-game-music-loop-19-153393.mp3',
      mood: 'battle',
    ),
    PocketMusicTrack(
      id: 'supa_loop_18',
      title: '8-Bit Retro Chiptune Blitz 👾',
      genre: 'Retro Chiptune',
      url:
          '${_kSupabaseStorageBase}xtremefreddy-game-music-loop-18-153392.mp3',
      mood: 'arcade',
    ),
    PocketMusicTrack(
      id: 'supa_loop_16',
      title: 'Speedy Platform Duel ⚡',
      genre: 'Action Platformer Loop',
      url:
          '${_kSupabaseStorageBase}xtremefreddy-game-music-loop-16-153389.mp3',
      mood: 'arcade',
    ),
    PocketMusicTrack(
      id: 'supa_loop_9',
      title: 'Epic Citadel Defense 🛡️',
      genre: 'Orchestral Defense',
      url: '${_kSupabaseStorageBase}xtremefreddy-game-music-loop-9-145494.mp3',
      mood: 'epic',
    ),
    PocketMusicTrack(
      id: 'supa_run_catch',
      title: 'Retro Platform Run & Catch 🏃',
      genre: 'Retro Platform Arcade',
      url:
          '${_kSupabaseStorageBase}kaazoom-run-and-catch-x27em-46-sec-loopable-retro-platform-game-music-442979.mp3',
      mood: 'arcade',
    ),
    PocketMusicTrack(
      id: 'supa_adventure_theme',
      title: 'Adventure Quest Anthem 🏆',
      genre: 'Action Game Beat',
      url: '${_kSupabaseStorageBase}u_l065ve68l2-game-music-202227.mp3',
      mood: 'epic',
    ),
    PocketMusicTrack(
      id: 'supa_market_square',
      title: 'Market Square RPG Stinger 🏰',
      genre: 'Fantasy Town RPG',
      url:
          '${_kSupabaseStorageBase}kaazoom-the-market-square-daytime-15-sec-stinger-rpg-game-music-519315.mp3',
      mood: 'happy',
    ),
    PocketMusicTrack(
      id: 'supa_arcade_short',
      title: 'Arcade Pop Sprint 🎯',
      genre: 'Short Arcade Theme',
      url:
          '${_kSupabaseStorageBase}moodmode-that-game-arcade-short-236108.mp3',
      mood: 'arcade',
    ),
    PocketMusicTrack(
      id: 'supa_mfcc_game',
      title: 'Playful Arcade Spin 🎭',
      genre: 'Chiptune Game Beat',
      url: '${_kSupabaseStorageBase}mfcc-game-game-music-603130.mp3',
      mood: 'arcade',
    ),
  ];

  /// 📸 Vibe Library Tracks (Used by Robots & Humans when sharing Vibes / Stories)
  static List<PocketMusicTrack> get vibeLibraryTracks =>
      [...homeTracks, ...attackTracks];

  /// 🎯 Target Recon & Street Exploration Tracks
  static List<PocketMusicTrack> get targetTracks => [
        homeTracks[1],
        attackTracks[8],
        attackTracks[1],
      ];

  // =========================================================================
  // 🎮 SMART PLAYBACK CONTROLLER
  // =========================================================================

  /// Selects the best attack track based on robot archetype, level, or president status
  static PocketMusicTrack getTrackForAttack({
    required String targetId,
    int targetDay = 1,
    String? archetypeId,
  }) {
    if (targetId == 'pocket_president' || targetId.startsWith('pres_')) {
      return attackTracks[0]; // Heroic Gaming Arena
    }

    final robot = PocketRobotService.getRobotById(targetId);
    final arcKey = archetypeId ?? robot?.archetype.name.toLowerCase() ?? '';

    if (arcKey.contains('grumpy')) {
      return attackTracks[2]; // Boss Raid Heavy Beat
    } else if (arcKey.contains('intellectual') ||
        arcKey.contains('trendsetter')) {
      return attackTracks[3]; // 8-Bit Retro Chiptune Blitz
    } else if (targetDay >= 30) {
      return attackTracks[5]; // Epic Citadel Defense
    }

    final hash = targetId.codeUnits.fold<int>(0, (sum, c) => sum + c);
    return attackTracks[hash.abs() % attackTracks.length];
  }

  /// Selects home track by houseId
  static PocketMusicTrack getTrackForHouse(String houseId) {
    final hash = houseId.codeUnits.fold<int>(0, (sum, c) => sum + c);
    return homeTracks[hash.abs() % homeTracks.length];
  }

  /// Pick a random or persona-fitting track for a robot's vibe
  static PocketMusicTrack getRandomVibeTrack({String? persona}) {
    if (persona == 'student') {
      return homeTracks[4]; // Fireside Relaxation
    } else if (persona == 'work' || persona == 'professional') {
      return homeTracks[0]; // Happy Whistler
    }
    final rand = math.Random();
    return homeTracks[rand.nextInt(homeTracks.length)];
  }

  /// 🌟 Plays a gentle ambient app theme (called on app startup / home page)
  Future<void> playAmbientAppTheme() async {
    if (isPlayingNotifier.value && _currentTrackUrl != null) {
      return; // Already playing background music
    }
    await playNextShuffleTrack(mood: 'happy');
  }

  /// 🔄 Smart Anti-Boredom Next Shuffle:
  /// Picks the next track that has NOT been played recently so users never get bored!
  Future<void> playNextShuffleTrack({String mood = 'happy'}) async {
    final pool = (mood == 'battle' ? attackTracks : homeTracks);
    final available = pool
        .where((t) => !_recentlyPlayedIds.contains(t.id))
        .toList();

    PocketMusicTrack selectedTrack;
    if (available.isNotEmpty) {
      selectedTrack = available[_random.nextInt(available.length)];
    } else {
      // Clear half of history and pick
      _recentlyPlayedIds.clear();
      selectedTrack = pool[_random.nextInt(pool.length)];
    }

    _recentlyPlayedIds.add(selectedTrack.id);
    if (_recentlyPlayedIds.length > 6) {
      _recentlyPlayedIds.removeAt(0);
    }

    await playTrack(selectedTrack,
        volume: mood == 'battle' ? kBattleBgmVolume : kDefaultBgmVolume);
  }

  /// ⚔️ Start Playing Attack Mode BGM
  Future<void> playAttackTheme({
    required String targetId,
    int targetDay = 1,
    String? archetypeId,
  }) async {
    final track = getTrackForAttack(
      targetId: targetId,
      targetDay: targetDay,
      archetypeId: archetypeId,
    );
    await playTrack(track, volume: kBattleBgmVolume);
  }

  /// 🏡 Start Playing Home Reels BGM
  Future<void> playHomeTheme(String houseId) async {
    final track = getTrackForHouse(houseId);
    await playTrack(track, volume: kDefaultBgmVolume);
  }

  /// 🎯 Start Playing Target Mode / Street Recon BGM
  Future<void> playTargetTheme() async {
    final track = targetTracks[0];
    await playTrack(track, volume: kDefaultBgmVolume);
  }

  /// Play any specific track with automatic error fallback
  Future<void> playTrack(PocketMusicTrack track, {double? volume}) async {
    if (_isDisposed) return;
    await _ensureInitialized();

    if (_currentTrackUrl == track.url && isPlayingNotifier.value) {
      return; // Already playing this track
    }

    try {
      _currentTrackUrl = track.url;
      _currentTrackTitle = track.title;
      currentTrackNotifier.value = track.title;

      if (_player == null) {
        _player = AudioPlayer();
        await _player?.setReleaseMode(ReleaseMode.stop);
        _player?.onPlayerComplete.listen((_) {
          playNextShuffleTrack();
        });
        _player?.onPlayerStateChanged.listen((state) {
          isPlayingNotifier.value = (state == PlayerState.playing);
        });
      }

      final isMuted = isMutedNotifier.value;
      final targetVolume = volume ?? kDefaultBgmVolume;
      await _player?.setVolume(isMuted ? 0.0 : targetVolume);

      if (!isMuted) {
        await _player?.stop();
        await _player?.play(UrlSource(track.url));
      }
    } catch (e) {
      debugPrint('⚠️ Error playing track ${track.title}: $e');
    }
  }

  /// Stop current playback
  Future<void> stop() async {
    try {
      _currentTrackUrl = null;
      _currentTrackTitle = null;
      currentTrackNotifier.value = null;
      await _player?.stop();
    } catch (e) {
      debugPrint('⚠️ Error stopping BGM: $e');
    }
  }

  /// Pause current playback
  Future<void> pause() async {
    try {
      await _player?.pause();
    } catch (e) {
      debugPrint('⚠️ Error pausing BGM: $e');
    }
  }

  /// Resume playback
  Future<void> resume() async {
    if (isMutedNotifier.value) return;
    try {
      if (_player != null && _currentTrackUrl != null) {
        if (_player?.state == PlayerState.paused) {
          await _player?.resume();
        } else if (_player?.state != PlayerState.playing) {
          await _player?.play(UrlSource(_currentTrackUrl!));
        }
      } else {
        await playAmbientAppTheme();
      }
    } catch (e) {
      debugPrint('⚠️ Error resuming BGM: $e');
    }
  }

  /// Toggle global mute state (persisted in SharedPreferences)
  Future<void> toggleMute() async {
    final nextMuted = !isMutedNotifier.value;
    isMutedNotifier.value = nextMuted;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kPrefMuteKey, nextMuted);

      if (_player != null) {
        if (nextMuted) {
          await _player?.setVolume(0.0);
          await _player?.pause();
        } else {
          await _player?.setVolume(kDefaultBgmVolume);
          if (_currentTrackUrl != null) {
            if (_player?.state == PlayerState.paused) {
              await _player?.resume();
            } else {
              await _player?.play(UrlSource(_currentTrackUrl!));
            }
          } else {
            await playAmbientAppTheme();
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error toggling mute: $e');
    }
  }

  /// Set exact volume level (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      if (!isMutedNotifier.value) {
        await _player?.setVolume(volume.clamp(0.0, 1.0));
      }
    } catch (e) {
      debugPrint('⚠️ Error setting volume: $e');
    }
  }

  /// Dispose service
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _player?.dispose();
    _player = null;
  }
}

/// 🔊 Reusable Floating / Inline Game Sound Control Pill
/// Renders a sleek glowing button showing animated audio wave / music note and mute toggle
class PocketSoundToggleWidget extends StatelessWidget {
  final bool compact;
  final Color? backgroundColor;

  const PocketSoundToggleWidget({
    super.key,
    this.compact = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: PocketGameAudioService.instance.isMutedNotifier,
      builder: (context, isMuted, _) {
        return ValueListenableBuilder<String?>(
          valueListenable:
              PocketGameAudioService.instance.currentTrackNotifier,
          builder: (context, currentTrack, _) {
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                PocketGameAudioService.instance.toggleMute();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isMuted
                              ? Icons.music_note_rounded
                              : Icons.volume_off_rounded,
                          color: Colors.black,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isMuted
                              ? '🎵 Pocket Music Unmuted'
                              : '🔇 Pocket Music Muted',
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFFFFFC00),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    margin: const EdgeInsets.only(
                        bottom: 80, left: 40, right: 40),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 8 : 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor ??
                      (isMuted
                          ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                          : const Color(0xFF0F172A).withValues(alpha: 0.85)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isMuted
                        ? Colors.white24
                        : const Color(0xFFFFFC00).withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                  boxShadow: isMuted
                      ? []
                      : [
                          BoxShadow(
                            color:
                                const Color(0xFFFFFC00).withValues(alpha: 0.25),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isMuted
                          ? Icons.volume_off_rounded
                          : Icons.music_note_rounded,
                      color:
                          isMuted ? Colors.white54 : const Color(0xFFFFFC00),
                      size: compact ? 16 : 18,
                    ),
                    if (!compact && !isMuted) ...[
                      const SizedBox(width: 5),
                      Text(
                        'BGM',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFFC00),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
