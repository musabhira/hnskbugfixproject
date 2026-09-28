import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
/// Powers:
/// 1. ⚔️ Attacking Mode (Citadel & House Attacks) - Level & Archetype specific battle beats
/// 2. 🏡 Homes Reels Feed - Cozy, happy, uplifting house themes
/// 3. 📸 Robot Vibes & Stories - Attached background music from music library
/// 4. 🔇 Global Mute / Unmute state persistent across app sessions
class PocketGameAudioService with WidgetsBindingObserver {
  static final PocketGameAudioService _instance = PocketGameAudioService._internal();
  static PocketGameAudioService get instance => _instance;

  PocketGameAudioService._internal() {
    _init();
  }

  static const String _kPrefMuteKey = 'game_bgm_muted_pref';
  static const double kDefaultBgmVolume = 0.45;

  AudioPlayer? _player;
  String? _currentTrackUrl;
  String? _currentTrackTitle;
  bool _isDisposed = false;
  Completer<void>? _initCompleter;

  /// Global reactive notifier for mute status (used by Mute/Unmute buttons across screens)
  final ValueNotifier<bool> isMutedNotifier = ValueNotifier<bool>(false);

  /// Global reactive notifier for current track title
  final ValueNotifier<String?> currentTrackNotifier = ValueNotifier<String?>(null);
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
      await _player?.setLoopMode(LoopMode.one);
      await _player?.setVolume(isMuted ? 0.0 : kDefaultBgmVolume);

      _player?.playerStateStream.listen((state) {
        isPlayingNotifier.value = state.playing &&
            state.processingState != ProcessingState.completed &&
            state.processingState != ProcessingState.idle;
      });
      _initCompleter?.complete();
    } catch (e) {
      debugPrint('⚠️ PocketGameAudioService init failed: $e');
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _player?.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (!isMutedNotifier.value && _currentTrackUrl != null) {
        _player?.play();
      }
    }
  }

  // =========================================================================
  // 🎼 CURATED HIGH-QUALITY ROYALTY-FREE GAME & REEL TRACKS (Kevin MacLeod / CC-BY)
  // Direct HTTPS audio streams with byte-range & CDN support
  // =========================================================================

  /// ⚔️ Battle & Attack Mode Tracks (Energetic, Arcade, Epic, Quirky)
  static const List<PocketMusicTrack> attackTracks = [
    PocketMusicTrack(
      id: 'atk_heroic_epic',
      title: 'Heroic Citadel Arena',
      genre: 'Epic Orchestral',
      url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Heroic%20Age.mp3',
      mood: 'epic',
    ),
    PocketMusicTrack(
      id: 'atk_clash_defiant',
      title: 'Fortress Clash Defiant',
      genre: 'Cinematic Battle Drums',
      url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Clash%20Defiant.mp3',
      mood: 'battle',
    ),
    PocketMusicTrack(
      id: 'atk_boss_rock',
      title: 'Grumpy Citadel Raid',
      genre: 'Volatile Boss Battle',
      url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Volatile%20Reaction.mp3',
      mood: 'battle',
    ),
    PocketMusicTrack(
      id: 'atk_pixelland_arcade',
      title: '8-Bit Retro Chiptune Blitz',
      genre: 'Chiptune Retro Arcade',
      url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Pixelland.mp3',
      mood: 'arcade',
    ),
  ];

  /// 🏡 Homes & Reels Mode Tracks (Happy, Cozy, Chill, Relaxing)
  static const List<PocketMusicTrack> homeTracks = [
    PocketMusicTrack(
      id: 'home_carefree',
      title: 'Sunny Homestead Ukulele',
      genre: 'Happy Acoustic',
      url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Carefree.mp3',
      mood: 'happy',
    ),
    PocketMusicTrack(
      id: 'home_life_of_riley',
      title: 'Valley of Champions',
      genre: 'Uplifting Whistle Folk',
      url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Life%20of%20Riley.mp3',
      mood: 'happy',
    ),
    PocketMusicTrack(
      id: 'home_builder',
      title: 'The Village Builder',
      genre: 'Cheerful Garden Acoustic',
      url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/The%20Builder.mp3',
      mood: 'happy',
    ),
    PocketMusicTrack(
      id: 'home_monkeys',
      title: 'Citadel Playful Waltz',
      genre: 'Funky Playful Pizzicato',
      url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Monkeys%20Spinning%20Monkeys.mp3',
      mood: 'happy',
    ),
    PocketMusicTrack(
      id: 'home_sneaky',
      title: 'Cottage Garden Mystery',
      genre: 'Sneaky Strings',
      url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Sneaky%20Snitch.mp3',
      mood: 'cozy',
    ),
    PocketMusicTrack(
      id: 'home_lounge',
      title: 'Twilight Fireside Lounge',
      genre: 'Chill Bossa Lofi',
      url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Airport%20Lounge.mp3',
      mood: 'cozy',
    ),
  ];

  /// 📸 Vibe Library Tracks (Used by Robots & Humans when sharing Vibes / Stories)
  static const List<PocketMusicTrack> vibeLibraryTracks = [
    PocketMusicTrack(
      id: 'vibe_sunny_hop',
      title: 'Sunny Morning Coffee ☕',
      genre: 'Upbeat Acoustic',
      url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Carefree.mp3',
      mood: 'happy',
    ),
    PocketMusicTrack(
      id: 'vibe_arcade_energy',
      title: 'Level Up Energy ⚡',
      genre: 'Arcade Pop',
      url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Pixelland.mp3',
      mood: 'arcade',
    ),
    PocketMusicTrack(
      id: 'vibe_focus_study',
      title: 'Deep Focus Library 📖',
      genre: 'Chill Study Beats',
      url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Airport%20Lounge.mp3',
      mood: 'cozy',
    ),
    PocketMusicTrack(
      id: 'vibe_acoustic_walk',
      title: 'Pocket Town Stroll 🌸',
      genre: 'Uplifting Folk',
      url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Life%20of%20Riley.mp3',
      mood: 'happy',
    ),
    PocketMusicTrack(
      id: 'vibe_epic_triumph',
      title: 'Citadel Victory Anthem 🏆',
      genre: 'Heroic Anthem',
      url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Heroic%20Age.mp3',
      mood: 'epic',
    ),
    PocketMusicTrack(
      id: 'vibe_playful_spin',
      title: 'Playful Story Vibe 🎭',
      genre: 'Joyful Play',
      url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Monkeys%20Spinning%20Monkeys.mp3',
      mood: 'happy',
    ),
  ];

  /// 🎯 Target Recon & Street Exploration Tracks (Strategic, Suspenseful, Adventurous)
  static const List<PocketMusicTrack> targetTracks = [
    PocketMusicTrack(
      id: 'target_recon_sneaky',
      title: 'Citadel Scout & Target Recon 🎯',
      genre: 'Strategic Mystery',
      url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Sneaky%20Snitch.mp3',
      mood: 'cozy',
    ),
    PocketMusicTrack(
      id: 'target_clash_drums',
      title: 'Scouting Strongholds ⚔️',
      genre: 'Cinematic Strategy Drums',
      url: 'https://incompetech.com/music/royalty-free/mp3-royaltyfree/Clash%20Defiant.mp3',
      mood: 'battle',
    ),
  ];

  // =========================================================================
  // 🎮 PLAYBACK CONTROLLERS
  // =========================================================================

  /// Selects the best attack track based on robot archetype, level, or president status
  static PocketMusicTrack getTrackForAttack({
    required String targetId,
    int targetDay = 1,
    String? archetypeId,
  }) {
    if (targetId == 'pocket_president' || targetId.startsWith('pres_')) {
      return attackTracks[0]; // Heroic Citadel Arena
    }

    final robot = PocketRobotService.getRobotById(targetId);
    final arcKey = archetypeId ?? robot?.archetype.name.toLowerCase() ?? '';

    if (arcKey.contains('grumpy')) {
      return attackTracks[2]; // Volatile Reaction (Grumpy Boss)
    } else if (arcKey.contains('intellectual') || arcKey.contains('trendsetter')) {
      return attackTracks[3]; // Pixelland (Chiptune Arcade)
    } else if (targetDay >= 30) {
      return attackTracks[0]; // Heroic Epic
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
      return vibeLibraryTracks[2]; // Deep Focus Library
    } else if (persona == 'work' || persona == 'professional') {
      return vibeLibraryTracks[0]; // Sunny Morning Coffee
    }
    final rand = math.Random();
    return vibeLibraryTracks[rand.nextInt(vibeLibraryTracks.length)];
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
    await playTrack(track);
  }

  /// 🏡 Start Playing Home Reels BGM
  Future<void> playHomeTheme(String houseId) async {
    final track = getTrackForHouse(houseId);
    await playTrack(track);
  }

  /// 🎯 Start Playing Target Mode / Street Recon BGM
  Future<void> playTargetTheme() async {
    final track = targetTracks[0];
    await playTrack(track);
  }

  /// Play any specific track with automatic headers and fallback
  Future<void> playTrack(PocketMusicTrack track) async {
    if (_isDisposed) return;
    await _ensureInitialized();

    if (_currentTrackUrl == track.url && (_player?.playing ?? false)) {
      return; // Already playing this track
    }

    try {
      _currentTrackUrl = track.url;
      _currentTrackTitle = track.title;
      currentTrackNotifier.value = track.title;

      if (_player == null) {
        _player = AudioPlayer();
        await _player?.setLoopMode(LoopMode.one);
      }

      final isMuted = isMutedNotifier.value;
      await _player?.setVolume(isMuted ? 0.0 : kDefaultBgmVolume);

      try {
        await _player?.setUrl(track.url);
      } catch (_) {
        await _player?.setUrl(
          track.url,
          headers: const {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': '*/*',
          },
        );
      }

      if (!isMuted) {
        await _player?.play();
      }
    } catch (e) {
      debugPrint('⚠️ Error playing track ${track.title}: $e');
      // Automatic fallback if the primary track fails
      if (track.url != homeTracks[0].url && track.url != attackTracks[0].url) {
        final fallback = (track.mood == 'epic' || track.mood == 'battle' || track.mood == 'arcade')
            ? attackTracks[0]
            : homeTracks[0];
        try {
          await _player?.setUrl(
            fallback.url,
            headers: const {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            },
          );
          if (!isMutedNotifier.value) {
            await _player?.play();
          }
        } catch (_) {}
      }
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
      if (_player != null && !(_player!.playing) && _currentTrackUrl != null) {
        await _player?.play();
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
            await _player?.play();
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error toggling mute: $e');
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
          valueListenable: PocketGameAudioService.instance.currentTrackNotifier,
          builder: (context, currentTrack, _) {
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                PocketGameAudioService.instance.toggleMute();
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
                        : const Color(0xFF38BDF8).withValues(alpha: 0.5),
                    width: 1,
                  ),
                  boxShadow: isMuted
                      ? []
                      : [
                          BoxShadow(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
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
                          : Icons.volume_up_rounded,
                      color: isMuted ? Colors.white54 : const Color(0xFF38BDF8),
                      size: compact ? 16 : 18,
                    ),
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
