import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Memory Card Item Model
class CoupleMemoryItem {
  final String id;
  final String title;
  final String dateText;
  final String emoji;
  final String caption;

  CoupleMemoryItem({
    required this.id,
    required this.title,
    required this.dateText,
    required this.emoji,
    required this.caption,
  });
}

/// Bucket List Item Model
class CoupleBucketItem {
  final String id;
  final String title;
  bool isCompleted;

  CoupleBucketItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
}

/// Love Note Model
class CoupleLoveNoteItem {
  final String id;
  final String senderName;
  final String previewText;
  final String timeText;
  bool isOpened;

  CoupleLoveNoteItem({
    required this.id,
    required this.senderName,
    required this.previewText,
    required this.timeText,
    this.isOpened = false,
  });
}

/// 💑 Complete Couple Gang: Romantic Shared-Life Workspace
class PocketGangCoupleWorkspaceWidget extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String currentUserId;

  const PocketGangCoupleWorkspaceWidget({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.currentUserId,
  });

  @override
  State<PocketGangCoupleWorkspaceWidget> createState() =>
      _PocketGangCoupleWorkspaceWidgetState();
}

class _PocketGangCoupleWorkspaceWidgetState
    extends State<PocketGangCoupleWorkspaceWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Memories Timeline State
  final List<CoupleMemoryItem> _memories = [
    CoupleMemoryItem(
      id: 'm1',
      title: 'First Coffee Date ☕',
      dateText: 'Oct 14, 2024',
      emoji: '🌸',
      caption: 'Talked for 4 hours non-stop at the rooftop cafe.',
    ),
    CoupleMemoryItem(
      id: 'm2',
      title: 'Beach Sunset Walk 🌅',
      dateText: 'Dec 22, 2024',
      emoji: '🌊',
      caption: 'Golden hour walk by the sea listening to waves.',
    ),
    CoupleMemoryItem(
      id: 'm3',
      title: 'Our First Road Trip 🚗',
      dateText: 'Jan 15, 2025',
      emoji: '⛰️',
      caption: 'Hill station journey and chilly misty morning.',
    ),
  ];

  // Bucket List State
  final List<CoupleBucketItem> _bucketItems = [
    CoupleBucketItem(id: 'b1', title: 'See the Northern Lights in Norway 🌌', isCompleted: false),
    CoupleBucketItem(id: 'b2', title: 'Cook a 3-course Italian dinner together 🍝', isCompleted: true),
    CoupleBucketItem(id: 'b3', title: 'Camp under starry sky in the mountains ⛺', isCompleted: false),
    CoupleBucketItem(id: 'b4', title: 'Adopt a sweet rescue pet 🐾', isCompleted: false),
  ];

  // Love Notes State
  final List<CoupleLoveNoteItem> _loveNotes = [
    CoupleLoveNoteItem(
      id: 'ln1',
      senderName: 'Your Mate',
      previewText: 'Thank you for always being my biggest supporter...',
      timeText: 'Yesterday',
      isOpened: true,
    ),
    CoupleLoveNoteItem(
      id: 'ln2',
      senderName: 'Your Mate',
      previewText: 'Surprise weekend plan waiting for you! ✨',
      timeText: '2 hours ago',
      isOpened: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1020), Color(0xFF0F172A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Elegant Romantic Sub-Header Ribbon Tabs
          Container(
            height: 42,
            color: const Color(0xFF261429),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: const Color(0xFFF43F5E),
              indicatorWeight: 2.5,
              labelColor: const Color(0xFFF43F5E),
              unselectedLabelColor: Colors.white60,
              labelStyle: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(icon: Icon(Icons.favorite_rounded, size: 14), text: 'Memories'),
                Tab(icon: Icon(Icons.auto_awesome_rounded, size: 14), text: 'Bucket List'),
                Tab(icon: Icon(Icons.mail_rounded, size: 14), text: 'Love Notes'),
                Tab(icon: Icon(Icons.dashboard_rounded, size: 14), text: 'Shared Life'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMemoriesTimelineView(),
                _buildBucketListView(),
                _buildLoveNotesView(),
                _buildSharedLifeDashboardView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. Memories Timeline View
  Widget _buildMemoriesTimelineView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _memories.length,
      itemBuilder: (context, index) {
        final mem = _memories[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF26182B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF43F5E).withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(mem.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mem.title,
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          mem.dateText,
                          style: const TextStyle(color: Color(0xFFF43F5E), fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                mem.caption,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. Shared Bucket List View
  Widget _buildBucketListView() {
    final completedCount = _bucketItems.where((b) => b.isCompleted).length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'OUR SHARED BUCKET LIST ✨',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
              ),
              Text(
                '$completedCount / ${_bucketItems.length} Achieved',
                style: const TextStyle(color: Color(0xFFF43F5E), fontSize: 11.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _bucketItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _bucketItems[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF26182B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: item.isCompleted ? const Color(0xFF10B981).withValues(alpha: 0.3) : Colors.white10,
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => item.isCompleted = !item.isCompleted);
                        },
                        child: Icon(
                          item.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                          color: item.isCompleted ? const Color(0xFF10B981) : Colors.white38,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: item.isCompleted ? Colors.white38 : Colors.white,
                            fontSize: 13.5,
                            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 3. Love Notes & Letters View
  Widget _buildLoveNotesView() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _loveNotes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final note = _loveNotes[index];
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => note.isOpened = true);
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF26182B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFFF43F5E), width: 1.5),
                ),
                title: Row(
                  children: [
                    const Text('💌 ', style: TextStyle(fontSize: 22)),
                    Text(
                      'A Note From ${note.senderName}',
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                content: Text(
                  note.previewText,
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 14, height: 1.5),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('CLOSE', style: TextStyle(color: Color(0xFFF43F5E), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF26182B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: note.isOpened ? Colors.white12 : const Color(0xFFF43F5E),
                width: note.isOpened ? 1.0 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Text(note.isOpened ? '📖' : '💌', style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            note.senderName,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(note.timeText, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        note.previewText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: note.isOpened ? Colors.white60 : Colors.white,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 4. Shared Life Dashboard View (Zero Competition, Pure Celebration)
  Widget _buildSharedLifeDashboardView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Milestone Countdown Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE11D48).withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text('⏳ ', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Milestone: 1-Year Anniversary! 🎉',
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '124 Days Remaining · October 14, 2025',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'SHARED LIFE SUMMARY',
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
          ),
          const SizedBox(height: 10),

          // Cards Row
          Row(
            children: [
              Expanded(
                child: _buildCoupleStatCard('Memories Saved', '${_memories.length}', '3 New this month', const Color(0xFFF43F5E)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCoupleStatCard('Bucket Dreams', '${_bucketItems.length}', '1 Completed', const Color(0xFFFFD700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildCoupleStatCard('Love Notes', '${_loveNotes.length}', '1 Unopened letter', const Color(0xFFEC4899)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCoupleStatCard('Shared Days', '180 Days', 'Growing together ❤️', const Color(0xFF10B981)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Privacy Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF26182B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: const [
                Icon(Icons.lock_outline_rounded, color: Color(0xFFF43F5E), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Private Couple Space: Only you and your partner have access to these shared memories and notes.',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoupleStatCard(String label, String value, String sub, Color accent) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF26182B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(color: accent, fontSize: 10.5, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

