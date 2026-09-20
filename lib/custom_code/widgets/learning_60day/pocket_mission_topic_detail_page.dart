import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🎮 Dedicated Gamified Detail Page Wrapper for Daily Mission Learning Topics
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
    this.xpReward = 20,
    required this.builder,
  });

  @override
  State<PocketMissionTopicDetailPage> createState() =>
      _PocketMissionTopicDetailPageState();
}

class _PocketMissionTopicDetailPageState
    extends State<PocketMissionTopicDetailPage> {
  late String _activeLanguage;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _activeLanguage = widget.initialLanguage.isEmpty
        ? 'Malayalam'
        : widget.initialLanguage;
    _isCompleted = widget.isInitiallyCompleted;
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: widget.accentColor, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [widget.accentColor, const Color(0xFFFFD700)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.4),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(widget.icon, style: const TextStyle(fontSize: 34)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${widget.title.toUpperCase()} MASTERED!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Great job! You have successfully completed this interactive quest and sharpened your speaking skills.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '+${widget.xpReward} XP EARNED',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.accentColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'RETURN TO MISSIONS ✓',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 0.5,
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
    return Scaffold(
      backgroundColor: const Color(0xFF080D1A),
      body: SafeArea(
        child: Column(
          children: [
            // ─────────────────────────────────────────────────────────────
            // 1. TOP GAME HUD
            // ─────────────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                border: Border(bottom: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(_isCompleted),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    tooltip: 'Back to Missions',
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isCompleted
                                ? const Color(0xFF10B981)
                                : widget.accentColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _isCompleted
                                ? 'STEP ${widget.stepNumber} ✓'
                                : 'STEP ${widget.stepNumber}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(widget.icon, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Day ${widget.day} Interactive Arena',
                                style: GoogleFonts.inter(
                                  color: Colors.white54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Language Selector
                  PopupMenuButton<String>(
                    initialValue: _activeLanguage,
                    onSelected: (lang) => setState(() => _activeLanguage = lang),
                    color: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.translate_rounded, color: Color(0xFFFFD700), size: 13),
                          const SizedBox(width: 4),
                          Text(
                            _activeLanguage,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 16),
                        ],
                      ),
                    ),
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'Malayalam', child: Text('മലയാളം (Malayalam)', style: TextStyle(color: Colors.white))),
                      const PopupMenuItem(value: 'English', child: Text('English', style: TextStyle(color: Colors.white))),
                      const PopupMenuItem(value: 'Tamil', child: Text('தமிழ் (Tamil)', style: TextStyle(color: Colors.white))),
                      const PopupMenuItem(value: 'Telugu', child: Text('తెలుగు (Telugu)', style: TextStyle(color: Colors.white))),
                      const PopupMenuItem(value: 'Hindi', child: Text('हिन्दी (Hindi)', style: TextStyle(color: Colors.white))),
                      const PopupMenuItem(value: 'Kannada', child: Text('ಕನ್ನಡ (Kannada)', style: TextStyle(color: Colors.white))),
                    ],
                  ),
                ],
              ),
            ),

            // ─────────────────────────────────────────────────────────────
            // 2. MAIN SCROLLABLE LEARNING ARENA
            // ─────────────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Intro banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.accentColor.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: widget.accentColor.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Text(widget.icon, style: const TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.subtitle,
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 11.5,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Embedded Topic Widget
                    widget.builder(context, _activeLanguage, _markCompleted),
                  ],
                ),
              ),
            ),

            // ─────────────────────────────────────────────────────────────
            // 3. BOTTOM COMPLETION ACTION BAR
            // ─────────────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                children: [
                  if (_isCompleted) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF10B981)),
                      ),
                      child: const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Quest Completed & Verified ✓',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Text(
                        'Practice & Speak Aloud to Finish',
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    icon: Icon(
                      _isCompleted ? Icons.check_circle_rounded : Icons.task_alt_rounded,
                      size: 18,
                    ),
                    label: Text(
                      _isCompleted ? 'FINISH STEP ✓' : 'COMPLETE STEP ✓',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
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
    );
  }
}
