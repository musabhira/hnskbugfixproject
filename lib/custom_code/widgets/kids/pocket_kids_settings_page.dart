import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_certificate_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/welcome_onboarding_page.dart';

/// ⚙️ Pocket Kids Settings & Parental Hub
///
/// Features:
/// 1. Mini-Profile: Kid Mascot avatar selection, display name editor, House Tier & Score summary.
/// 2. Certificate Access: Direct link to Golden 100-Day Summit Certificate.
/// 3. Audio & Speech: TTS speed slider, Sound FX, instant voice test.
/// 4. Parental Gate: Math challenge to safely switch back to adult mode.
/// 5. Kids Safety Commitment: Explains 100% isolation (No marketplace, no vibes, no adult calls).
/// 6. Gated Sign Out: Prevents accidental logouts by toddlers.
class PocketKidsSettingsPage extends StatefulWidget {
  const PocketKidsSettingsPage({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PocketKidsSettingsPage()),
    );
  }

  @override
  State<PocketKidsSettingsPage> createState() => _PocketKidsSettingsPageState();
}

class _PocketKidsSettingsPageState extends State<PocketKidsSettingsPage> {
  final FlutterTts _tts = FlutterTts();
  late TextEditingController _nameController;

  double _speechRate = 0.45;
  bool _soundFxEnabled = true;
  bool _autoPronounce = true;
  String _selectedAvatar = PocketKidsService.kidAvatar;

  final List<String> _mascotOptions = [
    '🦁', '🦄', '🚀', '🐼', '🐯', '🐰', '🦊', '🐶', '🐱', '🐻', '🦖', '🌟'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: PocketKidsService.kidName);
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.15); // cheerful kid pitch
      await _tts.setSpeechRate(_speechRate);
    } catch (_) {}
  }

  Future<void> _speakTest() async {
    HapticFeedback.lightImpact();
    try {
      await _tts.setSpeechRate(_speechRate);
      await _tts.speak('Hello ${PocketKidsService.kidName}! Pocket Mates Kids English is super fun!');
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tts.stop();
    super.dispose();
  }

  void _showParentalGateSwitchMode(BuildContext context) {
    final rand = math.Random();
    final a = rand.nextInt(6) + 4; // 4 to 9
    final b = rand.nextInt(5) + 3; // 3 to 7
    final correctAnswer = a + b;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
          ),
          title: Row(
            children: [
              const Text('🔒 ', style: TextStyle(fontSize: 22)),
              Text(
                PocketLanguageService.getParentZoneTitle(PocketLanguageService.currentLanguage),
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To switch to adult account, solve this math challenge:',
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
              ),
              const SizedBox(height: 14),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF38BDF8), width: 1),
                  ),
                  child: Text(
                    '$a + $b = ?',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF38BDF8),
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Enter answer',
                  hintStyle: GoogleFonts.inter(color: Colors.white30),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('CANCEL', style: GoogleFonts.inter(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                if (int.tryParse(controller.text.trim()) == correctAnswer) {
                  Navigator.pop(ctx);
                  await PocketKidsService.activateAdultAccount();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const WelcomeOnboardingPage()),
                      (route) => false,
                    );
                  }
                } else {
                  HapticFeedback.heavyImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Incorrect answer! Only parents can exit Kids Mode.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: Text('SWITCH TO ADULT', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showParentalGateLogout(BuildContext context) {
    final rand = math.Random();
    final a = rand.nextInt(7) + 5;
    final b = rand.nextInt(6) + 4;
    final correctAnswer = a + b;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
          ),
          title: Row(
            children: [
              const Text('⚠️ ', style: TextStyle(fontSize: 22)),
              Text(
                'Parent Gate: Sign Out',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To sign out of Poket Mates, a parent must solve:',
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
              ),
              const SizedBox(height: 14),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEF4444), width: 1),
                  ),
                  child: Text(
                    '$a + $b = ?',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFEF4444),
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Enter answer',
                  hintStyle: GoogleFonts.inter(color: Colors.white30),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('CANCEL', style: GoogleFonts.inter(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                if (int.tryParse(controller.text.trim()) == correctAnswer) {
                  Navigator.pop(ctx);
                  try {
                    await SupaFlow.client.auth.signOut().timeout(const Duration(seconds: 2));
                  } catch (_) {}
                  if (context.mounted) {
                    context.go('/authPage');
                  }
                } else {
                  HapticFeedback.heavyImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Incorrect answer! Only parents can sign out.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: Text('LOG OUT', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _saveKidProfile() {
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty) {
      PocketKidsService.saveKidProfile(
        name: newName,
        avatar: _selectedAvatar,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🌟 Profile updated! Awesome job $newName!',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlockedDay = PocketKidsService.currentUnlockedDay;
    final currentHouse = PocketKidsService.currentHouse;
    final pocketScore = PocketKidsService.pocketScore;
    final kidStars = PocketKidsService.kidStars;
    final isCertUnlocked = PocketKidsService.isCertificateUnlocked;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Row(
          children: [
            const Text('⚙️ ', style: TextStyle(fontSize: 20)),
            Text(
              'Kids Hub & Settings',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. MINI-PROFILE HERO CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    currentHouse.themeColor.withValues(alpha: 0.9),
                    const Color(0xFF1E293B),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: currentHouse.themeColor.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar circle
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(_selectedAvatar, style: const TextStyle(fontSize: 38)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              PocketKidsService.kidName,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(currentHouse.emoji, style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${currentHouse.title} (Tier ${currentHouse.tier})',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
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
                  const SizedBox(height: 18),
                  // Stats row: Day, Score, Stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat('Day', '$unlockedDay/100', '🏔️'),
                      _buildMiniStat('Score', '$pocketScore', '🎯'),
                      _buildMiniStat('Stars', '$kidStars', '⭐'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 2. 100-DAY CERTIFICATE CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
              ),
              child: Row(
                children: [
                  const Text('👑', style: TextStyle(fontSize: 36)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '100-Day Excellence Certificate',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF78350F),
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          isCertUnlocked
                              ? 'Unlocked! Ready to view & download.'
                              : 'Complete Day 100 to earn official certificate.',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF92400E),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onPressed: () {
                      PocketKidsCertificatePage.open(context);
                    },
                    child: Text(
                      isCertUnlocked ? 'VIEW 🏅' : 'PREVIEW',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // 3. EDIT CHARACTER & MASCOT
            _buildSectionHeader('🎨 Kid Character & Mascot', 'Pick your favorite buddy'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pick your avatar:',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _mascotOptions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (ctx, i) {
                        final emo = _mascotOptions[i];
                        final isSel = _selectedAvatar == emo;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedAvatar = emo);
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFF38BDF8) : const Color(0xFF334155),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSel ? Colors.white : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(emo, style: const TextStyle(fontSize: 24)),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kid Display Name:',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF38BDF8),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onPressed: _saveKidProfile,
                        child: Text('SAVE', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // 4. AUDIO & TTS SPEECH SETTINGS
            _buildSectionHeader('🔊 Speech & Audio Learning', 'Spoken English settings'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kids Voice Speed (${(_speechRate * 100).toInt()}%)',
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.volume_up_rounded, size: 16),
                        label: Text('TEST', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _speakTest,
                      ),
                    ],
                  ),
                  Slider(
                    value: _speechRate,
                    min: 0.25,
                    max: 0.70,
                    divisions: 9,
                    activeColor: const Color(0xFF38BDF8),
                    inactiveColor: const Color(0xFF334155),
                    onChanged: (val) {
                      setState(() => _speechRate = val);
                      _tts.setSpeechRate(val);
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Auto-pronounce new words',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                    ),
                    subtitle: Text(
                      'Hear correct Spoken English automatically',
                      style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                    ),
                    value: _autoPronounce,
                    activeThumbColor: const Color(0xFF38BDF8),
                    onChanged: (v) => setState(() => _autoPronounce = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Game Sound Effects',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                    ),
                    subtitle: Text(
                      'Celebratory chimes and cartoon sounds',
                      style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                    ),
                    value: _soundFxEnabled,
                    activeThumbColor: const Color(0xFF38BDF8),
                    onChanged: (v) => setState(() => _soundFxEnabled = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // 5. KIDS SAFE ZONE GUARANTEE
            _buildSectionHeader('🛡️ Kids Safe Zone Guarantee', '100% child-safe environment'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF064E3B).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF10B981), width: 1.2),
              ),
              child: Column(
                children: [
                  _buildSafetyBullet('🚫 No Adult Features', 'No marketplace, no vibes, and no telephone calls.'),
                  const SizedBox(height: 10),
                  _buildSafetyBullet('🤖 90 Verified AI Robots & Mates', 'Kids only meet friendly AI buddies and approved peer kids.'),
                  const SizedBox(height: 10),
                  _buildSafetyBullet('🔒 Parental Gate Protection', 'Math problem barrier prevents kids from leaving Kids Mode.'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 6. ACTION BUTTONS: SWITCH TO ADULT & LOGOUT
            ElevatedButton.icon(
              icon: const Icon(Icons.swap_horiz_rounded, size: 20),
              label: Text(
                'EXIT TO PARENT / ADULT MODE 🔒',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 4,
              ),
              onPressed: () => _showParentalGateSwitchMode(context),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              icon: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFEF4444)),
              label: Text(
                'PARENT SIGN OUT',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFEF4444),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: () => _showParentalGateLogout(context),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white60,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyBullet(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
