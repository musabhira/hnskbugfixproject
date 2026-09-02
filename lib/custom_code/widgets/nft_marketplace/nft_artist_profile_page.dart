import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pocket_mates_app/custom_code/widgets/doodle_background_painter.dart';
import 'nft_models.dart';
import 'nft_card_widget.dart';

class NftArtistProfilePage extends StatefulWidget {
  final String artistName;
  final String artistHandle;
  final String artistAvatar;

  const NftArtistProfilePage({
    super.key,
    required this.artistName,
    required this.artistHandle,
    required this.artistAvatar,
  });

  @override
  State<NftArtistProfilePage> createState() => _NftArtistProfilePageState();
}

class _NftArtistProfilePageState extends State<NftArtistProfilePage> {
  bool _isFollowing = false;

  @override
  Widget build(BuildContext context) {
    final allItems = NftMockData.getItems();
    final artistItems = allItems.where((i) => i.artistName == widget.artistName || i.artistHandle == widget.artistHandle).toList();
    final displayItems = artistItems.isNotEmpty ? artistItems : allItems;
    final featuredItem = displayItems.first;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0E15),
      body: Stack(
        children: [
          // Background Doodles
          Positioned.fill(
            child: CustomPaint(
              painter: PocketDoodleBackgroundPainter(
                color: const Color(0xFF8B5CF6),
                isDark: true,
                opacityMultiplier: 0.5,
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Top App Bar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  pinned: true,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                      onPressed: () {},
                    ),
                  ],
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Hexagonal Artist Profile Picture
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8B5CF6), Color(0xFFFF007A)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                                  blurRadius: 25,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(3),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: widget.artistAvatar,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Artist Name & Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.artistName,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, color: Color(0xFF00E5FF), size: 18),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Illustrator / Concept Artist • ${widget.artistHandle}',
                          style: GoogleFonts.inter(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Follow / Contact Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => setState(() => _isFollowing = !_isFollowing),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isFollowing ? const Color(0xFF1E202E) : const Color(0xFFFFFC00),
                                foregroundColor: _isFollowing ? Colors.white : Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text(
                                _isFollowing ? 'Following' : 'Follow Artist',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Stats Card (Matching Screen 3 in user image)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E1F30), Color(0xFF13141F)],
                            ),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Auction ending in', style: GoogleFonts.inter(color: Colors.white54, fontSize: 11)),
                                  const SizedBox(height: 4),
                                  Text(
                                    featuredItem.timeRemaining,
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFFFFC00),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              Container(width: 1, height: 32, color: Colors.white12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Highest bid', style: GoogleFonts.inter(color: Colors.white54, fontSize: 11)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${featuredItem.priceEth} ETH',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Active Auction Hero Card
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Featured Active Auction',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 380,
                          child: NftCardWidget(item: featuredItem, isLarge: true),
                        ),
                        const SizedBox(height: 28),

                        // Created Collection Header
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Artist Artworks (${displayItems.length})',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),

                // Grid of Artist NFTs
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => NftCardWidget(item: displayItems[index]),
                      childCount: displayItems.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
