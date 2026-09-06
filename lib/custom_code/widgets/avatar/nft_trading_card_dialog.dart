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

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🌟 The 3D Holographic Physical Card
              Container(
                width: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
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
                      blurRadius: 36,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4), // Holographic border thickness
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0F19),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Card Header Bar
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
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
                                  fontSize: 11,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            Text(
                              mintId,
                              style: GoogleFonts.firaCode(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Main NFT Artwork Frame (With bright saturated backing as in reference images!)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                        width: 292,
                        height: 292,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
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
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Center(
                            child: VectorAvatarWidget(
                              config: widget.config,
                              size: 270,
                              showAura: false,
                            ),
                          ),
                        ),
                      ),

                      // Card Identity Deck
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    characterTitle,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFC00)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: const Color(0xFFFFFC00)
                                            .withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    'DAY ${widget.day}',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFFFFC00),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Traits Matrix
                            Row(
                              children: [
                                _buildTraitPill(
                                  label: 'SPECIES',
                                  value: widget.config.species
                                      .replaceAll('_', ' ')
                                      .toUpperCase(),
                                  color: rarityColor,
                                ),
                                const SizedBox(width: 8),
                                _buildTraitPill(
                                  label: 'ACCESSORY',
                                  value: widget.config.accessory
                                      .replaceAll('_', ' ')
                                      .toUpperCase(),
                                  color: const Color(0xFFFFD700),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _buildTraitPill(
                                  label: 'OUTFIT',
                                  value: widget.config.outfitStyle
                                      .replaceAll('_', ' ')
                                      .toUpperCase(),
                                  color: const Color(0xFF38BDF8),
                                ),
                                const SizedBox(width: 8),
                                _buildTraitPill(
                                  label: 'POWER XP',
                                  value: '+${widget.day * 50} XP',
                                  color: const Color(0xFF10B981),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // ⚡ 90-Day Unique In-Game Fortress Perk (User Audio Specification!)
                            Builder(
                              builder: (context) {
                                final perk = VectorAvatarConfig.getAvatarPerkForDay(widget.day);
                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        perk.badgeColor.withValues(alpha: 0.18),
                                        const Color(0xFF111827),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: perk.badgeColor.withValues(alpha: 0.6),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: perk.badgeColor.withValues(alpha: 0.15),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(perk.icon, style: const TextStyle(fontSize: 14)),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'ACTIVE FORTRESS PERK',
                                              style: GoogleFonts.outfit(
                                                color: perk.badgeColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: perk.badgeColor.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              perk.shortBadgeText,
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontSize: 8.5,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        perk.title,
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        perk.description,
                                        style: GoogleFonts.inter(
                                          color: Colors.white70,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w500,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons Deck
              SizedBox(
                width: 320,
                child: Column(
                  children: [
                    // Equip Avatar Button (Owner) OR Locked Milestone Banner (Non-Owner)
                    if (widget.isOwner)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isEquipping ? null : _equipAvatar,
                          icon: _isEquipping
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check_circle_rounded,
                                  color: Colors.black, size: 20),
                          label: Text(
                            _isEquipping
                                ? 'EQUIPPING...'
                                : 'EQUIP AS MY AVATAR ⭐',
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFC00),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_rounded, color: Color(0xFFFFD700), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'LOCKED • REACH DAY ${widget.day} TO CLAIM',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFD700),
                                fontWeight: FontWeight.w900,
                                fontSize: 12.5,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 10),

                    // View Profile & Share Row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
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
                                color: Colors.white, size: 18),
                            label: Text(
                              'VIEW PROFILE',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white30),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _shareCard,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF1E293B),
                            padding: const EdgeInsets.all(14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Icon(Icons.share_rounded,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white60, size: 26),
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
