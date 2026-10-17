import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_certificate_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_parental_pattern_lock.dart';
import 'package:pocket_mates_app/pages/home_page/home_page_widget.dart';

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

  Future<void> _showParentalGateSwitchMode(BuildContext context) async {
    HapticFeedback.lightImpact();
    final unlocked = await PocketParentalPatternLock.verifyOrSetup(
      context,
      title: 'Parent Verification 🔒',
      subtitle: 'Draw pattern lock to switch to adult account',
    );

    if (unlocked) {
      await PocketKidsService.activateAdultAccount();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePageWidget()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _showParentalGateLogout(BuildContext context) async {
    HapticFeedback.lightImpact();
    final unlocked = await PocketParentalPatternLock.verifyOrSetup(
      context,
      title: 'Parent Sign Out Gate 🔒',
      subtitle: 'Draw pattern lock to confirm sign out',
    );

    if (unlocked) {
      try {
        await SupaFlow.client.auth.signOut().timeout(const Duration(seconds: 2));
      } catch (_) {}
      if (context.mounted) {
        context.go('/authPage');
      }
    }
  }

  void _showLanguagePickerModal(BuildContext context) {
    HapticFeedback.selectionClick();
    final languages = [
      {'name': 'English', 'native': 'English', 'flag': '🇬🇧'},
      {'name': 'Malayalam', 'native': 'മലയാളം', 'flag': '🇮🇳'},
      {'name': 'Hindi', 'native': 'हिंदी', 'flag': '🇮🇳'},
      {'name': 'Tamil', 'native': 'தமிழ்', 'flag': '🇮🇳'},
      {'name': 'Telugu', 'native': 'తెలుగు', 'flag': '🇮🇳'},
      {'name': 'Kannada', 'native': 'ಕನ್ನಡ', 'flag': '🇮🇳'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🌐 ', style: TextStyle(fontSize: 22)),
                  Text(
                    'Select Native Language',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Hints, explanations and guidance will be presented in your chosen language.',
                style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 16),
              ...languages.map((lang) {
                final isSelected = PocketLanguageService.currentLanguage == lang['name'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0284C7).withValues(alpha: 0.3) : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF38BDF8) : Colors.white12,
                      width: 1.5,
                    ),
                  ),
                  child: ListTile(
                    leading: Text(lang['flag']!, style: const TextStyle(fontSize: 22)),
                    title: Text(
                      '${lang['name']} (${lang['native']})',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: Color(0xFF38BDF8))
                        : null,
                    onTap: () async {
                      await PocketLanguageService.setNativeLanguage(lang['name']!);
                      if (ctx.mounted) Navigator.pop(ctx);
                      setState(() {});
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdminLionDesk(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtl) => FutureBuilder<List<Map<String, dynamic>>>(
          future: PocketKidsService.getAdminLionReports(),
          builder: (context, snapshot) {
            final reports = snapshot.data ?? [];
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🦁 ', style: TextStyle(fontSize: 26)),
                      Text(
                        'Admin Lion Desk: Student Inquiries',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Direct inquiries and forest reports submitted to King Lion',
                    style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: reports.isEmpty
                        ? Center(
                            child: Text(
                              'No pending student Lion reports.',
                              style: GoogleFonts.inter(color: Colors.white54),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollCtl,
                            itemCount: reports.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              final rep = reports[i];
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(rep['student_avatar'] ?? '🦁', style: const TextStyle(fontSize: 20)),
                                        const SizedBox(width: 8),
                                        Text(
                                          rep['student_name'] ?? 'Student',
                                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                        const Spacer(),
                                        Text(
                                          rep['status'] ?? 'pending',
                                          style: TextStyle(
                                            color: rep['status'] == 'resolved' ? Colors.green : Colors.amber,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      rep['subject'] ?? '',
                                      style: GoogleFonts.outfit(color: const Color(0xFF38BDF8), fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      rep['description'] ?? '',
                                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                                    ),
                                    if (rep['admin_reply'] != null) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black38,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '🦁 King Reply: ${rep['admin_reply']}',
                                          style: GoogleFonts.inter(color: const Color(0xFFFFD700), fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
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
              'Student Hub Settings',
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

            const SizedBox(height: 18),

            // 👑 VIP ADVENTURE PASS CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: PocketKidsService.isKidPremium
                      ? const [Color(0xFF312E81), Color(0xFF1E1B4B)]
                      : const [Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: PocketKidsService.isKidPremium ? const Color(0xFFFFD700) : const Color(0xFF6366F1),
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (PocketKidsService.isKidPremium ? const Color(0xFFFFD700) : const Color(0xFF6366F1))
                        .withValues(alpha: 0.15),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        PocketKidsService.isKidPremium ? '👑' : '⚡',
                        style: const TextStyle(fontSize: 26),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VIP Adventure Pass',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              PocketKidsService.isKidPremium
                                  ? 'Active • All 100 Days Instant Unlock 🚀'
                                  : 'Free Explorer • 12:00 AM Midnight Lock ⏳',
                              style: GoogleFonts.inter(
                                color: PocketKidsService.isKidPremium
                                    ? const Color(0xFFFDE047)
                                    : const Color(0xFF94A3B8),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: PocketKidsService.isKidPremium
                              ? const Color(0xFF10B981).withValues(alpha: 0.25)
                              : const Color(0xFF6366F1).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: PocketKidsService.isKidPremium
                                ? const Color(0xFF10B981)
                                : const Color(0xFF818CF8),
                          ),
                        ),
                        child: Text(
                          PocketKidsService.isKidPremium ? 'VIP' : 'FREE',
                          style: GoogleFonts.outfit(
                            color: PocketKidsService.isKidPremium
                                ? const Color(0xFF34D399)
                                : const Color(0xFFA5B4FC),
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    PocketKidsService.isKidPremium
                        ? 'Your child has unlimited instant access to all 100 Spoken English levels, 10 non-repeating game formats, and the Day 100 King Lion Summit Boss Battle without any cooldown wait times.'
                        : 'Free users unlock one new level per day at 12:00 AM midnight. Upgrade to VIP Adventure Pass to eliminate the 12:00 AM wait timer and unlock levels at your child\'s own pace.',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFCBD5E1),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(
                            PocketKidsService.isKidPremium ? Icons.verified_rounded : Icons.bolt_rounded,
                            size: 16,
                          ),
                          label: Text(
                            PocketKidsService.isKidPremium
                                ? 'VIP PASS ACTIVE'
                                : 'ACTIVATE VIP PASS (₹199)',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PocketKidsService.isKidPremium
                                ? const Color(0xFF10B981)
                                : const Color(0xFFFFD700),
                            foregroundColor: PocketKidsService.isKidPremium
                                ? Colors.white
                                : const Color(0xFF78350F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            elevation: 3,
                          ),
                          onPressed: () async {
                            HapticFeedback.heavyImpact();
                            final newPrem = !PocketKidsService.isKidPremium;
                            await PocketKidsService.setKidPremium(newPrem);
                            if (context.mounted) {
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    newPrem
                                        ? '👑 VIP Adventure Pass Activated! All 100 levels unlocked instantly!'
                                        : 'Switched to Free Explorer mode (12:00 AM midnight timer active).',
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: newPrem ? const Color(0xFF10B981) : const Color(0xFF6366F1),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      if (PocketKidsService.isKidPremium) ...[
                        const SizedBox(width: 8),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF64748B)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                          ),
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            await PocketKidsService.setKidPremium(false);
                            if (context.mounted) {
                              setState(() {});
                            }
                          },
                          child: Text(
                            'TEST FREE',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ],
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

            const SizedBox(height: 22),

            // 🌐 NATIVE LANGUAGE PREFERENCE (Audio Directive 7)
            _buildSectionHeader('🌐 Native Language Preference', 'Select your regional mother tongue'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        PocketLanguageService.currentLanguage,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Dynamic native explanations & hints',
                        style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => _showLanguagePickerModal(context),
                    child: Text('CHANGE', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),

            if (PocketKidsService.isAdminAccount) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.shield_rounded, color: Colors.amber),
                label: Text('🦁 ADMIN LION DESK (Student Inquiries)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF78350F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _showAdminLionDesk(context),
              ),
            ],

            const SizedBox(height: 24),

            // 6. ACTION BUTTONS: SWITCH TO ADULT & LOGOUT
            // Audio Directive 1: Pure Kid/Student accounts CANNOT exit to Adult mode! Only parents who switched can exit.
            if (PocketKidsService.canExitToAdultAccount) ...[
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
            ],

            OutlinedButton.icon(
              icon: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFEF4444)),
              label: Text(
                PocketKidsService.isPureKidAccount ? 'STUDENT SIGN OUT' : 'PARENT SIGN OUT',
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
