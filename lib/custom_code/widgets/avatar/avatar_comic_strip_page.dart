import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'vector_avatar_config.dart';
import 'vector_avatar_widget.dart';

/// Interactive 3-Panel Avatar Comic Strip & English Story Creator
class AvatarComicStripPage extends StatefulWidget {
  final VectorAvatarConfig? avatarConfig;

  const AvatarComicStripPage({
    super.key,
    this.avatarConfig,
  });

  @override
  State<AvatarComicStripPage> createState() => _AvatarComicStripPageState();
}

class ComicStoryTemplate {
  final String id;
  final String title;
  final String category;
  final String emoji;
  final List<ComicPanelData> panels;

  const ComicStoryTemplate({
    required this.id,
    required this.title,
    required this.category,
    required this.emoji,
    required this.panels,
  });
}

class ComicPanelData {
  final String sfx; // 'POW!', 'BOOM!', 'AHA!', 'GASP!', 'WHOOSH!'
  final Color sfxColor;
  final String setting;
  final String characterName;
  final String dialogue;
  final String expression; // 'anime', 'mischief', 'sparkle', 'chill', 'wink', 'focused'
  final String mouth; // 'smile', 'laugh', 'smirk', 'joker_grin', 'chill'
  final String caption;

  const ComicPanelData({
    required this.sfx,
    required this.sfxColor,
    required this.setting,
    required this.characterName,
    required this.dialogue,
    required this.expression,
    required this.mouth,
    required this.caption,
  });
}

class _AvatarComicStripPageState extends State<AvatarComicStripPage> {
  late VectorAvatarConfig _userConfig;
  late ComicStoryTemplate _currentStory;
  int _selectedStoryIndex = 0;

  final List<ComicStoryTemplate> _stories = [
    ComicStoryTemplate(
      id: 'coffee_mixup',
      title: 'Coffee in London ☕',
      category: 'Daily Life',
      emoji: '☕',
      panels: [
        ComicPanelData(
          sfx: 'DING!',
          sfxColor: Color(0xFFFF9900),
          setting: 'London Coffee Bar 🇬🇧',
          characterName: 'Barista',
          dialogue: 'Hello mate! How do you like your coffee?',
          expression: 'chill',
          mouth: 'smile',
          caption: 'Panel 1: The Order',
        ),
        ComicPanelData(
          sfx: 'GASP!',
          sfxColor: Color(0xFFE53935),
          setting: 'Counter Confusion 💭',
          characterName: 'You',
          dialogue: 'I like it like my English — bold, strong, and fluent!',
          expression: 'sparkle',
          mouth: 'laugh',
          caption: 'Panel 2: The Punchline',
        ),
        ComicPanelData(
          sfx: 'AHA!',
          sfxColor: Color(0xFF00FF66),
          setting: 'Respect Earned ✨',
          characterName: 'Barista',
          dialogue: 'Brilliant! It\'s on the house, mate! ☕🔥',
          expression: 'mischief',
          mouth: 'joker_grin',
          caption: 'Panel 3: Free Coffee!',
        ),
      ],
    ),
    ComicStoryTemplate(
      id: 'grammar_police',
      title: 'Grammar Police 🚨',
      category: 'Humor',
      emoji: '🚨',
      panels: [
        ComicPanelData(
          sfx: 'HALT!',
          sfxColor: Color(0xFFE53935),
          setting: 'Street Corner 🛑',
          characterName: 'Officer',
          dialogue: 'Stop right there! You said "irregardless"!',
          expression: 'focused',
          mouth: 'chill',
          caption: 'Panel 1: The Violation',
        ),
        ComicPanelData(
          sfx: 'SWEAT!',
          sfxColor: Color(0xFF00D2D3),
          setting: 'Nervous Defense 😅',
          characterName: 'You',
          dialogue: 'I meant "regardless", officer! I swear by Pocket Mates!',
          expression: 'wink',
          mouth: 'smirk',
          caption: 'Panel 2: The Correction',
        ),
        ComicPanelData(
          sfx: 'CASE CLOSED!',
          sfxColor: Color(0xFFFFD700),
          setting: 'Salute & Freedom 🎖️',
          characterName: 'Officer',
          dialogue: 'Keep up your 21-day streak and you\'re free to go! 👍',
          expression: 'anime',
          mouth: 'laugh',
          caption: 'Panel 3: Saved by Streaks',
        ),
      ],
    ),
    ComicStoryTemplate(
      id: 'secret_agent',
      title: 'Secret Agent Code 🕵️',
      category: 'Action',
      emoji: '🕵️',
      panels: [
        ComicPanelData(
          sfx: 'SHHH!',
          sfxColor: Color(0xFF6C5CE7),
          setting: 'Dark Alley 🕶️',
          characterName: 'Agent 007',
          dialogue: 'The eagle has landed. What is the passphrase?',
          expression: 'focused',
          mouth: 'chill',
          caption: 'Panel 1: The Drop',
        ),
        ComicPanelData(
          sfx: 'WHISPER!',
          sfxColor: Color(0xFF00F2FE),
          setting: 'Secret Exchange 💬',
          characterName: 'You',
          dialogue: '"To bite the bullet and break the ice!"',
          expression: 'mischief',
          mouth: 'smirk',
          caption: 'Panel 2: The Idiom',
        ),
        ComicPanelData(
          sfx: 'BOOM!',
          sfxColor: Color(0xFFFF007F),
          setting: 'Mission Cleared 🚀',
          characterName: 'Agent 007',
          dialogue: 'Identity verified. You are truly fluent, Agent! ⚡',
          expression: 'anime',
          mouth: 'smile',
          caption: 'Panel 3: Level Up',
        ),
      ],
    ),
    ComicStoryTemplate(
      id: 'alien_interview',
      title: 'Alien Job Interview 👽',
      category: 'Sci-Fi',
      emoji: '👽',
      panels: [
        ComicPanelData(
          sfx: 'ZAP!',
          sfxColor: Color(0xFF00FF66),
          setting: 'Spaceship Boardroom 🛸',
          characterName: 'Alien Boss',
          dialogue: 'Why should we hire a human for Mars operations?',
          expression: 'focused',
          mouth: 'chill',
          caption: 'Panel 1: The Question',
        ),
        ComicPanelData(
          sfx: 'BEAM!',
          sfxColor: Color(0xFFFFFC00),
          setting: 'Confident Pitch 🎤',
          characterName: 'You',
          dialogue: 'Because I can negotiate peace in 5 English accents!',
          expression: 'sparkle',
          mouth: 'laugh',
          caption: 'Panel 2: The Superpower',
        ),
        ComicPanelData(
          sfx: 'HIRED!',
          sfxColor: Color(0xFFFF512F),
          setting: 'Contract Signed 📝',
          characterName: 'Alien Boss',
          dialogue: 'You start on Monday at 300,000 cosmic credits! 🌌',
          expression: 'mischief',
          mouth: 'joker_grin',
          caption: 'Panel 3: Galactic Success',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _userConfig = widget.avatarConfig ?? const VectorAvatarConfig();
    _currentStory = _stories[0];
    _loadProfileAvatar();
  }

  Future<void> _loadProfileAvatar() async {
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
              _userConfig = VectorAvatarConfig.fromMap(data);
            });
          }
        }
      }
    } catch (_) {}
  }

  void _shareComic() {
    final text = '📰 Check out my 3-Panel Avatar Comic on Pocket Mates!\n\n'
        '🎬 Story: ${_currentStory.title}\n'
        '1️⃣ ${_currentStory.panels[0].dialogue}\n'
        '2️⃣ ${_currentStory.panels[1].dialogue}\n'
        '3️⃣ ${_currentStory.panels[2].dialogue}\n\n'
        'Join me on Pocket Mates: https://pocketmates.app';

    SharePlus.instance.share(ShareParams(text: text));
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
        title: Row(
          children: [
            const Icon(Icons.auto_stories, color: Color(0xFFFFFC00), size: 22),
            const SizedBox(width: 8),
            Text(
              'Avatar Comic Strip 📰',
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
            tooltip: 'Share Comic',
            icon: const Icon(Icons.share, color: Color(0xFFFFFC00), size: 22),
            onPressed: _shareComic,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // Story Scenario Chips
          _buildStorySelector(),

          // 3-Panel Comic Strip View
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildComicPanel(0, _currentStory.panels[0]),
                const SizedBox(height: 14),
                _buildComicPanel(1, _currentStory.panels[1]),
                const SizedBox(height: 14),
                _buildComicPanel(2, _currentStory.panels[2]),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Footer Action
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildStorySelector() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final s = _stories[index];
          final isSelected = _selectedStoryIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedStoryIndex = index;
                _currentStory = _stories[index];
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFFC00) : const Color(0xFF161822),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFFFC00) : Colors.white12,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  s.title,
                  style: GoogleFonts.outfit(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildComicPanel(int index, ComicPanelData panel) {
    // Modify avatar expression specifically for this comic panel
    final panelAvatarConfig = _userConfig.copyWith(
      eyeStyle: panel.expression,
      mouthStyle: panel.mouth,
      artStyle: 'doodle', // Comic Doodle mode for the Webtoon feel
      auraStyle: 'comic_boom',
    );

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161822),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 2),
        boxShadow: [
          BoxShadow(
            color: panel.sfxColor.withValues(alpha: 0.12),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              border: const Border(bottom: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  panel.caption,
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  panel.setting,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFFC00),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar with Sound Effect Badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    VectorAvatarWidget(
                      config: panelAvatarConfig,
                      size: 95,
                      showAura: true,
                    ),

                    // Comic SFX Starburst Badge
                    Positioned(
                      top: -6,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: panel.sfxColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: panel.sfxColor.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          panel.sfx,
                          style: GoogleFonts.bungee(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 14),

                // Comic Speech Bubble
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                        bottomLeft: Radius.circular(4),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 10,
                          offset: Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          panel.characterName,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFE53935),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '"${panel.dialogue}"',
                          style: GoogleFonts.comicNeue(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                      ],
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

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF161822),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _shareComic,
            icon: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
            label: Text(
              'Share Comic Strip to Mates & WhatsApp',
              style: GoogleFonts.outfit(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFFC00),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
            ),
          ),
        ),
      ),
    );
  }
}
