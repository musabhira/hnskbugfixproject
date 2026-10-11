import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';

/// 📚 Kids Productivity & English Study Tools Page
/// Includes:
/// 1. Daily Study Tasks & Quests Maker (with star rewards)
/// 2. Word Bank Flashcards with TTS pronunciation
/// 3. English Daily Routine & Schedule
/// 4. Quick Kids Notations & Voice Notes
class PocketKidsStudyToolsPage extends StatefulWidget {
  const PocketKidsStudyToolsPage({super.key});

  @override
  State<PocketKidsStudyToolsPage> createState() => _PocketKidsStudyToolsPageState();
}

class _PocketKidsStudyToolsPageState extends State<PocketKidsStudyToolsPage> {
  final FlutterTts _tts = FlutterTts();
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  int _selectedTab = 0; // 0 = Tasks & Quests, 1 = Flashcards, 2 = Routine, 3 = Notes

  // Daily Tasks
  final List<Map<String, dynamic>> _tasks = [
    {'title': 'Complete 1 Trail Level on Mountain Road 🏔️', 'done': false, 'stars': 10},
    {'title': 'Practice greeting 1 Mate with "Good morning!" ☀️', 'done': false, 'stars': 5},
    {'title': 'Listen to 3 Word Flashcards with voice 🎧', 'done': false, 'stars': 5},
    {'title': 'Challenge 1 Kid Citadel Defense 🏰', 'done': false, 'stars': 15},
    {'title': 'Say 1 polite sentence aloud with kindness 🙏', 'done': false, 'stars': 5},
  ];

  // Flashcards
  final List<Map<String, String>> _flashcards = [
    {
      'word': 'Brave',
      'emoji': '🦁',
      'definition': 'Having courage and not afraid of difficulties.',
      'example': 'The little cub is brave and climbs the mountain.',
    },
    {
      'word': 'Friendly',
      'emoji': '🤝',
      'definition': 'Kind, pleasant, and eager to help others.',
      'example': 'We are always friendly and share our toys with mates.',
    },
    {
      'word': 'Curious',
      'emoji': '🔍',
      'definition': 'Eager to learn and know new interesting things.',
      'example': 'Curious kids ask wonderful questions and explore nature.',
    },
    {
      'word': 'Honest',
      'emoji': '✨',
      'definition': 'Always telling the truth and being sincere.',
      'example': 'An honest friend is respected by everyone in the castle.',
    },
    {
      'word': 'Champion',
      'emoji': '🏆',
      'definition': 'A winner who practices hard and never gives up.',
      'example': 'Every kid on the 100-Day trail is a true English Champion!',
    },
  ];

  // Daily Routine Schedule
  final List<Map<String, dynamic>> _schedule = [
    {'time': '07:30 AM', 'title': 'Morning English Song & Greeting', 'icon': '☀️', 'desc': 'Say "Good Morning" to family & mates', 'hasAlarm': true},
    {'time': '04:00 PM', 'title': 'Mountain Trail Game Session', 'icon': '🎮', 'desc': 'Play 1 daily level & earn 3 stars', 'hasAlarm': true},
    {'time': '06:00 PM', 'title': 'Citadel Defense & Mate Talk', 'icon': '🏰', 'desc': 'Practice spoken English with peer animals', 'hasAlarm': true},
    {'time': '08:00 PM', 'title': 'Bedtime Story & Word Flashcard', 'icon': '🌙', 'desc': 'Listen to pronunciation & relax', 'hasAlarm': true},
  ];

  // Notes
  final List<String> _notes = [
    'Today I learned the word "Brave"! It means having courage like a lion. 🦁',
    'My mate Leo Cub helped me break the Stone Citadel shield today! 🏰⭐',
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.3);
      await _tts.setSpeechRate(0.42);
    } catch (_) {}
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void _addNewTask() {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _tasks.add({'title': '$text 🌟', 'done': false, 'stars': 5});
      _taskController.clear();
    });
    Navigator.pop(context);
    HapticFeedback.mediumImpact();
  }

  void _addNewNote() {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _notes.insert(0, text);
      _noteController.clear();
    });
    Navigator.pop(context);
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _tts.stop();
    _taskController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text('📚', style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STUDY TOOLS & ROUTINE',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'Kids Daily Productivity & Word Bank',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tab Switcher
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  _buildTabItem(0, 'TASKS ✅'),
                  _buildTabItem(1, 'WORDS 🗂️'),
                  _buildTabItem(2, 'ROUTINE ⏰'),
                  _buildTabItem(3, 'NOTES 📝'),
                ],
              ),
            ),

            // Tab Body
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _buildTasksView(),
                  _buildFlashcardsView(),
                  _buildScheduleView(),
                  _buildNotesView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    final active = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedTab = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFFD700) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: active ? const Color(0xFF78350F) : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  // --- 1. TASKS & QUESTS VIEW ---
  Widget _buildTasksView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TODAY\'S ENGLISH QUESTS',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
            GestureDetector(
              onTap: () => _showAddTaskDialog(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.add_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'ADD TASK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._tasks.map((task) {
          final bool done = task['done'];

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: done ? const Color(0xFF14532D).withValues(alpha: 0.3) : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: done ? const Color(0xFF22C55E) : Colors.white12,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      task['done'] = !done;
                    });
                    if (!done) {
                      await PocketKidsService.addStars(task['stars'] as int);
                      _speak("Great job completing your task! You earned ${task['stars']} bonus stars!");
                    }
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: done ? const Color(0xFF22C55E) : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: done ? const Color(0xFF22C55E) : Colors.white38, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: done ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task['title'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: done ? Colors.white60 : Colors.white,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '+${task['stars']} ⭐',
                    style: const TextStyle(
                      color: Color(0xFFFBBF24),
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // --- 2. FLASHCARDS WORD BANK VIEW ---
  Widget _buildFlashcardsView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _flashcards.length,
      itemBuilder: (context, idx) {
        final card = _flashcards[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(card['emoji']!, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 10),
                      Text(
                        card['word']!,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF38BDF8),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700), size: 24),
                    onPressed: () {
                      _speak("${card['word']}. ${card['definition']} Example: ${card['example']}");
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                card['definition']!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '💡 "${card['example']}"',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 3. ROUTINE SCHEDULE VIEW ---
  Widget _buildScheduleView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _schedule.length,
      itemBuilder: (context, idx) {
        final item = _schedule[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(item['icon']!, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['time']!,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF38BDF8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['title']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['desc'] as String,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  item['hasAlarm'] == true ? Icons.alarm_on_rounded : Icons.alarm_off_rounded,
                  color: item['hasAlarm'] == true ? const Color(0xFFFFD700) : Colors.white30,
                  size: 22,
                ),
                tooltip: 'Toggle Alarm Reminder',
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    item['hasAlarm'] = !(item['hasAlarm'] == true);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        item['hasAlarm'] == true
                            ? '⏰ Alarm set for ${item['time']}!'
                            : '🔕 Alarm turned off for ${item['time']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: item['hasAlarm'] == true ? const Color(0xFF10B981) : const Color(0xFF0F172A),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 4. NOTES VIEW ---
  Widget _buildNotesView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MY ENGLISH NOTES 📝',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
            GestureDetector(
              onTap: () => _showAddNoteDialog(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.edit_note_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'NEW NOTE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._notes.map((note) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📌', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    note,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.35,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF38BDF8), size: 18),
                  onPressed: () => _speak(note),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Add Study Quest 🎯',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _taskController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'e.g. Read 5 pages of my storybook',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: _addNewTask,
            child: const Text('Add Quest'),
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'New English Note 📝',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _noteController,
          maxLines: 3,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Write words or sentences you learned...',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
            onPressed: _addNewNote,
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }
}
