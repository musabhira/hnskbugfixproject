import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'avatar_network_service.dart';

class AvatarNetworkExplorerPage extends StatefulWidget {
  final Function(String avatarUrl)? onAvatarSelected;

  const AvatarNetworkExplorerPage({
    super.key,
    this.onAvatarSelected,
  });

  @override
  State<AvatarNetworkExplorerPage> createState() => _AvatarNetworkExplorerPageState();
}

class _AvatarNetworkExplorerPageState extends State<AvatarNetworkExplorerPage> {
  final TextEditingController _searchController = TextEditingController(text: 'PocketMate');
  String _selectedCategory = 'All';
  String _currentSeed = 'PocketMate';
  bool _isSaving = false;

  final List<String> _categories = [
    'All',
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _randomizeSeed() {
    final randWords = [
      'CyberKnight', 'SolarFlare', 'ShadowFox', 'NeonDragon', 'PixelSamurai',
      'QuantumAI', 'StarlightMage', 'AstroViper', 'TokyoNeko', 'ChibiHero',
      'VortexPilot', 'GoldenMonarch', 'ArcadeLegend', 'CosmicRanger', 'MythicBeast'
    ];
    randWords.shuffle();
    final newSeed = '${randWords.first}_${DateTime.now().millisecondsSinceEpoch % 999}';
    setState(() {
      _currentSeed = newSeed;
      _searchController.text = newSeed;
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _selectAvatar(String avatarUrl, String styleName) async {
    setState(() => _isSaving = true);
    try {
      final user = SupaFlow.client.auth.currentUser;
      if (user != null) {
        // Save as profile photo URL and avatar config
        await SupaFlow.client.from('profile').update({
          'profile_image_url': avatarUrl,
          'avatar_config': {
            'artStyle': 'network',
            'species': styleName.toLowerCase(),
            'mintId': '#MATE-${DateTime.now().millisecondsSinceEpoch % 100000}',
            'dnaHash': '0xNET-${DateTime.now().millisecondsSinceEpoch % 1000000}',
            'rarityTier': 'Original 1-of-1',
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
                    style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold),
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
            content: Row(
              children: [
                Expanded(
                  child: Text(
                    'Failed to update avatar: $e',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showAvatarPreviewModal(AvatarNetworkStyle style, String url) {
    showDialog(
      context: context,
      builder: (context) {
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
              border: Border.all(color: style.accentColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: style.accentColor.withValues(alpha: 0.35),
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
                        Text(style.icon, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Text(
                          style.name,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
                const SizedBox(height: 14),

                // Avatar Image Large
                Center(
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF14151F),
                      border: Border.all(color: style.accentColor, width: 2.5),
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: url,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(color: Color(0xFFFFFC00)),
                        ),
                        errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white30),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Seed Details
                Text(
                  'Seed: "$_currentSeed"',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFFFFC00),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  style.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 18),

                // Set As Avatar Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: style.accentColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _isSaving
                        ? null
                        : () {
                            Navigator.pop(context);
                            _selectAvatar(url, style.name);
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
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredStyles = _selectedCategory == 'All'
        ? AvatarNetworkService.catalog
        : AvatarNetworkService.catalog
            .where((s) => s.category == _selectedCategory)
            .toList();

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
              'Avatar Network (Millions+)',
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF161822),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1017),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFFFFFC00), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Type any name, character, or topic...',
                              hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (val) {
                              if (val.trim().isNotEmpty) {
                                setState(() => _currentSeed = val.trim());
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward, color: Color(0xFFFFFC00), size: 18),
                          onPressed: () {
                            if (_searchController.text.trim().isNotEmpty) {
                              setState(() => _currentSeed = _searchController.text.trim());
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Category Filter Pills
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSel = _selectedCategory == cat;

                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFFFFFC00) : const Color(0xFF1E202E),
                      borderRadius: BorderRadius.circular(12),
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

          // 3. Grid of Live Generated Avatars
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(14),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: filteredStyles.length,
              itemBuilder: (context, index) {
                final style = filteredStyles[index];
                final avatarUrl = AvatarNetworkService.buildAvatarUrl(
                  styleId: style.id,
                  seed: _currentSeed,
                  size: 240,
                );

                return GestureDetector(
                  onTap: () => _showAvatarPreviewModal(style, avatarUrl),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF161822),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: style.accentColor.withValues(alpha: 0.3), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: style.accentColor.withValues(alpha: 0.08),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Engine Tag
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: style.accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            style.category.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: style.accentColor,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Avatar Image
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF0F1017),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: avatarUrl,
                                placeholder: (_, __) => const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Color(0xFFFFFC00), strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white24),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Title & Icon
                        Text(
                          '${style.icon} ${style.name}',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
