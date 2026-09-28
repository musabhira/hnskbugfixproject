import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pocket_syllabus_repository.dart';

/// 🏛️ Interactive 90-Day Master Syllabus Modal & Level Switcher
/// Allows any learner to inspect their personalized 90-day learning curriculum,
/// switch between tracks (Zero -> Beginner -> Intermediate -> Peak), and see daily milestones.
class PocketMasterSyllabusModal extends StatefulWidget {
  final LearnerLevel initialLevel;
  final int currentDay;
  final Function(LearnerLevel newLevel)? onLevelChanged;

  const PocketMasterSyllabusModal({
    super.key,
    required this.initialLevel,
    this.currentDay = 1,
    this.onLevelChanged,
  });

  static Future<void> show(
    BuildContext context, {
    LearnerLevel? initialLevel,
    int currentDay = 1,
    Function(LearnerLevel newLevel)? onLevelChanged,
  }) async {
    final resolvedLevel =
        initialLevel ?? await PocketSyllabusRepository.getSavedLevel();
    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PocketMasterSyllabusModal(
        initialLevel: resolvedLevel,
        currentDay: currentDay,
        onLevelChanged: onLevelChanged,
      ),
    );
  }

  @override
  State<PocketMasterSyllabusModal> createState() =>
      _PocketMasterSyllabusModalState();
}

class _PocketMasterSyllabusModalState extends State<PocketMasterSyllabusModal>
    with SingleTickerProviderStateMixin {
  late LearnerLevel _selectedLevel;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.initialLevel;
    _tabController = TabController(
      length: LearnerLevel.values.length,
      initialIndex: _selectedLevel.index,
      vsync: this,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedLevel = LearnerLevel.values[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _applyLevel(LearnerLevel level) async {
    HapticFeedback.heavyImpact();
    await PocketSyllabusRepository.saveLevel(level);
    widget.onLevelChanged?.call(level);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Syllabus updated to: ${PocketSyllabusRepository.getTrack(level).nameEn} 🚀',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final track = PocketSyllabusRepository.getTrack(_selectedLevel);
    final isCurrentActiveTrack = _selectedLevel == widget.initialLevel;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.65,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.75),
                blurRadius: 32,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            children: [
              // 🔘 Top Drag Pill
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // 🏷️ Header Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: track.primaryColor.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: track.primaryColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Icon(
                        track.icon,
                        color: track.primaryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'YOUR 90-DAY SYLLABUS',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF38BDF8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              if (isCurrentActiveTrack) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981)
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF10B981)
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: Text(
                                    'ACTIVE TRACK ✓',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF10B981),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            track.nameEn,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white60, size: 22),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white10, height: 1),

              // 🎛️ Level Switcher Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: track.primaryColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: track.primaryColor.withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: const [
                    Tab(text: 'Level 0\nZero'),
                    Tab(text: 'Level 1\nBeginner'),
                    Tab(text: 'Level 2\nElementary'),
                    Tab(text: 'Level 3\nMiddle'),
                    Tab(text: 'Level 4\nAdvanced'),
                    Tab(text: 'Level 5\nExpert'),
                  ],
                ),
              ),

              // 📜 Scrollable Syllabus Details
              Expanded(
                child: ListView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  children: [
                    // Track Overview Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            track.primaryColor.withValues(alpha: 0.15),
                            const Color(0xFF1E293B).withValues(alpha: 0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: track.primaryColor.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                track.badgeText,
                                style: GoogleFonts.outfit(
                                  color: track.primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const Spacer(),
                              const Text('🗓️ 90 DAYS TOTAL',
                                  style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            track.nameNative,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            track.targetAudienceNative,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFCBD5E1),
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            track.targetAudienceEn,
                            style: GoogleFonts.inter(
                              color: Colors.white38,
                              fontSize: 11.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Section Title
                    Row(
                      children: [
                        const Icon(Icons.timeline_rounded,
                            color: Color(0xFFFACC15), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '90-DAY PROGRESSIVE MILESTONES',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Milestones List
                    ...track.milestones.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final m = entry.value;
                      return _buildMilestoneTile(idx + 1, m);
                    }),

                    const SizedBox(height: 24),

                    // Switch / Set Active Button
                    if (!isCurrentActiveTrack)
                      ElevatedButton.icon(
                        onPressed: () => _applyLevel(_selectedLevel),
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label: Text(
                          'SWITCH TO ${track.nameEn.toUpperCase()}',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: track.primaryColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      )
                    else
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          '✓ YOU ARE CURRENTLY ON THIS TRACK',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF10B981),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMilestoneTile(int stepNumber, SyllabusMilestone m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: m.color.withValues(alpha: 0.28),
          width: 1.1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: m.color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: m.color.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              children: [
                Icon(m.icon, color: m.color, size: 20),
                const SizedBox(height: 4),
                Text(
                  m.dayRange,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: m.color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.titleNative,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  m.titleEn,
                  style: GoogleFonts.inter(
                    color: m.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  m.descriptionNative,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text('🎯 ', style: TextStyle(fontSize: 10)),
                    Expanded(
                      child: Text(
                        m.focusAreaNative,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
