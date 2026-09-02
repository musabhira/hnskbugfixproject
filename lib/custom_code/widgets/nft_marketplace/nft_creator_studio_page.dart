import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/widgets/doodle_background_painter.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/bored_ape_painter.dart';
import 'nft_models.dart';

class NftCreatorStudioPage extends StatefulWidget {
  final Function(NftItem mintedItem)? onMinted;

  const NftCreatorStudioPage({super.key, this.onMinted});

  @override
  State<NftCreatorStudioPage> createState() => _NftCreatorStudioPageState();
}

class _NftCreatorStudioPageState extends State<NftCreatorStudioPage> {
  // Bored Ape Traits
  String _fur = 'brown';
  String _eyes = 'laser_beams';
  String _mouth = 'wide_grin';
  String _headwear = 'none';
  String _outfit = 'military_jacket';
  String _background = 'orange';
  bool _hasEarring = true;

  final TextEditingController _titleController = TextEditingController(text: 'Bored Ape Yacht #320');
  final TextEditingController _priceController = TextEditingController(text: '0.20');
  final int _coinPrice = 500;
  final String _rarityTier = 'Mythic 1-of-1';
  bool _isMinting = false;

  late String _dnaHash;

  final List<Map<String, dynamic>> _furOptions = [
    {'id': 'brown', 'name': 'Classic Brown', 'color': Color(0xFF8D5524)},
    {'id': 'leopard', 'name': 'Leopard Cheetah', 'color': Color(0xFFE4A444)},
    {'id': 'gold', 'name': 'Pure Gold', 'color': Color(0xFFFFD700)},
    {'id': 'cyber_grey', 'name': 'Cyber Grey', 'color': Color(0xFF7F8C8D)},
    {'id': 'zombie_green', 'name': 'Zombie Green', 'color': Color(0xFF55EFC4)},
    {'id': 'obsidian', 'name': 'Obsidian Dark', 'color': Color(0xFF2D3436)},
  ];

  final List<Map<String, dynamic>> _eyeOptions = [
    {'id': 'laser_beams', 'name': 'Cyan Laser Beams'},
    {'id': 'cyborg_red', 'name': 'Cyborg Red Eye'},
    {'id': '3d_glasses', 'name': '3D Red-Blue Glasses'},
    {'id': 'vr_visor', 'name': 'VR Neon Visor'},
    {'id': 'x_eyes', 'name': 'Dead X-Eyes'},
    {'id': 'sleepy', 'name': 'Sleepy Droop'},
  ];

  final List<Map<String, dynamic>> _mouthOptions = [
    {'id': 'wide_grin', 'name': 'Wide Grin Teeth'},
    {'id': 'tongue_out', 'name': 'Tongue Out'},
    {'id': 'cigarette', 'name': 'Cigarette Joint'},
    {'id': 'pout', 'name': 'Bored Pout'},
  ];

  final List<Map<String, dynamic>> _headwearOptions = [
    {'id': 'none', 'name': 'None'},
    {'id': 'sailor_hat', 'name': 'Navy Sailor Hat'},
    {'id': 'captain_hat', 'name': 'Captain Officer Hat'},
    {'id': 'gold_crown', 'name': 'Solar King Crown'},
  ];

  final List<Map<String, dynamic>> _outfitOptions = [
    {'id': 'military_jacket', 'name': 'Military Army Jacket'},
    {'id': 'cyber_armor', 'name': 'Cybernetic Plate Armor'},
    {'id': 'naked', 'name': 'Natural Fur'},
  ];

  final List<Map<String, dynamic>> _bgOptions = [
    {'id': 'orange', 'name': 'Vibrant Orange', 'color': Color(0xFFE58E26)},
    {'id': 'teal', 'name': 'Teal Green', 'color': Color(0xFF00B894)},
    {'id': 'cyan', 'name': 'Electric Cyan', 'color': Color(0xFF00CEC9)},
    {'id': 'purple', 'name': 'Cyber Purple', 'color': Color(0xFF6C5CE7)},
    {'id': 'amber', 'name': 'Golden Amber', 'color': Color(0xFFF39C12)},
    {'id': 'dark', 'name': 'Obsidian Void', 'color': Color(0xFF1E202E)},
  ];

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
      _fur = _furOptions[rand.nextInt(_furOptions.length)]['id'];
      _eyes = _eyeOptions[rand.nextInt(_eyeOptions.length)]['id'];
      _mouth = _mouthOptions[rand.nextInt(_mouthOptions.length)]['id'];
      _headwear = _headwearOptions[rand.nextInt(_headwearOptions.length)]['id'];
      _outfit = _outfitOptions[rand.nextInt(_outfitOptions.length)]['id'];
      _background = _bgOptions[rand.nextInt(_bgOptions.length)]['id'];
      _hasEarring = rand.nextBool();
      _generateDna();
    });
  }

  Future<void> _mintNft() async {
    setState(() => _isMinting = true);
    HapticFeedback.heavyImpact();

    await Future.delayed(const Duration(milliseconds: 1000));

    final eth = double.tryParse(_priceController.text) ?? 0.20;

    final minted = NftItem(
      id: 'BAYC-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim().isEmpty ? 'Bored Ape #999' : _titleController.text.trim(),
      collectionName: 'Bored Ape Yacht Club',
      artistName: 'You (Creator)',
      artistHandle: '@you',
      artistAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&auto=format&fit=crop&q=80',
      imageUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&auto=format&fit=crop&q=80',
      priceEth: eth,
      priceCoins: _coinPrice,
      priceInr: eth * 1000,
      likesCount: 1,
      rarityTier: _rarityTier,
      dnaHash: _dnaHash,
      auctionEndsAt: DateTime.now().add(const Duration(days: 7)),
      cardColor: BoredApeTraits.getBackgroundColor(_background),
      isTrending: true,
      traits: [
        NftTrait(traitType: 'Fur', value: _fur, rarityPercent: 1.2),
        NftTrait(traitType: 'Eyes', value: _eyes, rarityPercent: 2.5),
        NftTrait(traitType: 'Mouth', value: _mouth, rarityPercent: 3.1),
        NftTrait(traitType: 'Headwear', value: _headwear, rarityPercent: 1.8),
        NftTrait(traitType: 'Outfit', value: _outfit, rarityPercent: 4.2),
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
    final traits = BoredApeTraits(
      furColor: _fur,
      eyes: _eyes,
      mouth: _mouth,
      headwear: _headwear,
      outfit: _outfit,
      background: _background,
      hasEarring: _hasEarring,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0C0D14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'BORED APE NFT STUDIO',
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
                        // Live Vector Bored Ape Canvas (Matching user screenshot)
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: BoredApeTraits.getBackgroundColor(_background).withValues(alpha: 0.5),
                                  blurRadius: 35,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: BoredApeWidget(
                              traits: traits,
                              size: 260,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // DNA & Rarity Tag
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1B28),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              '🧬 DNA HASH: $_dnaHash  •  $_rarityTier',
                              style: GoogleFonts.sourceCodePro(
                                color: const Color(0xFFFFD700),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Title & Price Inputs
                        Text('NFT Name', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
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

                        // Trait 1: Eyes (Laser Beams, 3D Glasses, VR Visor, etc.)
                        Text('👀 Eyes & Cyber Visor', style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _eyeOptions.map((opt) {
                            final isSel = _eyes == opt['id'];
                            return ChoiceChip(
                              label: Text(opt['name']),
                              selected: isSel,
                              selectedColor: const Color(0xFF00CEC9),
                              backgroundColor: const Color(0xFF1A1B28),
                              labelStyle: GoogleFonts.outfit(color: isSel ? Colors.black : Colors.white70, fontWeight: FontWeight.bold),
                              onSelected: (_) => setState(() {
                                _eyes = opt['id'];
                                _generateDna();
                              }),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Trait 2: Mouth & Teeth Grin
                        Text('👄 Mouth & Expression', style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _mouthOptions.map((opt) {
                            final isSel = _mouth == opt['id'];
                            return ChoiceChip(
                              label: Text(opt['name']),
                              selected: isSel,
                              selectedColor: const Color(0xFFFF007A),
                              backgroundColor: const Color(0xFF1A1B28),
                              labelStyle: GoogleFonts.outfit(color: isSel ? Colors.white : Colors.white70, fontWeight: FontWeight.bold),
                              onSelected: (_) => setState(() {
                                _mouth = opt['id'];
                                _generateDna();
                              }),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Trait 3: Headwear (Sailor, Captain, Crown)
                        Text('🎩 Headwear & Hats', style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _headwearOptions.map((opt) {
                            final isSel = _headwear == opt['id'];
                            return ChoiceChip(
                              label: Text(opt['name']),
                              selected: isSel,
                              selectedColor: const Color(0xFF8B5CF6),
                              backgroundColor: const Color(0xFF1A1B28),
                              labelStyle: GoogleFonts.outfit(color: isSel ? Colors.white : Colors.white70, fontWeight: FontWeight.bold),
                              onSelected: (_) => setState(() {
                                _headwear = opt['id'];
                                _generateDna();
                              }),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Trait 4: Fur (Brown, Leopard, Gold, Cyber)
                        Text('🦁 Fur & Skin', style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 50,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _furOptions.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (context, i) {
                              final f = _furOptions[i];
                              final isSel = _fur == f['id'];
                              return GestureDetector(
                                onTap: () => setState(() {
                                  _fur = f['id'];
                                  _generateDna();
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSel ? f['color'] : const Color(0xFF1A1B28),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: isSel ? Colors.white : Colors.white10),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(width: 12, height: 12, decoration: BoxDecoration(color: f['color'], shape: BoxShape.circle)),
                                      const SizedBox(width: 8),
                                      Text(
                                        f['name'],
                                        style: GoogleFonts.outfit(color: isSel ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Trait 5: Outfit (Military Jacket, Cyber Armor)
                        Text('🥋 Outfit & Cyber Neck', style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _outfitOptions.map((opt) {
                            final isSel = _outfit == opt['id'];
                            return ChoiceChip(
                              label: Text(opt['name']),
                              selected: isSel,
                              selectedColor: const Color(0xFFF1C40F),
                              backgroundColor: const Color(0xFF1A1B28),
                              labelStyle: GoogleFonts.outfit(color: isSel ? Colors.black : Colors.white70, fontWeight: FontWeight.bold),
                              onSelected: (_) => setState(() {
                                _outfit = opt['id'];
                                _generateDna();
                              }),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Trait 6: Background Color
                        Text('🎨 Background Color', style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 48,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _bgOptions.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (context, i) {
                              final b = _bgOptions[i];
                              final isSel = _background == b['id'];
                              return GestureDetector(
                                onTap: () => setState(() => _background = b['id']),
                                child: Container(
                                  width: 48,
                                  decoration: BoxDecoration(
                                    color: b['color'],
                                    shape: BoxShape.circle,
                                    border: Border.all(color: isSel ? Colors.white : Colors.transparent, width: 3),
                                    boxShadow: [
                                      if (isSel) BoxShadow(color: (b['color'] as Color).withValues(alpha: 0.6), blurRadius: 10),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
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
                                  'MINT BORED APE 1-OF-1 NFT',
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
