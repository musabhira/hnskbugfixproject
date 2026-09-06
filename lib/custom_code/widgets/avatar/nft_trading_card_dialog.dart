import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/main_profile_widget.dart';
import 'package:share_plus/share_plus.dart';

/// 💎 3D Holographic NFT Collectible Trading Card Modal
/// Designed for Bored Ape, Cyber Doge, Lazy Lion, Anime Fox, and Day 90 Cosmic Dragon
class NftTradingCardDialog extends StatefulWidget {
  final int day;
  final VectorAvatarConfig config;
  final String? userId;
  final bool isOwner;

  const NftTradingCardDialog({
    super.key,
    required this.day,
    required this.config,
    this.userId,
    this.isOwner = true,
  });

  static Future<void> show(
    BuildContext context, {
    required int day,
    required VectorAvatarConfig config,
    String? userId,
    bool isOwner = true,
  }) {
    HapticFeedback.heavyImpact();
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) => NftTradingCardDialog(
        day: day,
        config: config,
        userId: userId,
        isOwner: isOwner,
      ),
    );
  }

  @override
  State<NftTradingCardDialog> createState() => _NftTradingCardDialogState();
}

class _NftTradingCardDialogState extends State<NftTradingCardDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  bool _isEquipping = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  String _getCharacterTitle() {
    if (widget.day == 90) return 'Supreme Astral Cosmic Dragon';
    if (widget.day == 60) return 'Sovereign Emperor Lazy Lion';
    if (widget.day == 30) return 'Trippy Rainbow Fur King Ape';
    if (widget.day == 21) return 'Habit Anchor Polka Doge';
    if (widget.config.dnaHash != null &&
        widget.config.dnaHash!.startsWith('0xNFT-')) {
      return widget.config.dnaHash!
          .replaceFirst('0xNFT-', '')
          .replaceAll('-', ' ');
    }

    final species = widget.config.species
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
    return '$species #${widget.day}';
  }

  Color _getRarityColor() {
    final tier = widget.config.rarityTier.toLowerCase();
    if (tier.contains('mythic')) return const Color(0xFF00E5FF);
    if (tier.contains('legendary')) return const Color(0xFFFFD700);
    if (tier.contains('epic')) return const Color(0xFFD946EF);
    if (tier.contains('rare')) return const Color(0xFF38BDF8);
    return const Color(0xFF10B981);
  }

  Future<void> _equipAvatar() async {
    final uid = widget.userId ?? SupaFlow.client.auth.currentUser?.id;
    if (uid == null) return;

    setState(() => _isEquipping = true);
    HapticFeedback.heavyImpact();

    try {
      await SupaFlow.client.from('profiles').update({
        'avatar_config': widget.config.toMap(),
      }).eq('id', uid);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_getCharacterTitle()} equipped as your active NFT identity!',
                    style: GoogleFonts.outfit(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isEquipping = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to equip: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _shareCard() {
    HapticFeedback.mediumImpact();
    final title = _getCharacterTitle();
    final mint = widget.config.mintId ?? '#MATE-DAY${widget.day}';
    final tier = widget.config.rarityTier;
    // ignore: deprecated_member_use
    Share.share(
      '🎮 Check out my exclusive Pocket Mates English NFT!\n'
      '🔥 $title ($tier)\n'
      '🏷️ Mint ID: $mint\n'
      '⚡ Unlocked at Day ${widget.day} of the 90-Day Transformation Journey!\n'
      'Download Pocket Mates to unlock yours: https://pocketmates.app',
      subject: 'Pocket Mates 90-Day NFT Collectible Card',
    );
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor();
    final characterTitle = _getCharacterTitle();
    final mintId = widget.config.mintId ?? '#MATE-DAY${widget.day}';

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 28).clamp(320.0, 390.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Center(
        child: Container(
          width: cardWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                rarityColor,
                const Color(0xFFFFD700),
                rarityColor.withValues(alpha: 0.6),
                const Color(0xFF0F172A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: rarityColor.withValues(alpha: 0.55),
                blurRadius: 32,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(3.5), // Holographic border
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0B0F19),
              borderRadius: BorderRadius.circular(21),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Card Header Bar: Rarity, Mint ID, and Close Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 10, 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: rarityColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: rarityColor.withValues(alpha: 0.6)),
                        ),
                        child: Text(
                          widget.config.rarityTier.toUpperCase(),
                          style: GoogleFonts.outfit(
                            color: rarityColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 10.5,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          mintId,
                          style: GoogleFonts.firaCode(
                            color: Colors.white70,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // ✕ Header Close Button (User audio: "സ്ക്രോൾ ചെയ്യാതെ അടിയിലെ ക്ലോസ് ബട്ടൺ മേലേക്ക് കയറുന്ന പോലെ")
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white70,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main NFT Artwork Frame (Widescreen collectible presentation)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  height: 165,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: widget.day == 90
                          ? [
                              const Color(0xFF020B24),
                              const Color(0xFF0D3268),
                              const Color(0xFF020B24)
                            ]
                          : [
                              rarityColor.withValues(alpha: 0.25),
                              const Color(0xFF161F33),
                            ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    border: Border.all(
                      color: rarityColor.withValues(alpha: 0.4),
                      width: 1.4,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: VectorAvatarWidget(
                        config: widget.config,
                        size: 155,
                        showAura: false,
                      ),
                    ),
                  ),
                ),

                // Card Identity & Details Deck
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Day Milestone Badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              characterTitle,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFC00)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                  color: const Color(0xFFFFFC00)
                                      .withValues(alpha: 0.45)),
                            ),
                            child: Text(
                              'DAY ${widget.day}',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFFC00),
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Compact 2x2 Trait Matrix
                      Row(
                        children: [
                          _buildTraitPill(
                            label: 'SPECIES',
                            value: widget.config.species
                                .replaceAll('_', ' ')
                                .toUpperCase(),
                            color: rarityColor,
                          ),
                          const SizedBox(width: 6),
                          _buildTraitPill(
                            label: 'ACCESSORY',
                            value: widget.config.accessory
                                .replaceAll('_', ' ')
                                .toUpperCase(),
                            color: const Color(0xFFFFD700),
                          ),
                          const SizedBox(width: 6),
                          _buildTraitPill(
                            label: 'OUTFIT',
                            value: widget.config.outfitStyle
                                .replaceAll('_', ' ')
                                .toUpperCase(),
                            color: const Color(0xFF38BDF8),
                          ),
                          const SizedBox(width: 6),
                          _buildTraitPill(
                            label: 'POWER XP',
                            value: '+${widget.day * 50}',
                            color: const Color(0xFF10B981),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // ⚡ 90-Day Unique In-Game Fortress Perk Container
                      Builder(
                        builder: (context) {
                          final perk = VectorAvatarConfig.getAvatarPerkForDay(widget.day);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  perk.badgeColor.withValues(alpha: 0.16),
                                  const Color(0xFF111827),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: perk.badgeColor.withValues(alpha: 0.55),
                                width: 1.1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(perk.icon, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              perk.title,
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w800,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: perk.badgeColor.withValues(alpha: 0.25),
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              perk.shortBadgeText,
                                              style: GoogleFonts.outfit(
                                                color: perk.badgeColor,
                                                fontSize: 8.5,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        perk.description,
                                        style: GoogleFonts.inter(
                                          color: Colors.white70,
                                          fontSize: 9.2,
                                          fontWeight: FontWeight.w500,
                                          height: 1.2,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),

                      // Inline Action Deck (Directly inside the card - Zero external scrolling!)
                      Row(
                        children: [
                          // Equip Avatar / Locked Milestone Button
                          Expanded(
                            child: widget.isOwner
                                ? ElevatedButton.icon(
                                    onPressed: _isEquipping ? null : _equipAvatar,
                                    icon: _isEquipping
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              color: Colors.black,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.check_circle_rounded,
                                            color: Colors.black, size: 16),
                                    label: Text(
                                      _isEquipping
                                          ? 'EQUIPPING...'
                                          : 'EQUIP AVATAR ⭐',
                                      style: GoogleFonts.outfit(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFFC00),
                                      padding: const EdgeInsets.symmetric(vertical: 11),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 4,
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E293B),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                                        width: 1.1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.lock_rounded, color: Color(0xFFFFD700), size: 14),
                                        const SizedBox(width: 6),
                                        Text(
                                          'REACH DAY ${widget.day} TO CLAIM',
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFFFFD700),
                                            fontWeight: FontWeight.w800,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 8),

                          // View Profile Button (Integrated into card header/deck as requested)
                          OutlinedButton.icon(
                            onPressed: () {
                              final uid = widget.userId ??
                                  SupaFlow.client.auth.currentUser?.id;
                              if (uid == null) return;
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MainProfileWidget(userId: uid),
                                ),
                              );
                            },
                            icon: const Icon(Icons.person_rounded,
                                color: Colors.white, size: 15),
                            label: Text(
                              'PROFILE',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white30),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Share Button
                          ElevatedButton(
                            onPressed: _shareCard,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E293B),
                              padding: const EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Icon(Icons.share_rounded,
                                color: Colors.white, size: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTraitPill({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF131A2A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white38,
                fontWeight: FontWeight.w900,
                fontSize: 8.5,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.outfit(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
