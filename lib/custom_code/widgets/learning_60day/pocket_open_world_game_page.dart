import 'dart:async';
import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/pocket_robot_service.dart';
import '../avatar/vector_avatar_config.dart';
import '../avatar/vector_avatar_painter.dart';
import '../chat/whatsapp_group_chat.dart';
import '../english_learning_hub_page.dart';
import '../main_profile_widget.dart';
import '../voice_accent_coach_page.dart';
import 'flame_english_house_game.dart';
import 'pocket_citadel_attack_page.dart';
import 'pocket_daily_mission_page.dart';
import 'pocket_fortress_defense_service.dart';
import 'pocket_world_street_page.dart';
import 'pocket_world_vocabulary_bank.dart';

/// 🌍 Pocket Open World: Hill Climb Racing Style 2D Rolling-Hills Adventure
///
/// Upgraded Features:
/// 1. True Hill Climb Racing Flipping & Stunts:
///    - Throttle/Gas produces front wheelie lift; Brake produces nose dive.
///    - If chassis tilts past 85°, vehicle flips onto its roof with sparks!
///    - "🔄 RECOVER / FLIP" button rights the car on its wheels.
///    - Mid-air backflip / frontflip stunt detection (+10 pts bonus!).
/// 2. Spawning Directly At User's Own House:
///    - Player starts right outside their home driveway (Street $currentDay) marked "🏠 YOUR HOME".
/// 3. Direct Profile Navigation with ZERO Errors:
///    - Opens [MainProfileWidget] cleanly for both Supabase users and Pocket Robots.
/// 4. Roadside English Learning Billboards & Audio TTS:
///    - Electronic LED billboards every 600px with Words, Meanings, Poems, and Quotes.
///    - FlutterTTS pronounces English words and poems as you drive or tap!
///    - Floating "📚 English Tools" quick access drawer (Stories, Poems, Vocabulary).
/// 5. Majestic Ocean Suspension Bridges:
///    - The road crosses high over turquoise ocean waters between sectors with towering suspension towers, cables, sailboats, and leaping dolphins.
class PocketOpenWorldGamePage extends StatefulWidget {
  final int currentDay;
  final int streak;

  const PocketOpenWorldGamePage({
    super.key,
    required this.currentDay,
    required this.streak,
  });

  @override
  State<PocketOpenWorldGamePage> createState() => _PocketOpenWorldGamePageState();
}

class _PocketOpenWorldGamePageState extends State<PocketOpenWorldGamePage> {
  late PocketOpenWorldGame _game;
  bool _isLoadingNeighbors = true;
  PocketNeighbor? _proximityNeighbor;

  // Zoom control
  double _currentZoom = 0.82;

  // Multilingual Vocabulary Language Filter (Malayalam, Tamil, Hindi, Telugu, English)
  String _selectedLanguage = 'malayalam';
  OpenWorldVocabItem? _activeVocabCard;
  Timer? _vocabCardTimer;

  // Locomotion & Environment
  LocomotionMode _locomotion = LocomotionMode.buggy;
  bool _isNightMode = false;
  bool _isAudioMuted = false;

  // Driving pedal states (Hill Climb style Gas & Brake/Reverse)
  bool _isGasPressed = false;
  bool _isBrakePressed = false;

  final FocusNode _keyboardFocusNode = FocusNode();
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
    _initGame();
    _loadNeighbors();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.48);
      await _tts.setVolume(1.0);
    } catch (_) {}
  }

  Future<void> _speakEnglish(String text) async {
    if (_isAudioMuted) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    _tts.stop();
    _vocabCardTimer?.cancel();
    super.dispose();
  }

  void _triggerVocabFlashcard(OpenWorldVocabItem vocab) {
    _vocabCardTimer?.cancel();
    _speakEnglish('${vocab.word}. ${vocab.exampleEn}');
    if (mounted) {
      setState(() {
        _activeVocabCard = vocab;
      });
      _vocabCardTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _activeVocabCard = null;
          });
        }
      });
    }
  }

  void _showLanguageFilterDialog() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final langs = [
          {'code': 'malayalam', 'name': 'മലയാളം (Malayalam)', 'flag': '🌴', 'desc': 'മലയാളത്തിൽ അർത്ഥം കാണുക'},
          {'code': 'tamil', 'name': 'தமிழ் (Tamil)', 'flag': '🦚', 'desc': 'தமிழில் அர்த்தம் காண்க'},
          {'code': 'hindi', 'name': 'हिन्दी (Hindi)', 'flag': '🇮🇳', 'desc': 'हिन्दी में अर्थ देखें'},
          {'code': 'telugu', 'name': 'తెలుగు (Telugu)', 'flag': '🌺', 'desc': 'తెలుగులో అర్థం చూడండి'},
          {'code': 'english', 'name': 'English', 'flag': '🌐', 'desc': 'English definitions & examples'},
        ];

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFF38BDF8), width: 2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🌐 Vocabulary Language Filter',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...langs.map((l) {
                final isSelected = _selectedLanguage == l['code'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0284C7).withValues(alpha: 0.25) : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF38BDF8) : Colors.white12,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: Text(l['flag']!, style: const TextStyle(fontSize: 22)),
                    title: Text(
                      l['name']!,
                      style: GoogleFonts.outfit(
                        color: isSelected ? const Color(0xFFFFFC00) : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      l['desc']!,
                      style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: Color(0xFF38BDF8))
                        : null,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedLanguage = l['code']!;
                      });
                      _game.setLanguage(l['code']!);
                      Navigator.pop(ctx);
                    },
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _initGame() {
    _game = PocketOpenWorldGame(
      playerDay: widget.currentDay,
      playerStreak: widget.streak,
      initialZoom: _currentZoom,
      selectedLanguage: _selectedLanguage,
      onProximityChanged: (neighbor) {
        if (mounted && _proximityNeighbor != neighbor) {
          setState(() {
            _proximityNeighbor = neighbor;
          });
          if (neighbor != null) {
            HapticFeedback.lightImpact();
          }
        }
      },
      onProfileTap: (neighbor) {
        _showNeighborProfileCard(neighbor);
      },
      onVocabCollected: (vocab) {
        _triggerVocabFlashcard(vocab);
      },
      onBillboardRead: (board) {
        if (board.vocabItem != null) {
          _triggerVocabFlashcard(board.vocabItem!);
        } else {
          _speakEnglish('${board.title}. ${board.content}');
        }
      },
    );
  }

  Future<void> _loadNeighbors() async {
    try {
      final supaNeighbors = await PocketFortressDefenseService.fetchSupabaseNeighbors(limit: 50);
      final allRobots = PocketRobotService.getAll90Robots();

      final List<PocketNeighbor> robotNeighbors = allRobots.map((robot) {
        return PocketNeighbor(
          id: robot.id,
          name: robot.name,
          day: robot.level,
          streak: (robot.level * 1.4).round().clamp(1, 120),
          rank: robot.cefrRank,
          paletteId: robot.housePalette,
          statusMessage: robot.bio,
          isPocketRobo: true,
          hasActiveShield: true,
          isDamaged: false,
          hp: 100,
          maxHp: 100,
        );
      }).toList();

      final dynamicTargets = PocketFortressDefenseService.generateDynamicTargetBracketHomes(
        widget.currentDay,
        count: 14,
      );

      final Map<String, PocketNeighbor> combinedMap = {};
      for (final r in robotNeighbors) {
        combinedMap[r.id] = r;
      }
      for (final d in dynamicTargets) {
        combinedMap[d.id] = d;
      }
      for (final s in supaNeighbors) {
        combinedMap[s.id] = s;
      }

      final combined = combinedMap.values.toList()..sort((a, b) => a.day.compareTo(b.day));

      if (mounted) {
        setState(() {
          _isLoadingNeighbors = false;
        });
        _game.setNeighbors(combined);
      }
    } catch (e) {
      debugPrint('OpenWorld load error: $e');
      if (mounted) {
        final allRobots = PocketRobotService.getAll90Robots();
        final fallback = allRobots.map((robot) {
          return PocketNeighbor(
            id: robot.id,
            name: robot.name,
            day: robot.level,
            streak: (robot.level * 1.4).round(),
            rank: robot.cefrRank,
            paletteId: robot.housePalette,
            statusMessage: robot.bio,
            isPocketRobo: true,
            hasActiveShield: true,
            isDamaged: false,
          );
        }).toList();

        setState(() {
          _isLoadingNeighbors = false;
        });
        _game.setNeighbors(fallback);
      }
    }
  }

  void _triggerJump() {
    HapticFeedback.mediumImpact();
    _game.playerJump();
  }

  void _setZoom(double zoom) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentZoom = zoom.clamp(0.20, 1.25);
    });
    _game.setZoom(_currentZoom);
  }

  void _toggleDayNight() {
    HapticFeedback.lightImpact();
    setState(() {
      _isNightMode = !_isNightMode;
    });
    _game.setDayNight(_isNightMode);
  }

  void _toggleAudio() {
    HapticFeedback.selectionClick();
    setState(() {
      _isAudioMuted = !_isAudioMuted;
    });
    if (_isAudioMuted) {
      _tts.stop();
    }
  }

  void _setLocomotion(LocomotionMode mode) {
    HapticFeedback.selectionClick();
    setState(() {
      _locomotion = mode;
    });
    _game.setLocomotionMode(mode);
  }

  /// 📇 Interactive Neighbor Profile Card Modal Bottom Sheet
  /// Clicking "View Profile" opens [MainProfileWidget] directly with zero UUID errors!
  void _showNeighborProfileCard(PocketNeighbor neighbor) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: neighbor.hasActiveShield ? const Color(0xFF38BDF8) : const Color(0xFFFFFC00),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 28,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1E293B),
                      border: Border.all(
                        color: neighbor.hasActiveShield ? const Color(0xFF38BDF8) : const Color(0xFFFFFC00),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (neighbor.hasActiveShield ? const Color(0xFF38BDF8) : const Color(0xFFFFFC00))
                              .withValues(alpha: 0.35),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CustomPaint(
                      painter: VectorAvatarPainter(
                        config: VectorAvatarConfig.getEvolutionAvatarForStage(neighbor.day),
                        showBackgroundAura: false,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (neighbor.isPocketRobo) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00F0FF).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF00F0FF), width: 0.8),
                                ),
                                child: const Text(
                                  'ROBOT',
                                  style: TextStyle(
                                    color: Color(0xFF00F0FF),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Street ${neighbor.day} • Level ${neighbor.day} • ${neighbor.rank}',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFFC00),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '🔥 ${neighbor.streak} Day Streak • ${neighbor.hasActiveShield ? "🛡️ Shield Active" : "🔓 Raid Open"}',
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (neighbor.statusMessage.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text(
                    '"${neighbor.statusMessage}"',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // Action Buttons: View Profile (Direct MainProfileWidget) | Direct Chat
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        final isUuid = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(neighbor.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainProfileWidget(
                              userId: isUuid ? neighbor.id : null,
                              preloadedProfile: {
                                'user_id': neighbor.id,
                                'first_name': neighbor.name,
                                'bio': neighbor.statusMessage,
                                'learning_day': neighbor.day,
                                'streak': neighbor.streak,
                                'rank': neighbor.rank,
                                'palette_id': neighbor.paletteId,
                                'is_pocket_robo': neighbor.isPocketRobo,
                              },
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_rounded, size: 16),
                      label: const Text('View Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _openChat(neighbor);
                      },
                      icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                      label: const Text('Direct Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _requestMate(neighbor);
                      },
                      icon: const Text('🤝', style: TextStyle(fontSize: 14)),
                      label: const Text('Mate Request'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF818CF8),
                        side: const BorderSide(color: Color(0xFF6366F1), width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _launchRaid(neighbor);
                      },
                      icon: const Text('⚔️', style: TextStyle(fontSize: 14)),
                      label: const Text('Raid Citadel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _openChat(PocketNeighbor neighbor) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WhatsAppGroupChat(
          groupId: neighbor.id,
          groupName: neighbor.name,
          groupImage: null,
        ),
      ),
    );
  }

  void _requestMate(PocketNeighbor neighbor) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🤝', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Learning Mate Request Sent!',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Invited ${neighbor.name} (Lvl ${neighbor.day}) to practice English daily.',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F766E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _launchRaid(PocketNeighbor neighbor) {
    HapticFeedback.heavyImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PocketCitadelAttackPage(
          neighbor: neighbor,
          attackerDay: widget.currentDay,
          attackerStreak: widget.streak,
        ),
      ),
    ).then((won) {
      if (won == true) {
        _loadNeighbors();
      }
    });
  }

  /// 📚 Opens English Learning Tools modal (Stories, Poems, Vocabulary)
  void _openEnglishToolsModal() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: Color(0xFF38BDF8), width: 2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '📚 English Highway Studio',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Tool Shortcuts
              Row(
                children: [
                  Expanded(
                    child: _buildToolShortcut(
                      icon: '🎙️',
                      label: 'Accent Coach',
                      color: const Color(0xFF6366F1),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceAccentCoachPage()));
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildToolShortcut(
                      icon: '🏛️',
                      label: 'Learning Hub',
                      color: const Color(0xFF0284C7),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const EnglishLearningHubPage()));
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildToolShortcut(
                      icon: '🎯',
                      label: 'Day Mission',
                      color: const Color(0xFF10B981),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PocketDailyMissionPage(
                              day: widget.currentDay,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Text(
                '📜 Micro-Poems & Stories on Road',
                style: GoogleFonts.outfit(color: const Color(0xFFFFFC00), fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: ListView(
                  children: [
                    _buildPoemCard(
                      title: 'The Road Not Taken',
                      poet: 'Robert Frost',
                      snippet: 'Two roads diverged in a yellow wood, and I took the one less traveled by.',
                    ),
                    _buildPoemCard(
                      title: 'Hope is the Thing with Feathers',
                      poet: 'Emily Dickinson',
                      snippet: 'Hope is the thing with feathers that perches in the soul, and sings the tune without words.',
                    ),
                    _buildPoemCard(
                      title: 'The Secret of Speed',
                      poet: 'English Wisdom',
                      snippet: 'Step by step, hill by hill, fluency is born through daily will.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolShortcut({
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color, width: 1.2),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPoemCard({
    required String title,
    required String poet,
    required String snippet,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8), size: 22),
            onPressed: () => _speakEnglish('$title by $poet. $snippet'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                Text(poet, style: GoogleFonts.outfit(color: const Color(0xFFFFFC00), fontSize: 10.5)),
                const SizedBox(height: 4),
                Text('"$snippet"', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateDrivingInput() {
    double dx = 0.0;
    if (_isGasPressed) dx += 1.0;
    if (_isBrakePressed) dx -= 1.0;
    _game.setHorizontalInput(dx, false);
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.keyD) {
            _isGasPressed = true;
            _updateDrivingInput();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.keyA) {
            _isBrakePressed = true;
            _updateDrivingInput();
          } else if (event.logicalKey == LogicalKeyboardKey.space || event.logicalKey == LogicalKeyboardKey.arrowUp) {
            _triggerJump();
          }
        } else if (event is KeyUpEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.keyD) {
            _isGasPressed = false;
            _updateDrivingInput();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.keyA) {
            _isBrakePressed = false;
            _updateDrivingInput();
          }
        }
      },
      child: Scaffold(
        backgroundColor: _isNightMode ? const Color(0xFF030712) : const Color(0xFF0284C7),
        body: GestureDetector(
          onScaleUpdate: (details) {
            if (details.scale != 1.0) {
              final newZoom = (_currentZoom * details.scale).clamp(0.20, 1.25);
              _setZoom(newZoom);
            }
          },
          child: Stack(
            children: [
              // 1. Full-Screen Flame Canvas with Tap Listener for House Cards
              GestureDetector(
                onTapUp: (details) {
                  _game.handleTapAt(details.localPosition);
                },
                child: GameWidget(game: _game),
              ),

              // 2. Ultra-Minimal Top Navigation Bar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      // Exit Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 1),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 14),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Street Location Pill
                      Expanded(
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.3), width: 1),
                          ),
                          child: Row(
                            children: [
                              const Text('🛣️', style: TextStyle(fontSize: 13)),
                              const SizedBox(width: 5),
                              Expanded(
                                child: ValueListenableBuilder<String>(
                                  valueListenable: _game.districtNotifier,
                                  builder: (context, district, _) {
                                    return Text(
                                      district,
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFFFFFC00),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  },
                                ),
                              ),
                              if (_isLoadingNeighbors) ...[
                                const SizedBox(width: 5),
                                const SizedBox(
                                  width: 9,
                                  height: 9,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFFC00)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      // 🟡 Coins Collected Pill
                      Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 9),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.5), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🟡', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            ValueListenableBuilder<int>(
                              valueListenable: _game.coinsCollectedNotifier,
                              builder: (context, coins, _) {
                                return Text(
                                  '$coins',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFFFC00),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 6),

                      // ⚡ Speedometer Pill
                      Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🏎️', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 3),
                            ValueListenableBuilder<double>(
                              valueListenable: _game.speedNotifier,
                              builder: (context, speed, _) {
                                return Text(
                                  '${speed.toStringAsFixed(0)}m',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF38BDF8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 6),

                      // 📚 English Studio Button
                      GestureDetector(
                        onTap: _openEnglishToolsModal,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF38BDF8), width: 1.2),
                          ),
                          child: const Center(
                            child: Text('📚', style: TextStyle(fontSize: 14)),
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      // 🌐 Language Filter Pill [ 🌴 ML ]
                      GestureDetector(
                        onTap: _showLanguageFilterDialog,
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFF38BDF8), width: 1.2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(OpenWorldVocabItem.getLanguageFlag(_selectedLanguage), style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 3),
                              Text(
                                OpenWorldVocabItem.getLanguageShortCode(_selectedLanguage),
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF38BDF8), size: 14),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      // 🔊 Audio TTS Mute / Unmute Toggle
                      GestureDetector(
                        onTap: _toggleAudio,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _isAudioMuted ? Colors.red.withValues(alpha: 0.7) : const Color(0xFF0F172A),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 1),
                          ),
                          child: Center(
                            child: Text(_isAudioMuted ? '🔇' : '🔊', style: const TextStyle(fontSize: 13)),
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      // Day / Night Mini Toggle
                      GestureDetector(
                        onTap: _toggleDayNight,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _isNightMode ? const Color(0xFF1E1B4B) : const Color(0xFFFEF08A),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isNightMode ? const Color(0xFF818CF8) : const Color(0xFFF59E0B),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(_isNightMode ? '🌙' : '☀️', style: const TextStyle(fontSize: 14)),
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      // Minimal Locomotion Selector [ 🚶 | 🚲 | 🏎️ ]
                      Container(
                        height: 36,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildMiniVehicleButton('🚶', _locomotion == LocomotionMode.walk, () => _setLocomotion(LocomotionMode.walk)),
                            _buildMiniVehicleButton('🚲', _locomotion == LocomotionMode.bike, () => _setLocomotion(LocomotionMode.bike)),
                            _buildMiniVehicleButton('🏎️', _locomotion == LocomotionMode.buggy, () => _setLocomotion(LocomotionMode.buggy)),
                          ],
                        ),
                      ),

                      const SizedBox(width: 6),

                      // Minimal Zoom Toggle [ 🔍 | 🌍 ]
                      Container(
                        height: 36,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.4), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildMiniZoomButton('🔍', _currentZoom >= 0.50, () => _setZoom(0.82)),
                            _buildMiniZoomButton('🌍', _currentZoom < 0.50, () => _setZoom(0.22)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2.5 Floating Interactive Vocabulary Flashcard HUD
              if (_activeVocabCard != null)
                Positioned(
                  top: 56,
                  left: 14,
                  right: 14,
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 460),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
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
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF38BDF8), width: 0.8),
                                ),
                                child: Text(
                                  '📘 ${_activeVocabCard!.category} • ${_activeVocabCard!.partOfSpeech}',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF38BDF8),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _activeVocabCard!.word,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                _activeVocabCard!.phonetics,
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFFFC00),
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => _speakEnglish('${_activeVocabCard!.word}. ${_activeVocabCard!.exampleEn}'),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8), size: 16),
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  setState(() => _activeVocabCard = null);
                                },
                                child: const Icon(Icons.close_rounded, color: Colors.white60, size: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  OpenWorldVocabItem.getLanguageFlag(_selectedLanguage),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _activeVocabCard!.getMeaning(_selectedLanguage),
                                    style: const TextStyle(
                                      color: Color(0xFFFFFC00),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '"${_activeVocabCard!.exampleEn}"',
                            style: GoogleFonts.outfit(
                              color: Colors.white70,
                              fontSize: 10.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 3. Proximity Action Pill (Appears above the Road when standing near a House Gate)
              if (_proximityNeighbor != null)
                Positioned(
                  top: 60,
                  left: 20,
                  right: 20,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _proximityNeighbor!.hasActiveShield ? const Color(0xFF38BDF8) : const Color(0xFFFFFC00),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => _showNeighborProfileCard(_proximityNeighbor!),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${_proximityNeighbor!.name} (Lvl ${_proximityNeighbor!.day})',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.info_outline_rounded, color: Color(0xFFFFFC00), size: 14),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildActionIcon(
                            icon: Icons.chat_bubble_rounded,
                            color: const Color(0xFF25D366),
                            tooltip: 'Chat',
                            onTap: () => _openChat(_proximityNeighbor!),
                          ),
                          const SizedBox(width: 6),
                          _buildActionIcon(
                            label: '🤝',
                            color: const Color(0xFF6366F1),
                            tooltip: 'Mate',
                            onTap: () => _requestMate(_proximityNeighbor!),
                          ),
                          const SizedBox(width: 6),
                          _buildActionIcon(
                            label: '⚔️',
                            color: const Color(0xFFFF2A55),
                            tooltip: 'Raid',
                            onTap: () => _launchRaid(_proximityNeighbor!),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 4. 🔄 CAR FLIP / RECOVER BUTTON (Hill Climb Racing Crash Recovery)
              ValueListenableBuilder<bool>(
                valueListenable: _game.isCrashedNotifier,
                builder: (context, isCrashed, _) {
                  if (!isCrashed) return const SizedBox.shrink();
                  return Positioned(
                    bottom: 118,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          _game.recoverFromCrash();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEF4444), Color(0xFFF97316)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.redAccent.withValues(alpha: 0.6),
                                blurRadius: 18,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔄', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(
                                'FLIP / RECOVER',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
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

              // 5. Hill Climb Racing Driving Pedals (Bottom HUD)
              // Left: BRAKE / REVERSE Pedal (◀️ REV) using raw Listener
              Positioned(
                bottom: 24,
                left: 20,
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (_) {
                    setState(() => _isBrakePressed = true);
                    _updateDrivingInput();
                  },
                  onPointerUp: (_) {
                    setState(() => _isBrakePressed = false);
                    _updateDrivingInput();
                  },
                  onPointerCancel: (_) {
                    setState(() => _isBrakePressed = false);
                    _updateDrivingInput();
                  },
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        colors: _isBrakePressed
                            ? [const Color(0xFFDC2626), const Color(0xFF991B1B)]
                            : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      border: Border.all(
                        color: _isBrakePressed ? Colors.redAccent : Colors.white24,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 26),
                        Text(
                          'BRAKE / REV',
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Right: GAS / ACCEL Pedal (▶️ GAS) & JUMP Button (🦘 JUMP)
              Positioned(
                bottom: 24,
                right: 20,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🦘 JUMP BUTTON
                    GestureDetector(
                      onTap: _triggerJump,
                      child: Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0284C7).withValues(alpha: 0.85),
                          border: Border.all(color: const Color(0xFF38BDF8), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🦘', style: TextStyle(fontSize: 18)),
                              Text(
                                'JUMP',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // ▶️ GAS / ACCELERATE PEDAL (Hill Climb Racing Style)
                    Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (_) {
                        setState(() => _isGasPressed = true);
                        _updateDrivingInput();
                      },
                      onPointerUp: (_) {
                        setState(() => _isGasPressed = false);
                        _updateDrivingInput();
                      },
                      onPointerCancel: (_) {
                        setState(() => _isGasPressed = false);
                        _updateDrivingInput();
                      },
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            colors: _isGasPressed
                                ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                : [const Color(0xFFFFFC00), const Color(0xFFF59E0B)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFFC00).withValues(alpha: 0.5),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.speed_rounded, color: Colors.black, size: 28),
                            Text(
                              'GAS / GO',
                              style: GoogleFonts.outfit(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniVehicleButton(String icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFFC00) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(icon, style: const TextStyle(fontSize: 14)),
        ),
      ),
    );
  }

  Widget _buildMiniZoomButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00F0FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
      ),
    );
  }

  Widget _buildActionIcon({
    IconData? icon,
    String? label,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: Colors.white, size: 14)
              : Text(label!, style: const TextStyle(fontSize: 13)),
        ),
      ),
    );
  }
}

enum LocomotionMode { walk, bike, buggy }

/// 🎮 Flame Game Engine Implementation with Hill Climb Racing Physics, Stunts, Bridges, & English Learning
class PocketOpenWorldGame extends FlameGame {
  final int playerDay;
  final int playerStreak;
  final ValueChanged<PocketNeighbor?> onProximityChanged;
  final ValueChanged<PocketNeighbor> onProfileTap;
  final void Function(String word, String meaning)? onWordCollected;
  final void Function(OpenWorldVocabItem vocab)? onVocabCollected;
  final void Function(RoadsideLearningBoard board)? onBillboardRead;
  double initialZoom;
  String selectedLanguage;

  PocketOpenWorldGame({
    required this.playerDay,
    required this.playerStreak,
    required this.onProximityChanged,
    required this.onProfileTap,
    this.onWordCollected,
    this.onVocabCollected,
    this.onBillboardRead,
    this.initialZoom = 0.82,
    this.selectedLanguage = 'malayalam',
  });

  // World Bounds
  double worldWidth = 55000.0;
  final double worldHeight = 1700.0;
  final double groundBaseY = 960.0;

  // Camera & Zoom
  double zoomScale = 0.82;
  double cameraX = 200.0;
  double cameraY = 600.0;

  // Player Physics & Hill Climb Racing Tipping dynamics
  double playerX = 240.0;
  double playerY = 960.0;
  double playerZ = 0.0;
  double vx = 0.0;
  double vy = 0.0;
  double jumpVelocity = 0.0;
  bool isJumping = false;
  double airTime = 0.0;
  double playerFacing = 1.0;
  bool isMoving = false;
  double runCycle = 0.0;
  double bikeWheelAngle = 0.0;
  double carWheelAngle = 0.0;

  // Chassis tilt & rotational angular velocity for genuine Hill Climb Racing flips
  double chassisTilt = 0.0;
  double angularVelocity = 0.0;
  double suspensionOffset = 0.0;
  double inputDx = 0.0;
  double airRotationProgress = 0.0;

  // Crash State
  bool isCrashed = false;
  final ValueNotifier<bool> isCrashedNotifier = ValueNotifier<bool>(false);

  // Environment & Modes
  bool isNight = false;
  LocomotionMode locomotion = LocomotionMode.buggy;
  double gameTime = 0.0;

  // District name & stats notifiers
  final ValueNotifier<String> districtNotifier = ValueNotifier('🛣️ Street 1 • Rookie Way');
  final ValueNotifier<int> coinsCollectedNotifier = ValueNotifier<int>(0);
  final ValueNotifier<double> speedNotifier = ValueNotifier<double>(0.0);
  String currentDistrictName = '🛣️ Street 1 • Rookie Way';

  // House nodes on the hill
  final List<WorldHouseNode> houseNodes = [];

  // Collectibles: Coins, English Learning Elements, & Roadside Billboards
  final List<WorldCoin> coins = [];
  final List<EnglishWordOrb> englishOrbs = [];
  final List<EnglishSpeedGate> speedGates = [];
  final List<RoadsideLearningBoard> roadsideBoards = [];
  final List<WorldJumpRamp> jumpRamps = [];

  // Roaming NPCs
  List<RoamingRobotNpc> robotNpcs = [];

  // Cruising Boats & Leaping Dolphins on the ocean
  List<CruisingBoat> riverBoats = [];
  List<FlyingBird> seagulls = [];

  // Particles & Floating Text FX
  final List<JumpDustParticle> particles = [];
  final List<FloatingTextEffect> floatingTexts = [];

  // Player Avatar Config & Painter
  late final VectorAvatarPainter playerAvatarPainter;

  @override
  Color backgroundColor() => isNight ? const Color(0xFF030712) : const Color(0xFF0284C7);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    zoomScale = initialZoom;
    playerY = getGroundY(playerX);

    playerAvatarPainter = VectorAvatarPainter(
      config: VectorAvatarConfig.getEvolutionAvatarForStage(playerDay),
      showBackgroundAura: false,
    );

    _spawnRoamingRobots();
    _spawnRiverBoatsAndSeagulls();
    _generateCoins();
    _generateEnglishLearningElements();
    _generateRoadsideBoards();
    _generateJumpRamps();
  }

  void setLanguage(String lang) {
    selectedLanguage = lang;
  }

  void setZoom(double newZoom) {
    zoomScale = newZoom;
  }

  void setDayNight(bool night) {
    isNight = night;
    for (final node in houseNodes) {
      node.houseMaster.lightsOn = isNight || node.neighbor.day >= 20;
    }
  }

  void setLocomotionMode(LocomotionMode mode) {
    locomotion = mode;
  }

  /// 🌊 Check if coordinate is crossing an ocean suspension bridge
  bool isOceanBridge(double x) {
    return (x >= 6200.0 && x <= 7600.0) || (x >= 18200.0 && x <= 19800.0) || (x >= 36200.0 && x <= 38000.0);
  }

  /// ⛰️ Rolling Hills & Ocean Suspension Bridges Spline
  double getGroundY(double x) {
    // 1. Ocean Suspension Bridge 1 (Streets 10 to 12)
    if (x >= 6200.0 && x <= 7600.0) {
      final progress = (x - 6200.0) / 1400.0;
      final arch = math.sin(progress * math.pi) * 32.0;
      return groundBaseY - 25.0 - arch;
    }
    // 2. Ocean Suspension Bridge 2 (Streets 30 to 32)
    if (x >= 18200.0 && x <= 19800.0) {
      final progress = (x - 18200.0) / 1600.0;
      final arch = math.sin(progress * math.pi) * 38.0;
      return groundBaseY - 25.0 - arch;
    }
    // 3. Ocean Suspension Bridge 3 (Streets 60 to 62)
    if (x >= 36200.0 && x <= 38000.0) {
      final progress = (x - 36200.0) / 1800.0;
      final arch = math.sin(progress * math.pi) * 42.0;
      return groundBaseY - 25.0 - arch;
    }

    // Rolling Hills elsewhere
    final wave1 = math.sin(x * 0.0024) * 55.0;
    final wave2 = math.sin(x * 0.0012 + 1.2) * 95.0;
    final wave3 = math.sin(x * 0.0006) * 120.0;
    return groundBaseY - wave1 - wave2 - wave3;
  }

  /// Returns the slope angle of the terrain at position x
  double getGroundSlope(double x) {
    const delta = 15.0;
    final y1 = getGroundY(x - delta);
    final y2 = getGroundY(x + delta);
    return math.atan2(y2 - y1, delta * 2);
  }

  /// 🏡 Distribute all houses with ZERO overlaps and spawn player at their own home!
  void setNeighbors(List<PocketNeighbor> list) {
    houseNodes.clear();

    final Map<int, int> housesPerLevel = {};
    for (final n in list) {
      housesPerLevel[n.day] = (housesPerLevel[n.day] ?? 0) + 1;
    }

    const minGap = 440.0;
    double currentX = 350.0;
    final Map<int, int> currentLevelIndex = {};
    double playerHomeSpawnX = 450.0;

    for (int i = 0; i < list.length; i++) {
      final neighbor = list[i];
      final lvl = neighbor.day.clamp(1, 90);
      final idxInLevel = (currentLevelIndex[lvl] ?? 0) + 1;
      currentLevelIndex[lvl] = idxInLevel;

      final progressRatio = (lvl - 1) / 89.0;
      double targetX = 350.0 + (progressRatio * 46000.0) + ((idxInLevel - 1) * minGap);

      // Avoid placing house directly in the middle of ocean bridges
      if (targetX >= 6100 && targetX <= 7700) targetX = 7780;
      if (targetX >= 18100 && targetX <= 19900) targetX = 19980;
      if (targetX >= 36100 && targetX <= 38100) targetX = 38180;

      final x = math.max(currentX, targetX);
      final y = getGroundY(x);
      currentX = x + minGap;

      int sectorIndex = 0;
      if (lvl > 60) {
        sectorIndex = 3;
      } else if (lvl > 30) {
        sectorIndex = 2;
      } else if (lvl > 10) {
        sectorIndex = 1;
      }

      final totalInLvl = housesPerLevel[lvl] ?? 1;
      final bool isMyOwnHome = lvl == playerDay && idxInLevel == 1;
      final streetLabel = isMyOwnHome
          ? '🏠 YOUR HOME • Street $lvl'
          : (totalInLvl > 1 ? 'STREET $lvl • #$idxInLevel' : 'STREET $lvl');

      if (isMyOwnHome) {
        playerHomeSpawnX = x;
      }

      houseNodes.add(
        WorldHouseNode(
          neighbor: neighbor,
          x: x,
          y: y,
          sectorIndex: sectorIndex,
          streetSignLabel: streetLabel,
          isPlayerHome: isMyOwnHome,
          isNight: isNight,
        ),
      );
    }

    worldWidth = math.max(55000.0, currentX + 2000.0);

    // 🚀 SPAWN PLAYER DIRECTLY AT THEIR OWN HOME DRIVEWAY!
    playerX = playerHomeSpawnX;
    playerY = getGroundY(playerX);
    cameraX = (playerX - (size.x / zoomScale / 2)).clamp(0.0, worldWidth);

    _generateCoins();
    _generateEnglishLearningElements();
    _generateRoadsideBoards();
  }

  /// 🟡 Generate 300+ Golden Coins along the Highway
  void _generateCoins() {
    coins.clear();
    for (double x = 450.0; x < worldWidth - 600.0; x += 190.0) {
      final nearHouse = houseNodes.any((h) => (h.x - x).abs() < 85);
      if (nearHouse) continue;

      final groupType = ((x / 190).floor()) % 3;
      if (groupType == 0) {
        for (int c = 0; c < 3; c++) {
          final cx = x + (c * 36.0);
          final groundY = getGroundY(cx);
          final arcHeight = 26.0 + math.sin((c / 2.0) * math.pi) * 24.0;
          coins.add(WorldCoin(x: cx, y: groundY - arcHeight, spinPhase: c * 0.4));
        }
      } else if (groupType == 1) {
        final groundY = getGroundY(x);
        coins.add(WorldCoin(x: x, y: groundY - 24.0));
      }
    }
  }

  /// 📘 Generate English Vocabulary Orbs & Nitro Speed Gates
  void _generateEnglishLearningElements() {
    englishOrbs.clear();
    speedGates.clear();

    for (int i = 0; i < kOpenWorldVocabBank.length; i++) {
      final x = 1100.0 + (i * 1550.0);
      if (x < worldWidth - 800) {
        final nearHouse = houseNodes.any((h) => (h.x - x).abs() < 90);
        final orbX = nearHouse ? x + 120.0 : x;
        final groundY = getGroundY(orbX);
        englishOrbs.add(
          EnglishWordOrb(
            x: orbX,
            y: groundY - 38.0,
            vocabItem: kOpenWorldVocabBank[i],
          ),
        );
      }
    }

    final idioms = [
      ('BREAK A LEG! 🎭', 'Good luck on your English speech!'),
      ('PIECE OF CAKE! 🍰', 'Simple and effortless English!'),
      ('HIT THE ROAD! 🛣️', 'Accelerate down the open highway!'),
      ('SKY IS THE LIMIT! 🌌', 'No boundaries to your potential!'),
      ('BITE THE BULLET ⚡', 'Face the next lesson with confidence!'),
      ('UNDER THE WEATHER 🌧️', 'Recover fast and keep learning!'),
      ('CALL IT A DAY 🏁', 'Finish today with high honors!'),
    ];

    for (int i = 0; i < idioms.length; i++) {
      final x = 2400.0 + (i * 7200.0);
      if (x < worldWidth - 800) {
        final y = getGroundY(x);
        speedGates.add(
          EnglishSpeedGate(
            x: x,
            y: y,
            idiom: idioms[i].$1,
            meaning: idioms[i].$2,
          ),
        );
      }
    }
  }

  /// 📜 Generate Roadside Electronic Billboards with Poems, Quotes, & Multilingual Vocabulary
  void _generateRoadsideBoards() {
    roadsideBoards.clear();

    int vocabIndex = 0;
    for (double bx = 950.0; bx < worldWidth - 1000.0; bx += 2100.0) {
      final isPoemOrQuote = ((bx / 2100).floor()) % 3;
      final y = getGroundY(bx);

      if (isPoemOrQuote == 1) {
        roadsideBoards.add(
          RoadsideLearningBoard(
            x: bx,
            y: y,
            category: 'POEM',
            title: 'The Road Not Taken',
            content: 'Two roads diverged in a yellow wood...',
            subtext: '— Robert Frost',
          ),
        );
      } else if (isPoemOrQuote == 2) {
        roadsideBoards.add(
          RoadsideLearningBoard(
            x: bx,
            y: y,
            category: 'QUOTE',
            title: 'Continuous Mastery',
            content: 'The journey of a thousand miles begins with a single step.',
            subtext: '— Lao Tzu',
          ),
        );
      } else {
        final vocab = kOpenWorldVocabBank[vocabIndex % kOpenWorldVocabBank.length];
        vocabIndex++;
        roadsideBoards.add(
          RoadsideLearningBoard(
            x: bx,
            y: y,
            category: 'VOCAB',
            title: vocab.word,
            content: vocab.meaningEn,
            subtext: '${vocab.phonetics} • "${vocab.exampleEn}"',
            vocabItem: vocab,
          ),
        );
      }
    }
  }

  /// 🚀 Generate Strategic Jump Ramps along the Highway and Bridges
  void _generateJumpRamps() {
    jumpRamps.clear();
    final rampPositions = [5800.0, 12200.0, 17800.0, 27500.0, 35800.0];
    for (final rx in rampPositions) {
      if (rx < worldWidth - 600) {
        final ry = getGroundY(rx);
        final slope = getGroundSlope(rx);
        jumpRamps.add(WorldJumpRamp(x: rx, y: ry, angle: slope));
      }
    }
  }

  void _spawnRoamingRobots() {
    robotNpcs = [
      RoamingRobotNpc(
        id: 'robo_01',
        name: 'Pocket Robo #01',
        x: 600,
        y: getGroundY(600),
        patrolMinX: 350,
        patrolMaxX: 900,
        speechText: 'Welcome to your Open World! 🌟',
      ),
      RoamingRobotNpc(
        id: 'robo_valk',
        name: 'Cyber Valkyrie',
        x: 2400,
        y: getGroundY(2400),
        patrolMinX: 1800,
        patrolMaxX: 2900,
        speechText: 'Climb the hills to reach Level 30! ⚡',
      ),
      RoamingRobotNpc(
        id: 'robo_titan',
        name: 'Iron Titan (Lvl 60)',
        x: 8500,
        y: getGroundY(8500),
        patrolMinX: 7800,
        patrolMaxX: 9200,
        speechText: 'Approaching Grandmaster territory! 🛡️',
      ),
      RoamingRobotNpc(
        id: 'robo_prime',
        name: 'Overlord Prime (Lvl 90)',
        x: 18500,
        y: getGroundY(18500),
        patrolMinX: 17500,
        patrolMaxX: 19500,
        speechText: 'The Apex Sovereign Citadel awaits! 👑',
      ),
    ];
  }

  void _spawnRiverBoatsAndSeagulls() {
    riverBoats = [
      CruisingBoat(x: 800, y: groundBaseY + 230, speed: 36, boatType: CruisingBoatType.kettuvallam),
      CruisingBoat(x: 3200, y: groundBaseY + 260, speed: 68, boatType: CruisingBoatType.speedboat),
      CruisingBoat(x: 6600, y: groundBaseY + 245, speed: 28, boatType: CruisingBoatType.cruiseShip),
      CruisingBoat(x: 7400, y: groundBaseY + 235, speed: 42, boatType: CruisingBoatType.sailboat),
      CruisingBoat(x: 11400, y: groundBaseY + 250, speed: 34, boatType: CruisingBoatType.kettuvallam),
      CruisingBoat(x: 18400, y: groundBaseY + 242, speed: 30, boatType: CruisingBoatType.cruiseShip),
      CruisingBoat(x: 19300, y: groundBaseY + 265, speed: 72, boatType: CruisingBoatType.speedboat),
      CruisingBoat(x: 36500, y: groundBaseY + 244, speed: 29, boatType: CruisingBoatType.cruiseShip),
      CruisingBoat(x: 37400, y: groundBaseY + 236, speed: 38, boatType: CruisingBoatType.kettuvallam),
    ];

    seagulls = [
      FlyingBird(x: 400, y: 180, speed: 40),
      FlyingBird(x: 2200, y: 150, speed: 52),
      FlyingBird(x: 4800, y: 210, speed: 35),
      FlyingBird(x: 9500, y: 170, speed: 48),
      FlyingBird(x: 15500, y: 190, speed: 42),
    ];
  }

  void setHorizontalInput(double dx, bool sprint) {
    inputDx = dx;
    isMoving = dx.abs() > 0.08;
    if (dx.abs() > 0.08 && !isCrashed) {
      playerFacing = dx > 0 ? 1.0 : -1.0;
    }
  }

  /// 🦘 Smooth arcade jump with momentum carryover
  void playerJump() {
    if (!isJumping && !isCrashed) {
      isJumping = true;
      airTime = 0.0;
      airRotationProgress = 0.0;
      jumpVelocity = locomotion == LocomotionMode.buggy ? 16.0 : (locomotion == LocomotionMode.bike ? 15.0 : 13.0);

      final groundY = getGroundY(playerX);
      for (int i = 0; i < 8; i++) {
        final angle = (i / 8) * math.pi * 2;
        particles.add(
          JumpDustParticle(
            x: playerX,
            y: groundY,
            vx: math.cos(angle) * 45,
            vy: math.sin(angle) * 22,
          ),
        );
      }
    }
  }

  /// 🔄 Recovers vehicle from a flip/crash back onto its wheels
  void recoverFromCrash() {
    isCrashed = false;
    isCrashedNotifier.value = false;
    chassisTilt = getGroundSlope(playerX);
    angularVelocity = 0.0;
    playerZ = 35.0;
    jumpVelocity = 6.0;
    isJumping = true;

    floatingTexts.add(
      FloatingTextEffect(
        text: '🔄 BACK ON WHEELS!',
        x: playerX,
        y: playerY - 45,
        color: const Color(0xFF10B981),
      ),
    );
  }

  /// 👆 Direct screen tap handling: checks if tapped any house, avatar, signpost, or billboard
  void handleTapAt(Offset screenOffset) {
    final worldX = (screenOffset.dx / zoomScale) + cameraX;
    final worldY = (screenOffset.dy / zoomScale) + cameraY;

    // Check Roadside Billboards
    for (final board in roadsideBoards) {
      final dist = math.sqrt(math.pow(worldX - board.x, 2) + math.pow(worldY - (board.y - 75), 2));
      if (dist < 110) {
        if (onBillboardRead != null) {
          onBillboardRead!(board);
        }
        return;
      }
    }

    // Check Houses / Avatars / Signposts
    for (final node in houseNodes) {
      final avatarCenterY = node.y - 220;
      final distAvatar = math.sqrt(math.pow(worldX - node.x, 2) + math.pow(worldY - avatarCenterY, 2));
      final distSign = math.sqrt(math.pow(worldX - (node.x + 120), 2) + math.pow(worldY - (node.y - 48), 2));
      final distHouse = (worldX - node.x).abs() < 120 && (worldY - (node.y - 100)).abs() < 140;

      if (distAvatar < 55 || distSign < 50 || distHouse) {
        onProfileTap(node.neighbor);
        return;
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    gameTime += dt;

    // If vehicle crashed (flipped over onto its roof), apply crash skidding physics
    if (isCrashed) {
      vx *= math.pow(0.82, dt * 60);
      playerX += vx * dt;
      playerY = getGroundY(playerX);
      if ((gameTime % 0.08) < dt) {
        particles.add(
          JumpDustParticle(
            x: playerX + (math.Random().nextDouble() * 20 - 10),
            y: playerY - 5,
            vx: (math.Random().nextDouble() * 40 - 20),
            vy: -25,
          ),
        );
      }
      return;
    }

    // 1. Hill Climb Racing Driving Physics & Engine Braking
    double accel = 0.0;
    double maxSpeed = 380.0;
    if (locomotion == LocomotionMode.bike) {
      maxSpeed = 400.0;
      accel = 640.0;
    } else if (locomotion == LocomotionMode.buggy) {
      maxSpeed = 490.0;
      accel = 780.0;
    } else {
      maxSpeed = 220.0;
      accel = 480.0;
    }

    if (inputDx > 0.05) {
      vx += accel * dt;
      vx = vx.clamp(-maxSpeed * 0.5, maxSpeed);
    } else if (inputDx < -0.05) {
      if (vx > 20.0) {
        vx -= 1300.0 * dt; // Active braking
      } else {
        vx -= (accel * 0.65) * dt; // Reverse
        vx = vx.clamp(-maxSpeed * 0.5, maxSpeed);
      }
    } else {
      // Immediate engine braking on release ("നിർത്തിക്കഴിഞ്ഞാൽ വണ്ടി നിൽക്കണം")
      vx *= math.pow(0.68, dt * 60);
      if (vx.abs() < 5.0) vx = 0.0;
    }

    playerX += vx * dt;
    playerX = playerX.clamp(100.0, worldWidth - 100.0);

    runCycle += dt * (vx.abs() / 20.0);
    bikeWheelAngle += (vx * dt) / 10.0;
    carWheelAngle += (vx * dt) / 8.0;
    speedNotifier.value = (vx.abs() * 0.12);

    final groundY = getGroundY(playerX);
    final targetSlope = getGroundSlope(playerX);

    // 2. Hill Climb Racing Tipping / Flip Physics & Torques
    if (!isJumping) {
      // On Ground:
      // Gas lifts front wheels (wheelie torque); Brake pushes nose down
      if (inputDx > 0) {
        angularVelocity -= 1.6 * dt;
      } else if (inputDx < 0) {
        angularVelocity += 2.0 * dt;
      }

      // Spring torque aligns with hill slope
      angularVelocity += (targetSlope - chassisTilt) * 12.0 * dt;
      angularVelocity *= math.pow(0.78, dt * 60); // Damping
      chassisTilt += angularVelocity * dt;

      // Check Flip / Driver Down Crash
      if ((chassisTilt - targetSlope).abs() > 1.38) {
        isCrashed = true;
        isCrashedNotifier.value = true;
        HapticFeedback.heavyImpact();

        floatingTexts.add(
          FloatingTextEffect(
            text: '💥 FLIPPED! DRIVER DOWN! 🔄',
            x: playerX,
            y: groundY - 45,
            color: const Color(0xFFEF4444),
          ),
        );
      }

      suspensionOffset = math.sin(gameTime * 14.0) * (vx.abs() > 30 ? 1.8 : 0.0);
    } else {
      // In Air: Player controls tilt rotation with Gas/Brake
      airTime += dt;
      if (inputDx > 0) {
        chassisTilt -= 2.8 * dt; // Tilt back
        airRotationProgress -= 2.8 * dt;
      } else if (inputDx < 0) {
        chassisTilt += 2.8 * dt; // Tilt forward
        airRotationProgress += 2.8 * dt;
      }

      // Detect 360 backflip / frontflip stunt!
      if (airRotationProgress.abs() >= (math.pi * 2 * 0.85)) {
        airRotationProgress = 0.0;
        floatingTexts.add(
          FloatingTextEffect(
            text: '🏆 360 FLIP STUNT! +10 🟡',
            x: playerX,
            y: playerY - 40,
            color: const Color(0xFFFFFC00),
          ),
        );
        PocketFortressDefenseService.awardPoints(10);
      }
    }

    // Jump Ramp Collisions
    for (final ramp in jumpRamps) {
      if ((playerX - ramp.x).abs() < 32 && (playerY - ramp.y).abs() < 42) {
        if (!isJumping || jumpVelocity < 10.0) {
          isJumping = true;
          jumpVelocity = 19.5;
          vx = (vx.abs() < 140 ? 340.0 : vx.abs() * 1.35) * playerFacing;
          HapticFeedback.heavyImpact();

          floatingTexts.add(
            FloatingTextEffect(
              text: '🚀 MEGA RAMP LAUNCH! +5 🟡',
              x: ramp.x,
              y: ramp.y - 65,
              color: const Color(0xFFFF9900),
            ),
          );
          PocketFortressDefenseService.awardPoints(5);

          for (int i = 0; i < 12; i++) {
            particles.add(
              JumpDustParticle(
                x: ramp.x,
                y: ramp.y - 10,
                vx: (math.Random().nextDouble() * 120 - 60),
                vy: -math.Random().nextDouble() * 45 - 20,
              ),
            );
          }
        }
      }
    }

    // 3. Vertical Jump & Landing with Frame-Rate Independent Delta Time
    if (isJumping) {
      playerZ += jumpVelocity * (dt * 60.0);
      jumpVelocity -= 0.65 * (dt * 60.0);

      // Rocket booster flame particles during airtime
      if (playerZ > 6.0 && locomotion == LocomotionMode.buggy) {
        if ((gameTime % 0.04) < dt) {
          final rearX = playerX - (playerFacing * 28.0);
          final rearY = playerY + 4.0;
          particles.add(
            BoosterFlameParticle(
              x: rearX,
              y: rearY,
              vx: -playerFacing * (140.0 + math.Random().nextDouble() * 50),
              vy: (math.Random().nextDouble() * 24 - 12),
              color: math.Random().nextBool() ? const Color(0xFF00F0FF) : const Color(0xFFFF9900),
            ),
          );
        }
      }

      if (playerZ <= 0.0) {
        playerZ = 0.0;
        isJumping = false;
        suspensionOffset = (jumpVelocity.abs() * 0.45).clamp(0.0, 10.0);
        jumpVelocity = 0.0;

        // Check if landed upside down
        if ((chassisTilt - targetSlope).abs() > 1.35) {
          isCrashed = true;
          isCrashedNotifier.value = true;
          HapticFeedback.heavyImpact();
          floatingTexts.add(
            FloatingTextEffect(
              text: '💥 ROUGH LANDING! FLIPPED! 🔄',
              x: playerX,
              y: groundY - 45,
              color: const Color(0xFFEF4444),
            ),
          );
        } else if (airTime >= 0.7) {
          floatingTexts.add(
            FloatingTextEffect(
              text: '🚀 AIR TIME ${airTime.toStringAsFixed(1)}s! +2 🟡',
              x: playerX,
              y: groundY - 50,
              color: const Color(0xFFFF2A55),
            ),
          );
          PocketFortressDefenseService.awardPoints(2);
        }

        for (int i = 0; i < 5; i++) {
          final angle = (i / 5) * math.pi * 2;
          particles.add(
            JumpDustParticle(
              x: playerX,
              y: groundY,
              vx: math.cos(angle) * 24,
              vy: math.sin(angle) * 12,
            ),
          );
        }
      }
    }
    playerY = groundY - playerZ;

    // 4. Collect Coins & Trigger Score Award
    final playerHitRect = Rect.fromCenter(
      center: Offset(playerX, playerY - 18),
      width: 44,
      height: 38,
    );

    for (final coin in coins) {
      if (!coin.collected && playerHitRect.contains(Offset(coin.x, coin.y))) {
        coin.collected = true;
        coinsCollectedNotifier.value += 1;
        HapticFeedback.selectionClick();

        floatingTexts.add(
          FloatingTextEffect(
            text: '+1 🟡',
            x: coin.x,
            y: coin.y - 12,
            color: const Color(0xFFFFFC00),
          ),
        );
        PocketFortressDefenseService.awardPoints(1);
      }
    }

    // 5. Collect English Word Orbs with Multilingual Flashcard Callback
    for (final orb in englishOrbs) {
      if (!orb.collected && playerHitRect.contains(Offset(orb.x, orb.y))) {
        orb.collected = true;
        HapticFeedback.mediumImpact();

        floatingTexts.add(
          FloatingTextEffect(
            text: '📘 ${orb.word}! +5',
            x: orb.x,
            y: orb.y - 20,
            color: const Color(0xFF38BDF8),
          ),
        );
        PocketFortressDefenseService.awardPoints(5);
        if (onVocabCollected != null) {
          onVocabCollected!(orb.vocabItem);
        }
        if (onWordCollected != null) {
          onWordCollected!(orb.word, orb.meaning);
        }
      }
    }

    // 6. Roadside Billboards proximity auto-read
    for (final board in roadsideBoards) {
      if (!board.isRead && (playerX - board.x).abs() < 55) {
        board.isRead = true;
        if (onBillboardRead != null) {
          onBillboardRead!(board);
        }
      }
    }

    // 7. Nitro Speed Boost Gates
    for (final gate in speedGates) {
      if ((playerX - gate.x).abs() < 35 && (playerY - gate.y).abs() < 90) {
        if (gameTime - gate.lastTriggerTime > 3.0) {
          gate.lastTriggerTime = gameTime;
          HapticFeedback.heavyImpact();
          vx = (vx >= 0 ? 1 : -1) * (maxSpeed * 1.35);

          floatingTexts.add(
            FloatingTextEffect(
              text: '${gate.idiom} ⚡ NITRO BOOST!',
              x: gate.x,
              y: gate.y - 70,
              color: const Color(0xFF00F0FF),
            ),
          );

          for (int i = 0; i < 10; i++) {
            particles.add(
              JumpDustParticle(
                x: playerX - (playerFacing * 25),
                y: playerY - 10,
                vx: -playerFacing * (220.0 + (i * 20.0)),
                vy: (i - 5) * 12.0,
              ),
            );
          }
        }
      }
    }

    // 8. Update Particles & Floating Text
    for (int i = particles.length - 1; i >= 0; i--) {
      particles[i].update(dt);
      if (particles[i].isDead) particles.removeAt(i);
    }
    for (int i = floatingTexts.length - 1; i >= 0; i--) {
      floatingTexts[i].update(dt);
      if (floatingTexts[i].isDead) floatingTexts.removeAt(i);
    }

    // 9. Update Roaming Robots
    for (final bot in robotNpcs) {
      bot.update(dt);
      bot.y = getGroundY(bot.x);
    }

    for (final boat in riverBoats) {
      boat.update(dt, worldWidth);
    }
    for (final bird in seagulls) {
      bird.update(dt, worldWidth);
    }

    // 10. Update Visible Houses
    for (final node in houseNodes) {
      if ((node.x - playerX).abs() < 1800) {
        node.update(dt);
      }
    }

    // 11. Camera Tracking
    final viewportW = size.x / zoomScale;
    final viewportH = size.y / zoomScale;
    final targetCamX = playerX - (viewportW / 2);
    final targetCamY = playerY - (viewportH * 0.65);

    cameraX += (targetCamX - cameraX) * 0.12;
    cameraY += (targetCamY - cameraY) * 0.12;
    cameraX = cameraX.clamp(0.0, math.max(0.0, worldWidth - viewportW));
    cameraY = cameraY.clamp(0.0, math.max(0.0, worldHeight - viewportH));

    // 12. Current Street & Sector Computation
    final currentStreetNumber = ((playerX / 480.0).floor() + 1).clamp(1, 90);
    String sectorTitle;
    if (isOceanBridge(playerX)) {
      sectorTitle = '🌉 Grand Ocean Bridge';
    } else if (currentStreetNumber <= 10) {
      sectorTitle = 'Rookie Way';
    } else if (currentStreetNumber <= 30) {
      sectorTitle = 'Grammar Avenue';
    } else if (currentStreetNumber <= 60) {
      sectorTitle = 'Scholar Boulevard';
    } else {
      sectorTitle = 'Apex Ridge';
    }

    currentDistrictName = '🛣️ Street $currentStreetNumber • $sectorTitle';
    if (districtNotifier.value != currentDistrictName) {
      districtNotifier.value = currentDistrictName;
    }

    // 13. Proximity Detection
    PocketNeighbor? closest;
    double minDistance = 160.0;

    for (final node in houseNodes) {
      final dist = (playerX - node.x).abs();
      if (dist < minDistance) {
        minDistance = dist;
        closest = node.neighbor;
      }
    }

    onProximityChanged(closest);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.save();
    canvas.scale(zoomScale, zoomScale);
    canvas.translate(-cameraX, -cameraY);

    // 1. Sky & Mountains
    _drawSkyAndMountains(canvas);

    // 2. Rolling Hills & Earth
    _drawRollingHills(canvas);

    // 3. Ocean Suspension Bridges
    _drawOceanSuspensionBridges(canvas);

    // 4. Living River Water with Cruising Boats & Jumping Fish
    _drawLivingRiver(canvas);

    final viewportW = size.x / zoomScale;
    final leftBound = cameraX - 300;
    final rightBound = cameraX + viewportW + 300;

    // 5. Collectible Golden Coins
    for (final coin in coins) {
      if (coin.x >= leftBound && coin.x <= rightBound) {
        coin.render(canvas, gameTime);
      }
    }

    // 6. English Learning Orbs & Speed Gates
    for (final orb in englishOrbs) {
      if (orb.x >= leftBound && orb.x <= rightBound) {
        orb.render(canvas, gameTime);
      }
    }
    for (final gate in speedGates) {
      if (gate.x >= leftBound && gate.x <= rightBound) {
        gate.render(canvas, gameTime);
      }
    }

    // 7. Roadside English Learning Billboards with Multilingual Translation
    for (final board in roadsideBoards) {
      if (board.x >= leftBound && board.x <= rightBound) {
        board.render(canvas, gameTime, selectedLanguage);
      }
    }

    // 7.5 Strategic Launch Ramps
    for (final ramp in jumpRamps) {
      if (ramp.x >= leftBound && ramp.x <= rightBound) {
        ramp.render(canvas, gameTime);
      }
    }

    // 8. Authentic 2D Front-Facing English Houses + Street Signboards
    for (final node in houseNodes) {
      if (node.x >= leftBound && node.x <= rightBound) {
        _drawAuthenticEnglishHouse(canvas, node);
      }
    }

    // 9. Roaming Robots
    for (final bot in robotNpcs) {
      if (bot.x >= leftBound && bot.x <= rightBound) {
        _drawRobotNpc(canvas, bot);
      }
    }

    // 10. Dust, Smoke, and Floating Text Particles
    for (final p in particles) {
      p.render(canvas);
    }
    for (final ft in floatingTexts) {
      ft.render(canvas);
    }

    // 11. 2D Avatar with Hill Climb Racing Physics
    _drawPlatformerAvatar(canvas);

    canvas.restore();
  }

  void _drawSkyAndMountains(Canvas canvas) {
    if (isNight) {
      final skyPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF030712), Color(0xFF0F172A), Color(0xFF1E1B4B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, worldWidth, worldHeight));
      canvas.drawRect(Rect.fromLTWH(0, 0, worldWidth, worldHeight), skyPaint);

      final moonX = cameraX + (size.x / zoomScale * 0.75);
      const moonY = 160.0;
      final moonPaint = Paint()..color = const Color(0xFFFEF08A);
      canvas.drawCircle(Offset(moonX, moonY), 36, moonPaint);
      canvas.drawCircle(
        Offset(moonX + 10, moonY - 6),
        30,
        Paint()..color = const Color(0xFF0F172A),
      );
      canvas.drawCircle(
        Offset(moonX, moonY),
        55,
        Paint()
          ..color = const Color(0xFFFEF08A).withValues(alpha: 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
      );

      for (double sx = 60; sx < worldWidth; sx += 140) {
        final sy = 80 + (math.sin(sx * 1.5) * 60);
        final twinkle = (math.sin(gameTime * 3.0 + sx) * 0.4) + 0.6;
        canvas.drawCircle(
          Offset(sx, sy),
          1.8 * twinkle,
          Paint()..color = Colors.white.withValues(alpha: 0.85 * twinkle),
        );
      }
    } else {
      final skyPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF38BDF8), Color(0xFFBAE6FD)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, worldWidth, worldHeight));
      canvas.drawRect(Rect.fromLTWH(0, 0, worldWidth, worldHeight), skyPaint);

      final sunX = cameraX + (size.x / zoomScale * 0.80);
      const sunY = 140.0;
      canvas.drawCircle(Offset(sunX, sunY), 42, Paint()..color = const Color(0xFFFDE047));
      canvas.drawCircle(
        Offset(sunX, sunY),
        70,
        Paint()
          ..color = const Color(0xFFFDE047).withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
      );

      for (double cx = 100; cx < worldWidth; cx += 520) {
        final cy = 120 + (math.sin(cx * 0.8) * 35);
        _drawFluffyCloud(canvas, cx + ((gameTime * 12) % 400), cy);
      }

      for (final bird in seagulls) {
        bird.render(canvas);
      }
    }

    final mountainPath = Path();
    mountainPath.moveTo(0, groundBaseY - 180);
    for (double x = 0; x <= worldWidth; x += 300) {
      final my = groundBaseY - 240 - (math.sin(x * 0.0015) * 140.0);
      mountainPath.lineTo(x, my);
    }
    mountainPath.lineTo(worldWidth, worldHeight);
    mountainPath.lineTo(0, worldHeight);
    mountainPath.close();

    final mountainPaint = Paint()
      ..color = isNight ? const Color(0xFF0B132B) : const Color(0xFF0D9488).withValues(alpha: 0.65);
    canvas.drawPath(mountainPath, mountainPaint);
  }

  void _drawFluffyCloud(Canvas canvas, double cx, double cy) {
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.75);
    canvas.drawCircle(Offset(cx, cy), 22, cloudPaint);
    canvas.drawCircle(Offset(cx + 20, cy - 8), 28, cloudPaint);
    canvas.drawCircle(Offset(cx + 45, cy - 4), 22, cloudPaint);
    canvas.drawCircle(Offset(cx + 60, cy), 16, cloudPaint);
  }

  void _drawRollingHills(Canvas canvas) {
    final hillPath = Path();
    hillPath.moveTo(0, getGroundY(0));
    for (double x = 0; x <= worldWidth; x += 15) {
      hillPath.lineTo(x, getGroundY(x));
    }
    hillPath.lineTo(worldWidth, worldHeight);
    hillPath.lineTo(0, worldHeight);
    hillPath.close();

    final hillPaint = Paint()
      ..shader = LinearGradient(
        colors: isNight
            ? const [Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF030712)]
            : const [Color(0xFF15803D), Color(0xFF166534), Color(0xFF14532D)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 400, worldWidth, 1200));
    canvas.drawPath(hillPath, hillPaint);

    final ridgePaint = Paint()
      ..color = isNight ? const Color(0xFF10B981).withValues(alpha: 0.8) : const Color(0xFF4ADE80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0;
    canvas.drawPath(hillPath, ridgePaint);

    final pathOutline = Paint()
      ..color = (isNight ? const Color(0xFF38BDF8) : const Color(0xFFFDE047)).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0;
    canvas.drawPath(hillPath, pathOutline);

    for (double x = 160; x < worldWidth; x += 320) {
      if (isOceanBridge(x)) continue; // Skip lamp posts over ocean bridges
      final y = getGroundY(x);
      canvas.drawLine(
        Offset(x, y),
        Offset(x, y - 55),
        Paint()..color = const Color(0xFF475569)..strokeWidth = 3.5,
      );
      canvas.drawCircle(Offset(x, y - 55), 6, Paint()..color = const Color(0xFFFFFC00));
      canvas.drawCircle(
        Offset(x, y - 55),
        isNight ? 42 : 24,
        Paint()
          ..color = const Color(0xFFFFFC00).withValues(alpha: isNight ? 0.28 : 0.12)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, isNight ? 12 : 6),
      );
    }
  }

  /// 🌉 Draws Majestic Ocean Suspension Bridges spanning across ocean channels
  void _drawOceanSuspensionBridges(Canvas canvas) {
    final bridges = [
      (6200.0, 7600.0, 'OCEAN STRAIT I'),
      (18200.0, 19800.0, 'SAPPHIRE BAY II'),
      (36200.0, 38000.0, 'APEX SOUND III'),
    ];

    for (final b in bridges) {
      final startX = b.$1;
      final endX = b.$2;

      // Only draw if inside viewport
      if (endX < cameraX - 200 || startX > cameraX + (size.x / zoomScale) + 200) {
        continue;
      }

      final tower1X = startX + 280.0;
      final tower2X = endX - 280.0;
      final deckY = getGroundY(tower1X);
      final towerTopY = deckY - 180.0;

      // 1. Towering Suspension Pillars
      final towerPaint = Paint()
        ..color = const Color(0xFFDC2626) // Golden Gate Crimson Red
        ..strokeWidth = 10.0;

      canvas.drawLine(Offset(tower1X, deckY + 80), Offset(tower1X, towerTopY), towerPaint);
      canvas.drawLine(Offset(tower2X, deckY + 80), Offset(tower2X, towerTopY), towerPaint);

      // Tower cross-beams
      final beamPaint = Paint()..color = const Color(0xFF991B1B)..strokeWidth = 4.0;
      canvas.drawLine(Offset(tower1X - 12, towerTopY + 50), Offset(tower1X + 12, towerTopY + 50), beamPaint);
      canvas.drawLine(Offset(tower1X - 12, towerTopY + 110), Offset(tower1X + 12, towerTopY + 110), beamPaint);
      canvas.drawLine(Offset(tower2X - 12, towerTopY + 50), Offset(tower2X + 12, towerTopY + 50), beamPaint);
      canvas.drawLine(Offset(tower2X - 12, towerTopY + 110), Offset(tower2X + 12, towerTopY + 110), beamPaint);

      // Tower lights
      canvas.drawCircle(Offset(tower1X, towerTopY), 5.0, Paint()..color = const Color(0xFFFFFC00));
      canvas.drawCircle(Offset(tower2X, towerTopY), 5.0, Paint()..color = const Color(0xFFFFFC00));

      // 2. Main Glowing Suspension Cable Curve
      final cablePath = Path();
      cablePath.moveTo(startX, getGroundY(startX));
      cablePath.lineTo(tower1X, towerTopY);

      // Parabolic drop between towers
      final midX = (tower1X + tower2X) / 2;
      final midDeckY = getGroundY(midX);
      cablePath.quadraticBezierTo(midX, midDeckY - 15.0, tower2X, towerTopY);

      cablePath.lineTo(endX, getGroundY(endX));

      final cablePaint = Paint()
        ..color = const Color(0xFFFFFC00).withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawPath(cablePath, cablePaint);

      // 3. Vertical Suspension Wire Droppers every 40px
      final wirePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..strokeWidth = 1.2;

      for (double wx = tower1X + 35; wx <= tower2X - 35; wx += 40) {
        final wyDeck = getGroundY(wx);
        // compute cable y at wx
        final t = (wx - tower1X) / (tower2X - tower1X);
        final cableY = (1 - t) * (1 - t) * towerTopY + 2 * (1 - t) * t * (midDeckY - 15.0) + t * t * towerTopY;
        canvas.drawLine(Offset(wx, cableY), Offset(wx, wyDeck), wirePaint);
      }

      // 4. Bridge Road Deck & Railings
      final deckPath = Path();
      deckPath.moveTo(startX, getGroundY(startX));
      for (double bx = startX; bx <= endX; bx += 20) {
        deckPath.lineTo(bx, getGroundY(bx));
      }
      final bridgeRoadPaint = Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16.0;
      canvas.drawPath(deckPath, bridgeRoadPaint);

      // Glowing Runway Edge
      final runwayPaint = Paint()
        ..color = const Color(0xFF00F0FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawPath(deckPath, runwayPaint);

      // Bridge Welcome Arch Text
      final bannerTp = TextPainter(
        text: TextSpan(
          text: '🌉 ${b.$3} • OCEAN HIGHWAY',
          style: const TextStyle(
            color: Color(0xFFFFFC00),
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      bannerTp.paint(canvas, Offset(startX + 60, getGroundY(startX) - 45));
    }
  }

  /// 🌊 Living Water River with cruising boats & leaping fish
  void _drawLivingRiver(Canvas canvas) {
    final riverTopY = groundBaseY + 180.0;
    final riverRect = Rect.fromLTWH(0, riverTopY, worldWidth, worldHeight - riverTopY);

    final waterPaint = Paint()
      ..shader = LinearGradient(
        colors: isNight
            ? const [Color(0xFF0F2744), Color(0xFF081326), Color(0xFF020712)]
            : const [Color(0xFF0284C7), Color(0xFF0369A1), Color(0xFF075985)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(riverRect);
    canvas.drawRect(riverRect, waterPaint);

    final wavePath = Path();
    wavePath.moveTo(0, riverTopY);
    for (double wx = 0; wx <= worldWidth; wx += 30) {
      final wy = riverTopY + (math.sin((wx * 0.02) + (gameTime * 3.5)) * 4.5);
      wavePath.lineTo(wx, wy);
    }
    final ripplePaint = Paint()
      ..color = const Color(0xFF7DD3FC).withValues(alpha: isNight ? 0.25 : 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(wavePath, ripplePaint);

    for (final boat in riverBoats) {
      boat.render(canvas, isNight);
    }

    final fishCycle = (gameTime * 0.8) % 6.0;
    if (fishCycle < 1.4) {
      final fx = 1200.0 + ((gameTime * 40.0) % 8000.0);
      final leapHeight = math.sin(fishCycle * math.pi / 1.4) * 32.0;
      final fy = riverTopY - leapHeight;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(fx, fy), width: 14, height: 6),
        Paint()..color = const Color(0xFFE2E8F0),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(fx, riverTopY), width: 18 * (fishCycle / 1.4), height: 4),
        Paint()..color = const Color(0xFFBAE6FD).withValues(alpha: 0.6),
      );
    }

    // Leaping Dolphins under Bridge & River
    for (int d = 0; d < 3; d++) {
      final dolphinBaseX = 6400.0 + (d * 12000.0);
      final dolphinCycle = ((gameTime * 0.9) + (d * 2.1)) % 5.0;
      if (dolphinCycle < 1.6) {
        final leapProgress = dolphinCycle / 1.6;
        final dx = dolphinBaseX + (leapProgress * 120.0);
        final leapHeight = math.sin(leapProgress * math.pi) * 42.0;
        final dy = riverTopY - leapHeight;
        final dolphinAngle = math.cos(leapProgress * math.pi) * 0.6;

        canvas.save();
        canvas.translate(dx, dy);
        canvas.rotate(dolphinAngle);

        // Sleek dolphin body
        final dolphinPath = Path();
        dolphinPath.moveTo(-16, 0);
        dolphinPath.quadraticBezierTo(-4, -8, 12, 0);
        dolphinPath.quadraticBezierTo(2, 6, -16, 0);

        // Dorsal fin
        dolphinPath.moveTo(0, -6);
        dolphinPath.lineTo(4, -13);
        dolphinPath.lineTo(6, -6);

        // Tail fluke
        dolphinPath.moveTo(-16, 0);
        dolphinPath.lineTo(-22, -4);
        dolphinPath.lineTo(-20, 0);
        dolphinPath.lineTo(-22, 4);
        dolphinPath.close();

        canvas.drawPath(dolphinPath, Paint()..color = const Color(0xFF94A3B8));
        canvas.drawPath(dolphinPath, Paint()..color = const Color(0xFFE2E8F0)..style = PaintingStyle.stroke..strokeWidth = 1);

        canvas.restore();

        // Water splash rings
        if (leapProgress > 0.05 && leapProgress < 0.95) {
          canvas.drawOval(
            Rect.fromCenter(center: Offset(dx, riverTopY), width: 22 * math.sin(leapProgress * math.pi), height: 5),
            Paint()..color = const Color(0xFFBAE6FD).withValues(alpha: 0.65),
          );
        }
      }
    }
  }

  /// 🏡 Draws the House directly via [HouseMasterComponent] + Roadside Signpost [ STREET X • #N ]
  void _drawAuthenticEnglishHouse(Canvas canvas, WorldHouseNode node) {
    final x = node.x;
    final groundY = node.y;
    final neighbor = node.neighbor;

    canvas.save();
    const houseScale = 0.72;
    const cx = 190.0;
    const baseGroundY = 286.0;

    canvas.translate(x, groundY);
    canvas.scale(houseScale, houseScale);
    canvas.translate(-cx, -baseGroundY);

    node.houseMaster.render(canvas);

    canvas.restore();

    // 1. Shimmering Shield Bubble (if active)
    if (neighbor.hasActiveShield) {
      final shieldCenter = Offset(x, groundY - 110);
      canvas.drawCircle(
        shieldCenter,
        105,
        Paint()
          ..color = const Color(0xFF00F0FF).withValues(alpha: 0.14)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
      canvas.drawCircle(
        shieldCenter,
        105,
        Paint()
          ..color = const Color(0xFF38BDF8).withValues(alpha: 0.65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }

    // 2. 👤 Authentic VectorAvatar Portrait Badge Floating Over the Roof
    final avatarCenterY = groundY - 220;
    const avatarRadius = 18.0;

    canvas.drawCircle(
      Offset(x, avatarCenterY),
      avatarRadius + 3.0,
      Paint()
        ..color = (neighbor.hasActiveShield ? const Color(0xFF00F0FF) : const Color(0xFFFFFC00)).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(Offset(x, avatarCenterY), avatarRadius + 2.0, Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(
      Offset(x, avatarCenterY),
      avatarRadius + 2.0,
      Paint()
        ..color = neighbor.hasActiveShield ? const Color(0xFF00F0FF) : const Color(0xFFFFFC00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    canvas.save();
    canvas.translate(x - avatarRadius, avatarCenterY - avatarRadius);
    node.avatarPainter.paint(canvas, const Size(avatarRadius * 2, avatarRadius * 2));
    canvas.restore();

    // Special Glowing Banner for User's Own Home
    if (node.isPlayerHome) {
      final homeBadgeRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, groundY - 250), width: 130, height: 22),
        const Radius.circular(6),
      );
      canvas.drawRRect(homeBadgeRect, Paint()..color = const Color(0xFFFFFC00));
      final homeTp = TextPainter(
        text: const TextSpan(
          text: '👑 YOUR HOME',
          style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      homeTp.paint(canvas, Offset(x - (homeTp.width / 2), groundY - 250 - (homeTp.height / 2)));
    }

    // 3. 🚏 Roadside Street Signpost next to Driveway
    final signX = x + 120.0;
    final signGroundY = getGroundY(signX);
    final signTopY = signGroundY - 48.0;

    canvas.drawLine(
      Offset(signX, signGroundY),
      Offset(signX, signTopY),
      Paint()..color = const Color(0xFF78350F)..strokeWidth = 3.5,
    );

    final signBoardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(signX, signTopY - 14), width: 130, height: 32),
      const Radius.circular(6),
    );
    canvas.drawRRect(signBoardRect, Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.92));
    canvas.drawRRect(
      signBoardRect,
      Paint()
        ..color = const Color(0xFFFFFC00).withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final signTp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${node.streetSignLabel}\n',
            style: const TextStyle(
              color: Color(0xFFFFFC00),
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          TextSpan(
            text: neighbor.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
    )..layout(maxWidth: 125);
    signTp.paint(canvas, Offset(signX - (signTp.width / 2), signTopY - 14 - (signTp.height / 2)));
  }

  void _drawRobotNpc(Canvas canvas, RoamingRobotNpc bot) {
    final x = bot.x;
    final y = bot.y - 20;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, bot.y), width: 38, height: 12),
      Paint()..color = Colors.black.withValues(alpha: 0.4),
    );

    final bodyPaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, y), width: 32, height: 36), const Radius.circular(8)),
      bodyPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, y - 5), width: 22, height: 9), const Radius.circular(3)),
      Paint()..color = const Color(0xFF00F0FF),
    );

    canvas.drawLine(Offset(x, y - 18), Offset(x, y - 26), Paint()..color = const Color(0xFFFFFC00)..strokeWidth = 2);
    canvas.drawCircle(Offset(x, y - 28), 3.5, Paint()..color = const Color(0xFFFF2A55));

    if ((playerX - x).abs() < 160) {
      final bRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y - 55), width: 160, height: 28),
        const Radius.circular(8),
      );
      canvas.drawRRect(bRect, Paint()..color = Colors.black.withValues(alpha: 0.85));
      canvas.drawRRect(
        bRect,
        Paint()
          ..color = const Color(0xFF00F0FF).withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: bot.speechText,
          style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '...',
      )..layout(maxWidth: 150);
      tp.paint(canvas, Offset(x - (tp.width / 2), y - 55 - (tp.height / 2)));
    }
  }

  /// 🏃 Draws 2D Platformer Avatar with Hill Climb Racing chassis tilt
  void _drawPlatformerAvatar(Canvas canvas) {
    final x = playerX;
    final groundY = getGroundY(playerX);
    final avatarY = groundY - playerZ;

    // Ground Shadow
    final shadowScale = math.max(0.3, 1.0 - (playerZ / 95.0));
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.45 * shadowScale);
    final shadowWidth = locomotion == LocomotionMode.buggy ? 64.0 : 48.0;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(playerX, groundY + 4),
        width: shadowWidth * shadowScale,
        height: 15 * shadowScale,
      ),
      shadowPaint,
    );

    canvas.save();
    canvas.translate(x, avatarY - 24 + suspensionOffset);

    // Dynamic slope and torque tilt rotation!
    canvas.rotate(chassisTilt);

    if (playerFacing < 0) {
      canvas.scale(-1.0, 1.0);
    }

    if (locomotion == LocomotionMode.buggy) {
      _drawSportsBuggy(canvas);
    } else if (locomotion == LocomotionMode.bike) {
      _drawSportsBicycle(canvas);
    } else {
      _drawOnFootRunner(canvas);
    }

    canvas.restore();

    // "YOU (Lvl X)" Text Tag
    final tp = TextPainter(
      text: TextSpan(
        text: isCrashed ? '😵 CRASHED!' : 'YOU (Lvl $playerDay)',
        style: TextStyle(
          color: isCrashed ? const Color(0xFFEF4444) : const Color(0xFFFFFC00),
          fontSize: 11,
          fontWeight: FontWeight.w900,
          shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - (tp.width / 2), avatarY - 82));
  }

  void _drawSportsBuggy(Canvas canvas) {
    final wheelPaint = Paint()..color = const Color(0xFF0F172A);
    final rimPaint = Paint()
      ..color = const Color(0xFFFFFC00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final springPaint = Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 2;
    canvas.drawLine(const Offset(-22, 2), const Offset(-22, 14), springPaint);
    canvas.drawLine(const Offset(24, 2), const Offset(24, 14), springPaint);

    for (final wx in [-22.0, 24.0]) {
      canvas.drawCircle(Offset(wx, 14), 10, wheelPaint);
      canvas.drawCircle(Offset(wx, 14), 7, rimPaint);
      for (int s = 0; s < 4; s++) {
        final a = carWheelAngle + (s * math.pi / 2);
        canvas.drawLine(
          Offset(wx, 14),
          Offset(wx + math.cos(a) * 7, 14 + math.sin(a) * 7),
          Paint()..color = Colors.white70..strokeWidth = 1,
        );
      }
    }

    final chassisPath = Path();
    chassisPath.moveTo(-32, 12);
    chassisPath.lineTo(-28, 0);
    chassisPath.lineTo(-12, -4);
    chassisPath.lineTo(16, -4);
    chassisPath.lineTo(34, 4);
    chassisPath.lineTo(36, 12);
    chassisPath.close();

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF2A55), Color(0xFFDC2626)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(-32, -4, 68, 16));
    canvas.drawPath(chassisPath, bodyPaint);

    canvas.drawLine(const Offset(-30, 6), const Offset(34, 6), Paint()..color = const Color(0xFFFFFC00)..strokeWidth = 2);

    final cagePaint = Paint()..color = Colors.white70..strokeWidth = 2..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(-10, -4), const Offset(-4, -18), cagePaint);
    canvas.drawLine(const Offset(-4, -18), const Offset(14, -6), cagePaint);

    canvas.drawCircle(const Offset(34, 6), 3.5, Paint()..color = const Color(0xFFFEF08A));
    canvas.drawCircle(
      const Offset(42, 6),
      8,
      Paint()..color = const Color(0xFFFEF08A).withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    canvas.drawLine(const Offset(8, -4), const Offset(6, -11), Paint()..color = Colors.black..strokeWidth = 2.5);
    canvas.drawCircle(const Offset(6, -11), 3.5, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.5);

    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-8, -12, 16, 12), const Radius.circular(4)),
      Paint()..color = const Color(0xFF0F172A),
    );

    const headRadius = 11.0;
    canvas.save();
    canvas.translate(-headRadius + 2, -26 - headRadius);
    playerAvatarPainter.paint(canvas, const Size(headRadius * 2, headRadius * 2));
    canvas.restore();
  }

  void _drawSportsBicycle(Canvas canvas) {
    final wheelPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    final rimPaint = Paint()
      ..color = const Color(0xFF00F0FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(const Offset(-18, 16), 11, wheelPaint);
    canvas.drawCircle(const Offset(-18, 16), 8, rimPaint);
    canvas.drawCircle(const Offset(18, 16), 11, wheelPaint);
    canvas.drawCircle(const Offset(18, 16), 8, rimPaint);

    for (int s = 0; s < 4; s++) {
      final a = bikeWheelAngle + (s * (math.pi / 2));
      canvas.drawLine(
        const Offset(-18, 16),
        Offset(-18 + math.cos(a) * 8, 16 + math.sin(a) * 8),
        Paint()..color = Colors.white70..strokeWidth = 1,
      );
      canvas.drawLine(
        const Offset(18, 16),
        Offset(18 + math.cos(a) * 8, 16 + math.sin(a) * 8),
        Paint()..color = Colors.white70..strokeWidth = 1,
      );
    }

    final framePaint = Paint()
      ..color = const Color(0xFFFFFC00)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-18, 16), const Offset(-2, 14), framePaint);
    canvas.drawLine(const Offset(-18, 16), const Offset(-8, 2), framePaint);
    canvas.drawLine(const Offset(-2, 14), const Offset(-8, 2), framePaint);
    canvas.drawLine(const Offset(-2, 14), const Offset(12, 4), framePaint);
    canvas.drawLine(const Offset(-8, 2), const Offset(12, 4), framePaint);
    canvas.drawLine(const Offset(12, 4), const Offset(18, 16), framePaint);

    canvas.drawLine(const Offset(-12, 0), const Offset(-4, 0), Paint()..color = Colors.black..strokeWidth = 4);
    canvas.drawLine(const Offset(12, 4), const Offset(14, -4), Paint()..color = Colors.white..strokeWidth = 3);
    canvas.drawLine(const Offset(10, -4), const Offset(18, -4), Paint()..color = const Color(0xFFFF2A55)..strokeWidth = 3);

    final bodyRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-14, -18, 20, 20),
      const Radius.circular(6),
    );
    canvas.drawRRect(bodyRect, Paint()..color = const Color(0xFF0F172A));

    const headRadius = 11.0;
    canvas.save();
    canvas.translate(-4 - headRadius, -24 - headRadius);
    playerAvatarPainter.paint(canvas, const Size(headRadius * 2, headRadius * 2));
    canvas.restore();
  }

  void _drawOnFootRunner(Canvas canvas) {
    if (isMoving && !isJumping) {
      final legAngle = math.sin(runCycle) * 0.45;
      final legPaint = Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeWidth = 4.0;
      canvas.drawLine(const Offset(-6, 12), Offset(-6 - (legAngle * 18), 24), legPaint);
      canvas.drawLine(const Offset(6, 12), Offset(6 + (legAngle * 18), 24), legPaint);
    } else {
      final legPaint = Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeWidth = 4.0;
      canvas.drawLine(const Offset(-6, 12), const Offset(-6, 24), legPaint);
      canvas.drawLine(const Offset(6, 12), const Offset(6, 24), legPaint);
    }

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, 2), width: 28, height: 32),
      const Radius.circular(10),
    );
    canvas.drawRRect(bodyRect, Paint()..color = const Color(0xFFFFFC00));
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    const headRadius = 13.0;
    canvas.save();
    canvas.translate(-headRadius, -22 - headRadius);
    playerAvatarPainter.paint(canvas, const Size(headRadius * 2, headRadius * 2));
    canvas.restore();
  }
}

/// 🏰 Node representing a neighbor's house positioned on the hill
class WorldHouseNode {
  final PocketNeighbor neighbor;
  final double x;
  final double y;
  final int sectorIndex;
  final String streetSignLabel;
  final bool isPlayerHome;
  late final HouseMasterComponent houseMaster;
  late final VectorAvatarPainter avatarPainter;

  WorldHouseNode({
    required this.neighbor,
    required this.x,
    required this.y,
    required this.sectorIndex,
    required this.streetSignLabel,
    this.isPlayerHome = false,
    bool isNight = false,
  }) {
    houseMaster = HouseMasterComponent(
      day: neighbor.day.clamp(1, 90),
      streak: neighbor.hasActiveShield ? 7 : 1,
      palette: HousePalette.getById(neighbor.paletteId),
      isDamaged: neighbor.isDamaged,
    );
    houseMaster.lightsOn = isNight || neighbor.day >= 20;
    houseMaster.resize(Vector2(380, 320));

    avatarPainter = VectorAvatarPainter(
      config: VectorAvatarConfig.getEvolutionAvatarForStage(neighbor.day),
      showBackgroundAura: false,
    );
  }

  void update(double dt) {
    houseMaster.update(dt);
  }
}

/// 🟡 Spinning 3D Golden Coin
class WorldCoin {
  final double x;
  final double y;
  bool collected = false;
  double spinPhase;

  WorldCoin({
    required this.x,
    required this.y,
    this.spinPhase = 0.0,
  });

  void render(Canvas canvas, double gameTime) {
    if (collected) return;
    final widthScale = math.cos((gameTime * 6.5) + spinPhase).abs();

    canvas.drawCircle(
      Offset(x, y),
      12.0,
      Paint()
        ..color = const Color(0xFFFFFC00).withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    final coinRect = Rect.fromCenter(
      center: Offset(x, y),
      width: math.max(3.0, 16.0 * widthScale),
      height: 16.0,
    );
    canvas.drawOval(
      coinRect,
      Paint()..color = const Color(0xFFF59E0B),
    );

    final innerRect = Rect.fromCenter(
      center: Offset(x, y),
      width: math.max(2.0, 13.0 * widthScale),
      height: 13.0,
    );
    canvas.drawOval(
      innerRect,
      Paint()..color = const Color(0xFFFFFC00),
    );

    if (widthScale > 0.45) {
      canvas.drawCircle(
        Offset(x, y),
        2.4 * widthScale,
        Paint()..color = const Color(0xFFB45309),
      );
    }
  }
}

/// 📘 Floating English Vocabulary Orb with Multilingual Translation
class EnglishWordOrb {
  final double x;
  final double y;
  final OpenWorldVocabItem vocabItem;
  bool collected = false;

  EnglishWordOrb({
    required this.x,
    required this.y,
    required this.vocabItem,
  });

  String get word => vocabItem.word;
  String get meaning => vocabItem.meaningEn;

  void render(Canvas canvas, double gameTime) {
    if (collected) return;
    final floatY = y + (math.sin(gameTime * 4.0 + x) * 5.0);

    canvas.drawCircle(
      Offset(x, floatY),
      18,
      Paint()
        ..color = const Color(0xFF00F0FF).withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(Offset(x, floatY), 13, Paint()..color = const Color(0xFF0284C7));
    canvas.drawCircle(
      Offset(x, floatY),
      13,
      Paint()
        ..color = const Color(0xFFFFFC00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Mini icon inside
    final iconTp = TextPainter(
      text: const TextSpan(
        text: '📖',
        style: TextStyle(fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    iconTp.paint(canvas, Offset(x - (iconTp.width / 2), floatY - (iconTp.height / 2)));

    // Word label on top
    final tp = TextPainter(
      text: TextSpan(
        text: word,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9.0,
          fontWeight: FontWeight.w900,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - (tp.width / 2), floatY - 24));
  }
}

/// 📜 Roadside Electronic Learning Billboard (Poems, Quotes, Vocabulary)
class RoadsideLearningBoard {
  final double x;
  final double y;
  final String category; // 'VOCAB', 'POEM', 'QUOTE'
  final String title;
  final String content;
  final String subtext;
  final OpenWorldVocabItem? vocabItem;
  bool isRead = false;

  RoadsideLearningBoard({
    required this.x,
    required this.y,
    required this.category,
    required this.title,
    required this.content,
    required this.subtext,
    this.vocabItem,
  });

  void render(Canvas canvas, double gameTime, String selectedLanguage) {
    final boardW = 230.0;
    final boardH = 74.0;
    final boardCenterY = y - 78.0;

    // Twin steel support legs
    canvas.drawLine(Offset(x - 70, y), Offset(x - 70, boardCenterY + 34), Paint()..color = const Color(0xFF334155)..strokeWidth = 4);
    canvas.drawLine(Offset(x + 70, y), Offset(x + 70, boardCenterY + 34), Paint()..color = const Color(0xFF334155)..strokeWidth = 4);

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x, boardCenterY), width: boardW, height: boardH),
      const Radius.circular(10),
    );

    canvas.drawRRect(rect, Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.95));

    final themeColor = category == 'POEM'
        ? const Color(0xFFA855F7)
        : (category == 'QUOTE' ? const Color(0xFF38BDF8) : const Color(0xFFFFFC00));

    canvas.drawRRect(
      rect,
      Paint()
        ..color = themeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    final displayTitle = vocabItem != null ? '[VOCAB] ${vocabItem!.word} (${vocabItem!.partOfSpeech})' : '[$category] $title';
    final displayBody = vocabItem != null ? vocabItem!.getMeaning(selectedLanguage) : content;
    final displaySub = vocabItem != null ? '${vocabItem!.phonetics} • "${vocabItem!.exampleEn}"' : subtext;

    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$displayTitle\n',
            style: TextStyle(
              color: themeColor,
              fontSize: 9.0,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          TextSpan(
            text: '$displayBody\n',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: displaySub,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 8.0,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 3,
      ellipsis: '...',
    )..layout(maxWidth: boardW - 16);

    tp.paint(canvas, Offset(x - (tp.width / 2), boardCenterY - (tp.height / 2)));
  }
}

/// 🚀 Animated Launch Ramp on Hill Crests & Bridge Entrances
class WorldJumpRamp {
  final double x;
  final double y;
  final double angle;

  WorldJumpRamp({
    required this.x,
    required this.y,
    this.angle = -0.22,
  });

  void render(Canvas canvas, double gameTime) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);

    final rampPath = Path();
    rampPath.moveTo(-32, 0);
    rampPath.lineTo(32, -22);
    rampPath.lineTo(32, 0);
    rampPath.close();

    canvas.drawPath(rampPath, Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.95));
    canvas.drawPath(
      rampPath,
      Paint()
        ..color = const Color(0xFFFF9900)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Animated chevrons
    final chevronPhase = (gameTime * 4.0) % 1.0;
    for (int i = 0; i < 3; i++) {
      final cx = -14.0 + (i * 18.0) + (chevronPhase * 8.0);
      final cy = -5.0 - (i * 5.0);
      final arrow = Path();
      arrow.moveTo(cx - 5, cy + 5);
      arrow.lineTo(cx, cy);
      arrow.lineTo(cx - 5, cy - 5);
      canvas.drawPath(
        arrow,
        Paint()
          ..color = const Color(0xFFFFFC00)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      );
    }

    final tp = TextPainter(
      text: const TextSpan(
        text: '🚀 RAMP',
        style: TextStyle(
          color: Color(0xFFFF9900),
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, const Offset(6, 2));

    canvas.restore();
  }
}

/// ⚡ English Idiom Speed Boost Gate
class EnglishSpeedGate {
  final double x;
  final double y;
  final String idiom;
  final String meaning;
  double lastTriggerTime = -999.0;

  EnglishSpeedGate({
    required this.x,
    required this.y,
    required this.idiom,
    required this.meaning,
  });

  void render(Canvas canvas, double gameTime) {
    final gateHeight = 70.0;
    final topY = y - gateHeight;

    final gatePaint = Paint()
      ..color = const Color(0xFF00F0FF)
      ..strokeWidth = 3.5;
    canvas.drawLine(Offset(x - 24, y), Offset(x - 24, topY), gatePaint);
    canvas.drawLine(Offset(x + 24, y), Offset(x + 24, topY), gatePaint);
    canvas.drawLine(Offset(x - 24, topY), Offset(x + 24, topY), gatePaint);

    final bannerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x, topY - 12), width: 150, height: 24),
      const Radius.circular(6),
    );
    canvas.drawRRect(bannerRect, Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.92));
    canvas.drawRRect(
      bannerRect,
      Paint()
        ..color = const Color(0xFF00F0FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: idiom,
        style: const TextStyle(
          color: Color(0xFFFFFC00),
          fontSize: 9.0,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - (tp.width / 2), topY - 12 - (tp.height / 2)));
  }
}

/// ✨ Floating Text Effect (+1 🟡, +5 XP, Air Time)
class FloatingTextEffect {
  final String text;
  double x;
  double y;
  final Color color;
  double life = 0.0;
  final double maxLife = 1.2;

  FloatingTextEffect({
    required this.text,
    required this.x,
    required this.y,
    required this.color,
  });

  bool get isDead => life >= maxLife;

  void update(double dt) {
    life += dt;
    y -= 35.0 * dt;
  }

  void render(Canvas canvas) {
    final progress = life / maxLife;
    final alpha = (1.0 - progress).clamp(0.0, 1.0);

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color.withValues(alpha: alpha),
          fontSize: 12.0,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: alpha * 0.8),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - (tp.width / 2), y));
  }
}

class RoamingRobotNpc {
  final String id;
  final String name;
  double x;
  double y;
  final double patrolMinX;
  final double patrolMaxX;
  double speed = 40.0;
  double facing = 1.0;
  final String speechText;

  RoamingRobotNpc({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.patrolMinX,
    required this.patrolMaxX,
    required this.speechText,
  });

  void update(double dt) {
    x += speed * facing * dt;
    if (x >= patrolMaxX) {
      x = patrolMaxX;
      facing = -1.0;
    } else if (x <= patrolMinX) {
      x = patrolMinX;
      facing = 1.0;
    }
  }
}

enum CruisingBoatType { kettuvallam, cruiseShip, speedboat, sailboat }

/// ⛵ Diverse Living Fleet: Kerala Kettuvallam, Cruise Liner, Speedboat & Sailboat
class CruisingBoat {
  double x;
  final double y;
  final double speed;
  final CruisingBoatType boatType;
  double animationTimer = 0.0;

  CruisingBoat({
    required this.x,
    required this.y,
    required this.speed,
    required this.boatType,
  });

  void update(double dt, double worldWidth) {
    x += speed * dt;
    animationTimer += dt;
    if (x > worldWidth + 250) {
      x = -250;
    }
  }

  void render(Canvas canvas, bool isNight) {
    canvas.save();
    canvas.translate(x, y);

    switch (boatType) {
      case CruisingBoatType.kettuvallam:
        _drawKettuvallam(canvas, isNight);
        break;
      case CruisingBoatType.cruiseShip:
        _drawCruiseShip(canvas, isNight);
        break;
      case CruisingBoatType.speedboat:
        _drawSpeedboat(canvas, isNight);
        break;
      case CruisingBoatType.sailboat:
        _drawSailboat(canvas, isNight);
        break;
    }

    canvas.restore();
  }

  /// 🛶 Authentic Kerala Kettuvallam (Houseboat)
  void _drawKettuvallam(Canvas canvas, bool isNight) {
    final hull = Path();
    hull.moveTo(-36, 0);
    hull.quadraticBezierTo(-22, 10, 0, 10);
    hull.quadraticBezierTo(22, 10, 36, 0);
    hull.quadraticBezierTo(24, 4, 0, 4);
    hull.quadraticBezierTo(-24, 4, -36, 0);
    hull.close();

    canvas.drawPath(hull, Paint()..color = const Color(0xFF451A03));
    canvas.drawPath(hull, Paint()..color = const Color(0xFF78350F)..style = PaintingStyle.stroke..strokeWidth = 1.2);

    final canopy = Path();
    canopy.moveTo(-24, 1);
    canopy.quadraticBezierTo(-20, -16, 0, -18);
    canopy.quadraticBezierTo(20, -16, 24, 1);
    canopy.close();
    canvas.drawPath(canopy, Paint()..color = const Color(0xFFD97706));
    canvas.drawPath(canopy, Paint()..color = const Color(0xFF92400E)..style = PaintingStyle.stroke..strokeWidth = 1);

    for (double rx = -16; rx <= 16; rx += 8) {
      canvas.drawLine(Offset(rx, 1), Offset(rx * 0.8, -17), Paint()..color = const Color(0xFF78350F)..strokeWidth = 1);
    }

    for (double wx = -12; wx <= 12; wx += 10) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(wx, -5), width: 6, height: 5), const Radius.circular(1.5)),
        Paint()..color = isNight ? const Color(0xFFFEF08A) : const Color(0xFFFFFBEB),
      );
    }

    canvas.drawLine(const Offset(30, 0), const Offset(30, -5), Paint()..color = Colors.black87..strokeWidth = 1);
    canvas.drawCircle(const Offset(30, -4), 2.5, Paint()..color = const Color(0xFFFFD700));
    if (isNight) {
      canvas.drawCircle(
        const Offset(30, -4),
        7.0,
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    canvas.drawOval(
      const Rect.fromLTWH(-46, 6, 20, 3),
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  /// 🚢 Luxury Ocean Cruise Liner
  void _drawCruiseShip(Canvas canvas, bool isNight) {
    final lowerHull = Path();
    lowerHull.moveTo(-55, 0);
    lowerHull.lineTo(-44, 12);
    lowerHull.lineTo(44, 12);
    lowerHull.lineTo(58, 0);
    lowerHull.close();
    canvas.drawPath(lowerHull, Paint()..color = const Color(0xFF1E3A8A));

    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-48, -8, 96, 9), const Radius.circular(2)),
      Paint()..color = const Color(0xFFF8FAFC),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-38, -16, 76, 9), const Radius.circular(2)),
      Paint()..color = const Color(0xFFF1F5F9),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-26, -23, 48, 8), const Radius.circular(2)),
      Paint()..color = const Color(0xFFE2E8F0),
    );

    for (double px = -40; px <= 38; px += 10) {
      canvas.drawCircle(
        Offset(px, -4),
        1.6,
        Paint()..color = isNight ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
      );
      if (px >= -30 && px <= 30) {
        canvas.drawCircle(
          Offset(px, -12),
          1.5,
          Paint()..color = isNight ? const Color(0xFFFFFC00) : const Color(0xFF0284C7),
        );
      }
    }

    canvas.drawRect(const Rect.fromLTWH(-16, -30, 7, 8), Paint()..color = const Color(0xFFDC2626));
    canvas.drawRect(const Rect.fromLTWH(4, -30, 7, 8), Paint()..color = const Color(0xFFDC2626));
    canvas.drawRect(const Rect.fromLTWH(-16, -30, 7, 2), Paint()..color = Colors.black87);
    canvas.drawRect(const Rect.fromLTWH(4, -30, 7, 2), Paint()..color = Colors.black87);

    final puffX = -22.0 - (animationTimer * 12.0 % 20.0);
    final puffY = -34.0 - (animationTimer * 6.0 % 10.0);
    canvas.drawCircle(Offset(puffX, puffY), 3.5, Paint()..color = Colors.white.withValues(alpha: 0.35));

    canvas.drawLine(const Offset(-4, -23), const Offset(-4, -34), Paint()..color = Colors.white70..strokeWidth = 1.2);
    canvas.drawLine(const Offset(-8, -31), const Offset(0, -31), Paint()..color = Colors.white70..strokeWidth = 1);

    canvas.drawOval(const Rect.fromLTWH(-68, 8, 22, 4), Paint()..color = Colors.white.withValues(alpha: 0.4));
    canvas.drawOval(const Rect.fromLTWH(48, 8, 14, 3), Paint()..color = Colors.white.withValues(alpha: 0.4));
  }

  /// 🚤 High-Speed Motorboat
  void _drawSpeedboat(Canvas canvas, bool isNight) {
    final hull = Path();
    hull.moveTo(-24, 1);
    hull.lineTo(-14, 7);
    hull.lineTo(24, 7);
    hull.lineTo(32, 1);
    hull.close();
    canvas.drawPath(hull, Paint()..color = const Color(0xFF06B6D4));

    final stripe = Path();
    stripe.moveTo(-20, 2);
    stripe.lineTo(-12, 6);
    stripe.lineTo(22, 6);
    stripe.lineTo(28, 2);
    stripe.close();
    canvas.drawPath(stripe, Paint()..color = const Color(0xFFF97316));

    final glass = Path();
    glass.moveTo(2, 1);
    glass.lineTo(8, -6);
    glass.lineTo(16, -6);
    glass.lineTo(14, 1);
    glass.close();
    canvas.drawPath(glass, Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.8));

    canvas.drawCircle(const Offset(6, -8), 3.0, Paint()..color = Colors.white);

    final wake = Path();
    wake.moveTo(-24, 4);
    wake.lineTo(-44, -2);
    wake.lineTo(-40, 7);
    wake.close();
    canvas.drawPath(wake, Paint()..color = Colors.white.withValues(alpha: 0.7));
    canvas.drawOval(const Rect.fromLTWH(-52, 5, 26, 4), Paint()..color = Colors.white.withValues(alpha: 0.6));
  }

  /// ⛵ Classic Two-Sail Yacht
  void _drawSailboat(Canvas canvas, bool isNight) {
    final hullPath = Path();
    hullPath.moveTo(-22, 0);
    hullPath.lineTo(-14, 7);
    hullPath.lineTo(18, 7);
    hullPath.lineTo(26, 0);
    hullPath.close();

    canvas.drawPath(hullPath, Paint()..color = const Color(0xFF78350F));
    canvas.drawPath(hullPath, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1);

    canvas.drawLine(const Offset(3, 0), const Offset(3, -28), Paint()..color = const Color(0xFF451A03)..strokeWidth = 2);

    final mainSail = Path();
    mainSail.moveTo(3, -26);
    mainSail.lineTo(18, -4);
    mainSail.lineTo(3, -4);
    mainSail.close();
    canvas.drawPath(mainSail, Paint()..color = const Color(0xFFFEF08A));

    final jibSail = Path();
    jibSail.moveTo(2, -24);
    jibSail.lineTo(-12, -4);
    jibSail.lineTo(2, -4);
    jibSail.close();
    canvas.drawPath(jibSail, Paint()..color = const Color(0xFFEF4444));

    final flag = Path();
    flag.moveTo(3, -28);
    flag.lineTo(-4, -26);
    flag.lineTo(3, -24);
    flag.close();
    canvas.drawPath(flag, Paint()..color = const Color(0xFF00F0FF));

    canvas.drawOval(const Rect.fromLTWH(-32, 5, 16, 3), Paint()..color = Colors.white.withValues(alpha: 0.5));
  }
}

/// 🕊️ Flying Seagull in the Sky
class FlyingBird {
  double x;
  double y;
  final double speed;
  double wingAngle = 0.0;

  FlyingBird({
    required this.x,
    required this.y,
    required this.speed,
  });

  void update(double dt, double worldWidth) {
    x += speed * dt;
    wingAngle += dt * 8.0;
    if (x > worldWidth + 100) {
      x = -100;
    }
  }

  void render(Canvas canvas) {
    final wingY = math.sin(wingAngle) * 3.5;
    final birdPaint = Paint()..color = Colors.white..strokeWidth = 1.5..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(x - 8, y + wingY);
    path.quadraticBezierTo(x - 4, y - 4, x, y);
    path.quadraticBezierTo(x + 4, y - 4, x + 8, y + wingY);
    canvas.drawPath(path, birdPaint);
  }
}

class JumpDustParticle {
  double x;
  double y;
  double vx;
  double vy;
  double life = 0.0;
  final double maxLife = 0.45;

  JumpDustParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
  });

  bool get isDead => life >= maxLife;

  void update(double dt) {
    life += dt;
    x += vx * dt;
    y += vy * dt;
    vx *= 0.92;
    vy *= 0.92;
  }

  void render(Canvas canvas) {
    final progress = life / maxLife;
    final alpha = (1.0 - progress).clamp(0.0, 1.0);
    final size = 4.5 + (progress * 6.0);
    final paint = Paint()..color = const Color(0xFFFDE047).withValues(alpha: alpha * 0.7);
    canvas.drawCircle(Offset(x, y), size, paint);
  }
}

/// 🚀 Booster Flame Particle for Aerial Jumps
class BoosterFlameParticle {
  double x;
  double y;
  double vx;
  double vy;
  double life = 0.0;
  final double maxLife = 0.35;
  final Color color;

  BoosterFlameParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
  });

  bool get isDead => life >= maxLife;

  void update(double dt) {
    life += dt;
    x += vx * dt;
    y += vy * dt;
    vx *= 0.90;
    vy *= 0.90;
  }

  void render(Canvas canvas) {
    final progress = life / maxLife;
    final alpha = (1.0 - progress).clamp(0.0, 1.0);
    final size = (4.0 * (1.0 - progress)).clamp(1.0, 5.0);
    canvas.drawCircle(
      Offset(x, y),
      size,
      Paint()
        ..color = color.withValues(alpha: alpha * 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }
}
