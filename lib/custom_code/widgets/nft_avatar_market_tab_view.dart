import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/widgets/doodle_background_painter.dart';
import 'nft_marketplace/nft_models.dart';
import 'nft_marketplace/nft_card_widget.dart';
import 'nft_marketplace/nft_creator_studio_page.dart';

class NftAvatarMarketTabView extends StatefulWidget {
  const NftAvatarMarketTabView({super.key});

  @override
  State<NftAvatarMarketTabView> createState() => _NftAvatarMarketTabViewState();
}

class _NftAvatarMarketTabViewState extends State<NftAvatarMarketTabView> {
  String _selectedCategory = 'Trending';
  int _userCoins = 1500;
  late List<NftItem> _items;

  final List<String> _categories = [
    'Trending',
    'Popular',
    'Following',
    'Bored Apes',
    'Cyberpunk',
    'Pixel Punks',
  ];

  @override
  void initState() {
    super.initState();
    _loadBalance();
    _items = NftMockData.getItems();
  }

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final coins = prefs.getInt('pocket_coins_balance') ?? 1500;
    if (mounted) setState(() => _userCoins = coins);
  }

  void _openCreatorStudio() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NftCreatorStudioPage(
          onMinted: (minted) {
            setState(() {
              _items.insert(0, minted);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final heroItem = _items.first;
    final collectionItems = _items.skip(1).toList();

    return Stack(
      children: [
        // Subtle Background Doodles
        Positioned.fill(
          child: CustomPaint(
            painter: PocketDoodleBackgroundPainter(
              color: const Color(0xFF8B5CF6),
              isDark: isDark,
              opacityMultiplier: 0.5,
            ),
          ),
        ),

        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar (Matching Screenshot 2)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Coins Pill & Mint Button
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B1D2A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Text('🪙', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                '$_userCoins Coins',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFFD700),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _openCreatorStudio,
                          icon: const Icon(Icons.auto_awesome, size: 14, color: Colors.black),
                          label: Text(
                            'Mint NFT',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFC00),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Big Bold Headline (Matching Screenshot 2)
                    Text(
                      "Find Your\nNFT's Today",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Category Filter Pills (Matching Screenshot 2)
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isSel = _selectedCategory == cat;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: isSel
                                    ? const LinearGradient(
                                        colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                                      )
                                    : null,
                                color: isSel ? null : const Color(0xFF1A1B28),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: isSel
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  cat,
                                  style: GoogleFonts.outfit(
                                    color: isSel ? Colors.white : Colors.white60,
                                    fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Hero Featured NFT Card (Matching Screenshot 2 center card)
                    SizedBox(
                      height: 380,
                      width: double.infinity,
                      child: NftCardWidget(
                        item: heroItem,
                        isLarge: true,
                        onPurchased: _loadBalance,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Latest Collection Section (Matching Screenshot 2)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Latest Collection',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'View All (${_items.length})',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFFC00),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // Horizontal Swipeable Collection Stack
            SliverToBoxAdapter(
              child: SizedBox(
                height: 260,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: collectionItems.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final item = collectionItems[index];
                    return SizedBox(
                      width: 190,
                      child: NftCardWidget(
                        item: item,
                        onPurchased: _loadBalance,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 28, 20, 14),
                child: Text(
                  'Explore All 1-of-1 NFTs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),

            // 2-Column Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => NftCardWidget(
                    item: _items[index],
                    onPurchased: _loadBalance,
                  ),
                  childCount: _items.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
        ),
      ],
    );
  }
}
