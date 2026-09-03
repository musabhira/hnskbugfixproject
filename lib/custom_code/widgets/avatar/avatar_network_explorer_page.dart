import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'avatar_network_service.dart';
import 'avatar_uniqueness_service.dart';
import 'bored_ape_painter.dart';
import 'package:pocket_mates_app/custom_code/widgets/nft_marketplace/nft_models.dart';

enum ExplorerItemType {
  networkStyle,
  nftApe,
}

class ExplorerFeedItem {
  final ExplorerItemType type;
  final AvatarNetworkStyle? networkStyle;
  final NftItem? nftItem;
  final double aspectRatio;

  const ExplorerFeedItem({
    required this.type,
    this.networkStyle,
    this.nftItem,
    this.aspectRatio = 1.0,
  });
}

class AvatarNetworkExplorerPage extends StatefulWidget {
  final Function(String avatarUrl)? onAvatarSelected;

  const AvatarNetworkExplorerPage({
    super.key,
    this.onAvatarSelected,
  });

  @override
  State<AvatarNetworkExplorerPage> createState() =>
      _AvatarNetworkExplorerPageState();
}

class _AvatarNetworkExplorerPageState extends State<AvatarNetworkExplorerPage> {
  final TextEditingController _searchController =
      TextEditingController(text: 'PocketMate');
  String _selectedCategory = 'All';
  String _currentSeed = 'PocketMate';
  bool _isSaving = false;
  int _refreshCounter = 0;

  final List<String> _categories = [
    'All',
    '🔥 1-of-1 NFTs',
    'Anime / Fantasy',
    'Sci-Fi / Mecha',
    'People / Urban',
    'Pixel Art',
    'Animals / Chibi',
    'Robots / AI',
    'Artistic / Doodle',
    'Multiverse / Global',
    'Abstract / Minimal',
  ];

  final List<double> _aspectRatios = [1.0, 1.15, 0.95, 1.2, 1.05, 0.9];

  @override
  void initState() {
    super.initState();
    AvatarUniquenessService().init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _randomizeSeed() {
    final randWords = [
      'CyberKnight',
      'SolarFlare',
      'ShadowFox',
      'NeonDragon',
      'PixelSamurai',
      'QuantumAI',
      'StarlightMage',
      'AstroViper',
      'TokyoNeko',
      'ChibiHero',
      'VortexPilot',
      'GoldenMonarch',
      'ArcadeLegend',
      'CosmicRanger',
      'MythicBeast'
    ];
    randWords.shuffle();
    final newSeed =
        '${randWords.first}_${DateTime.now().millisecondsSinceEpoch % 999}';
    setState(() {
      _currentSeed = newSeed;
      _searchController.text = newSeed;
      _refreshCounter++;
    });
    HapticFeedback.lightImpact();
  }

  List<ExplorerFeedItem> _buildFeedItems() {
    final List<ExplorerFeedItem> items = [];
    final rand = Random(_currentSeed.hashCode + _refreshCounter);

    // 1. Filtered styles
    final filteredStyles = _selectedCategory == 'All' ||
            _selectedCategory == '🔥 1-of-1 NFTs'
        ? AvatarNetworkService.catalog
        : AvatarNetworkService.catalog
            .where((s) => s.category == _selectedCategory)
            .toList();

    // 2. Procedural Bored Apes (NFTs)
    final apes = AvatarUniquenessService()
        .generateProceduralBoredApes(count: _selectedCategory == '🔥 1-of-1 NFTs' ? 30 : 12);

    int styleIdx = 0;
    int apeIdx = 0;

    if (_selectedCategory == '🔥 1-of-1 NFTs') {
      for (final ape in apes) {
        final ratio = _aspectRatios[rand.nextInt(_aspectRatios.length)];
        items.add(ExplorerFeedItem(
          type: ExplorerItemType.nftApe,
          nftItem: ape,
          aspectRatio: ratio,
        ));
      }
      return items;
    }

    while (styleIdx < filteredStyles.length || apeIdx < apes.length) {
      if (styleIdx < filteredStyles.length) {
        final style = filteredStyles[styleIdx];
        final ratio = _aspectRatios[(styleIdx + _refreshCounter) % _aspectRatios.length];
        items.add(ExplorerFeedItem(
          type: ExplorerItemType.networkStyle,
          networkStyle: style,
          aspectRatio: ratio,
        ));
        styleIdx++;
      }

      // Interleave 1-of-1 NFT every 2 items
      if (styleIdx % 2 == 0 && apeIdx < apes.length) {
        final ape = apes[apeIdx];
        final ratio = _aspectRatios[(apeIdx + _refreshCounter + 1) % _aspectRatios.length];
        items.add(ExplorerFeedItem(
          type: ExplorerItemType.nftApe,
          nftItem: ape,
          aspectRatio: ratio,
        ));
        apeIdx++;
      }
    }

    return items;
  }

  Future<void> _selectAvatar({
    required String avatarUrl,
    required String styleName,
    String? species,
    String? dnaHash,
    String? mintId,
    String rarityTier = 'Original 1-of-1',
    String artStyle = 'network',
  }) async {
    setState(() => _isSaving = true);
    try {
      final user = SupaFlow.client.auth.currentUser;
      final finalDna = dnaHash ??
          '0xNET-${DateTime.now().millisecondsSinceEpoch % 1000000}';
      final finalMintId =
          mintId ?? '#MATE-${DateTime.now().millisecondsSinceEpoch % 100000}';

      if (user != null) {
        // Save ONLY to avatar_config without touching profile_image_url
        await SupaFlow.client.from('profile').update({
          'avatar_config': {
            'artStyle': artStyle,
            'species': species ?? styleName.toLowerCase(),
            'mintId': finalMintId,
            'dnaHash': finalDna,
            'rarityTier': rarityTier,
            'networkImageUrl': avatarUrl,
            'imageUrl': avatarUrl,
          },
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', user.id);

        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('profile_cache_${user.id}');
          await prefs.remove('cached_profile_${user.id}');
        } catch (_) {}
      }

      if (widget.onAvatarSelected != null) {
        widget.onAvatarSelected!(avatarUrl);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.black),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Set $styleName as your Avatar! 🚀',
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFFFFC00),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, avatarUrl);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update avatar: $e',
                style: const TextStyle(color: Colors.white, fontSize: 12)),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- Pinterest-style Modal Dialog with Full Provenance History ---
  void _showItemPreviewModal(ExplorerFeedItem item) {
    if (item.type == ExplorerItemType.networkStyle) {
      final style = item.networkStyle!;
      final url = AvatarNetworkService.buildAvatarUrl(
        styleId: style.id,
        seed: _currentSeed,
        size: 320,
      );
      final mintId = '#NET-${style.id.toUpperCase()}-${_currentSeed.hashCode.abs() % 9999}';
      final dna = '0x${_currentSeed.hashCode.toRadixString(16).padLeft(6, '0').toUpperCase()}';
      final provenance = AvatarUniquenessService().getProvenance(mintId, creator: 'Pocket Labs (${style.name})', dnaHash: dna);

      _showModalDetails(
        title: style.name,
        badge: '${style.icon} ${style.category}',
        badgeColor: style.accentColor,
        creator: 'Pocket Labs',
        mintId: mintId,
        dnaHash: dna,
        rarityTier: 'Network 1-of-1',
        description: style.description,
        provenance: provenance,
        previewWidget: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, __) => const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFFC00), strokeWidth: 2),
          ),
          errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white30),
        ),
        onSetAvatar: () => _selectAvatar(
          avatarUrl: url,
          styleName: style.name,
          species: style.id,
          dnaHash: dna,
          mintId: mintId,
          rarityTier: 'Network 1-of-1',
          artStyle: 'network',
        ),
      );
    } else {
      final ape = item.nftItem!;
      final provenance = AvatarUniquenessService().getProvenance(ape.id, creator: ape.artistName, dnaHash: ape.dnaHash);

      _showModalDetails(
        title: ape.title,
        badge: '🔥 ${ape.rarityTier}',
        badgeColor: ape.rarityTier.contains('Mythic') ? const Color(0xFFFF007A) : const Color(0xFFFFFC00),
        creator: ape.artistName,
        mintId: ape.id,
        dnaHash: ape.dnaHash,
        rarityTier: ape.rarityTier,
        description: 'Verified 1-of-1 NFT Identity with cryptographic DNA hashing.',
        provenance: provenance,
        previewWidget: ape.apeTraits != null
            ? BoredApeWidget(
                traits: ape.apeTraits!,
                size: 200,
                backgroundColor: ape.cardColor,
              )
            : const Icon(Icons.stars, color: Color(0xFFFFFC00), size: 80),
        onSetAvatar: () => _selectAvatar(
          avatarUrl: ape.imageUrl,
          styleName: ape.title,
          species: 'bored_ape',
          dnaHash: ape.dnaHash,
          mintId: ape.id,
          rarityTier: ape.rarityTier,
          artStyle: 'bayc',
        ),
      );
    }
  }

  void _showModalDetails({
    required String title,
    required String badge,
    required Color badgeColor,
    required String creator,
    required String mintId,
    required String dnaHash,
    required String rarityTier,
    required String description,
    required List<AvatarProvenanceEvent> provenance,
    required Widget previewWidget,
    required VoidCallback onSetAvatar,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF13151F),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: Color(0xFFFFFC00), width: 2)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  children: [
                    // Header Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.outfit(
                              color: badgeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white54),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Avatar Visual Card
                    Center(
                      child: Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF181A26),
                          border: Border.all(color: const Color(0xFFFFFC00), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFFC00).withValues(alpha: 0.25),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(child: previewWidget),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Title & Creator
                    Center(
                      child: Column(
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.verified, color: Color(0xFFFFFC00), size: 14),
                              const SizedBox(width: 5),
                              Text(
                                'Creator: $creator',
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Blockchain / DNA Info Badges
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF181A26),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('TOKEN ID',
                                    style: GoogleFonts.outfit(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text(mintId,
                                    style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 28, color: Colors.white12),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('DNA HASH',
                                    style: GoogleFonts.outfit(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text(dnaHash,
                                    style: GoogleFonts.inter(color: const Color(0xFFFFFC00), fontSize: 11, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 📜 Provenance & Transfer History Section
                    Row(
                      children: [
                        const Icon(Icons.history_rounded, color: Color(0xFFFFFC00), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Ownership & Transfer History',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF181A26),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: provenance.map((evt) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    evt.eventType == 'MINTED'
                                        ? Icons.auto_awesome
                                        : (evt.eventType == 'CLAIMED'
                                            ? Icons.how_to_reg
                                            : Icons.swap_horiz),
                                    color: const Color(0xFFFFFC00),
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${evt.eventType}: ${evt.from} → ${evt.to}',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (evt.note != null)
                                        Text(
                                          evt.note!,
                                          style: GoogleFonts.inter(
                                            color: Colors.white60,
                                            fontSize: 10,
                                          ),
                                        ),
                                      Text(
                                        'Tx: ${evt.txHash} • ${_formatDate(evt.timestamp)}',
                                        style: GoogleFonts.inter(
                                          color: Colors.white38,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Bottom Sticky Action Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF13151F),
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFC00),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                    ),
                    onPressed: _isSaving
                        ? null
                        : () {
                            Navigator.pop(context);
                            onSetAvatar();
                          },
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                          )
                        : Text(
                            'Set as My Profile Avatar',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final feedItems = _buildFeedItems();

    // Split feed into 2 Pinterest columns
    final List<ExplorerFeedItem> col1 = [];
    final List<ExplorerFeedItem> col2 = [];
    for (int i = 0; i < feedItems.length; i++) {
      if (i % 2 == 0) {
        col1.add(feedItems[i]);
      } else {
        col2.add(feedItems[i]);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F1017),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161822),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text('🌐', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              'Avatar Explorer',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Roll Random Seeds',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8906)]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.casino_rounded, color: Colors.black, size: 20),
            ),
            onPressed: _randomizeSeed,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar & Seed Generator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: const Color(0xFF161822),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1017),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Color(0xFFFFFC00), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search anime, mecha, pixel, names...',
                        hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          setState(() {
                            _currentSeed = val.trim();
                            _refreshCounter++;
                          });
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search_rounded, color: Color(0xFFFFFC00), size: 18),
                    onPressed: () {
                      if (_searchController.text.trim().isNotEmpty) {
                        setState(() {
                          _currentSeed = _searchController.text.trim();
                          _refreshCounter++;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // 2. Category Filter Pills
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSel = _selectedCategory == cat;

                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFFFFFC00) : const Color(0xFF1A1C28),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSel ? const Color(0xFFFFFC00) : Colors.white10,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        cat,
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

          // 3. Pinterest-Style Masonry Staggered Grid (Edge-to-Edge Visuals)
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFFFFFC00),
              backgroundColor: const Color(0xFF161822),
              onRefresh: () async {
                _randomizeSeed();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Column 1
                    Expanded(
                      child: Column(
                        children: col1.map((item) => _buildPinterestCard(item)).toList(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Column 2
                    Expanded(
                      child: Column(
                        children: col2.map((item) => _buildPinterestCard(item)).toList(),
                      ),
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

  Widget _buildPinterestCard(ExplorerFeedItem item) {
    final bool isNft = item.type == ExplorerItemType.nftApe;

    return GestureDetector(
      onTap: () => _showItemPreviewModal(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF161822),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isNft ? const Color(0xFFFFFC00).withValues(alpha: 0.6) : Colors.white12,
            width: isNft ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isNft
                  ? const Color(0xFFFFFC00).withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              // Edge-to-Edge Image
              if (!isNft)
                AspectRatio(
                  aspectRatio: item.aspectRatio,
                  child: Container(
                    color: const Color(0xFF11121A),
                    child: CachedNetworkImage(
                      imageUrl: AvatarNetworkService.buildAvatarUrl(
                        styleId: item.networkStyle!.id,
                        seed: _currentSeed,
                        size: 240,
                      ),
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: const Color(0xFF161822),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFFC00)),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white24),
                    ),
                  ),
                )
              else
                AspectRatio(
                  aspectRatio: item.aspectRatio,
                  child: Container(
                    color: item.nftItem!.cardColor,
                    child: item.nftItem!.apeTraits != null
                        ? BoredApeWidget(
                            traits: item.nftItem!.apeTraits!,
                            size: 180,
                            backgroundColor: item.nftItem!.cardColor,
                          )
                        : const Icon(Icons.stars, color: Color(0xFFFFFC00), size: 40),
                  ),
                ),

              // Gradient Overlay on hover/bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isNft ? '1-of-1 NFT' : item.networkStyle!.category.split(' ').first,
                        style: GoogleFonts.outfit(
                          color: isNft ? const Color(0xFFFFFC00) : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                      const Icon(Icons.touch_app_rounded, color: Colors.white54, size: 11),
                    ],
                  ),
                ),
              ),

              // Top Ribbon for NFTs
              if (isNft)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF007A), Color(0xFF7928CA)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF007A).withValues(alpha: 0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      '🔥 1-of-1',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
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
