import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_studio_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/doodle_background_painter.dart';

class NftAvatarMarketListing {
  final String id;
  final String title;
  final String artistName;
  final String artistHandle;
  final VectorAvatarConfig avatarConfig;
  final int coinPrice;
  final double inrPrice;
  final String rarity;
  final bool isSold;
  final String? buyerId;

  const NftAvatarMarketListing({
    required this.id,
    required this.title,
    required this.artistName,
    required this.artistHandle,
    required this.avatarConfig,
    required this.coinPrice,
    required this.inrPrice,
    required this.rarity,
    this.isSold = false,
    this.buyerId,
  });
}

class NftAvatarMarketTabView extends StatefulWidget {
  const NftAvatarMarketTabView({super.key});

  @override
  State<NftAvatarMarketTabView> createState() => _NftAvatarMarketTabViewState();
}

class _NftAvatarMarketTabViewState extends State<NftAvatarMarketTabView> {
  String _selectedFilter = 'All';
  int _userCoinBalance = 1250; // User Pocket Coins earned from tasks/streaks
  bool _isProcessingPurchase = false;

  final List<String> _filters = [
    'All',
    'Mythic 1-of-1',
    'Cyber Beasts',
    'Anime RPG',
    'Manga',
    'Pixel Arcade',
  ];

  late List<NftAvatarMarketListing> _listings;

  @override
  void initState() {
    super.initState();
    _loadUserCoins();
    _initCatalog();
  }

  Future<void> _loadUserCoins() async {
    final prefs = await SharedPreferences.getInstance();
    final coins = prefs.getInt('pocket_coins_balance') ?? 1500;
    if (mounted) setState(() => _userCoinBalance = coins);
  }

  void _initCatalog() {
    _listings = [
      NftAvatarMarketListing(
        id: 'NFT-001',
        title: 'Kitsune Cyber Fox #094',
        artistName: 'Musab Hira',
        artistHandle: '@musabhira',
        rarity: 'Mythic 1-of-1',
        coinPrice: 450,
        inrPrice: 199.0,
        avatarConfig: const VectorAvatarConfig(
          species: 'cyber_fox',
          artStyle: 'cyberpunk',
          skinColor: '#00F0FF',
          outfitStyle: 'hacker_hood',
          auraStyle: 'matrix_green',
          hairStyle: 'anime_spiky',
          hairColor: '#FF007F',
          mintId: '#MATE-FOX-094',
          dnaHash: '0x9A-8F-11-BC',
          rarityTier: 'Mythic 1-of-1',
        ),
      ),
      NftAvatarMarketListing(
        id: 'NFT-002',
        title: 'Solar Mecha Lion #102',
        artistName: 'Zoya Rex Studio',
        artistHandle: '@zoyarex',
        rarity: 'Mythic 1-of-1',
        coinPrice: 600,
        inrPrice: 249.0,
        avatarConfig: const VectorAvatarConfig(
          species: 'mecha_lion',
          artStyle: 'vector',
          skinColor: '#FFD700',
          outfitStyle: 'superman_suit',
          auraStyle: 'royal_gold',
          hairStyle: 'afro_fade',
          hairColor: '#D4AF37',
          mintId: '#MATE-LION-102',
          dnaHash: '0xFE-43-9A-02',
          rarityTier: 'Mythic 1-of-1',
        ),
      ),
      NftAvatarMarketListing(
        id: 'NFT-003',
        title: 'Shadow Alpha Wolf #319',
        artistName: 'Neon Apex',
        artistHandle: '@neon_apex',
        rarity: 'Legendary',
        coinPrice: 350,
        inrPrice: 149.0,
        avatarConfig: const VectorAvatarConfig(
          species: 'shadow_wolf',
          artStyle: 'cyberpunk',
          skinColor: '#1E202E',
          outfitStyle: 'ninja_robe',
          auraStyle: 'cyber_purple',
          hairStyle: 'mohawk',
          hairColor: '#00E5FF',
          mintId: '#MATE-WOLF-319',
          dnaHash: '0x7C-12-88-DA',
          rarityTier: 'Legendary',
        ),
      ),
      NftAvatarMarketListing(
        id: 'NFT-004',
        title: 'Shinobi Bamboo Panda #404',
        artistName: 'Doodle Master',
        artistHandle: '@doodle_art',
        rarity: 'Legendary',
        coinPrice: 300,
        inrPrice: 129.0,
        avatarConfig: const VectorAvatarConfig(
          species: 'ninja_panda',
          artStyle: 'doodle',
          skinColor: '#FFFFFF',
          outfitStyle: 'ninja_robe',
          auraStyle: 'cherry_blossom',
          hairStyle: 'curly_fade',
          hairColor: '#1E1E24',
          mintId: '#MATE-PANDA-404',
          dnaHash: '0x1B-44-8C-33',
          rarityTier: 'Legendary',
        ),
      ),
      NftAvatarMarketListing(
        id: 'NFT-005',
        title: 'Astral Cosmic Dragon #777',
        artistName: 'Celestial Arts',
        artistHandle: '@celestial',
        rarity: 'Mythic 1-of-1',
        coinPrice: 750,
        inrPrice: 299.0,
        avatarConfig: const VectorAvatarConfig(
          species: 'cosmic_dragon',
          artStyle: 'cyberpunk',
          skinColor: '#8B5CF6',
          outfitStyle: 'traditional_kurta',
          auraStyle: 'golden_sparks',
          hairStyle: 'long_wavy',
          hairColor: '#FFFC00',
          mintId: '#MATE-DRAGON-777',
          dnaHash: '0x99-CC-14-AA',
          rarityTier: 'Mythic 1-of-1',
        ),
      ),
      NftAvatarMarketListing(
        id: 'NFT-006',
        title: 'Quantum Space Robot #811',
        artistName: 'Tokyo Synth',
        artistHandle: '@tokyosynth',
        rarity: 'Epic',
        coinPrice: 250,
        inrPrice: 99.0,
        avatarConfig: const VectorAvatarConfig(
          species: 'space_robot',
          artStyle: 'pixel',
          skinColor: '#00E5FF',
          outfitStyle: 'astronaut_suit',
          auraStyle: 'pixel_arcade',
          hairStyle: 'bald_beanie',
          hairColor: '#10B981',
          mintId: '#MATE-BOT-811',
          dnaHash: '0x34-90-E1-F5',
          rarityTier: 'Epic',
        ),
      ),
    ];
  }

  void _showPurchaseModal(NftAvatarMarketListing item) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B1D2A), Color(0xFF0F1017)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified_rounded, color: Color(0xFFFFD700), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'BUY 1-OF-1 NFT AVATAR',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white54),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Avatar Preview
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFFD700), width: 2),
                        ),
                        child: VectorAvatarWidget(config: item.avatarConfig, size: 100, showAura: true),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      item.title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Created by ${item.artistName} (${item.artistHandle})',
                      style: GoogleFonts.inter(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // DNA Hash & Rarity Card
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text('DNA HASH', style: GoogleFonts.inter(color: Colors.white38, fontSize: 9)),
                              Text(item.avatarConfig.dnaHash ?? '0x7F-00-11', style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 11)),
                            ],
                          ),
                          Container(width: 1, height: 24, color: Colors.white12),
                          Column(
                            children: [
                              Text('RARITY TIER', style: GoogleFonts.inter(color: Colors.white38, fontSize: 9)),
                              Text(item.rarity.toUpperCase(), style: GoogleFonts.outfit(color: const Color(0xFFFF007A), fontWeight: FontWeight.bold, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Your Coins Balance Box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFC00).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text('🪙', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text('Your Pocket Coins:', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                          Text('$_userCoinBalance Coins', style: GoogleFonts.outfit(color: const Color(0xFFFFFC00), fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Option A: Pay with Pocket Coins (Earned from Tasks & Streaks)
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: _userCoinBalance >= item.coinPrice && !_isProcessingPurchase
                            ? () async {
                                Navigator.pop(context);
                                await _completePurchase(item, isCoins: true);
                              }
                            : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🪙', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(
                              'Claim for ${item.coinPrice} Coins',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Option B: Buy with Direct Payment (INR)
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          await _completePurchase(item, isCoins: false);
                        },
                        child: Text(
                          'Buy with Cash: ₹${item.inrPrice.toInt()}',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
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

  Future<void> _completePurchase(NftAvatarMarketListing item, {required bool isCoins}) async {
    setState(() => _isProcessingPurchase = true);
    HapticFeedback.heavyImpact();

    try {
      final user = SupaFlow.client.auth.currentUser;
      final prefs = await SharedPreferences.getInstance();

      if (isCoins) {
        final newBalance = _userCoinBalance - item.coinPrice;
        await prefs.setInt('pocket_coins_balance', newBalance);
        setState(() => _userCoinBalance = newBalance);
      }

      // Save as user's primary 1-of-1 Avatar Config
      if (user != null) {
        await SupaFlow.client.from('profile').update({
          'avatar_config': item.avatarConfig.toMap(),
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', user.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.stars_rounded, color: Colors.yellow),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '🎉 Owned ${item.title}! Verified 1-of-1 NFT Avatar is now your profile!',
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
      if (mounted) setState(() => _isProcessingPurchase = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedFilter == 'All'
        ? _listings
        : _listings.where((l) => l.rarity.contains(_selectedFilter) || l.title.contains(_selectedFilter)).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Reusable Doodle Background
        Positioned.fill(
          child: CustomPaint(
            painter: PocketDoodleBackgroundPainter(
              color: const Color(0xFFFFFC00),
              isDark: isDark,
              opacityMultiplier: 0.8,
            ),
          ),
        ),
        Column(
          children: [
            // Top Balance Banner & Sell Button
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E202E), Color(0xFF14151F)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('🪙', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pocket Coins Balance', style: GoogleFonts.inter(color: Colors.white60, fontSize: 10)),
                        Text('$_userCoinBalance Coins', style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const VectorAvatarStudioPage()),
                      );
                    },
                    icon: const Icon(Icons.add_photo_alternate_rounded, size: 14, color: Colors.black),
                    label: Text('Mint & Sell', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Pills
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final f = _filters[index];
                  final isSel = _selectedFilter == f;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFFFFFC00) : const Color(0xFF1E202E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSel ? const Color(0xFFFFFC00) : Colors.white10),
                      ),
                      child: Center(
                        child: Text(
                          f,
                          style: GoogleFonts.outfit(
                            color: isSel ? Colors.black : Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Avatar Listings Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(14),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];

                  return GestureDetector(
                    onTap: () => _showPurchaseModal(item),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161822),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.25), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Rarity Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFFFF007A), Color(0xFF7928CA)]),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.rarity.toUpperCase(),
                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Icon(Icons.verified_rounded, color: Color(0xFFFFD700), size: 14),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Avatar Preview
                          Center(
                            child: VectorAvatarWidget(config: item.avatarConfig, size: 76, showAura: true),
                          ),
                          const Spacer(),

                          // Title & Creator
                          Text(
                            item.title,
                            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item.artistHandle,
                            style: GoogleFonts.inter(color: Colors.white54, fontSize: 10),
                          ),
                          const SizedBox(height: 8),

                          // Price Row & Buy Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('🪙 ${item.coinPrice}', style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontWeight: FontWeight.w900, fontSize: 12)),
                                  Text('₹${item.inrPrice.toInt()}', style: GoogleFonts.inter(color: Colors.white38, fontSize: 9)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFC00),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Buy 1-of-1',
                                  style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
