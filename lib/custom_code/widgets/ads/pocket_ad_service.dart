import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Architecture for Google AdMob and Sponsor Monetization with Ad-Free VIP Bypass
class PocketAdService {
  static final PocketAdService _instance = PocketAdService._internal();
  factory PocketAdService() => _instance;
  PocketAdService._internal();

  /// Check whether the current user is subscribed (Starter, Pro, or Business)
  /// Subscribed users enjoy a 100% Ad-Free Experience
  Future<bool> isUserSubscribed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plan = prefs.getString('handskill_plan') ?? 'free';
      return plan != 'free';
    } catch (_) {
      return false;
    }
  }

  /// Calculates user account age in days to provide a pleasant, non-intrusive onboarding cushion.
  /// For the first 3 days, ads are heavily reduced or muted so new users fall in love with the app first.
  Future<bool> isWithinNewUserCushionPeriod() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final firstLaunch = prefs.getInt('pocket_first_launch_ts');
      final now = DateTime.now().millisecondsSinceEpoch;
      if (firstLaunch == null) {
        await prefs.setInt('pocket_first_launch_ts', now);
        return true; // Day 1
      }
      final daysSinceFirstLaunch = (now - firstLaunch) / (1000 * 60 * 60 * 24);
      return daysSinceFirstLaunch < 2.5; // First 2-3 days grace period
    } catch (_) {
      return false;
    }
  }

  /// Shows a rewarded / interstitial video ad dialog (e.g. before an anonymous match or bonus practice)
  /// If the user is subscribed, or in the first 2-3 days onboarding grace period, it completes smoothly without interruption
  Future<bool> showVideoAd({
    required BuildContext context,
    required String placementTitle,
    VoidCallback? onRewardEarned,
  }) async {
    final isSubscribed = await isUserSubscribed();
    if (isSubscribed) {
      if (onRewardEarned != null) onRewardEarned();
      return true;
    }

    // New user grace period: do not annoy new users in their first 2-3 days
    final isNewUserGrace = await isWithinNewUserCushionPeriod();
    if (isNewUserGrace) {
      // 80% of the time, let new users practice freely without video ad popups
      final allowFreeBypass = (DateTime.now().millisecond % 5) != 0;
      if (allowFreeBypass) {
        if (onRewardEarned != null) onRewardEarned();
        return true;
      }
    }

    if (!context.mounted) return false;

    // Show sleek, non-intrusive video ad card dialog
    final bool? watched = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _VideoAdModal(
        placementTitle: placementTitle,
        onRewardEarned: onRewardEarned,
      ),
    );

    return watched ?? false;
  }
}

/// A non-intrusive, native-styled in-feed Ad Widget tailored to match Pocket Mates chat theme
class PocketNativeAdWidget extends StatefulWidget {
  final String category;
  final EdgeInsetsGeometry margin;

  const PocketNativeAdWidget({
    super.key,
    this.category = 'English & Career',
    this.margin = const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  });

  @override
  State<PocketNativeAdWidget> createState() => _PocketNativeAdWidgetState();
}

class _PocketNativeAdWidgetState extends State<PocketNativeAdWidget> {
  bool _isSubscribed = false;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _curatedSponsors = [
    {
      'headline': 'Oxford Spoken English Masterclass',
      'body': 'Practice with certified British mentors. Get 50% off this week!',
      'advertiser': 'Sponsored • Oxford English',
      'cta': 'Learn More',
      'icon': Icons.school_rounded,
      'color': Color(0xFF38BDF8),
    },
    {
      'headline': 'Global Remote Tech Jobs 2026',
      'body': 'High-paying jobs for fluent English speakers worldwide.',
      'advertiser': 'Sponsored • RemoteCareers',
      'cta': 'Apply Now',
      'icon': Icons.work_outline_rounded,
      'color': Color(0xFF10B981),
    },
    {
      'headline': 'IELTS & Duolingo Exam Prep Sprint',
      'body': 'Score Band 8+ in speaking and writing with mock AI drills.',
      'advertiser': 'Sponsored • ExamSprint',
      'cta': 'Start Free',
      'icon': Icons.menu_book_rounded,
      'color': Color(0xFFFFD700),
    },
  ];

  late final Map<String, dynamic> _adData;

  @override
  void initState() {
    super.initState();
    _adData = (_curatedSponsors..shuffle()).first;
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    final sub = await PocketAdService().isUserSubscribed();
    if (mounted) {
      setState(() {
        _isSubscribed = sub;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _isSubscribed) {
      return const SizedBox
          .shrink(); // Hide ad completely for paid VIP subscribers
    }

    final color = _adData['color'] as Color;

    return Container(
      margin: widget.margin,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF131726),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_adData['icon'] as IconData, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'AD',
                        style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _adData['advertiser'] as String,
                        style: GoogleFonts.inter(
                            color: Colors.white54, fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _adData['headline'] as String,
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5),
                ),
                const SizedBox(height: 2),
                Text(
                  _adData['body'] as String,
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening sponsor link...',
                      style: GoogleFonts.outfit()),
                  duration: const Duration(milliseconds: 700),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(60, 30),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              _adData['cta'] as String,
              style:
                  GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simulated video interstitial / rewarded ad modal
class _VideoAdModal extends StatefulWidget {
  final String placementTitle;
  final VoidCallback? onRewardEarned;

  const _VideoAdModal({required this.placementTitle, this.onRewardEarned});

  @override
  State<_VideoAdModal> createState() => _VideoAdModalState();
}

class _VideoAdModalState extends State<_VideoAdModal> {
  int _secondsRemaining = 5;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _secondsRemaining--;
      });
      return _secondsRemaining > 0;
    }).then((_) {
      if (mounted) {
        if (widget.onRewardEarned != null) widget.onRewardEarned!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFC00),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'AD',
                    style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 9),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.placementTitle,
                    style:
                        GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                  ),
                ),
                Text(
                  _secondsRemaining > 0 ? '${_secondsRemaining}s' : 'Ready',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFFC00),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Video Preview Canvas
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_circle_fill_rounded,
                      color: Color(0xFFFFFC00), size: 48),
                  const SizedBox(height: 10),
                  Text(
                    'Cambridge English Certification Partner',
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Accelerate your career with accredited certifications',
                    style:
                        GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _secondsRemaining > 0
                    ? null
                    : () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFC00),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _secondsRemaining > 0
                      ? 'Ad ends in ${_secondsRemaining}s'
                      : 'Continue to Chat ✓',
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A full-screen, Instagram-styled Story Ad for Vibes / Status Viewer
class PocketVibesStoryAdWidget extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const PocketVibesStoryAdWidget({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<PocketVibesStoryAdWidget> createState() => _PocketVibesStoryAdWidgetState();
}

class _PocketVibesStoryAdWidgetState extends State<PocketVibesStoryAdWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  final List<Map<String, dynamic>> _vibeSponsors = [
    {
      'brand': 'Oxford English Masterclass',
      'tagline': 'Certified Spoken Fluency',
      'headline': 'Speak English Confidently in 30 Days',
      'cta': 'Enroll Free',
      'gradient': [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0284C7)],
      'icon': Icons.school_rounded,
      'accent': Color(0xFF38BDF8),
    },
    {
      'brand': 'Global Remote Careers',
      'tagline': 'Work From Anywhere',
      'headline': 'High-Paying Tech & Design Jobs for English Speakers',
      'cta': 'Explore Jobs',
      'gradient': [Color(0xFF064E3B), Color(0xFF065F46), Color(0xFF10B981)],
      'icon': Icons.public_rounded,
      'accent': Color(0xFF34D399),
    },
    {
      'brand': 'Duolingo & IELTS Sprint',
      'tagline': 'Band 8+ Guarantee',
      'headline': 'Master Daily English Vocabulary & Speaking Drills',
      'cta': 'Start Practice',
      'gradient': [Color(0xFF451A03), Color(0xFF78350F), Color(0xFFF59E0B)],
      'icon': Icons.emoji_events_rounded,
      'accent': Color(0xFFFFD700),
    },
  ];

  late final Map<String, dynamic> _currentSponsor;

  @override
  void initState() {
    super.initState();
    _currentSponsor = (_vibeSponsors..shuffle()).first;
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onNext();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _currentSponsor['gradient'] as List<Color>;
    final accent = _currentSponsor['accent'] as Color;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Aesthetic Canvas
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: accent.withValues(alpha: 0.3), width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(_currentSponsor['icon'] as IconData,
                                  color: accent, size: 44),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              _currentSponsor['headline'] as String,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _currentSponsor['tagline'] as String,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Swipe Up / CTA Button
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Opening sponsor link...',
                                    style: GoogleFonts.outfit()),
                                duration: const Duration(milliseconds: 700),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentSponsor['cta'] as String,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Tap Gesture Zones (Left = Prev, Right = Next)
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: widget.onPrevious,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: widget.onNext,
                  ),
                ),
              ],
            ),
          ),

          // Top Progress Bar & Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // Story Progress Bar
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: _progressController.value,
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(accent),
                            minHeight: 3,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: accent.withValues(alpha: 0.2),
                          child: Icon(_currentSponsor['icon'] as IconData,
                              color: accent, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentSponsor['brand'] as String,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: accent.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'SPONSORED',
                                    style: GoogleFonts.outfit(
                                      color: accent,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white70),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
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
}
