import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/widgets/doodle_background_painter.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/avatar_uniqueness_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/pocket_ambient_flame_background.dart';
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
  bool _isGenerating = false;
  late List<NftItem> _items;

  final List<String> _categories = [
    'Trending',
    'Unclaimed Only',
    'Bored Apes (BAYC)',
    'Claimed 1-of-1s',
  ];

  @override
  void initState() {
    super.initState();
    AvatarUniquenessService().init();
    _loadCatalog();
  }

  void _loadCatalog() {
    final base = NftMockData.getItems();
    final procedural = AvatarUniquenessService().generateProceduralBoredApes(count: 30);
    _items = [...base, ...procedural];
  }

  Future<void> _generateFreshBatch() async {
    setState(() => _isGenerating = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 600));
    final fresh = AvatarUniquenessService().generateProceduralBoredApes(count: 20);

    if (mounted) {
      setState(() {
        _items.insertAll(0, fresh);
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.yellow),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '✨ Generated 20+ fresh unique 1-of-1 Bored Ape NFT avatars!',
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

    final filteredItems = _items.where((item) {
      final isClaimed = item.isClaimed || AvatarUniquenessService().isClaimed(item.id);
      if (_selectedCategory == 'Unclaimed Only') {
        return !isClaimed;
      }
      if (_selectedCategory == 'Claimed 1-of-1s') {
        return isClaimed;
      }
      return true;
    }).toList();

    final heroItem = filteredItems.isNotEmpty ? filteredItems.first : _items.first;
    final collectionItems = filteredItems.skip(1).toList();

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

        // Ambient Flame Sparkles & Embers
        const Positioned.fill(
          child: PocketAmbientFlameBackground(
            showTopFlameGlow: true,
            emberDensity: 0.6,
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
                    // Top Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Auto-Replenish / Generate Fresh Button
                        ElevatedButton.icon(
                          onPressed: _isGenerating ? null : _generateFreshBatch,
                          icon: _isGenerating
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFFFFD700)),
                          label: Text(
                            'Generate Fresh',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B1D2A),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: Colors.white12),
                            ),
                          ),
                        ),

                        // Mint Custom Button
                        ElevatedButton.icon(
                          onPressed: _openCreatorStudio,
                          icon: const Icon(Icons.auto_awesome, size: 14, color: Colors.black),
                          label: Text(
                            'Mint 1-of-1 Ape',
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

                    // Big Bold Headline (Matching user screenshot 2)
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

                    // Category Filter Pills
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
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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

                    // Hero Featured NFT Card
                    SizedBox(
                      height: 380,
                      width: double.infinity,
                      child: NftCardWidget(
                        item: heroItem,
                        isLarge: true,
                        onPurchased: () => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Latest Collection Section
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
                          'Available: ${filteredItems.length}',
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
                        onPurchased: () => setState(() {}),
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
                    item: filteredItems[index],
                    onPurchased: () => setState(() {}),
                  ),
                  childCount: filteredItems.length,
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
