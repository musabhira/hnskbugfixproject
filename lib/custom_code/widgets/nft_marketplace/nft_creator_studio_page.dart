import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pocket_mates_app/custom_code/widgets/doodle_background_painter.dart';
import 'nft_models.dart';

class NftCreatorStudioPage extends StatefulWidget {
  final Function(NftItem mintedItem)? onMinted;

  const NftCreatorStudioPage({super.key, this.onMinted});

  @override
  State<NftCreatorStudioPage> createState() => _NftCreatorStudioPageState();
}

class _NftCreatorStudioPageState extends State<NftCreatorStudioPage> {
  // Config state
  int _selectedArchetype = 0;
  int _selectedBackground = 0;
  int _selectedHeadwear = 0;
  int _selectedEyes = 0;
  int _selectedOutfit = 0;

  final TextEditingController _titleController = TextEditingController(text: 'Cyber Bored Ape #999');
  final TextEditingController _priceController = TextEditingController(text: '0.25');
  int _coinPrice = 500;
  String _rarityTier = 'Mythic 1-of-1';
  bool _isMinting = false;

  late String _dnaHash;

  final List<Map<String, dynamic>> _archetypes = [
    {
      'name': 'Bored Ape',
      'species': 'Ape Illustration',
      'img': 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&auto=format&fit=crop&q=80',
      'color': const Color(0xFF8B5CF6),
    },
    {
      'name': 'Monarch Ape',
      'species': 'Royal Ape',
      'img': 'https://images.unsplash.com/photo-1634017839464-5c339ebe3cb4?w=800&auto=format&fit=crop&q=80',
      'color': const Color(0xFFFFB700),
    },
    {
      'name': 'Samurai Shinobi',
      'species': 'Shinobi Beast',
      'img': 'https://images.unsplash.com/photo-1620641788421-7a1c342ea42e?w=800&auto=format&fit=crop&q=80',
      'color': const Color(0xFFFF007A),
    },
    {
      'name': 'Mecha Kong',
      'species': 'Cyber Mecha',
      'img': 'https://images.unsplash.com/photo-1614680376593-902f749f7ffc?w=800&auto=format&fit=crop&q=80',
      'color': const Color(0xFF00E5FF),
    },
    {
      'name': 'Cosmic Dragon',
      'species': 'Astral Dragon',
      'img': 'https://images.unsplash.com/photo-1633167606207-d840b5070fc2?w=800&auto=format&fit=crop&q=80',
      'color': const Color(0xFF7928CA),
    },
  ];

  final List<Color> _backgroundColors = [
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFFFF007A), // Neon Magenta
    const Color(0xFF00E5FF), // Cyber Cyan
    const Color(0xFFFFB700), // Gold
    const Color(0xFF10B981), // Emerald Matrix
    const Color(0xFF1E202E), // Obsidian Dark
  ];

  final List<String> _headwears = ['None', 'Solar Gold Crown', 'Artist Pencil', 'Samurai Headband', 'VR Goggles'];
  final List<String> _eyesOptions = ['Normal', 'Neon Laser Eyes', 'Cyber Glasses', 'Shuriken Pupils', 'Golden Shades'];
  final List<String> _outfits = ['Tuxedo Bowtie', 'Cyber Armor', 'Shadow Kimono', 'Astronaut Suit', 'Royal Cape'];

  @override
  void initState() {
    super.initState();
    _generateDna();
  }

  void _generateDna() {
    final rand = Random();
    final h1 = rand.nextInt(256).toRadixString(16).padLeft(2, '0').toUpperCase();
    final h2 = rand.nextInt(256).toRadixString(16).padLeft(2, '0').toUpperCase();
    final h3 = rand.nextInt(256).toRadixString(16).padLeft(2, '0').toUpperCase();
    final h4 = rand.nextInt(256).toRadixString(16).padLeft(2, '0').toUpperCase();
    _dnaHash = '0x$h1-$h2-$h3-$h4';
  }

  void _randomize() {
    HapticFeedback.mediumImpact();
    final rand = Random();
    setState(() {
      _selectedArchetype = rand.nextInt(_archetypes.length);
      _selectedBackground = rand.nextInt(_backgroundColors.length);
      _selectedHeadwear = rand.nextInt(_headwears.length);
      _selectedEyes = rand.nextInt(_eyesOptions.length);
      _selectedOutfit = rand.nextInt(_outfits.length);
      _generateDna();
    });
  }

  Future<void> _mintNft() async {
    setState(() => _isMinting = true);
    HapticFeedback.heavyImpact();

    await Future.delayed(const Duration(milliseconds: 1200));

    final archetype = _archetypes[_selectedArchetype];
    final eth = double.tryParse(_priceController.text) ?? 0.20;

    final minted = NftItem(
      id: 'MINT-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim().isEmpty ? archetype['name'] : _titleController.text.trim(),
      collectionName: 'Pocket Exclusive Mints',
      artistName: 'You (Creator)',
      artistHandle: '@you',
      artistAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&auto=format&fit=crop&q=80',
      imageUrl: archetype['img'],
      priceEth: eth,
      priceCoins: _coinPrice,
      priceInr: eth * 1000,
      likesCount: 1,
      rarityTier: _rarityTier,
      dnaHash: _dnaHash,
      auctionEndsAt: DateTime.now().add(const Duration(days: 7)),
      cardColor: _backgroundColors[_selectedBackground],
      isTrending: true,
      traits: [
        NftTrait(traitType: 'Archetype', value: archetype['name'], rarityPercent: 1.5),
        NftTrait(traitType: 'Headwear', value: _headwears[_selectedHeadwear], rarityPercent: 2.8),
        NftTrait(traitType: 'Eyes', value: _eyesOptions[_selectedEyes], rarityPercent: 3.1),
        NftTrait(traitType: 'Outfit', value: _outfits[_selectedOutfit], rarityPercent: 4.0),
      ],
    );

    if (mounted) {
      widget.onMinted?.call(minted);
      setState(() => _isMinting = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.verified, color: Colors.yellow),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '🎉 Successfully Minted ${minted.title} to NFT Marketplace!',
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

  @override
  Widget build(BuildContext context) {
    final curArchetype = _archetypes[_selectedArchetype];
    final curBg = _backgroundColors[_selectedBackground];

    return Scaffold(
      backgroundColor: const Color(0xFF0C0D14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'PRO NFT MINTING STUDIO',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle_rounded, color: Color(0xFFFFFC00)),
            tooltip: 'Randomize Traits',
            onPressed: _randomize,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: PocketDoodleBackgroundPainter(
                color: const Color(0xFF8B5CF6),
                isDark: true,
                opacityMultiplier: 0.4,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Live 3D High-Res NFT Card Preview (Matching User Screenshot)
                        Center(
                          child: Container(
                            height: 320,
                            width: 270,
                            decoration: BoxDecoration(
                              color: curBg,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: curBg.withValues(alpha: 0.5),
                                  blurRadius: 35,
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
                                      imageUrl: curArchetype['img'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  // Gradient shadow
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black26,
                                            Colors.transparent,
                                            Colors.black.withValues(alpha: 0.8),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Top Rarity
                                  Positioned(
                                    top: 14,
                                    left: 14,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
                                      ),
                                      child: Text(
                                        _rarityTier,
                                        style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  // DNA Hash
                                  Positioned(
                                    top: 14,
                                    right: 14,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        _dnaHash,
                                        style: GoogleFonts.sourceCodePro(color: Colors.white70, fontSize: 9),
                                      ),
                                    ),
                                  ),
                                  // Bottom Frosted Bar
                                  Positioned(
                                    bottom: 12,
                                    left: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF14141E).withValues(alpha: 0.85),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.white12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                _titleController.text.isEmpty ? curArchetype['name'] : _titleController.text,
                                                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                              ),
                                              Text(
                                                'By You (Creator)',
                                                style: GoogleFonts.inter(color: Colors.white54, fontSize: 10),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${_priceController.text} ETH',
                                            style: GoogleFonts.outfit(color: const Color(0xFFFF007A), fontWeight: FontWeight.w900, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title & Price Inputs
                        Text('NFT Title', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _titleController,
                          onChanged: (_) => setState(() {}),
                          style: GoogleFonts.outfit(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF1A1B28),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Price (ETH)', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _priceController,
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setState(() {}),
                                    style: GoogleFonts.outfit(color: Colors.white),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(0xFF1A1B28),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Pocket Coins (🪙)', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A1B28),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text('🪙 $_coinPrice Coins', style: GoogleFonts.outfit(color: const Color(0xFFFFFC00), fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Section 1: Base Character Archetype
                        Text('Base Character Archetype', style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 70,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _archetypes.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (context, i) {
                              final a = _archetypes[i];
                              final isSel = _selectedArchetype == i;
                              return GestureDetector(
                                onTap: () => setState(() {
                                  _selectedArchetype = i;
                                  _generateDna();
                                }),
                                child: Container(
                                  width: 120,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSel ? a['color'] : const Color(0xFF1A1B28),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: isSel ? Colors.white : Colors.white10, width: isSel ? 2 : 1),
                                  ),
                                  child: Center(
                                    child: Text(
                                      a['name'],
                                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Section 2: Background Canvas
                        Text('Background Color & Aura', style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 50,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _backgroundColors.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (context, i) {
                              final c = _backgroundColors[i];
                              final isSel = _selectedBackground == i;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedBackground = i),
                                child: Container(
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: isSel ? Colors.white : Colors.transparent, width: 3),
                                    boxShadow: [
                                      if (isSel) BoxShadow(color: c.withValues(alpha: 0.6), blurRadius: 10),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Section 3: Headwear
                        Text('Headwear & Crowns', style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(_headwears.length, (i) {
                            final isSel = _selectedHeadwear == i;
                            return ChoiceChip(
                              label: Text(_headwears[i]),
                              selected: isSel,
                              selectedColor: const Color(0xFF8B5CF6),
                              backgroundColor: const Color(0xFF1A1B28),
                              labelStyle: GoogleFonts.outfit(color: isSel ? Colors.white : Colors.white70, fontWeight: FontWeight.bold),
                              onSelected: (_) => setState(() => _selectedHeadwear = i),
                            );
                          }),
                        ),
                        const SizedBox(height: 20),

                        // Section 4: Eyes & Cyber Visor
                        Text('Eyes & Cyber Visor', style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(_eyesOptions.length, (i) {
                            final isSel = _selectedEyes == i;
                            return ChoiceChip(
                              label: Text(_eyesOptions[i]),
                              selected: isSel,
                              selectedColor: const Color(0xFFFF007A),
                              backgroundColor: const Color(0xFF1A1B28),
                              labelStyle: GoogleFonts.outfit(color: isSel ? Colors.white : Colors.white70, fontWeight: FontWeight.bold),
                              onSelected: (_) => setState(() => _selectedEyes = i),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Mint Button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF14151F),
                    border: Border(top: BorderSide(color: Colors.white10)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFC00),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: _isMinting ? null : _mintNft,
                      child: _isMinting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.auto_awesome, color: Colors.black, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'MINT 1-OF-1 NFT TO MARKET',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
                                ),
                              ],
                            ),
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
