import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../avatar/vector_avatar_config.dart';
import '../avatar/vector_avatar_widget.dart';
import 'flame_english_house_game.dart';
import 'pocket_battle_arena_page.dart';
import 'pocket_defense_admin_modal.dart';
import 'pocket_fortress_defense_service.dart';

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
  });
}

/// 🌍 Pocket World: Interactive 2D Parallax Neighborhood Street
/// As you swipe horizontally, the focused house scales up while neighbors scale down smoothly.
class PocketWorldStreetPage extends StatefulWidget {
  final int currentDay;
  final int streak;

  const PocketWorldStreetPage({
    super.key,
    required this.currentDay,
    required this.streak,
  });

  @override
  State<PocketWorldStreetPage> createState() => _PocketWorldStreetPageState();
}

class _PocketWorldStreetPageState extends State<PocketWorldStreetPage> {
  late final PageController _pageController;
  double _currentPage = 0.0;
  late final List<PocketNeighbor> _neighbors;
  Set<String> _bannedHouseIds = {'neighbor_cheat'};

  @override
  void initState() {
    super.initState();
    _loadBannedHouses();
    _pageController = PageController(viewportFraction: 0.82);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });

    // Generate neighborhood street with user + peers at varied stages
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
      const PocketNeighbor(
        id: 'neighbor_1',
        name: 'Aisha K.',
        day: 82,
        streak: 82,
        rank: 'Victorian Palace',
        paletteId: 'royal_gold',
        hasActiveShield: true,
        statusMessage: 'Mastered 600 vocabulary words! 👑',
      ),
      const PocketNeighbor(
        id: 'neighbor_cheat',
        name: 'ShadowKing_07',
        day: 62,
        streak: 1,
        rank: 'Banned Manor',
        paletteId: 'charcoal',
        hasActiveShield: false,
        statusMessage: '🚫 Banned by Admin Tribunal for fake questions',
        isBanned: true,
        banReason: 'Intentionally marked incorrect answers in defense traps.',
      ),
      const PocketNeighbor(
        id: 'neighbor_2',
        name: 'Rahul Nair',
        day: 58,
        streak: 41,
        rank: 'Gabled Manor',
        paletteId: 'cyber_yellow',
        hasActiveShield: false,
        statusMessage: 'Shield down! Challenge my defense! ⚔️',
      ),
      const PocketNeighbor(
        id: 'neighbor_3',
        name: 'Sneha Roy',
        day: 35,
        streak: 35,
        rank: 'Country Residence',
        paletteId: 'sakura',
        hasActiveShield: true,
        statusMessage: 'Audio speaking streak going strong 🌸',
      ),
      const PocketNeighbor(
        id: 'neighbor_4',
        name: 'Vikram S.',
        day: 18,
        streak: 18,
        rank: 'Starter Cottage',
        paletteId: 'emerald',
        hasActiveShield: false,
        statusMessage: 'Learning English basics daily 🌲',
      ),
      const PocketNeighbor(
        id: 'neighbor_5',
        name: 'Dr. John Mathew',
        day: 90,
        streak: 90,
        rank: 'Palace Sovereign',
        paletteId: 'mirror_glass',
        hasActiveShield: true,
        statusMessage: '90-Day Fluency Champion! 💎',
      ),
    ];
  }

  Future<void> _loadBannedHouses() async {
    final reports = await PocketFortressDefenseService.getDefenseReports();
    final set = <String>{'neighbor_cheat'};
    for (final r in reports) {
      if (r.status == 'banned' || await PocketFortressDefenseService.isHouseBanned(r.houseId)) {
        set.add(r.houseId);
      }
    }
    if (await PocketFortressDefenseService.isHouseBanned('me')) {
      set.add('me');
    }
    if (mounted) {
      setState(() {
        _bannedHouseIds = set;
      });
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
                '⚔️ "See you in the Battle Arena!"',
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

  void _openEnglishDuelDialog(PocketNeighbor neighbor) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('⚔️', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'English Battle Challenge',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Challenge ${neighbor.name}’s House Defenses',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12.5,
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
            if (neighbor.isBanned || _bannedHouseIds.contains(neighbor.id))
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF7F1D1D), Color(0xFF450A0A)]),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.redAccent, width: 1.2),
                ),
                child: Row(
                  children: const [
                    Text('🚫', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This house has been banned by Admin for invalid defense questions. Raid easily to claim free loot!',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: neighbor.hasActiveShield ? Colors.amber.shade400 : Colors.redAccent,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    neighbor.hasActiveShield ? '🛡️' : '⚠️',
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          neighbor.hasActiveShield
                              ? 'Golden Shield Active (Streak: ${neighbor.streak} Days)'
                              : 'Shield Down! (Daily Task Pending)',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          neighbor.hasActiveShield
                              ? 'Friendly Practice Match: Earn +25 XP without risking defense HP.'
                              : 'Vulnerable to friendly raid: Win duel to claim study coins!',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '🎮 45-Second Rapid Vocab Duel',
              style: GoogleFonts.outfit(
                color: const Color(0xFF38BDF8),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pronounce 5 words correctly & solve 3 grammar puzzles against the clock. Higher accuracy wins the duel!',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 6,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PocketBattleArenaPage(
                        neighbor: neighbor,
                        userDay: widget.currentDay,
                        userStreak: widget.streak,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🚀', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      'START 1v1 DUEL',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 0.8,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    onPressed: () => Navigator.pop(context),
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
                    onTap: () async {
                      await PocketDefenseAdminModal.show(context);
                      _loadBannedHouses();
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

            // --- SUB-HEADER STATUS BANNER ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF131D31),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Text('🏘️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Each house grows as its owner learns English! Challenge neighbors to friendly vocab battles.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11.5,
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
                                  // Shield Icon
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isBanned
                                          ? const Color(0xFF7F1D1D).withValues(alpha: 0.6)
                                          : (neighbor.hasActiveShield
                                              ? const Color(0xFF065F46).withValues(alpha: 0.4)
                                              : const Color(0xFF7F1D1D).withValues(alpha: 0.4)),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isBanned
                                            ? Colors.redAccent
                                            : (neighbor.hasActiveShield ? const Color(0xFF10B981) : Colors.redAccent),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(isBanned ? '🚫' : (neighbor.hasActiveShield ? '🛡️' : '⚠️'), style: const TextStyle(fontSize: 11)),
                                        const SizedBox(width: 4),
                                        Text(
                                          isBanned ? 'Banned' : (neighbor.hasActiveShield ? 'Shield' : 'Raidable'),
                                          style: TextStyle(
                                            color: isBanned
                                                ? Colors.redAccent
                                                : (neighbor.hasActiveShield ? const Color(0xFF34D399) : Colors.redAccent),
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // --- 🏡 THE INTERACTIVE HOUSE CANVAS ---
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: FlameEnglishHouseWidget(
                                        currentDay: neighbor.day,
                                        streak: neighbor.streak,
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
                                                        fontSize: 13,
                                                        letterSpacing: 1.0,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    const Text(
                                                      'Fake Defense Traps Reported',
                                                      style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 9.5,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    // Plot Number Tag
                                    Positioned(
                                      bottom: 10,
                                      left: 14,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.65),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.white12),
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
                                  // Challenge / Duel button
                                  Expanded(
                                    flex: 1,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: neighbor.isMe
                                            ? const Color(0xFF1E293B)
                                            : const Color(0xFF0284C7),
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
                                      icon: Text(neighbor.isMe ? '🏡' : '⚔️', style: const TextStyle(fontSize: 13)),
                                      label: Text(
                                        neighbor.isMe ? 'My Home' : 'Challenge',
                                        style: GoogleFonts.outfit(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                        ),
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
    );
  }
}
