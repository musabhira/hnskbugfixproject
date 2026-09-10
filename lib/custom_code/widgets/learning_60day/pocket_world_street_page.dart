import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../avatar/vector_avatar_config.dart';
import '../avatar/vector_avatar_widget.dart';
import 'flame_english_house_game.dart';
import 'pocket_citadel_attack_page.dart';
import 'pocket_defense_admin_modal.dart';
import 'pocket_fortress_defense_service.dart';
import 'pocket_open_world_game_page.dart';
import 'pocket_world_game_rules_modal.dart';

/// 🌍 Pocket World Street Model: A resident on the neighborhood street
class PocketNeighbor {
  final String id;
  final String name;
  final int day;
  final int streak;
  final String rank;
  final String paletteId;
  final bool isMe;
  final bool hasActiveShield;
  final String statusMessage;
  final bool isBanned;
  final String? banReason;
  final bool isPocketRobo;
  final bool isDamaged;
  final int hp;
  final int maxHp;

  const PocketNeighbor({
    required this.id,
    required this.name,
    required this.day,
    required this.streak,
    required this.rank,
    required this.paletteId,
    this.isMe = false,
    this.hasActiveShield = true,
    required this.statusMessage,
    this.isBanned = false,
    this.banReason,
    this.isPocketRobo = false,
    this.isDamaged = false,
    this.hp = 100,
    this.maxHp = 100,
  });
}

/// 🌍 Pocket World: Interactive 2D Parallax Neighborhood Street
/// As you swipe horizontally, the focused house scales up while neighbors scale down smoothly.
class PocketWorldStreetPage extends StatefulWidget {
  final int currentDay;
  final int streak;
  final bool autoRollRaid;

  const PocketWorldStreetPage({
    super.key,
    required this.currentDay,
    required this.streak,
    this.autoRollRaid = false,
  });

  @override
  State<PocketWorldStreetPage> createState() => _PocketWorldStreetPageState();
}

class _PocketWorldStreetPageState extends State<PocketWorldStreetPage> {
  late final PageController _pageController;
  double _currentPage = 0.0;
  late List<PocketNeighbor> _neighbors;
  Set<String> _bannedHouseIds = {'neighbor_cheat'};
  Set<String> _protectedHouseIds = {};
  bool _isRollingRandomTarget = false;
  bool _hasWonAnyRaid = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.82);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });
    _loadNeighborsFromSupabase();

    // Audio Directive: Dynamic level matching (Level 4 targets Level 6) & Dynamic Robot Homes
    final dynamicTargetHomes = PocketFortressDefenseService.generateDynamicTargetBracketHomes(widget.currentDay, count: 6);
    _neighbors = [
      PocketNeighbor(
        id: 'me',
        name: 'You (Your Pocket Home)',
        day: widget.currentDay,
        streak: widget.streak,
        rank: widget.currentDay >= 71 ? 'Grandmaster' : (widget.currentDay >= 30 ? 'Scholar' : 'Explorer'),
        paletteId: 'terracotta',
        isMe: true,
        hasActiveShield: true,
        statusMessage: 'Practicing English daily! 🏡',
      ),
      ...dynamicTargetHomes,
    ];

    _loadBannedAndProtectedHouses();

    if (widget.autoRollRaid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _rollRandomRaidTarget();
      });
    }
  }

  Future<void> _loadBannedAndProtectedHouses() async {
    final reports = await PocketFortressDefenseService.getDefenseReports();
    final bannedSet = <String>{'neighbor_cheat'};
    for (final r in reports) {
      if (r.status == 'banned' || await PocketFortressDefenseService.isHouseBanned(r.houseId)) {
        bannedSet.add(r.houseId);
      }
    }
    if (await PocketFortressDefenseService.isHouseBanned('me')) {
      bannedSet.add('me');
    }

    final protectedSet = <String>{};
    for (final n in _neighbors) {
      if (await PocketFortressDefenseService.isUnderPresidentialProtection(n.id)) {
        protectedSet.add(n.id);
      }
    }

    if (mounted) {
      setState(() {
        _bannedHouseIds = bannedSet;
        _protectedHouseIds = protectedSet;
      });
    }
  }

  Future<void> _loadNeighborsFromSupabase() async {
    try {
      final supaNeighbors = await PocketFortressDefenseService.fetchSupabaseNeighbors(limit: 30);
      if (supaNeighbors.isNotEmpty && mounted) {
        setState(() {
          final me = _neighbors.firstWhere((n) => n.isMe, orElse: () => _neighbors[0]);
          final robo = _neighbors.firstWhere((n) => n.isPocketRobo, orElse: () => _neighbors[1]);
          final otherNeighbors = supaNeighbors.where((n) => !n.isMe).toList();

          _neighbors = [me, robo, ...otherNeighbors];
        });
      }
    } catch (e) {
      debugPrint('Error loading Supabase neighbors: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _ringDoorbell(PocketNeighbor neighbor) {
    HapticFeedback.heavyImpact();
    if (neighbor.isMe) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🔔 You rang your own doorbell! Warm window lights toggled.',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF0284C7),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Doorbell with Visitor Guestbook Greeting Dialog!
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🔔', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ring ${neighbor.name}’s Bell',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Leave a friendly cheer in their guestbook!',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white60),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...[
                '🏰 "Loved your English House architecture!"',
                '🔥 "Keep up your ${neighbor.streak}-day learning streak!"',
                '⚔️ "See you in Pocket Battle!"',
                '👋 "Just dropping by to say hello!"',
              ].map((msg) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      HapticFeedback.mediumImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '🔔 Doorbell chimed! Notification sent to ${neighbor.name}!',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: const Color(0xFF059669),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                    child: Text(msg, style: GoogleFonts.outfit(fontSize: 13)),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openEnglishDuelDialog(PocketNeighbor neighbor) async {
    HapticFeedback.selectionClick();
    if (!PocketFortressDefenseService.canUserAttack(widget.currentDay)) {
      HapticFeedback.vibrate();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
          ),
          title: Row(
            children: [
              const Text('🔒 ', style: TextStyle(fontSize: 22)),
              Expanded(
                child: Text(
                  'Raid Warfare Unlocks at Level 4',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          content: Text(
            'Complete your English training missions up to Level 4 (Day 4) to unlock direct citadel attacks and test your vocabulary under pressure!',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
              child: const Text('UNDERSTOOD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return;
    }

    // Audio Directive: Full-screen attack page with house at the bottom and defense questions on top
    final won = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PocketCitadelAttackPage(
          neighbor: neighbor,
          attackerDay: widget.currentDay,
          attackerStreak: widget.streak,
        ),
      ),
    );

    if (won == true && mounted) {
      setState(() => _hasWonAnyRaid = true);
      _loadBannedAndProtectedHouses();
    }
  }




  /// 🎲 Random House Raid Roulette ("കടകടകാ" Rapid Roll Animation)
  /// User audio directive: "ഒരു നാലാമത്തെ ലെവൽ ഒക്കെ ആകുമ്പോൾ നമുക്ക് അറ്റാക്ക് സ്റ്റാർട്ട് ചെയ്യാം...
  /// അറ്റാക്കിൽ ടാപ്പ് ചെയ്യുമ്പോൾ റാൻഡം ആയിട്ട് സെലക്ട് ചെയ്യാൻ പറ്റുന്ന ഒരു ബട്ടൺ കൊടുക്കണം...
  /// കടകടകാ എന്ന് അടിക്കുമ്പോൾ വേറെ വേറെ വേറെ അറ്റാക്ക് ചെയ്യാനുള്ള വീടുകൾ ഒക്കെ വരും.
  /// നാലാമത്തെ ആണെന്നുണ്ടെങ്കിൽ അഞ്ചോ ആറോ ആ ഒരു ലെവലിൽ ഉള്ള വീടുകൾ ആയിരിക്കും ആക്രമിക്കാൻ ഉള്ള ഓപ്ഷൻസ് ഉണ്ടാവുക."
  Future<void> _rollRandomRaidTarget() async {
    if (!PocketFortressDefenseService.canUserAttack(widget.currentDay)) {
      HapticFeedback.vibrate();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
          ),
          title: Row(
            children: [
              const Text('🔒 ', style: TextStyle(fontSize: 22)),
              Expanded(
                child: Text(
                  'Raid Warfare Unlocks at Level 4',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          content: Text(
            'Complete your English training missions up to Level 4 (Day 4) to unlock direct citadel attacks and test your vocabulary under pressure!',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
              child: const Text('UNDERSTOOD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return;
    }

    if (_isRollingRandomTarget) return;
    setState(() => _isRollingRandomTarget = true);

    // Rapid slot-machine animation ("കടകടകാ" selection ticks through houses)
    final totalNeighbors = _neighbors.length;
    for (int i = 0; i < 7; i++) {
      HapticFeedback.selectionClick();
      final randomIdx = math.Random().nextInt(totalNeighbors);
      _pageController.animateToPage(
        randomIdx,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
      );
      await Future.delayed(const Duration(milliseconds: 160));
    }

    // Audio Directive: Level 4 user targets Level 6 (+1 to +3 level bracket)
    final minTargetDay = widget.currentDay >= 4 ? widget.currentDay + 1 : 2;
    final maxTargetDay = widget.currentDay >= 4 ? widget.currentDay + 3 : 6;

    List<PocketNeighbor> candidates = _neighbors
        .where((n) =>
            !n.isMe &&
            !n.isBanned &&
            !_bannedHouseIds.contains(n.id) &&
            !_protectedHouseIds.contains(n.id) &&
            n.day >= minTargetDay &&
            n.day <= maxTargetDay)
        .toList();

    if (candidates.isEmpty) {
      // Generate realistic dynamic robot homes matching user's target bracket!
      final dynamicRobots = PocketFortressDefenseService.generateDynamicTargetBracketHomes(widget.currentDay, count: 6);
      setState(() {
        _neighbors.addAll(dynamicRobots);
      });
      candidates = dynamicRobots;
    }

    PocketNeighbor targetNeighbor;
    candidates.shuffle();
    targetNeighbor = candidates.first;
    final targetIdx = _neighbors.indexOf(targetNeighbor);
    if (targetIdx != -1) {
      await _pageController.animateToPage(
        targetIdx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }

    HapticFeedback.heavyImpact();
    setState(() => _isRollingRandomTarget = false);

    if (!mounted) return;
    _openEnglishDuelDialog(targetNeighbor);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _hasWonAnyRaid);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF070B14),
        body: SafeArea(
          child: Column(
            children: [
              // --- TOP HEADER BAR ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context, _hasWonAnyRaid),
                    ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🌍', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              'Pocket World',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF38BDF8), width: 0.8),
                              ),
                              child: Text(
                                'Avenue #4',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF38BDF8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF22C55E),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${_neighbors.length} Learners on this street • Swipe to explore',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => PocketWorldGameRulesModal.show(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF38BDF8), width: 1),
                      ),
                      child: Row(
                        children: [
                          const Text('📜', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            'Rules',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF38BDF8),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () async {
                      await PocketDefenseAdminModal.show(context);
                      _loadBannedAndProtectedHouses();
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.shade400, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Text('⚖️', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            'Admin',
                            style: GoogleFonts.outfit(
                              color: Colors.amber.shade200,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- 🌐 SWITCH TO OPEN WORLD (FREE ROAM) BANNER ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PocketOpenWorldGamePage(
                        currentDay: widget.currentDay,
                        streak: widget.streak,
                      ),
                    ),
                  ).then((_) {
                    _loadNeighborsFromSupabase();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.6), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00F0FF).withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFC00),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('🎮', style: TextStyle(fontSize: 15)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'OPEN WORLD (FREE ROAM)',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFFFC00),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'NEW',
                                    style: GoogleFonts.outfit(
                                      color: Colors.black,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Walk, jump & explore neighborhoods in live 2D Flame engine!',
                              style: GoogleFonts.outfit(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFFFFC00), size: 13),
                    ],
                  ),
                ),
              ),
            ),

            // --- SUB-HEADER STATUS BANNER & INTERACTIVE RANDOM RAID ROLL ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131D31),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          const Text('🏘️', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.currentDay >= 4
                                  ? 'Level ${widget.currentDay}: Raid higher citadels (+1 or +2 Lvls) to sharpen English!'
                                  : 'Raid warfare unlocks at Level 4. Complete tasks to unlock!',
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _isRollingRandomTarget ? null : _rollRandomRaidTarget,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.currentDay >= 4
                              ? [const Color(0xFFDC2626), const Color(0xFF991B1B)]
                              : [const Color(0xFF334155), const Color(0xFF1E293B)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.currentDay >= 4 ? const Color(0xFFF87171) : Colors.white24,
                          width: 1.2,
                        ),
                        boxShadow: [
                          if (widget.currentDay >= 4)
                            BoxShadow(
                              color: Colors.redAccent.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isRollingRandomTarget) ...[
                            const SizedBox(
                              width: 13,
                              height: 13,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Rolling...',
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ] else ...[
                            const Text('🎲', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 5),
                            Text(
                              widget.currentDay >= 4 ? 'ROLL RAID ⚔️' : 'LOCKED 🔒',
                              style: GoogleFonts.outfit(
                                color: widget.currentDay >= 4 ? Colors.white : Colors.white60,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- HORIZONTAL PARALLAX STREET PAGE VIEW ---
            // As user scrolls, focused house scales up to 1.0, while side houses scale to 0.82!
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _neighbors.length,
                itemBuilder: (context, index) {
                  final neighbor = _neighbors[index];
                  final isBanned = neighbor.isBanned || _bannedHouseIds.contains(neighbor.id);

                  // Parallax scaling calculation
                  final pageDiff = (_currentPage - index).abs();
                  final scale = (1.0 - (pageDiff * 0.18)).clamp(0.80, 1.0);
                  final opacity = (1.0 - (pageDiff * 0.35)).clamp(0.55, 1.0);

                  return Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: neighbor.isMe
                                ? const Color(0xFF0284C7)
                                : (neighbor.hasActiveShield ? Colors.white12 : Colors.redAccent.withValues(alpha: 0.6)),
                            width: neighbor.isMe ? 2.0 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: neighbor.isMe
                                  ? const Color(0xFF0284C7).withValues(alpha: 0.3)
                                  : Colors.black45,
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // --- TOP NEIGHBOR INFO CARD ---
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                              child: Row(
                                children: [
                                  // Resident Avatar
                                  SizedBox(
                                    width: 42,
                                    height: 42,
                                    child: VectorAvatarWidget(
                                      config: VectorAvatarConfig.getEvolutionAvatarForStage(neighbor.day),
                                      size: 42,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
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
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (neighbor.isMe) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF0284C7),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: const Text(
                                                  'YOU',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              '🔥 Day ${neighbor.day}',
                                              style: GoogleFonts.outfit(
                                                color: Colors.amber.shade400,
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '• ${neighbor.rank}',
                                              style: TextStyle(
                                                color: Colors.white.withValues(alpha: 0.65),
                                                fontSize: 11,
                                              ),
                                            ),
                                            if (neighbor.day >= 30) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                decoration: BoxDecoration(
                                                  color: neighbor.day >= 90
                                                      ? Colors.amber.withValues(alpha: 0.2)
                                                      : const Color(0xFF1E293B),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: neighbor.day >= 90 ? Colors.amber : Colors.white24,
                                                    width: 0.8,
                                                  ),
                                                ),
                                                child: Text(
                                                  neighbor.day >= 90
                                                      ? '🏎️ Rolls-Royce'
                                                      : (neighbor.day >= 60 ? '🚙 Grand SUV' : '🏍️ Superbike'),
                                                  style: GoogleFonts.outfit(
                                                    color: neighbor.day >= 90 ? Colors.amber : Colors.white70,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                   // Defense Status Badge
                                   Builder(builder: (ctx) {
                                     final isProtected = _protectedHouseIds.contains(neighbor.id);
                                     return Container(
                                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                       decoration: BoxDecoration(
                                         color: isBanned
                                             ? const Color(0xFF7F1D1D).withValues(alpha: 0.6)
                                             : (isProtected
                                                 ? const Color(0xFF1E3A8A).withValues(alpha: 0.6)
                                                 : (neighbor.isPocketRobo
                                                     ? const Color(0xFF312E81).withValues(alpha: 0.5)
                                                     : (neighbor.hasActiveShield
                                                         ? const Color(0xFF065F46).withValues(alpha: 0.4)
                                                         : const Color(0xFF7F1D1D).withValues(alpha: 0.4)))),
                                         borderRadius: BorderRadius.circular(10),
                                         border: Border.all(
                                           color: isBanned
                                               ? Colors.redAccent
                                               : (isProtected
                                                   ? const Color(0xFF60A5FA)
                                                   : (neighbor.isPocketRobo
                                                       ? const Color(0xFF818CF8)
                                                       : (neighbor.hasActiveShield ? const Color(0xFF10B981) : Colors.redAccent))),
                                           width: 0.8,
                                         ),
                                       ),
                                       child: Row(
                                         mainAxisSize: MainAxisSize.min,
                                         children: [
                                           Text(
                                             isBanned
                                                 ? '🚫'
                                                 : (isProtected
                                                     ? '👮‍♂️'
                                                     : (neighbor.isPocketRobo
                                                         ? '🤖'
                                                         : (neighbor.hasActiveShield ? '🛡️' : '⚠️'))),
                                             style: const TextStyle(fontSize: 11),
                                           ),
                                           const SizedBox(width: 4),
                                           Text(
                                             isBanned
                                                 ? 'Banned'
                                                 : (isProtected
                                                     ? 'Protected (48h)'
                                                     : (neighbor.isPocketRobo
                                                         ? 'Robo'
                                                         : (neighbor.hasActiveShield ? 'Home Defense' : 'Raidable'))),
                                             style: TextStyle(
                                               color: isBanned
                                                   ? Colors.redAccent
                                                   : (isProtected
                                                       ? const Color(0xFF93C5FD)
                                                       : (neighbor.isPocketRobo
                                                           ? const Color(0xFFA5B4FC)
                                                           : (neighbor.hasActiveShield ? const Color(0xFF34D399) : Colors.redAccent))),
                                               fontSize: 9.5,
                                               fontWeight: FontWeight.bold,
                                             ),
                                           ),
                                         ],
                                       ),
                                     );
                                   }),
                                ],
                              ),
                            ),

                            // --- 🏡 THE INTERACTIVE HOUSE CANVAS ---
                            Expanded(
                              child: GestureDetector(
                                onTap: neighbor.isMe ? null : () => _openEnglishDuelDialog(neighbor),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: FlameEnglishHouseWidget(
                                        currentDay: neighbor.day,
                                        streak: neighbor.streak,
                                        isDamaged: neighbor.isDamaged,
                                        houseId: neighbor.id,
                                        paletteId: neighbor.paletteId,
                                      ),
                                    ),
                                    // 👮‍♂️ Presidential Police Guard banner overlay
                                    if (_protectedHouseIds.contains(neighbor.id))
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1E3A8A).withValues(alpha: 0.9),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFF60A5FA)),
                                            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                             Text('👮‍♂️', style: TextStyle(fontSize: 12)),
                                             SizedBox(width: 4),
                                             Text(
                                               'POLICE GUARD ACTIVE',
                                               style: TextStyle(
                                                 color: Colors.white,
                                                 fontSize: 9,
                                                 fontWeight: FontWeight.w900,
                                               ),
                                             ),
                                           ],
                                         ),
                                       ),
                                     ),
                                    // Banned house ribbon seal
                                    if (isBanned)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.45),
                                          ),
                                          child: Center(
                                            child: Transform.rotate(
                                              angle: -0.15,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFDC2626),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: Colors.white, width: 2),
                                                  boxShadow: const [
                                                    BoxShadow(color: Colors.black87, blurRadius: 12),
                                                  ],
                                                ),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '🚫 BANNED BY ADMIN',
                                                      style: GoogleFonts.outfit(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w900,
                                                        fontSize: 14,
                                                        letterSpacing: 1.2,
                                                      ),
                                                    ),
                                                    if (neighbor.banReason != null) ...[
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        neighbor.banReason!,
                                                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                                                        textAlign: TextAlign.center,
                                                        maxLines: 2,
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    // House Level / Address Badge
                                    Positioned(
                                      bottom: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.6),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Plot #${index + 1}',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.7),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ),

                            // --- BOTTOM INTERACTION BUTTONS ---
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
                              child: Row(
                                children: [
                                  // Ring Bell button
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(color: Colors.white24),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                      onPressed: () => _ringDoorbell(neighbor),
                                      icon: const Text('🔔', style: TextStyle(fontSize: 13)),
                                      label: Text(
                                        neighbor.isMe ? 'Doorbell' : 'Ring Bell',
                                        style: GoogleFonts.outfit(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Builder(builder: (ctx) {
                                    final isProtected = _protectedHouseIds.contains(neighbor.id);
                                    return Expanded(
                                      flex: 1,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: neighbor.isMe
                                              ? const Color(0xFF1E293B)
                                              : (isProtected
                                                  ? const Color(0xFF1E3A8A)
                                                  : const Color(0xFFDC2626)),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          elevation: neighbor.isMe ? 0 : 4,
                                        ),
                                        onPressed: neighbor.isMe
                                            ? null
                                            : () => _openEnglishDuelDialog(neighbor),
                                        icon: Text(
                                          neighbor.isMe
                                              ? '🏡'
                                              : (isProtected ? '👮‍♂️' : '⚔️'),
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        label: Text(
                                          neighbor.isMe
                                              ? 'My Home'
                                              : (isProtected ? 'Protected' : 'Attack'),
                                          style: GoogleFonts.outfit(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // --- PAGE INDICATOR DOTS ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_neighbors.length, (idx) {
                  final isSelected = (_currentPage.round() == idx);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isSelected ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0284C7) : Colors.white24,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
