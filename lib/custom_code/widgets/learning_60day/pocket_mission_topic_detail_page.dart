import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pocket_language_selection_dialog.dart';

/// 🎮 Dedicated Gamified Arcade Detail Page Arena for Daily Mission Learning Topics
class PocketMissionTopicDetailPage extends StatefulWidget {
  final int day;
  final String stepNumber;
  final String icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final String initialLanguage;
  final bool isInitiallyCompleted;
  final int xpReward;
  final Widget Function(
    BuildContext context,
    String currentLanguage,
    void Function(bool) markCompleted,
  ) builder;

  const PocketMissionTopicDetailPage({
    super.key,
    required this.day,
    required this.stepNumber,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.initialLanguage,
    required this.isInitiallyCompleted,
    this.xpReward = 25,
    required this.builder,
  });

  @override
  State<PocketMissionTopicDetailPage> createState() =>
      _PocketMissionTopicDetailPageState();
}

class _PocketMissionTopicDetailPageState
    extends State<PocketMissionTopicDetailPage>
    with SingleTickerProviderStateMixin {
  late String _activeLanguage;
  late bool _isCompleted;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _activeLanguage = widget.initialLanguage.isEmpty
        ? 'Malayalam'
        : widget.initialLanguage;
    _isCompleted = widget.isInitiallyCompleted;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _syncLanguagePreference();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _syncLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(PocketLanguageSelectionDialog.kPrefLangKey);
      if (saved != null && saved.isNotEmpty && mounted) {
        setState(() => _activeLanguage = saved);
      }
    } catch (_) {}
  }

  Future<void> _openLanguagePicker() async {
    HapticFeedback.lightImpact();
    final chosen = await PocketLanguageSelectionDialog.show(
      context,
      currentLanguage: _activeLanguage,
    );
    if (chosen != null && chosen.isNotEmpty && mounted) {
      setState(() => _activeLanguage = chosen);
    }
  }

  void _markCompleted([bool completed = true]) {
    if (!mounted) return;
    setState(() => _isCompleted = completed);
  }

  void _onFinishAndReturn() {
    HapticFeedback.heavyImpact();
    setState(() => _isCompleted = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF0F172A),
          elevation: 24,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFFFFD700), width: 2),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing Trophy Badge
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFF6D00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.icon,
                      style: const TextStyle(fontSize: 38),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '🌟 QUEST COMPLETE! 🌟',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Outstanding work! You mastered this stage and strengthened your subconscious English muscle memory.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                // Rewards Bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.stars_rounded,
                              color: Color(0xFFFFD700), size: 20),
                          const SizedBox(width: 6),
                          Text(
                            '+${widget.xpReward} XP',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 18, color: Colors.white24),
                      Row(
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            '+50 COINS',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF10B981),
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.black, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'CLAIM & RETURN TO MISSIONS ✓',
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 13.5,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
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
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: Stack(
        children: [
          // 🕹️ Background 1: Custom Arcade Grid Painter
          Positioned.fill(
            child: CustomPaint(
              painter: _ArcadeGridPainter(accentColor: widget.accentColor),
            ),
          ),

          // 🕹️ Background 2: Ambient Glowing Neon Orbs
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.accentColor.withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.25),
                    blurRadius: 90,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                    blurRadius: 90,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ─────────────────────────────────────────────────────────────
                // 1. TOP ARCADE HUD BAR
                // ─────────────────────────────────────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                    border: Border(
                      bottom: BorderSide(
                        color: widget.accentColor.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Retro back button
                      InkWell(
                        onTap: () =>
                            Navigator.of(context).pop(_isCompleted),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'BACK',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Level and Step Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.accentColor,
                              widget.accentColor.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: widget.accentColor.withValues(alpha: 0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Text(
                          'LVL ${widget.day} • STEP ${widget.stepNumber}',
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // XP Rewards Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color:
                                const Color(0xFFFFD700).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars_rounded,
                                color: Color(0xFFFFD700), size: 13),
                            const SizedBox(width: 3),
                            Text(
                              '+${widget.xpReward} XP',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFD700),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Language Switcher Pill (Audio Directive: Global Language Switcher)
                      InkWell(
                        onTap: _openLanguagePicker,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF00FFCC)
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.translate_rounded,
                                  color: Color(0xFF00FFCC), size: 13),
                              const SizedBox(width: 4),
                              Text(
                                _activeLanguage,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down,
                                  color: Colors.white70, size: 15),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ─────────────────────────────────────────────────────────────
                // 2. MAIN SCROLLABLE LEARNING ARENA
                // ─────────────────────────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ⚔️ Arcade Quest Objective Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF0F172A).withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: widget.accentColor.withValues(alpha: 0.5),
                              width: 1.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    widget.accentColor.withValues(alpha: 0.15),
                                blurRadius: 14,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Pulsing Beacon
                                  ScaleTransition(
                                    scale: _pulseAnim,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: widget.accentColor,
                                        boxShadow: [
                                          BoxShadow(
                                            color: widget.accentColor
                                                .withValues(alpha: 0.8),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isCompleted
                                        ? 'QUEST OBJECTIVE: CLEARED ✓'
                                        : 'INTERACTIVE ARENA QUEST',
                                    style: GoogleFonts.outfit(
                                      color: _isCompleted
                                          ? const Color(0xFF10B981)
                                          : widget.accentColor,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _isCompleted
                                          ? const Color(0xFF10B981)
                                              .withValues(alpha: 0.2)
                                          : Colors.amber.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      _isCompleted ? '100% COMPLETE' : 'IN PROGRESS',
                                      style: GoogleFonts.outfit(
                                        color: _isCompleted
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFFFD700),
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: widget.accentColor
                                          .withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: widget.accentColor
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Text(widget.icon,
                                        style: const TextStyle(fontSize: 22)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.title,
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          widget.subtitle,
                                          style: GoogleFonts.inter(
                                            color: Colors.white70,
                                            fontSize: 11,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Live Objective Progress Bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _isCompleted ? 1.0 : 0.4,
                                  minHeight: 5,
                                  backgroundColor: Colors.white12,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _isCompleted
                                        ? const Color(0xFF10B981)
                                        : widget.accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // 🎮 Gaming Frame Wrapping The Detail Learning Content
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0C1322)
                                .withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 1.2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black45,
                                blurRadius: 18,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: widget.builder(
                                context, _activeLanguage, _markCompleted),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─────────────────────────────────────────────────────────────
                // 3. BOTTOM GAMIFIED ACTION BAR
                // ─────────────────────────────────────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    border: Border(
                      top: BorderSide(
                        color: widget.accentColor.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (_isCompleted) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF10B981).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF10B981), width: 1.5),
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Color(0xFF10B981), size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'QUEST VERIFIED ✓',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF10B981),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12.5,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'Tap to claim points & advance',
                                style: GoogleFonts.inter(
                                  color: Colors.white54,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child: Row(
                            children: [
                              const Text('🕹️', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Complete the drill above to earn +${widget.xpReward} XP',
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: _onFinishAndReturn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isCompleted
                              ? const Color(0xFF10B981)
                              : widget.accentColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        icon: Icon(
                          _isCompleted
                              ? Icons.stars_rounded
                              : Icons.task_alt_rounded,
                          size: 18,
                        ),
                        label: Text(
                          _isCompleted
                              ? 'CLAIM VICTORY ✓'
                              : 'FINISH STEP ✓',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900,
                            fontSize: 12.5,
                            letterSpacing: 0.5,
                          ),
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
}

/// 🕹️ Custom Arcade Perspective Grid Painter
class _ArcadeGridPainter extends CustomPainter {
  final Color accentColor;

  _ArcadeGridPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor.withValues(alpha: 0.04)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Horizontal grid lines
    const double rowSpacing = 32.0;
    for (double y = 0; y < size.height; y += rowSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical grid lines
    const double colSpacing = 32.0;
    for (double x = 0; x < size.width; x += colSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Glowing Star Dots at intersections
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final rand = math.Random(42);
    for (int i = 0; i < 35; i++) {
      final dx = rand.nextDouble() * size.width;
      final dy = rand.nextDouble() * size.height;
      final radius = rand.nextDouble() * 1.5 + 0.5;
      canvas.drawCircle(Offset(dx, dy), radius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArcadeGridPainter oldDelegate) =>
      oldDelegate.accentColor != accentColor;
}
