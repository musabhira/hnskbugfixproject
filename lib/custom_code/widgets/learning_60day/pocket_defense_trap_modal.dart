import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'pocket_fortress_defense_service.dart';

/// 🛡️ Direct & Minimal Defense Shield Creation & Management Modal
/// Audio Directive (Audio 13 & 14):
/// "ഇവിടുന്ന് Add Defense Shield എന്ന് പറഞ്ഞു കഴിഞ്ഞാൽ... direct Add Shield Question എന്ന് പറഞ്ഞ് direct കൊടുക്കുക.
/// ആ ബോക്സിൽ വരുന്നു, അവർ ക്വസ്റ്റ്യൻ add ചെയ്യുന്നു, നേരത്തെ add ചെയ്ത questions ഇവിടെ കാണുകയും ചെയ്യുന്നു.
/// അല്ലാതെ Admin Panel, Court ഒന്നും അതിൽ കാണിക്കേണ്ട ആവശ്യമില്ല.
/// Gate select ചെയ്യുമ്പോൾ തന്നെ അതിന്റെ ഉള്ളിൽ hint demo കാണിക്കണം.
/// സേവ് കൊടുത്താൽ Supabase-ൽ പോയി സേവ് ആകും. മിനിമൽ ആക്കുക."
class PocketDefenseTrapModal extends StatefulWidget {
  final int userDay;

  const PocketDefenseTrapModal({
    super.key,
    required this.userDay,
  });

  static Future<void> show(BuildContext context, int userDay) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PocketDefenseTrapModal(userDay: userDay),
    );
  }

  @override
  State<PocketDefenseTrapModal> createState() => _PocketDefenseTrapModalState();
}

class _PocketDefenseTrapModalState extends State<PocketDefenseTrapModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<HouseShieldQuestion> _questions = [];
  bool _isLoading = true;

  // Selected Gate
  int _selectedGateIdx = 0;

  // Question Form Controllers
  final TextEditingController _questionCtrl = TextEditingController();
  final TextEditingController _explanationCtrl = TextEditingController();
  final List<TextEditingController> _optionCtrls =
      List.generate(4, (_) => TextEditingController());
  int _correctIndex = 0;
  bool _isDeploying = false;

  // Gate definitions with levels and sample hint demos
  static const List<Map<String, dynamic>> _gateDefinitions = [
    {
      'id': 'vocab_gate',
      'title': 'Vocab MCQ',
      'levelRange': 'Days 1–10',
      'icon': '📖',
      'color': Color(0xFF00E5FF),
      'demo':
          'Demo: "What is the synonym of Resilient?"\n(A) Strong  (B) Fragile  (C) Lazy  (D) Weak',
    },
    {
      'id': 'grammar_defusal',
      'title': 'Grammar Defusal',
      'levelRange': 'Days 11–20',
      'icon': '⚡',
      'color': Color(0xFF8B5CF6),
      'demo':
          'Demo: "If we ___ earlier, we would have reached on time."\n(A) had left  (B) left  (C) will leave  (D) have left',
    },
    {
      'id': 'speed_blitz',
      'title': 'Rapid Syntax',
      'levelRange': 'Days 21–30',
      'icon': '⏱️',
      'color': Color(0xFFF59E0B),
      'demo':
          'Demo: "Choose the correct preposition: She is proficient ___ English."\n(A) in  (B) at  (C) on  (D) with',
    },
    {
      'id': 'idiom_shield',
      'title': 'Idiom Bastion',
      'levelRange': 'Days 31–40',
      'icon': '🛡️',
      'color': Color(0xFF10B981),
      'demo':
          'Demo: "What does the idiom \'Burn the midnight oil\' mean?"\n(A) Study late into the night  (B) Cook food  (C) Start a fire  (D) Waste energy',
    },
    {
      'id': 'riddle_sphinx',
      'title': 'Nuance Sphinx',
      'levelRange': 'Days 41–90',
      'icon': '🔮',
      'color': Color(0xFFEC4899),
      'demo':
          'Demo: "Identify the grammatically flawed sentence:"\n(A) Neither of the candidates was selected  (B) Neither of them were present',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadQuestions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _questionCtrl.dispose();
    _explanationCtrl.dispose();
    for (final c in _optionCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final list = await PocketFortressDefenseService.loadShieldQuestions(widget.userDay);
    if (mounted) {
      setState(() {
        _questions = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _deployShieldQuestion() async {
    final questionText = _questionCtrl.text.trim();
    final options = _optionCtrls.map((c) => c.text.trim()).toList();

    if (questionText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please enter a question for your defense shield!'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    if (options.any((o) => o.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please provide all 4 multiple-choice options!'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    final maxAllowed = PocketFortressDefenseService.getMaxQuestionsForStage(widget.userDay);
    if (_questions.length >= maxAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Maximum shield slots reached ($maxAllowed). Level up to unlock more!'),
          backgroundColor: const Color(0xFFB45309),
        ),
      );
      return;
    }

    setState(() => _isDeploying = true);
    HapticFeedback.mediumImpact();

    final selectedGate = _gateDefinitions[_selectedGateIdx];
    final newQuestion = HouseShieldQuestion(
      id: 'shield_${DateTime.now().millisecondsSinceEpoch}',
      question: questionText,
      options: options,
      correctIndex: _correctIndex,
      explanation: _explanationCtrl.text.trim().isNotEmpty
          ? _explanationCtrl.text.trim()
          : 'Correct answer: ${options[_correctIndex]}',
      category: selectedGate['id'] as String,
      trapType: selectedGate['id'] as String,
      isPresidentApproved: true,
    );

    final updated = List<HouseShieldQuestion>.from(_questions)..add(newQuestion);

    // 1. Save locally
    await PocketFortressDefenseService.saveShieldQuestions(updated);

    // 2. Sync to Supabase
    try {
      final myId = SupaFlow.client.auth.currentUser?.id;
      if (myId != null) {
        await SupaFlow.client.from('profile').update({
          'house_shield_questions': updated.map((q) => q.toJson()).toList(),
        }).eq('id', myId);
      }
    } catch (e) {
      debugPrint('Supabase shield sync error: $e');
    }

    if (!mounted) return;

    // Clear form
    _questionCtrl.clear();
    _explanationCtrl.clear();
    for (final c in _optionCtrls) {
      c.clear();
    }
    _correctIndex = 0;

    setState(() {
      _questions = updated;
      _isDeploying = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🛡️ Shield Question Armed & Synced to Supabase!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );

    // Switch to Armed tab to show newly added shield
    _tabController.animateTo(1);
  }

  Future<void> _deleteQuestion(int index) async {
    final updated = List<HouseShieldQuestion>.from(_questions)..removeAt(index);
    await PocketFortressDefenseService.saveShieldQuestions(updated);

    try {
      final myId = SupaFlow.client.auth.currentUser?.id;
      if (myId != null) {
        await SupaFlow.client.from('profile').update({
          'house_shield_questions': updated.map((q) => q.toJson()).toList(),
        }).eq('id', myId);
      }
    } catch (e) {
      debugPrint('Supabase delete sync: $e');
    }

    if (mounted) {
      setState(() => _questions = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🗑️ Shield question removed from gate.'),
          backgroundColor: Color(0xFF1E293B),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxAllowed = PocketFortressDefenseService.getMaxQuestionsForStage(widget.userDay);
    final selectedGate = _gateDefinitions[_selectedGateIdx];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header (Minimal: No admin panels, no court decrees)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('🛡️', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Defense Shield',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Day ${widget.userDay} • ${_questions.length} / $maxAllowed Slots Armed',
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Minimal Tabs: Add Question / Armed Shields
            Container(
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color(0xFF0284C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                tabs: [
                  Tab(text: '➕ Add Shield Question #${_questions.length + 1}'),
                  Tab(text: '🛡️ Armed (${_questions.length}/$maxAllowed)'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Tab Content
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
                ),
              )
            else
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // --- TAB 1: ADD SHIELD QUESTION ---
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Gate Category Selector
                          Text(
                            'Select Gate Type (Different challenge per stage):',
                            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                          ),
                          const SizedBox(height: 6),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(_gateDefinitions.length, (i) {
                                final gate = _gateDefinitions[i];
                                final isSelected = i == _selectedGateIdx;
                                final color = gate['color'] as Color;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedGateIdx = i);
                                    HapticFeedback.selectionClick();
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected ? color.withValues(alpha: 0.25) : const Color(0xFF1E293B),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected ? color : Colors.white12,
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(gate['icon'] as String, style: const TextStyle(fontSize: 13)),
                                        const SizedBox(width: 4),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              gate['title'] as String,
                                              style: GoogleFonts.outfit(
                                                color: isSelected ? Colors.white : Colors.white70,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              gate['levelRange'] as String,
                                              style: TextStyle(
                                                color: isSelected ? color : Colors.white38,
                                                fontSize: 9,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // 💡 Dynamic Hint Demo Box (Direct requirement from user audio!)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (selectedGate['color'] as Color).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: (selectedGate['color'] as Color).withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('💡', style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${selectedGate['title']} Pattern & Hint:',
                                        style: GoogleFonts.outfit(
                                          color: selectedGate['color'] as Color,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        selectedGate['demo'] as String,
                                        style: GoogleFonts.inter(
                                          color: Colors.white70,
                                          fontSize: 10.5,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Question Input Field
                          Text(
                            'Defense Question #${_questions.length + 1}:',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _questionCtrl,
                            maxLines: 2,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Enter your authentic English challenge...',
                              hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                              filled: true,
                              fillColor: const Color(0xFF1E293B),
                              contentPadding: const EdgeInsets.all(12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.white12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 4 Options with Radio / Tap to select correct answer
                          Text(
                            'Options (Tap the circle to mark correct answer):',
                            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                          ),
                          const SizedBox(height: 6),
                          ...List.generate(4, (optIdx) {
                            final isCorrect = optIdx == _correctIndex;
                            final letter = String.fromCharCode(65 + optIdx);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() => _correctIndex = optIdx);
                                      HapticFeedback.selectionClick();
                                    },
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isCorrect
                                            ? const Color(0xFF10B981)
                                            : Colors.white.withValues(alpha: 0.08),
                                        border: Border.all(
                                          color: isCorrect ? const Color(0xFF34D399) : Colors.white24,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          letter,
                                          style: GoogleFonts.outfit(
                                            color: isCorrect ? Colors.black : Colors.white70,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _optionCtrls[optIdx],
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                      decoration: InputDecoration(
                                        hintText: 'Option $letter',
                                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 11),
                                        filled: true,
                                        fillColor: const Color(0xFF1E293B),
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: isCorrect ? const Color(0xFF10B981) : Colors.white12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 10),

                          // Optional Explanation Field
                          TextField(
                            controller: _explanationCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 11.5),
                            decoration: InputDecoration(
                              hintText: 'Explanation / Rule note (optional)...',
                              hintStyle: const TextStyle(color: Colors.white30, fontSize: 11),
                              filled: true,
                              fillColor: const Color(0xFF1E293B),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Save & Deploy Button
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0284C7),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              onPressed: _isDeploying ? null : _deployShieldQuestion,
                              child: _isDeploying
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.shield_outlined, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          'DEPLOY SHIELD TO SUPABASE 🛡️',
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    // --- TAB 2: ARMED SHIELDS LIST ---
                    _questions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🛡️', style: TextStyle(fontSize: 36)),
                                const SizedBox(height: 8),
                                Text(
                                  'No Defense Shields Armed Yet',
                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Switch to "Add Shield Question" to arm your house!',
                                  style: TextStyle(color: Colors.white54, fontSize: 11),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: _questions.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final q = _questions[index];
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '#${index + 1}',
                                        style: const TextStyle(
                                          color: Color(0xFF38BDF8),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            q.question,
                                            style: GoogleFonts.outfit(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          if (q.options.isNotEmpty && q.correctIndex < q.options.length)
                                            Text(
                                              '✓ Answer: ${q.options[q.correctIndex]}',
                                              style: const TextStyle(
                                                color: Color(0xFF34D399),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.white38, size: 18),
                                      onPressed: () => _deleteQuestion(index),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              );
                            },
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
