import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
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
              // Full-Bleed Artwork Image
              Positioned.fill(
                child: CachedNetworkImage(
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

              // Gradient Overlay for readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              // Top Floating Likes Pill (Like screenshot)
              Positioned(
                top: 14,
                right: 14,
                child: GestureDetector(
                  onTap: _toggleLike,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
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

              // Top Left Rarity Badge
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
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

              // Bottom Info Card Overlay (Matching screenshot)
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14141E).withValues(alpha: 0.85),
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
                              item.artistName,
                              style: GoogleFonts.inter(
                                color: Colors.white60,
                                fontSize: widget.isLarge ? 11 : 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Price Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7928CA), Color(0xFFFF007A)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${item.priceEth} ETH',
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
  int _userCoins = 1500;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final coins = prefs.getInt('pocket_coins_balance') ?? 1500;
    if (mounted) setState(() => _userCoins = coins);
  }

  Future<void> _buyWithCoins() async {
    final item = widget.item;
    if (_userCoins < item.priceCoins) return;

    setState(() => _isProcessing = true);
    HapticFeedback.heavyImpact();

    try {
      final prefs = await SharedPreferences.getInstance();
      final newBalance = _userCoins - item.priceCoins;
      await prefs.setInt('pocket_coins_balance', newBalance);

      final user = SupaFlow.client.auth.currentUser;
      if (user != null) {
        await SupaFlow.client.from('profile').update({
          'image_url': item.imageUrl,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', user.id);
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
                    '🎉 Owned ${item.title}! 1-of-1 NFT Avatar is now your profile picture!',
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
          SnackBar(content: Text('Purchase error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

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
                            child: CachedNetworkImage(
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
                          item.rarityTier,
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

                  // Creator Info Card (Matching Screenshot 3)
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
                                  'Creator & Concept Artist • ${item.artistHandle}',
                                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
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
                              'Auction ending in',
                              style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.timeRemaining,
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFFC00),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Current Price / Bid',
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
            child: Row(
              children: [
                // Pocket Coins Button
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: _userCoins >= item.priceCoins && !_isProcessing ? _buyWithCoins : null,
                    child: Text(
                      'Claim for 🪙 ${item.priceCoins}',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Place Bid / Buy Cash
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Bid of ${item.priceEth} ETH placed for ${item.title}!'),
                          backgroundColor: const Color(0xFF8B5CF6),
                        ),
                      );
                    },
                    child: Text(
                      'Bid ${item.priceEth} ETH',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
