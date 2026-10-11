import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_auth_page.dart';

/// 🧸 Dedicated Kids Account & Profile Creation Onboarding Page
/// 100% separate from Adult Onboarding, filled with high-energy cartoon magic!
class PocketKidsOnboardingPage extends StatefulWidget {
  const PocketKidsOnboardingPage({super.key});

  static const String routeName = 'PocketKidsOnboarding';
  static const String routePath = '/pocket_kids_onboarding';

  static Future<void> launch(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PocketKidsOnboardingPage()),
    );
  }

  @override
  State<PocketKidsOnboardingPage> createState() =>
      _PocketKidsOnboardingPageState();
}

class _PocketKidsOnboardingPageState extends State<PocketKidsOnboardingPage> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();

  int _step = 0;
  String _selectedAgeGroup = '6-8';
  String _selectedAvatar = '🦁';
  String _selectedHouse = 'Rainbow Treehouse';

  static const List<Map<String, String>> _mascots = [
    {'emoji': '🦁', 'name': 'Leo Lion', 'tag': 'Brave'},
    {'emoji': '🐼', 'name': 'Pandy Panda', 'tag': 'Gentle'},
    {'emoji': '🦊', 'name': 'Finny Fox', 'tag': 'Smart'},
    {'emoji': '🦄', 'name': 'Sparkle Unicorn', 'tag': 'Magic'},
    {'emoji': '🐰', 'name': 'Bouncy Bunny', 'tag': 'Swift'},
    {'emoji': '🦖', 'name': 'Dino Rex', 'tag': 'Strong'},
    {'emoji': '🐯', 'name': 'Tigger Cub', 'tag': 'Curious'},
    {'emoji': '🐻', 'name': 'Teddy Bear', 'tag': 'Kind'},
  ];

  static const List<Map<String, String>> _starterHouses = [
    {
      'title': 'Rainbow Treehouse',
      'emoji': '🌳',
      'desc': 'Cozy treetop hideout with slide & swings!'
    },
    {
      'title': 'Candy Cottage',
      'emoji': '🍭',
      'desc': 'Delicious sugary home with chocolate roof!'
    },
    {
      'title': 'Rocket Space Base',
      'emoji': '🚀',
      'desc': 'Futuristic launchpad pointing to the stars!'
    },
  ];

  void _nextStep() {
    HapticFeedback.mediumImpact();
    if (_step == 0 && _nameController.text.trim().isEmpty) {
      _nameController.text = 'Leo';
    }
    if (_step < 3) {
      setState(() => _step++);
      _pageController.animateToPage(
        _step,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishKidsOnboarding();
    }
  }

  void _prevStep() {
    HapticFeedback.lightImpact();
    if (_step > 0) {
      setState(() => _step--);
      _pageController.animateToPage(
        _step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _finishKidsOnboarding() async {
    HapticFeedback.heavyImpact();
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'Little Hero';

    if (mounted) {
      PocketKidsAuthPage.launch(
        context,
        kidName: name,
        ageGroup: _selectedAgeGroup,
        avatar: _selectedAvatar,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0284C7),
      body: Stack(
        children: [
          // Playful Sky Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF38BDF8),
                  Color(0xFF0284C7),
                  Color(0xFF0F172A),
                ],
              ),
            ),
          ),

          // Floating background stars and balloons
          Positioned(
            top: 50,
            left: 20,
            child: Opacity(
              opacity: 0.25,
              child: const Text('☁️', style: TextStyle(fontSize: 80)),
            ),
          ),
          Positioned(
            top: 130,
            right: 30,
            child: Opacity(
              opacity: 0.2,
              child: const Text('🎈', style: TextStyle(fontSize: 50)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Progress & Back Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 28),
                        onPressed: _prevStep,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (_step + 1) / 4.0,
                            minHeight: 10,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFFFD700),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'STEP ${_step + 1}/4',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Page Body
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStepName(),
                      _buildStepAge(),
                      _buildStepMascot(),
                      _buildStepHouse(),
                    ],
                  ),
                ),

                // Bottom Action CTA
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: const Color(0xFF0F172A),
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _step == 3
                                ? 'NEXT: KID LOGIN / SIGNUP 🔐'
                                : 'CONTINUE ➔',
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
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
        ],
      ),
    );
  }

  // Step 1: Kid Name
  Widget _buildStepName() {
    final t = PocketLanguageService.getKidsProfileTranslations(PocketLanguageService.currentLanguage);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const Text('🌟', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text(
            t['nameTitle'] ?? 'What is your name, little hero?',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t['nameSub'] ?? 'We will call you this throughout your 100-day journey!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: const Color(0xFF0F172A),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: t['nameHint'] ?? 'e.g. Leo, Mia, Arjun',
                hintStyle: const TextStyle(color: Colors.black26),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Step 2: Age Group
  Widget _buildStepAge() {
    final ages = [
      {
        'range': '3-5',
        'title': 'Tiny Explorers',
        'desc': 'ABCs, Colors & Nursery Fun',
        'emoji': '🐣',
        'color': const Color(0xFF10B981)
      },
      {
        'range': '6-8',
        'title': 'Word Detectives',
        'desc': 'Phonics, Animals & Words',
        'emoji': '🦁',
        'color': const Color(0xFFF59E0B)
      },
      {
        'range': '9-12',
        'title': 'Language Champions',
        'desc': 'Stories, Sentences & Speaking',
        'emoji': '🚀',
        'color': const Color(0xFF6366F1)
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const Text('🎂', style: TextStyle(fontSize: 54)),
          const SizedBox(height: 12),
          Text(
            PocketLanguageService.getKidsProfileTranslations(PocketLanguageService.currentLanguage)['ageTitle'] ?? 'How old are you?',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            PocketLanguageService.getKidsProfileTranslations(PocketLanguageService.currentLanguage)['ageSub'] ?? 'We customize all games and phonics to match your age!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ...ages.map((a) {
            final isSelected = _selectedAgeGroup == a['range'];
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedAgeGroup = a['range'] as String);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF1E293B).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFFD700)
                        : Colors.white24,
                    width: isSelected ? 3 : 1.5,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(a['emoji'] as String,
                        style: const TextStyle(fontSize: 36)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${a['title']} (${a['range']} Years)',
                            style: GoogleFonts.outfit(
                              color: isSelected
                                  ? const Color(0xFF0F172A)
                                  : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            a['desc'] as String,
                            style: GoogleFonts.inter(
                              color: isSelected
                                  ? Colors.black54
                                  : Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF10B981), size: 26),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Step 3: Mascot Avatar
  Widget _buildStepMascot() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Text(_selectedAvatar, style: const TextStyle(fontSize: 54)),
          const SizedBox(height: 12),
          Text(
            PocketLanguageService.getKidsProfileTranslations(PocketLanguageService.currentLanguage)['avatarTitle'] ?? 'Choose your Mascot Buddy!',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            PocketLanguageService.getKidsProfileTranslations(PocketLanguageService.currentLanguage)['avatarSub'] ?? 'Your buddy will cheer you on as you pop balloons & climb!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _mascots.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final m = _mascots[index];
              final isSel = _selectedAvatar == m['emoji'];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedAvatar = m['emoji']!);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: isSel
                        ? Colors.white
                        : const Color(0xFF1E293B).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSel ? const Color(0xFFFFD700) : Colors.white12,
                      width: isSel ? 3 : 1,
                    ),
                    boxShadow: [
                      if (isSel)
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                          blurRadius: 10,
                        ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(m['emoji']!, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 4),
                      Text(
                        m['name']!.split(' ')[0],
                        style: GoogleFonts.outfit(
                          color: isSel
                              ? const Color(0xFF0F172A)
                              : Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Step 4: Starter Playhouse
  Widget _buildStepHouse() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const Text('🏰', style: TextStyle(fontSize: 54)),
          const SizedBox(height: 12),
          Text(
            'Pick your Starter Playhouse!',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete day levels to evolve your home into a Magic Castle!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ..._starterHouses.map((h) {
            final isSel = _selectedHouse == h['title'];
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedHouse = h['title']!);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSel
                      ? Colors.white
                      : const Color(0xFF1E293B).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSel ? const Color(0xFFFFD700) : Colors.white24,
                    width: isSel ? 3 : 1.5,
                  ),
                  boxShadow: [
                    if (isSel)
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(h['emoji']!, style: const TextStyle(fontSize: 38)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h['title']!,
                            style: GoogleFonts.outfit(
                              color: isSel
                                  ? const Color(0xFF0F172A)
                                  : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            h['desc']!,
                            style: GoogleFonts.inter(
                              color: isSel ? Colors.black54 : Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSel)
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF10B981), size: 26),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
