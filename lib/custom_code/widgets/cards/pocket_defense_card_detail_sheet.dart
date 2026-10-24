import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pop_art_card_flame_game.dart';
import 'pop_art_cards_viewer_page.dart';
import '../learning_60day/pocket_citadel_challenge_generator.dart';
import '../learning_60day/pocket_citadel_attack_page.dart';

/// 🎴 Defense Card Detail Bottom Sheet / Modal
/// Displays the full PopArt Card Artwork, Assigned Citadel Defense System,
/// Game Mechanics (Sentence Builder, Spelling, Spoken English, etc.),
/// and Card Loss / Protection Status.
/// (User Audio Directive: "കാർഡുകൾ ഇവന്റെ ഡിഫെൻസ് കാർഡുകൾ നോക്കിക്കഴിഞ്ഞാൽ
/// ഒരു കാർഡ് എടുത്തു കഴിഞ്ഞാൽ ഇവർക്ക് എന്തൊക്കെ ഡിഫെൻസ് അതിൽ വരുന്നുണ്ട്
/// എന്നുള്ളത് ഇവർക്ക് ഡീറ്റെയിൽ പേജിൽ കാണാൻ കഴിയണം. മനസ്സിലായോ?")
class PocketDefenseCardDetailSheet extends StatelessWidget {
  final PopArtAvatarCardData card;
  final int cardDay;
  final DefenseGameTypeInfo gameInfo;
  final String difficulty;
  final bool isUnlocked;
  final bool isCardLost;
  final bool isKidMode;
  final String defenderId;
  final String defenderName;

  const PocketDefenseCardDetailSheet({
    super.key,
    required this.card,
    required this.cardDay,
    required this.gameInfo,
    required this.difficulty,
    this.isUnlocked = true,
    this.isCardLost = false,
    this.isKidMode = false,
    this.defenderId = 'hero',
    this.defenderName = 'Defender',
  });

  /// 🚀 Open the Defense Card Detail Sheet from anywhere in the app
  static Future<void> show(
    BuildContext context, {
    required PopArtAvatarCardData card,
    required int cardDay,
    required DefenseGameTypeInfo gameInfo,
    required String difficulty,
    bool isUnlocked = true,
    bool isCardLost = false,
    bool isKidMode = false,
    String defenderId = 'hero',
    String defenderName = 'Defender',
  }) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PocketDefenseCardDetailSheet(
        card: card,
        cardDay: cardDay,
        gameInfo: gameInfo,
        difficulty: difficulty,
        isUnlocked: isUnlocked,
        isCardLost: isCardLost,
        isKidMode: isKidMode,
        defenderId: defenderId,
        defenderName: defenderName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final cardIdx = kPopArt180Cards.indexWhere((c) => c.id == card.id);
    final scoreUnit = isKidMode ? 'SS' : 'PS';

    return Container(
      constraints: BoxConstraints(maxHeight: screenH * 0.90),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F19),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: Color(0xFFFFD700),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x4DFFD700),
            blurRadius: 28,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Title & Day Badge Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFFFD700).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFFFD700)
                                  .withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🛡️', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 5),
                            Text(
                              'SHIELD #$cardDay DEFENSE',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFD700),
                                fontWeight: FontWeight.w900,
                                fontSize: 11.5,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white60, size: 22),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 🎴 Prominent PopArt Artwork Display
                  Center(
                    child: Container(
                      width: 175,
                      height: 235,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isCardLost
                              ? const Color(0xFFEF4444)
                              : (isUnlocked
                                  ? const Color(0xFFFFD700)
                                  : const Color(0xFF475569)),
                          width: 2.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isCardLost
                                ? const Color(0xFFEF4444)
                                    .withValues(alpha: 0.35)
                                : (isUnlocked
                                    ? const Color(0xFFFFD700)
                                        .withValues(alpha: 0.30)
                                    : Colors.black45),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.5),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CustomPaint(
                              painter: PopArtCardCustomPainter(data: card),
                            ),
                            if (!isUnlocked || isCardLost)
                              Container(
                                color: Colors.black.withValues(alpha: 0.70),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isCardLost
                                          ? Icons.broken_image_rounded
                                          : Icons.lock_rounded,
                                      color: isCardLost
                                          ? const Color(0xFFF87171)
                                          : const Color(0xFF94A3B8),
                                      size: 38,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      isCardLost
                                          ? 'LOST TO RAID'
                                          : 'LOCKED SHIELD',
                                      style: GoogleFonts.outfit(
                                        color: isCardLost
                                            ? const Color(0xFFFCA5A5)
                                            : const Color(0xFFCBD5E1),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Top Day Badge
                            Positioned(
                              top: 6,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.82),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFFFD700)
                                          .withValues(alpha: 0.7),
                                      width: 0.8),
                                ),
                                child: Text(
                                  'DAY $cardDay',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFFD700),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Card Title & Subtitle
                  Text(
                    card.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    card.subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF38BDF8),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (card.quote.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '"${card.quote}"',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.caveat(
                          color: const Color(0xFFFDE68A),
                          fontSize: 14.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // ⚠️ Card Loss / Active Shield Status Notice
                  if (isCardLost)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF450A0A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFFEF4444), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          const Text('⚠️', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CARD SHIELD LOST TO ENEMY RAID!',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFCA5A5),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Citadel attack caused $scoreUnit drop below milestone! Re-study Day $cardDay and win challenges to reclaim and re-arm this card shield.',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFFECACA),
                                    fontSize: 11,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (!isUnlocked)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFF64748B), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          const Text('🔒', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SHIELD UNLOCKS AT DAY $cardDay',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFE2E8F0),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Conquer Day $cardDay on the English learning trail to activate this defense card shield for your house.',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF064E3B).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF10B981), width: 1.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🛡️', style: TextStyle(fontSize: 15)),
                          const SizedBox(width: 6),
                          Text(
                            'ARMED & ACTIVE FORTRESS SHIELD',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF6EE7B7),
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 🎮 Fortress Defense System Details Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF38BDF8)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFF38BDF8)
                                        .withValues(alpha: 0.4)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                gameInfo.icon,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    gameInfo.title.toUpperCase(),
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF38BDF8),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14.5,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    gameInfo.titleMl,
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF94A3B8),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFFF59E0B)
                                        .withValues(alpha: 0.6)),
                              ),
                              child: Text(
                                difficulty.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFBBF24),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Colors.white12, height: 1),
                        const SizedBox(height: 12),

                        Text(
                          'DEFENSE MECHANISM / TRAP RULES:',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF94A3B8),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          gameInfo.description,
                          style: GoogleFonts.inter(
                            color: const Color(0xFFE2E8F0),
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Stats Grid (Protection & Loot Info)
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('PROTECTED BOUNTY',
                                        style: GoogleFonts.inter(
                                            color: const Color(0xFF64748B),
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Text('+15 $scoreUnit Shield',
                                        style: GoogleFonts.outfit(
                                            color: const Color(0xFF10B981),
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w900)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('BREACH DEFENSE',
                                        style: GoogleFonts.inter(
                                            color: const Color(0xFF64748B),
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Text('Gauntlet Step $cardDay',
                                        style: GoogleFonts.outfit(
                                            color: const Color(0xFFF59E0B),
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w900)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ⚔️ Primary Action: Test Practice Defense Simulation
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.flash_on_rounded, size: 19),
                      label: Text(
                        'PRACTICE DEFENSE BATTLE ⚔️',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        PocketCitadelAttackPage.openForUser(
                          context,
                          userId: defenderId,
                          targetName: defenderName,
                          attackerDay: cardDay,
                          targetDay: cardDay,
                          isDefenseMode: true,
                          isKidMode: isKidMode,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 🎴 Secondary Action: Swipe 180-Card Gallery
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFFD700),
                        side: const BorderSide(
                            color: Color(0xFFFFD700), width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.style_rounded, size: 18),
                      label: Text(
                        'SWIPE 180-CARD GALLERY 🎴',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        PopArtAvatarCardsViewerPage.open(
                          context,
                          initialIndex: cardIdx >= 0 ? cardIdx : 0,
                        );
                      },
                    ),
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
