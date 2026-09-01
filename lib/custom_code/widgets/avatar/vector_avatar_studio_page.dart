import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'vector_avatar_config.dart';
import 'vector_avatar_widget.dart';
import 'avatar_sticker_pack_sheet.dart';
import 'avatar_comic_strip_page.dart';

class VectorAvatarStudioPage extends StatefulWidget {
  final VectorAvatarConfig? initialConfig;
  final Function(VectorAvatarConfig)? onAvatarSaved;

  const VectorAvatarStudioPage({
    super.key,
    this.initialConfig,
    this.onAvatarSaved,
  });

  @override
  State<VectorAvatarStudioPage> createState() => _VectorAvatarStudioPageState();
}

class _VectorAvatarStudioPageState extends State<VectorAvatarStudioPage>
    with SingleTickerProviderStateMixin {
  late VectorAvatarConfig _config;
  late TabController _tabController;
  bool _isSaving = false;
  bool _isLoading = true;
  String? _selectedPersonaId;
  String _selectedRoleCategory = 'All';

  final List<String> _tabs = [
    '🎭 Roles (50+)',
    'Face & Skin',
    'Hairstyle',
    'Expressions',
    'Outfits',
    'Accessories',
    'Aura',
  ];

  final List<String> _roleCategories = [
    'All',
    'Healthcare',
    'Tech',
    'Hero',
    'Aviation',
    'Art',
    'Warrior',
    'Royalty',
    'Business',
  ];

  @override
  void initState() {
    super.initState();
    _config = widget.initialConfig ?? const VectorAvatarConfig();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadUserAvatar();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAvatar() async {
    try {
      final user = SupaFlow.client.auth.currentUser;
      if (user != null) {
        final profileRes = await SupaFlow.client
            .from('profile')
            .select('avatar_config')
            .eq('user_id', user.id)
            .maybeSingle();

        if (profileRes != null && profileRes['avatar_config'] != null) {
          final Map<String, dynamic> data =
              Map<String, dynamic>.from(profileRes['avatar_config']);
          if (mounted) {
            setState(() {
              _config = VectorAvatarConfig.fromMap(data);
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading avatar config: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyPersona(Map<String, dynamic> persona) {
    final cfg = persona['config'] as VectorAvatarConfig;
    setState(() {
      _selectedPersonaId = persona['id'];
      _config = cfg;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎭 Applied role: ${persona['name']}'),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _randomizeAvatar() {
    final rand = math.Random();

    final skins = VectorAvatarPalette.skinTones;
    final hairs = VectorAvatarPalette.hairStyles;
    final hairColors = VectorAvatarPalette.hairColors;
    final eyes = VectorAvatarPalette.eyeStyles;
    final eyeColors = VectorAvatarPalette.eyeColors;
    final beards = VectorAvatarPalette.beardStyles;
    final outfits = VectorAvatarPalette.outfitStyles;
    final outfitColors = VectorAvatarPalette.outfitColors;
    final accessories = VectorAvatarPalette.accessoryStyles;
    final auras = VectorAvatarPalette.auraStyles;
    final artStyles = VectorAvatarPalette.artStyles;

    setState(() {
      _selectedPersonaId = null;
      _config = _config.copyWith(
        artStyle: artStyles[rand.nextInt(artStyles.length)]['id'],
        skinColor: skins[rand.nextInt(skins.length)],
        faceShape: ['oval', 'round', 'sharp', 'square'][rand.nextInt(4)],
        hairStyle: hairs[rand.nextInt(hairs.length)]['id'],
        hairColor: hairColors[rand.nextInt(hairColors.length)],
        eyeStyle: eyes[rand.nextInt(eyes.length)]['id'],
        eyeColor: eyeColors[rand.nextInt(eyeColors.length)],
        eyebrowStyle: ['confident', 'thick', 'arched', 'angry_hero'][rand.nextInt(4)],
        mouthStyle: ['smile', 'laugh', 'smirk', 'joker_grin', 'chill'][rand.nextInt(5)],
        beardStyle: beards[rand.nextInt(beards.length)]['id'],
        outfitStyle: outfits[rand.nextInt(outfits.length)]['id'],
        outfitColor: outfitColors[rand.nextInt(outfitColors.length)],
        outfitAccentColor: outfitColors[rand.nextInt(outfitColors.length)],
        accessory: accessories[rand.nextInt(accessories.length)]['id'],
        auraStyle: auras[rand.nextInt(auras.length)]['id'],
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎲 Rolled a fresh randomized avatar!'),
        duration: Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveAvatar() async {
    setState(() => _isSaving = true);
    try {
      final user = SupaFlow.client.auth.currentUser;
      if (user != null) {
        await SupaFlow.client.from('profile').update({
          'avatar_config': _config.toMap(),
        }).eq('user_id', user.id);
      }

      widget.onAvatarSaved?.call(_config);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Avatar saved to your Profile!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, _config);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving avatar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0E15),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pocket Mates Avatar Studio',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // Comic Strip Creator Button
          IconButton(
            tooltip: 'Avatar Comic Strip',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_stories, color: Color(0xFFFF6B6B), size: 20),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AvatarComicStripPage(avatarConfig: _config),
                ),
              );
            },
          ),
          // Sticker Pack Generator Button
          IconButton(
            tooltip: 'Stickers Pack',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFC00).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_mosaic, color: Color(0xFFFFFC00), size: 20),
            ),
            onPressed: () => AvatarStickerPackSheet.show(context, _config),
          ),
          IconButton(
            tooltip: 'Randomize',
            icon: const Icon(Icons.casino_outlined, color: Color(0xFFFFFC00), size: 24),
            onPressed: _randomizeAvatar,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFFC00)),
            )
          : Column(
              children: [
                // 1. Art Style Selector
                _buildArtStyleSelector(),

                // 2. Hero Profile Avatar Preview Card
                _buildHeroPreviewCard(),

                // 3. Category Tab Bar
                _buildTabBar(),

                // 4. Tab View Customization Options
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildHeroRolesTab(),
                      _buildFaceAndSkinTab(),
                      _buildHairTab(),
                      _buildExpressionTab(),
                      _buildOutfitsTab(),
                      _buildAccessoriesTab(),
                      _buildAuraTab(),
                    ],
                  ),
                ),

                // 5. Save Button & Sticker Pack Action
                _buildSaveFooter(),
              ],
            ),
    );
  }

  Widget _buildArtStyleSelector() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: VectorAvatarPalette.artStyles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final style = VectorAvatarPalette.artStyles[index];
          final isSelected = _config.artStyle == style['id'];
          final Color accent = style['accent'];

          return GestureDetector(
            onTap: () => setState(() => _config = _config.copyWith(artStyle: style['id'])),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? accent : const Color(0xFF161822),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? accent : Colors.white12,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.35),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  style['name'],
                  style: GoogleFonts.outfit(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroPreviewCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161822),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFFC00).withValues(alpha: 0.08),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Live Avatar Display
          Center(
            child: VectorAvatarWidget(
              config: _config,
              size: 130,
              showAura: true,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        _getArtStyleLabel(_config.artStyle),
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFFC00),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _getRoleDisplayName(),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                // Sticker Quick Link
                GestureDetector(
                  onTap: () => AvatarStickerPackSheet.show(context, _config),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFFFFFC00), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'View 12 Chat Stickers 💬',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFFC00),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleDisplayName() {
    if (_selectedPersonaId != null) {
      final p = VectorAvatarPalette.heroPersonas.firstWhere(
        (e) => e['id'] == _selectedPersonaId,
        orElse: () => {'name': 'Custom Mate'},
      );
      return p['name'];
    }
    final o = VectorAvatarPalette.outfitStyles.firstWhere(
      (e) => e['id'] == _config.outfitStyle,
      orElse: () => {'name': 'Streetwear Mate'},
    );
    return o['name'];
  }

  String _getArtStyleLabel(String id) {
    switch (id) {
      case 'doodle':
        return '🎨 Comic Caricature';
      case 'pixel':
        return '👾 8-Bit Pixel Mate';
      case 'cyberpunk':
        return '⚡ Neon Cyber Matrix';
      default:
        return '✨ Modern 2D Vector';
    }
  }

  Widget _buildTabBar() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF161822),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          color: const Color(0xFFFFFC00),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.white60,
        labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 12),
        tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  // --- TAB 1: Roles (50+ Roles with category pills) ---
  Widget _buildHeroRolesTab() {
    final filteredPersonas = _selectedRoleCategory == 'All'
        ? VectorAvatarPalette.heroPersonas
        : VectorAvatarPalette.heroPersonas
            .where((p) => p['badge'] == _selectedRoleCategory)
            .toList();

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // Category Filter Chips
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _roleCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final cat = _roleCategories[index];
              final isSel = _selectedRoleCategory == cat;

              return GestureDetector(
                onTap: () => setState(() => _selectedRoleCategory = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFFFFFC00) : const Color(0xFF1E202E),
                    borderRadius: BorderRadius.circular(12),
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
        const SizedBox(height: 12),

        // Grid of 50+ Roles
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: filteredPersonas.length,
          itemBuilder: (context, index) {
            final p = filteredPersonas[index];
            final isSelected = _selectedPersonaId == p['id'];

            return GestureDetector(
              onTap: () => _applyPersona(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFFC00).withValues(alpha: 0.18) : const Color(0xFF161822),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFFFC00) : Colors.white12,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      p['name'],
                      style: GoogleFonts.outfit(
                        color: isSelected ? const Color(0xFFFFFC00) : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        p['badge'],
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // --- TAB 2: Face & Skin ---
  Widget _buildFaceAndSkinTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('Skin Tone Palette'),
        _buildColorPalette(
          colors: VectorAvatarPalette.skinTones,
          selectedColor: _config.skinColor,
          onColorSelected: (c) => setState(() {
            _selectedPersonaId = null;
            _config = _config.copyWith(skinColor: c);
          }),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Face Shape (4 Shapes)'),
        Row(
          children: [
            _buildOptionCard(
              title: 'Classic Oval',
              icon: Icons.circle_outlined,
              isSelected: _config.faceShape == 'oval',
              onTap: () => setState(() => _config = _config.copyWith(faceShape: 'oval')),
            ),
            const SizedBox(width: 8),
            _buildOptionCard(
              title: 'Round Soft',
              icon: Icons.lens,
              isSelected: _config.faceShape == 'round',
              onTap: () => setState(() => _config = _config.copyWith(faceShape: 'round')),
            ),
            const SizedBox(width: 8),
            _buildOptionCard(
              title: 'Sharp Anime',
              icon: Icons.change_history,
              isSelected: _config.faceShape == 'sharp',
              onTap: () => setState(() => _config = _config.copyWith(faceShape: 'sharp')),
            ),
            const SizedBox(width: 8),
            _buildOptionCard(
              title: 'Square Jaw',
              icon: Icons.crop_square,
              isSelected: _config.faceShape == 'square',
              onTap: () => setState(() => _config = _config.copyWith(faceShape: 'square')),
            ),
          ],
        ),
      ],
    );
  }

  // --- TAB 3: Hair & Beard ---
  Widget _buildHairTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('Hair Style (14 Styles)'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: VectorAvatarPalette.hairStyles.map((item) {
            final isSelected = _config.hairStyle == item['id'];
            return _buildChipOption(
              label: item['name'],
              icon: item['icon'],
              isSelected: isSelected,
              onTap: () => setState(() {
                _selectedPersonaId = null;
                _config = _config.copyWith(hairStyle: item['id']);
              }),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Hair Color (11 Colors)'),
        _buildColorPalette(
          colors: VectorAvatarPalette.hairColors,
          selectedColor: _config.hairColor,
          onColorSelected: (c) => setState(() {
            _selectedPersonaId = null;
            _config = _config.copyWith(hairColor: c);
          }),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Beard / Facial Hair (6 Styles)'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: VectorAvatarPalette.beardStyles.map((item) {
            final isSelected = _config.beardStyle == item['id'];
            return _buildChipOption(
              label: item['name'],
              isSelected: isSelected,
              onTap: () => setState(() {
                _selectedPersonaId = null;
                _config = _config.copyWith(beardStyle: item['id']);
              }),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- TAB 4: Expressions ---
  Widget _buildExpressionTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('Eye Mood & Look'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: VectorAvatarPalette.eyeStyles.map((item) {
            final isSelected = _config.eyeStyle == item['id'];
            return _buildChipOption(
              label: item['name'],
              isSelected: isSelected,
              onTap: () => setState(() {
                _selectedPersonaId = null;
                _config = _config.copyWith(eyeStyle: item['id']);
              }),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Eye Color'),
        _buildColorPalette(
          colors: VectorAvatarPalette.eyeColors,
          selectedColor: _config.eyeColor,
          onColorSelected: (c) => setState(() {
            _selectedPersonaId = null;
            _config = _config.copyWith(eyeColor: c);
          }),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Smile & Expression (6 Types)'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            {'id': 'smile', 'name': 'Warm Smile 😊'},
            {'id': 'laugh', 'name': 'Happy Laugh 😄'},
            {'id': 'smirk', 'name': 'Cool Smirk 😏'},
            {'id': 'joker_grin', 'name': 'Joker Grin 🃏'},
            {'id': 'chill', 'name': 'Chill Neutral 😐'},
          ].map((item) {
            final isSelected = _config.mouthStyle == item['id'];
            return _buildChipOption(
              label: item['name']!,
              isSelected: isSelected,
              onTap: () => setState(() {
                _selectedPersonaId = null;
                _config = _config.copyWith(mouthStyle: item['id']);
              }),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- TAB 5: Outfits & Roles ---
  Widget _buildOutfitsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('Profession Outfits & Tops (16 Styles)'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: VectorAvatarPalette.outfitStyles.map((item) {
            final isSelected = _config.outfitStyle == item['id'];
            return _buildChipOption(
              label: item['name'],
              isSelected: isSelected,
              onTap: () => setState(() {
                _selectedPersonaId = null;
                _config = _config.copyWith(outfitStyle: item['id']);
              }),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Primary Outfit Color'),
        _buildColorPalette(
          colors: VectorAvatarPalette.outfitColors,
          selectedColor: _config.outfitColor,
          onColorSelected: (c) => setState(() => _config = _config.copyWith(outfitColor: c)),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Accent / Details Color'),
        _buildColorPalette(
          colors: VectorAvatarPalette.outfitColors,
          selectedColor: _config.outfitAccentColor,
          onColorSelected: (c) => setState(() => _config = _config.copyWith(outfitAccentColor: c)),
        ),
      ],
    );
  }

  // --- TAB 6: Accessories ---
  Widget _buildAccessoriesTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('Props & Gear (12 Styles)'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: VectorAvatarPalette.accessoryStyles.map((item) {
            final isSelected = _config.accessory == item['id'];
            return _buildChipOption(
              label: item['name'],
              isSelected: isSelected,
              onTap: () => setState(() {
                _selectedPersonaId = null;
                _config = _config.copyWith(accessory: item['id']);
              }),
            );
          }).toList(),
        ),
        if (_config.accessory != 'none') ...[
          const SizedBox(height: 24),
          _buildSectionHeader('Accessory Color'),
          _buildColorPalette(
            colors: VectorAvatarPalette.outfitColors,
            selectedColor: _config.accessoryColor,
            onColorSelected: (c) => setState(() => _config = _config.copyWith(accessoryColor: c)),
          ),
        ],
      ],
    );
  }

  // --- TAB 7: Aura ---
  Widget _buildAuraTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('Aura Lighting & Action Themes (10 Auras)'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: VectorAvatarPalette.auraStyles.map((item) {
            final isSelected = _config.auraStyle == item['id'];
            final colors = item['colors'] as List<Color>;

            return GestureDetector(
              onTap: () => setState(() => _config = _config.copyWith(auraStyle: item['id'])),
              child: Container(
                width: 150,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colors[0].withValues(alpha: 0.5),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['name'],
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- UI Helpers ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildColorPalette({
    required List<String> colors,
    required String selectedColor,
    required Function(String) onColorSelected,
  }) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final hex = colors[index];
          final color = VectorAvatarConfig.parseHex(hex);
          final isSelected = hex.toLowerCase() == selectedColor.toLowerCase();

          return GestureDetector(
            onTap: () => onColorSelected(hex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFFFFC00) : Colors.white24,
                  width: isSelected ? 3 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFFC00).withValues(alpha: 0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 18,
                      color: ThemeData.estimateBrightnessForColor(color) == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildChipOption({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFFC00) : const Color(0xFF1B1D2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFFC00) : Colors.white12,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: isSelected ? Colors.black : Colors.white70),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFFC00).withValues(alpha: 0.15) : const Color(0xFF1B1D2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFFFFFC00) : Colors.white12,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? const Color(0xFFFFFC00) : Colors.white60, size: 20),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: isSelected ? const Color(0xFFFFFC00) : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF161822),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Sticker Pack Sheet Trigger
            Container(
              height: 48,
              width: 48,
              margin: const EdgeInsets.only(right: 10),
              child: OutlinedButton(
                onPressed: () => AvatarStickerPackSheet.show(context, _config),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  side: const BorderSide(color: Color(0xFFFFFC00), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Icon(Icons.auto_awesome_mosaic, color: Color(0xFFFFFC00), size: 22),
              ),
            ),

            // Save Button
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveAvatar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFC00),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 19, color: Colors.black),
                            const SizedBox(width: 8),
                            Text(
                              'Set as Pocket Mate Avatar',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
