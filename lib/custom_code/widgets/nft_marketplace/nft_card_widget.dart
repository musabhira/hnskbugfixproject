import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/bored_ape_painter.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/avatar_uniqueness_service.dart';
import 'nft_models.dart';
import 'nft_artist_profile_page.dart';

class NftCardWidget extends StatefulWidget {
  final NftItem item;
  final bool isLarge;
  final VoidCallback? onPurchased;

  const NftCardWidget({
    super.key,
    required this.item,
    this.isLarge = false,
    this.onPurchased,
  });

  @override
  State<NftCardWidget> createState() => _NftCardWidgetState();
}

class _NftCardWidgetState extends State<NftCardWidget> {
  late bool _isLiked;
  late int _likes;

  @override
  void initState() {
    super.initState();
    _isLiked = false;
    _likes = widget.item.likesCount;
  }

  void _toggleLike() {
    HapticFeedback.selectionClick();
    setState(() {
      _isLiked = !_isLiked;
      _likes += _isLiked ? 1 : -1;
    });
  }

  void _openDetailModal() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NftDetailModal(
        item: widget.item,
        onPurchased: widget.onPurchased,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isClaimed = item.isClaimed || AvatarUniquenessService().isClaimed(item.id);
    final claimInfo = AvatarUniquenessService().getClaimRecord(item.id);

    return GestureDetector(
      onTap: _openDetailModal,
      child: Container(
        decoration: BoxDecoration(
          color: item.cardColor,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: item.cardColor.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            children: [
              // Full-Bleed Artwork (Vector Bored Ape or Network Image)
              Positioned.fill(
                child: item.apeTraits != null
                    ? BoredApeWidget(traits: item.apeTraits!, size: 300)
                    : CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: item.cardColor.withValues(alpha: 0.5),
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: item.cardColor,
                          child: const Center(
                            child: Icon(Icons.broken_image_rounded, color: Colors.white54, size: 40),
                          ),
                        ),
                      ),
              ),

              // Gradient Overlay for readability at bottom
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),

              // Top Floating Likes Pill
              Positioned(
                top: 14,
                right: 14,
                child: GestureDetector(
                  onTap: _toggleLike,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_likes',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border_rounded,
                          color: _isLiked ? const Color(0xFFFF007A) : Colors.white,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Top Left Rarity Badge or Claimed Badge
              Positioned(
                top: 14,
                left: 14,
                child: isClaimed
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF007A), Color(0xFF7928CA)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF007A).withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock_rounded, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'CLAIMED 1-OF-1',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_rounded, color: Color(0xFFFFD700), size: 12),
                            const SizedBox(width: 4),
                            Text(
                              item.rarityTier.toUpperCase(),
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFD700),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              // Bottom Info Card Overlay
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14141E).withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: widget.isLarge ? 15 : 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isClaimed
                                  ? 'Owned by @${claimInfo?.username ?? "Mate"}'
                                  : item.artistName,
                              style: GoogleFonts.inter(
                                color: isClaimed ? const Color(0xFFFFFC00) : Colors.white60,
                                fontSize: widget.isLarge ? 11 : 10,
                                fontWeight: isClaimed ? FontWeight.bold : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Price Tag or Owned Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: isClaimed
                              ? const LinearGradient(colors: [Color(0xFF374151), Color(0xFF1F2937)])
                              : const LinearGradient(colors: [Color(0xFF7928CA), Color(0xFFFF007A)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isClaimed ? 'CLAIMED' : '${item.priceEth} ETH',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Detailed Auction & 3D Buy Modal
class NftDetailModal extends StatefulWidget {
  final NftItem item;
  final VoidCallback? onPurchased;

  const NftDetailModal({
    super.key,
    required this.item,
    this.onPurchased,
  });

  @override
  State<NftDetailModal> createState() => _NftDetailModalState();
}

class _NftDetailModalState extends State<NftDetailModal> {
  bool _isProcessing = false;

  Future<void> _claimAsAvatar() async {
    final item = widget.item;

    if (AvatarUniquenessService().isClaimed(item.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ This 1-of-1 NFT Avatar has already been claimed by another user!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);
    HapticFeedback.heavyImpact();

    try {
      final user = SupaFlow.client.auth.currentUser;
      final username = user?.email?.split('@').first ?? 'Mate_${Random().nextInt(9000) + 1000}';
      final userId = user?.id ?? 'anon_${DateTime.now().millisecondsSinceEpoch}';

      // 1. Register in Global Uniqueness Engine
      await AvatarUniquenessService().claimAvatar(
        avatarId: item.id,
        userId: userId,
        username: username,
        dnaHash: item.dnaHash,
      );

      // 2. Update Supabase Profile (avatar_config only, preserve real profile image)
      if (user != null) {
        await SupaFlow.client.from('profile').update({
          'avatar_config': {
            'species': 'bored_ape',
            'mintId': item.id,
            'dnaHash': item.dnaHash,
            'rarityTier': item.rarityTier,
            'artStyle': 'bayc',
            'imageUrl': item.imageUrl,
            'traits': item.apeTraits != null
                ? {
                    'fur': item.apeTraits!.furColor,
                    'eyes': item.apeTraits!.eyes,
                    'mouth': item.apeTraits!.mouth,
                    'headwear': item.apeTraits!.headwear,
                    'outfit': item.apeTraits!.outfit,
                    'bg': item.apeTraits!.background,
                  }
                : null,
          },
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', user.id);

        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('profile_cache_${user.id}');
          await prefs.remove('cached_profile_${user.id}');
        } catch (_) {}
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onPurchased?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.stars_rounded, color: Colors.yellow),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '🎉 Owned ${item.title}! 1-of-1 Bored Ape NFT is permanently bound to @$username!',
                    style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFFFFC00),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Expanded(
                  child: Text('Claim error: $e', style: const TextStyle(color: Colors.white, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.copy, color: Color(0xFFFFFC00), size: 14),
                  label: const Text('Copy', style: TextStyle(color: Color(0xFFFFFC00), fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: e.toString()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error copied to clipboard!'), duration: Duration(seconds: 1)),
                    );
                  },
                ),
              ],
            ),
            backgroundColor: Colors.red[900],
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isClaimed = item.isClaimed || AvatarUniquenessService().isClaimed(item.id);
    final claimInfo = AvatarUniquenessService().getClaimRecord(item.id);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF0F1017),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Artwork Showcase Card with 3D Depth
                  Container(
                    height: 320,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: item.cardColor,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: item.cardColor.withValues(alpha: 0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: item.apeTraits != null
                                ? BoredApeWidget(traits: item.apeTraits!, size: 320)
                                : CachedNetworkImage(
                                    imageUrl: item.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          // Rarity & DNA Tag
                          Positioned(
                            bottom: 14,
                            left: 14,
                            right: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'DNA: ${item.dnaHash}',
                                    style: GoogleFonts.sourceCodePro(
                                      color: const Color(0xFFFFD700),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    item.collectionName,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Title & Verification
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF007A), Color(0xFF7928CA)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isClaimed ? 'CLAIMED 1-OF-1' : item.rarityTier,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Ownership / Creator Info Card
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NftArtistProfilePage(
                            artistName: item.artistName,
                            artistHandle: item.artistHandle,
                            artistAvatar: item.artistAvatar,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1D2A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: CachedNetworkImage(
                              imageUrl: item.artistAvatar,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      item.artistName,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified, color: Color(0xFF00E5FF), size: 14),
                                  ],
                                ),
                                Text(
                                  isClaimed
                                      ? 'Permanently owned by @${claimInfo?.username ?? "Mate"}'
                                      : 'Creator & Concept Artist • ${item.artistHandle}',
                                  style: GoogleFonts.inter(
                                    color: isClaimed ? const Color(0xFFFFFC00) : Colors.white54,
                                    fontSize: 11,
                                    fontWeight: isClaimed ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Colors.white38),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Auction Timer & Highest Bid Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF24153E), Color(0xFF151624)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isClaimed ? 'Status' : 'Auction ending in',
                              style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isClaimed ? 'LOCKED / CLAIMED' : item.timeRemaining,
                              style: GoogleFonts.outfit(
                                color: isClaimed ? const Color(0xFFFF007A) : const Color(0xFFFFFC00),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Valuation',
                              style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.priceEth} ETH',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Traits & Properties Grid
                  Text(
                    'Properties & Traits',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.traits.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1E2C),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.traitType.toUpperCase(),
                              style: GoogleFonts.inter(color: const Color(0xFF00E5FF), fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              t.value,
                              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            Text(
                              '${t.rarityPercent}% have this',
                              style: GoogleFonts.inter(color: Colors.white38, fontSize: 9),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF14151F),
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isClaimed ? const Color(0xFF2C3E50) : const Color(0xFFFFD700),
                  foregroundColor: isClaimed ? Colors.white70 : Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: isClaimed || _isProcessing ? null : _claimAsAvatar,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isClaimed ? Icons.lock : Icons.verified, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      isClaimed ? 'Already Claimed by Owner' : 'Claim 1-of-1 NFT Avatar',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
