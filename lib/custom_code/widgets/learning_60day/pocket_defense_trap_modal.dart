import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🛡️ Custom English Defense Trap Model
class CustomDefenseTrap {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String trapType; // 'vocab', 'grammar', 'idiom'

  const CustomDefenseTrap({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.trapType = 'vocab',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
        'trapType': trapType,
      };

  factory CustomDefenseTrap.fromJson(Map<String, dynamic> json) => CustomDefenseTrap(
        id: json['id'] ?? '',
        question: json['question'] ?? '',
        options: List<String>.from(json['options'] ?? []),
        correctIndex: json['correctIndex'] ?? 0,
        explanation: json['explanation'] ?? '',
        trapType: json['trapType'] ?? 'vocab',
      );
}

/// Curated starter traps that users can equip or customize
final List<CustomDefenseTrap> kDefaultTraps = [
  const CustomDefenseTrap(
    id: 'trap_1',
    question: 'What is the precise synonym of "Benevolent"?',
    options: ['Malevolent', 'Generous & Charitable', 'Greedy', 'Cowardly'],
    correctIndex: 1,
    explanation: '"Benevolent" means kind, generous, and caring.',
    trapType: 'vocab',
  ),
  const CustomDefenseTrap(
    id: 'trap_2',
    question: 'Spot the correct grammar form: "Neither of the cars ___ working."',
    options: ['are', 'is', 'were', 'have been'],
    correctIndex: 1,
    explanation: '"Neither of" takes a singular verb: "is".',
    trapType: 'grammar',
  ),
  const CustomDefenseTrap(
    id: 'trap_3',
    question: 'What does the idiom "Bite the bullet" mean?',
    options: [
      'Eat metal food',
      'Endure a painful or difficult situation with courage',
      'Give up easily',
      'Shoot a firearm'
    ],
    correctIndex: 1,
    explanation: '"Bite the bullet" means to face a tough situation bravely.',
    trapType: 'idiom',
  ),
];

class PocketDefenseTrapModal extends StatefulWidget {
  final int userDay;

  const PocketDefenseTrapModal({
    super.key,
    required this.userDay,
  });

  static void show(BuildContext context, int userDay) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A0F1D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => PocketDefenseTrapModal(userDay: userDay),
    );
  }

  @override
  State<PocketDefenseTrapModal> createState() => _PocketDefenseTrapModalState();
}

class _PocketDefenseTrapModalState extends State<PocketDefenseTrapModal> {
  List<CustomDefenseTrap> _traps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTraps();
  }

  Future<void> _loadTraps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('user_custom_defense_traps');
      if (raw != null) {
        final decoded = jsonDecode(raw) as List;
        setState(() {
          _traps = decoded.map((e) => CustomDefenseTrap.fromJson(e)).toList();
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    setState(() {
      _traps = List.from(kDefaultTraps);
      _isLoading = false;
    });
  }

  Future<void> _saveTraps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_traps.map((e) => e.toJson()).toList());
      await prefs.setString('user_custom_defense_traps', encoded);
    } catch (_) {}
  }

  void _openEditTrapDialog(int index) {
    final trap = _traps[index];
    final qCtrl = TextEditingController(text: trap.question);
    final expCtrl = TextEditingController(text: trap.explanation);
    final opCtrls = List.generate(4, (i) => TextEditingController(text: trap.options[i]));
    int selectedCorrect = trap.correctIndex;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDState) => AlertDialog(
          backgroundColor: const Color(0xFF131D31),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Text('🛡️', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                'Customize Trap #${index + 1}',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('English Challenge Question:', style: TextStyle(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 4),
                TextField(
                  controller: qCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Options (Tap radio button to select correct answer):',
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 6),
                ...List.generate(4, (i) {
                  final isCorrect = selectedCorrect == i;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isCorrect ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isCorrect ? const Color(0xFF10B981) : Colors.white38,
                            size: 20,
                          ),
                          onPressed: () => setDState(() => selectedCorrect = i),
                        ),
                        Expanded(
                          child: TextField(
                            controller: opCtrls[i],
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF1E293B),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                const Text('Explanation:', style: TextStyle(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 4),
                TextField(
                  controller: expCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _traps[index] = CustomDefenseTrap(
                    id: trap.id,
                    question: qCtrl.text.trim(),
                    options: opCtrls.map((c) => c.text.trim()).toList(),
                    correctIndex: selectedCorrect,
                    explanation: expCtrl.text.trim(),
                    trapType: trap.trapType,
                  );
                });
                _saveTraps();
                Navigator.pop(ctx);
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Defense Trap #${index + 1} Armored & Active!', style: GoogleFonts.outfit()),
                    backgroundColor: const Color(0xFF059669),
                  ),
                );
              },
              child: const Text('SAVE TRAP', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(3)),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              const Text('🛡️', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CUSTOM SHIELD DEFENSE TRAPS',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      'Arm your house with custom English questions to repel attackers!',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: ListView.builder(
                itemCount: _traps.length,
                itemBuilder: (context, i) {
                  final t = _traps[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131D31),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.35)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'TRAP #${i + 1} (${t.trapType.toUpperCase()})',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF38BDF8),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.edit_note_rounded, color: Colors.amber, size: 22),
                              onPressed: () => _openEditTrapDialog(i),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t.question,
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Correct Answer: ${t.options[t.correctIndex]}',
                          style: TextStyle(color: Colors.greenAccent.shade200, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '💡 ${t.explanation}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 11),
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
}
