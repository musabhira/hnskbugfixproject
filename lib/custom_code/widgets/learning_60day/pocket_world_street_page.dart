import 'dart:math' as math;
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
  final bool isPocketRobo;

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
  late final List<PocketNeighbor> _neighbors;
  Set<String> _bannedHouseIds = {'neighbor_cheat'};
  Set<String> _protectedHouseIds = {};
  bool _isRollingRandomTarget = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.82);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });

    // Generate neighborhood street with user + peers at varied stages
    final roboTargetDay = widget.currentDay >= 4 ? widget.currentDay + 2 : 5;
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
      // 🤖 Pocket Robo Defender (Audio 16: Always available AI defender matching target bracket)
      PocketFortressDefenseService.generatePocketRoboDefender(roboTargetDay),
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

  Future<void> _openEnglishDuelDialog(PocketNeighbor neighbor) async {
    HapticFeedback.selectionClick();
    final inCooldown = await PocketFortressDefenseService.isTargetInCooldown(neighbor.id);
    final isTargetJailed = await PocketFortressDefenseService.isHouseJailed(neighbor.id);
    final isPlayerJailed = await PocketFortressDefenseService.isHouseJailed('me');
    final isTargetProtected = await PocketFortressDefenseService.isUnderPresidentialProtection(neighbor.id);
    final protectionMinutes = isTargetProtected
        ? await PocketFortressDefenseService.getPresidentialProtectionMinutesRemaining(neighbor.id)
        : 0;
    final attacksUsed = await PocketFortressDefenseService.getDailyAttacksUsedToday();
    final isDailyLimitReached = attacksUsed >= PocketFortressDefenseService.kDailyMaxAttacks;
    final cannotAttack = inCooldown || isTargetJailed || isPlayerJailed || isTargetProtected || isDailyLimitReached;
    if (!mounted) return;

    // Load actual defense trap questions for this neighbor
    final defenseQuestions = await PocketFortressDefenseService.loadShieldQuestions(neighbor.day, isNeighbor: true);

    int raidStep = 0; // 0: Zoomed House, 1: Defense Question, 2: Gate Breached, 3: Victory Result, -1: Trap Failed
    int selectedOption = -1;
    bool isStriking = false;
    Map<String, dynamic>? breachResult;
    int currentQIdx = 0;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF070B14),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final currentQ = defenseQuestions.isNotEmpty
              ? defenseQuestions[currentQIdx % defenseQuestions.length]
              : null;

          return Container(
            height: MediaQuery.of(context).size.height * 0.94,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // --- TOP TARGET RESIDENT HEADER ---
                Row(
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: VectorAvatarWidget(
                        config: VectorAvatarConfig.getEvolutionAvatarForStage(neighbor.day),
                        size: 44,
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: neighbor.hasActiveShield
                                      ? const Color(0xFF065F46).withValues(alpha: 0.5)
                                      : const Color(0xFF7F1D1D).withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: neighbor.hasActiveShield ? const Color(0xFF10B981) : Colors.redAccent,
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  neighbor.hasActiveShield ? '🛡️ Shielded' : '⚠️ Unshielded',
                                  style: TextStyle(
                                    color: neighbor.hasActiveShield ? const Color(0xFF34D399) : Colors.redAccent,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Level ${neighbor.day} Citadel • 🔥 ${neighbor.streak} Days Streak • ${neighbor.rank}',
                            style: GoogleFonts.inter(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDailyLimitReached
                            ? Colors.red.withValues(alpha: 0.15)
                            : const Color(0xFF0284C7).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDailyLimitReached
                              ? Colors.redAccent.withValues(alpha: 0.4)
                              : const Color(0xFF38BDF8).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        '⚔️ $attacksUsed / ${PocketFortressDefenseService.kDailyMaxAttacks} Today',
                        style: TextStyle(
                          color: isDailyLimitReached ? Colors.redAccent : const Color(0xFF38BDF8),
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                      onPressed: () => Navigator.pop(ctx),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // --- 🏡 ZOOMED FULL-SCREEN HOUSE CANVAS ---
                // User Audio: "ആ വീട് ജസ്റ്റ് ഇങ്ങനെ സൂം ആയിട്ട് ഫുൾ സ്ക്രീൻ ആയിട്ട് ആ വീട് കാണിക്കുന്നു. ആ വീടിന്റെ ബാക്ഗ്രൗണ്ട് ഒക്കെ ആയിട്ട് വീട് കാണിക്കുന്നു."
                Expanded(
                  flex: 5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: FlameEnglishHouseWidget(
                            currentDay: neighbor.day,
                            streak: neighbor.streak,
                          ),
                        ),
                        // House status banner at top of canvas
                        Positioned(
                          top: 10,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  neighbor.hasActiveShield ? '🛡️ House HP: 100/100' : '⚠️ House HP: 70/100',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Attack strike flash animation
                        if (isStriking)
                          Positioned.fill(
                            child: Container(
                              color: Colors.red.withValues(alpha: 0.35),
                              child: const Center(
                                child: Text('💥 STRIKE! ⚔️', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // --- INTERACTIVE BOTTOM RAID FLOW ---
                // User Audio Directive:
                // "എന്നിട്ട് 'അറ്റാക്ക്' എന്ന് അടിയിൽ ഇങ്ങനെ സിംപിൾ ആയിട്ട് ഒരു ബട്ടൺ കാണിക്കുന്നു.
                // അറ്റാക്ക് കൊടുക്കുന്ന സമയത്ത് ഡിഫൻസ് വരും. ഡിഫൻസ് അവര് ഉണ്ടാക്കിയ ക്വസ്റ്റ്യൻസ് വരും.
                // അത് കറക്റ്റ് കൊടുത്ത് ടിക്ക് ഒക്കെ കൊടുത്തു കഴിഞ്ഞുകഴിഞ്ഞാൽ ഇവർക്ക് 'അറ്റാക്ക്' എന്നൊരു ബട്ടൺ കൊടുക്കും.
                // അറ്റാക്ക് എന്ന് പറയുമ്പോൾ ഇവര് അറ്റാക്ക് ചെയ്യുന്നു."
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- STEP 0: INITIAL VIEW (Simple "ATTACK CITADEL" button) ---
                        if (raidStep == 0) ...[
                          if (isTargetJailed)
                            _buildNoticeCard('⛓️ Target is serving a Presidential Jail sentence. Raids are blocked.')
                          else if (isPlayerJailed)
                            _buildNoticeCard('⛓️ You cannot raid while serving your Presidential Jail sentence.')
                          else if (isTargetProtected)
                            _buildNoticeCard('👮‍♂️ Under 48-Hour Presidential Police Protection!\nPresidential guards are stationed here to allow the resident 48 hours to rebuild & recover after a battle breach (${(protectionMinutes / 60).toStringAsFixed(1)}h remaining). Raids are blocked!')
                          else if (inCooldown)
                            _buildNoticeCard('⏳ 24h Peace Treaty active! You attacked this home recently.')
                          else if (isDailyLimitReached)
                            _buildNoticeCard('🔒 Daily limit reached! You have completed 2/2 raids today.')
                          else
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Row(
                                children: [
                                  const Text('⚔️', style: TextStyle(fontSize: 20)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Home Defense Challenge',
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          'Crack ${neighbor.name}\'s Home Defense questions to breach their gates & claim +45 study coins!',
                                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cannotAttack ? Colors.white12 : const Color(0xFFDC2626),
                                foregroundColor: cannotAttack ? Colors.white38 : Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: cannotAttack ? 0 : 6,
                              ),
                              onPressed: cannotAttack
                                  ? null
                                  : () {
                                      if (widget.currentDay < 4) {
                                        showDialog(
                                          context: context,
                                          builder: (dCtx) => AlertDialog(
                                            backgroundColor: const Color(0xFF0F172A),
                                            title: const Text('🔒 Citadel Raids Locked', style: TextStyle(color: Colors.white)),
                                            content: const Text(
                                              'Raid warfare unlocks at Level 4. Advance through your daily learning challenges to unlock combat!',
                                              style: TextStyle(color: Colors.white70),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(dCtx),
                                                child: const Text('OK', style: TextStyle(color: Color(0xFF38BDF8))),
                                              ),
                                            ],
                                          ),
                                        );
                                        return;
                                      }
                                      HapticFeedback.heavyImpact();
                                      setModalState(() {
                                        raidStep = 1; // Move to defense question
                                        selectedOption = -1;
                                      });
                                    },
                              icon: const Icon(Icons.flash_on_rounded, size: 18),
                              label: Text(
                                cannotAttack
                                    ? (isDailyLimitReached
                                        ? 'DAILY LIMIT (2/2) REACHED 🔒'
                                        : (inCooldown ? 'PEACE TREATY IN EFFECT ⏳' : 'RAID LOCKED 🔒'))
                                    : 'ATTACK CITADEL ⚔️',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.6),
                              ),
                            ),
                          ),
                        ]

                        // --- STEP 1: DEFENSE QUESTION POPUP ("ഡിഫൻസ് അവര് ഉണ്ടാക്കിയ ക്വസ്റ്റ്യൻസ് വരും") ---
                        else if (raidStep == 1 && currentQ != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '🛡️ DEFENSE GATE: ${currentQ.trapType.toUpperCase()}',
                                        style: const TextStyle(
                                          color: Color(0xFF38BDF8),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Question ${currentQIdx + 1} of ${defenseQuestions.length}',
                                      style: const TextStyle(color: Colors.white54, fontSize: 10),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currentQ.question,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ...List.generate(currentQ.options.length, (optIdx) {
                                  final letter = String.fromCharCode(65 + optIdx);
                                  final isSelected = selectedOption == optIdx;

                                  return GestureDetector(
                                    onTap: () {
                                      setModalState(() => selectedOption = optIdx);
                                      HapticFeedback.selectionClick();
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFF0284C7).withValues(alpha: 0.2) : const Color(0xFF0F172A),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFF38BDF8) : Colors.white12,
                                          width: isSelected ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isSelected ? const Color(0xFF38BDF8) : Colors.white10,
                                            ),
                                            child: Center(
                                              child: Text(
                                                letter,
                                                style: GoogleFonts.outfit(
                                                  color: isSelected ? Colors.black : Colors.white70,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              currentQ.options[optIdx],
                                              style: TextStyle(
                                                color: isSelected ? Colors.white : Colors.white70,
                                                fontSize: 12,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            const Icon(Icons.check_circle_rounded, color: Color(0xFF38BDF8), size: 16),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedOption == -1 ? Colors.white12 : const Color(0xFF0284C7),
                                foregroundColor: selectedOption == -1 ? Colors.white38 : Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: selectedOption == -1
                                  ? null
                                  : () {
                                      HapticFeedback.mediumImpact();
                                      if (selectedOption == currentQ.correctIndex) {
                                        // Answer is correct -> Move to Step 2 to give the "ATTACK" button!
                                        setModalState(() => raidStep = 2);
                                      } else {
                                        // Trap triggered -> Defender defended!
                                        setModalState(() => raidStep = -1);
                                      }
                                    },
                              child: Text(
                                'CONFIRM DEFENSE ANSWER ✓',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                        ]

                        // --- STEP 2: GATE BREACHED -> "ATTACK" BUTTON ENABLED ---
                        // User Audio: "അത് കറക്റ്റ് കൊടുത്ത് ടിക്ക് ഒക്കെ കൊടുത്തു കഴിഞ്ഞുകഴിഞ്ഞാൽ ഇവർക്ക് 'അറ്റാക്ക്' എന്നൊരു ബട്ടൺ കൊടുക്കും. അറ്റാക്ക് എന്ന് പറയുമ്പോൾ ഇവര് അറ്റാക്ക് ചെയ്യുന്നു."
                        else if (raidStep == 2 && currentQ != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF10B981)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('🎯', style: TextStyle(fontSize: 20)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'DEFENSE CODE CRACKED! GATE BREACHED!',
                                        style: GoogleFonts.outfit(
                                          color: const Color(0xFF34D399),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '✓ Answer Correct: ${currentQ.options[currentQ.correctIndex]}',
                                  style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                                ),
                                if (currentQ.explanation.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    currentQ.explanation,
                                    style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 8,
                              ),
                              onPressed: isStriking
                                  ? null
                                  : () async {
                                      setModalState(() => isStriking = true);
                                      HapticFeedback.heavyImpact();

                                      final perk = VectorAvatarConfig.getAvatarPerkForDay(widget.currentDay);
                                      final result = await PocketFortressDefenseService.processRaidBreach(
                                        defenderHouseId: neighbor.id,
                                        attackerId: 'me',
                                        damageHp: 60,
                                        attackerName: 'You',
                                        attackerWeapon: perk.combatWeaponName,
                                        defenderHasIronDome: neighbor.hasActiveShield,
                                      );

                                      await PocketFortressDefenseService.recordTargetAttacked(neighbor.id);
                                      await PocketFortressDefenseService.recordAttackLaunchedToday();

                                      final looted = (result['lootedCoins'] as num? ?? 0).toInt();
                                      if (looted > 0) {
                                        await PocketFortressDefenseService.awardRaidLoot(looted);
                                      }

                                      await Future.delayed(const Duration(milliseconds: 600));

                                      if (mounted) {
                                        setModalState(() {
                                          isStriking = false;
                                          breachResult = result;
                                          raidStep = 3; // Show victory
                                        });
                                      }
                                    },
                              icon: isStriking
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.flash_on_rounded, size: 20),
                              label: Text(
                                isStriking ? 'STRIKING CITADEL...' : 'ATTACK CITADEL NOW! 💥',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.8),
                              ),
                            ),
                          ),
                        ]

                        // --- STEP 3: ATTACK RESULT / VICTORY ---
                        else if (raidStep == 3) ...[
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF065F46), Color(0xFF0F172A)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('🏆', style: TextStyle(fontSize: 24)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'CITADEL BREACHED & LOOTED!',
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFF34D399),
                                              fontWeight: FontWeight.w900,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            'Target: ${neighbor.name} (Level ${neighbor.day})',
                                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '💥 ${breachResult?['damageDealt'] ?? 60} HP Damage Dealt to Citadel',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  breachResult?['ironDomeBlocked'] == true
                                      ? '🛡️ Iron Dome Absorbed Breach (0 Coins Looted)'
                                      : '🪙 +${breachResult?['lootedCoins'] ?? 45} Coins Looted from Vault!',
                                  style: TextStyle(
                                    color: breachResult?['ironDomeBlocked'] == true ? Colors.amber : const Color(0xFF34D399),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFF60A5FA).withValues(alpha: 0.5)),
                                  ),
                                  child: Row(
                                    children: const [
                                      Text('👮‍♂️', style: TextStyle(fontSize: 13)),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '48h Presidential Police Guard Dispatched: Target is under protective peace treaty while recovering.',
                                          style: TextStyle(color: Colors.white70, fontSize: 10.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF059669),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                _loadBannedAndProtectedHouses();
                                HapticFeedback.selectionClick();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('🏆 Home Raid Victory against ${neighbor.name}! +${breachResult?['lootedCoins'] ?? 45} coins claimed!'),
                                    backgroundColor: const Color(0xFF059669),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Text(
                                'CLAIM LOOT & RETURN 🏆',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                        ]

                        // --- STEP -1: TRAP TRIGGERED / ATTACK FAILED ---
                        else if (raidStep == -1) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFDC2626)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('💥', style: TextStyle(fontSize: 20)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'TRAP TRIGGERED! ATTACK REPELLED!',
                                        style: GoogleFonts.outfit(
                                          color: const Color(0xFFF87171),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'You failed to crack the defender\'s English shield. Their house defense holds firm!',
                                  style: TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                                if (currentQ != null && currentQ.explanation.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Explanation: ${currentQ.explanation}',
                                    style: const TextStyle(color: Colors.white60, fontSize: 10.5, fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white70,
                                side: const BorderSide(color: Colors.white24),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('RETREAT 🛡️', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoticeCard(String msg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const Text('ℹ️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ),
        ],
      ),
    );
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

    // Filter valid candidate neighbors (favoring higher levels: Level 5 or 6 for Level 4 user)
    // Audio 16: Exclude banned, on-cooldown, and 48h Presidential Police Protected houses!
    List<PocketNeighbor> candidates = _neighbors
        .where((n) =>
            !n.isMe &&
            !n.isBanned &&
            !_bannedHouseIds.contains(n.id) &&
            !_protectedHouseIds.contains(n.id) &&
            n.day > widget.currentDay)
        .toList();

    if (candidates.isEmpty) {
      candidates = _neighbors
          .where((n) =>
              !n.isMe &&
              !n.isBanned &&
              !_bannedHouseIds.contains(n.id) &&
              !_protectedHouseIds.contains(n.id))
          .toList();
    }

    PocketNeighbor targetNeighbor;
    if (candidates.isNotEmpty) {
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
    } else {
      // Audio 16 Directive: When no eligible peer is available in the level bracket, fallback to Pocket Robo 🤖!
      final targetRoboDay = widget.currentDay >= 4 ? widget.currentDay + 2 : 5;
      targetNeighbor = PocketFortressDefenseService.generatePocketRoboDefender(targetRoboDay);
    }

    HapticFeedback.heavyImpact();
    setState(() => _isRollingRandomTarget = false);

    if (!mounted) return;
    _openEnglishDuelDialog(targetNeighbor);
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
    );
  }
}
