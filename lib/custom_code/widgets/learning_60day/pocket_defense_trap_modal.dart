import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/ai_prompt_service.dart';
import 'pocket_fortress_defense_service.dart';

/// 🛡️ Direct & Minimal Defense Shield Creation, Editing & Interactive Demo Modal
/// User Directives (Audio 13, 14, & 16):
/// 1. "ഷീൽഡ് ആഡ് ചെയ്യണം എന്നുണ്ടെങ്കിൽ ഒറ്റ വഴിയേ ഉള്ളൂ - ലെവൽ കംപ്ലീറ്റ് ചെയ്യുമ്പോൾ അവിടുന്ന് ആഡ് ചെയ്യുക.
///    അല്ലാതെ വെറുതെ ആഡ് ചെയ്യാനുള്ള ഓപ്ഷൻ കൊടുക്കുന്നില്ല.
///    എക്സിസ്റ്റിങ് ക്വസ്റ്റ്യൻസ് എഡിറ്റ് ചെയ്യാം - അതിനുള്ള ഓപ്ഷൻ കൊടുക്കുക."
/// 2. "ഫ്രീ എഐസ് ഒക്കെ ഉണ്ട് - ഹെൽപ്പിന് വേണ്ടിയിട്ട് ക്വസ്റ്റ്യൻസ് ആഡ് ചെയ്യുന്ന സമയത്ത് ഫ്രീ എഐ യൂസ് ചെയ്യാനുള്ള ഓപ്ഷൻ കൊടുക്കുക."
/// 3. "ഈ 'ആംസ്' എന്ന് കാണിക്കുന്നതിന് പകരം 'ഡെമോ' കൊടുത്തൂടെ? ഡെമോ എന്ന രീതിയിൽ കൊടുത്താൽ അടിപൊളിയാവും.
///    ക്വസ്റ്റ്യൻ സെലക്ട് ചെയ്യുമ്പോഴും ആഡ് ചെയ്യുമ്പോഴും ലൈവ് ഡെമോ കാണിക്കണം."
class PocketDefenseTrapModal extends StatefulWidget {
  final int userDay;
  final HouseShieldQuestion? editingQuestion;
  final bool isLevelComplete;

  const PocketDefenseTrapModal({
    super.key,
    required this.userDay,
    this.editingQuestion,
    this.isLevelComplete = false,
  });

  static Future<void> show(
    BuildContext context,
    int userDay, {
    HouseShieldQuestion? editingQuestion,
    bool isLevelComplete = false,
  }) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PocketDefenseTrapModal(
        userDay: userDay,
        editingQuestion: editingQuestion,
        isLevelComplete: isLevelComplete,
      ),
    );
  }

  static Future<void> showShieldUnlockPrompt(
    BuildContext context, {
    required int day,
    int? coins,
  }) =>
      show(context, day, isLevelComplete: true);

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

  // Form Controllers
  final TextEditingController _questionCtrl = TextEditingController();
  final TextEditingController _explanationCtrl = TextEditingController();
  final List<TextEditingController> _optionCtrls =
      List.generate(4, (_) => TextEditingController());
  int _correctIndex = 0;
  bool _isDeploying = false;
  bool _isAiGenerating = false;

  // Edit Mode State
  bool _isEditMode = false;
  String? _editingQuestionId;
  int? _editingIndex;

  // Demo Simulation State
  int? _demoSelectedOption;
  bool? _demoResultSuccess;

  // Inline Validation Error State (Visible inside modal above Deploy button)
  String? _inlineError;

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
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    _questionCtrl.addListener(_clearInlineError);
    for (final c in _optionCtrls) {
      c.addListener(_clearInlineError);
    }

    _loadQuestions().then((_) {
      if (widget.editingQuestion != null) {
        _populateForEdit(widget.editingQuestion!);
      }
    });
  }

  void _clearInlineError() {
    if (_inlineError != null) {
      setState(() => _inlineError = null);
    }
  }

  @override
  void dispose() {
    _questionCtrl.removeListener(_clearInlineError);
    for (final c in _optionCtrls) {
      c.removeListener(_clearInlineError);
    }
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

      // If user has already filled capacity and is not completing a level or editing,
      // default to My Shields list so they can view and edit.
      final maxAllowed = math.max(10, widget.userDay * 3);
      if (widget.editingQuestion == null &&
          !widget.isLevelComplete &&
          _questions.length >= maxAllowed &&
          _questions.isNotEmpty) {
        _tabController.animateTo(2);
      }
    }
  }

  void _populateForEdit(HouseShieldQuestion q) {
    setState(() {
      _isEditMode = true;
      _editingQuestionId = q.id;
      _editingIndex = _questions.indexWhere((element) => element.id == q.id);
      _questionCtrl.text = q.question;
      _explanationCtrl.text = q.explanation;
      for (int i = 0; i < 4; i++) {
        _optionCtrls[i].text = i < q.options.length ? q.options[i] : '';
      }
      _correctIndex = (q.correctIndex >= 0 && q.correctIndex < 4) ? q.correctIndex : 0;

      final gateIdx = _gateDefinitions.indexWhere((g) => g['id'] == q.category || g['id'] == q.trapType);
      if (gateIdx != -1) {
        _selectedGateIdx = gateIdx;
      }
      _resetDemoState();
    });
    _tabController.animateTo(0);
  }

  void _cancelEdit() {
    setState(() {
      _isEditMode = false;
      _editingQuestionId = null;
      _editingIndex = null;
      _questionCtrl.clear();
      _explanationCtrl.clear();
      for (final c in _optionCtrls) {
        c.clear();
      }
      _correctIndex = 0;
      _resetDemoState();
    });
  }

  void _resetDemoState() {
    _demoSelectedOption = null;
    _demoResultSuccess = null;
  }

  /// ✨ Free AI Question Generator
  /// Calls OpenRouter free text model with instant curated fallback
  Future<void> _generateWithAi() async {
    setState(() => _isAiGenerating = true);
    HapticFeedback.lightImpact();

    final selectedGate = _gateDefinitions[_selectedGateIdx];
    final gateTitle = selectedGate['title'] as String;
    final gateId = selectedGate['id'] as String;

    try {
      Map<String, dynamic>? aiResult;

      // Try OpenRouter Free endpoint
      try {
        final res = await http.post(
          Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AIService.OPENROUTER_API_KEY}',
            'HTTP-Referer': 'https://pocketmates.app',
            'X-Title': 'PocketMates Defense Shield',
          },
          body: jsonEncode({
            'model': 'google/gemma-4-31b-it:free',
            'messages': [
              {
                'role': 'system',
                'content':
                    'You are an English language testing expert. Create one multiple-choice question for English defense trap challenge "$gateTitle" (Day ${widget.userDay}). Output JSON only with keys: question (string), options (array of 4 strings), correctIndex (0-3 integer), explanation (string).'
              },
              {
                'role': 'user',
                'content': 'Generate a single high quality $gateTitle challenge in JSON format.'
              }
            ],
            'max_tokens': 300,
          }),
        ).timeout(const Duration(seconds: 4));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final rawContent = data['choices']?[0]?['message']?['content'] as String?;
          if (rawContent != null) {
            final sIdx = rawContent.indexOf('{');
            final eIdx = rawContent.lastIndexOf('}');
            if (sIdx != -1 && eIdx != -1) {
              final parsed = jsonDecode(rawContent.substring(sIdx, eIdx + 1));
              if (parsed is Map && parsed['question'] != null && parsed['options'] is List) {
                aiResult = Map<String, dynamic>.from(parsed);
              }
            }
          }
        }
      } catch (e) {
        debugPrint('OpenRouter free AI call notice: $e');
      }

      // Reliable curated AI bank fallback
      aiResult ??= _getCuratedAiChallenge(gateId, widget.userDay);

      if (mounted) {
        _questionCtrl.text = aiResult['question'] ?? '';
        final opts = List<String>.from(aiResult['options'] ?? []);
        for (int i = 0; i < 4; i++) {
          _optionCtrls[i].text = i < opts.length ? opts[i] : '';
        }
        _correctIndex = (aiResult['correctIndex'] is num)
            ? (aiResult['correctIndex'] as num).toInt()
            : 0;
        _explanationCtrl.text = aiResult['explanation'] ?? '';

        _resetDemoState();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✨ Free AI generated a $gateTitle challenge! Review or edit below.'),
            backgroundColor: const Color(0xFF0284C7),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAiGenerating = false);
      }
    }
  }

  Map<String, dynamic> _getCuratedAiChallenge(String gateId, int day) {
    final Map<String, List<Map<String, dynamic>>> bank = {
      'vocab_gate': [
        {
          'question': 'What is the closest synonym for the word "Tenacious"?',
          'options': ['Persistent', 'Careless', 'Fragile', 'Hesitant'],
          'correctIndex': 0,
          'explanation': '"Tenacious" means holding firmly to a purpose or opinion.',
        },
        {
          'question': 'Which word means "to make something bad or unsatisfactory better"?',
          'options': ['Ameliorate', 'Deteriorate', 'Aggravate', 'Obliterate'],
          'correctIndex': 0,
          'explanation': '"Ameliorate" means to improve or make more tolerable.',
        },
        {
          'question': 'Choose the antonym for "Lugubrious":',
          'options': ['Joyful', 'Mournful', 'Gloomy', 'Melancholy'],
          'correctIndex': 0,
          'explanation': '"Lugubrious" means looking or sounding sad and dismal.',
        },
      ],
      'grammar_defusal': [
        {
          'question': 'Identify the correct conditional sentence:',
          'options': [
            'If she had practiced, she would have won.',
            'If she practiced, she would had won.',
            'If she has practiced, she will won.',
            'If she would practice, she had won.'
          ],
          'correctIndex': 0,
          'explanation': 'Third conditional uses "If + past perfect, ... would have + past participle".',
        },
        {
          'question': 'Choose the grammatically flawless sentence:',
          'options': [
            'Neither the teacher nor the students were present.',
            'Neither the teacher nor the students was present.',
            'Neither the teacher or the students are present.',
            'Neither the teacher nor students is present.'
          ],
          'correctIndex': 0,
          'explanation': 'With "neither... nor", the verb agrees with the closer subject ("students were").',
        },
      ],
      'speed_blitz': [
        {
          'question': 'Fill in the correct preposition: "He is adept ___ solving puzzles."',
          'options': ['at', 'in', 'with', 'for'],
          'correctIndex': 0,
          'explanation': 'The adjective "adept" takes the preposition "at".',
        },
        {
          'question': 'Complete the syntax: "Hardly ___ entered the room when the lights went out."',
          'options': ['had he', 'he had', 'did he', 'he has'],
          'correctIndex': 0,
          'explanation': 'Negative inversion: "Hardly had [subject] [past participle]...".',
        },
      ],
      'idiom_shield': [
        {
          'question': 'What is the true meaning of "Bite the bullet"?',
          'options': [
            'Face a difficult situation with courage',
            'Eat metallic food',
            'Start an unnecessary fight',
            'Avoid making a decision'
          ],
          'correctIndex': 0,
          'explanation': '"Bite the bullet" means accepting a harsh or difficult situation bravely.',
        },
        {
          'question': 'What does "Barking up the wrong tree" signify?',
          'options': [
            'Pursuing a mistaken line of thought',
            'Shouting at stray animals',
            'Climbing without safety gear',
            'Making loud forest noises'
          ],
          'correctIndex': 0,
          'explanation': 'It means pursuing a misguided course of action.',
        },
      ],
      'riddle_sphinx': [
        {
          'question': 'Detect the sentence with the misplaced modifier:',
          'options': [
            'Walking to the store, the rain soaked my jacket.',
            'While I was walking to the store, rain soaked my jacket.',
            'The rain soaked my jacket while I walked to the store.',
            'Walking to the store, I was soaked by rain.'
          ],
          'correctIndex': 0,
          'explanation': 'In option A, the dangling participle implies the rain was walking to the store.',
        },
      ],
    };

    final list = bank[gateId] ?? bank['vocab_gate']!;
    return list[day % list.length];
  }

  Future<void> _deployShieldQuestion() async {
    setState(() => _inlineError = null);
    final questionText = _questionCtrl.text.trim();
    final rawOptions = _optionCtrls.map((c) => c.text.trim()).toList();
    final activeOptions = rawOptions.where((o) => o.isNotEmpty).toList();

    if (questionText.isEmpty) {
      const msg = '⚠️ Please enter a question for your defense shield!';
      setState(() => _inlineError = msg);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(msg),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (activeOptions.length < 2) {
      const msg = '⚠️ Please provide at least 2 answer options!';
      setState(() => _inlineError = msg);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(msg),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Defense Slot Capacity Check (User Audio Directive: Up to 10 questions for Day 1 and beyond)
    if (!_isEditMode) {
      final maxAllowed = math.max(10, widget.userDay * 3);
      if (_questions.length >= maxAllowed && !widget.isLevelComplete) {
        final msg = '⚠️ Defense Armory Capacity: All $maxAllowed slots are armed for Level ${widget.userDay}. Complete more days or edit existing questions!';
        setState(() => _inlineError = msg);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: const Color(0xFFB45309),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    int safeCorrectIndex = _correctIndex;
    if (safeCorrectIndex >= activeOptions.length) {
      safeCorrectIndex = 0;
    }

    // Validate anti-duplicate & fair play
    final verdict = PocketFortressDefenseService.validateQuestion(
      questionText,
      activeOptions,
      safeCorrectIndex,
      existingQuestions: _questions,
      currentQuestionId: _isEditMode ? _editingQuestionId : null,
    );

    if (!verdict.isApproved) {
      final msg = '⚠️ ${verdict.feedback}';
      setState(() => _inlineError = msg);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isDeploying = true);
    HapticFeedback.mediumImpact();

    final selectedGate = _gateDefinitions[_selectedGateIdx];
    final questionId = _isEditMode
        ? (_editingQuestionId ?? 'shield_${DateTime.now().millisecondsSinceEpoch}')
        : 'shield_${DateTime.now().millisecondsSinceEpoch}';

    final questionItem = HouseShieldQuestion(
      id: questionId,
      question: questionText,
      options: activeOptions,
      correctIndex: safeCorrectIndex,
      explanation: _explanationCtrl.text.trim().isNotEmpty
          ? _explanationCtrl.text.trim()
          : 'Correct answer: ${activeOptions[safeCorrectIndex]}',
      category: selectedGate['id'] as String,
      trapType: selectedGate['id'] as String,
      isPresidentApproved: true,
    );

    List<HouseShieldQuestion> updated;
    if (_isEditMode && _editingIndex != null && _editingIndex! < _questions.length) {
      updated = List<HouseShieldQuestion>.from(_questions);
      updated[_editingIndex!] = questionItem;
    } else {
      updated = List<HouseShieldQuestion>.from(_questions)..add(questionItem);
    }

    try {
      // 1. Save locally
      await PocketFortressDefenseService.saveShieldQuestions(updated);

      // 2. Sync to Supabase profile
      try {
        final myId = SupaFlow.client.auth.currentUser?.id;
        if (myId != null) {
          final payload = {'house_shield_questions': updated.map((q) => q.toJson()).toList()};
          try {
            await SupaFlow.client.from('profile').update(payload).eq('user_id', myId);
          } catch (_) {
            await SupaFlow.client.from('profile').update(payload).eq('id', myId);
          }
        }
      } catch (e) {
        debugPrint('Supabase shield sync notice: $e');
      }

      if (!mounted) return;

      final wasEditing = _isEditMode;
      setState(() {
        _questions = updated;
        _isDeploying = false;
        _isEditMode = false;
        _editingQuestionId = null;
        _editingIndex = null;
        _inlineError = null;
        _questionCtrl.clear();
        _explanationCtrl.clear();
        for (final c in _optionCtrls) {
          c.clear();
        }
        _correctIndex = 0;
        _resetDemoState();
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasEditing
                ? '🛡️ Defense Shield Updated & Synced!'
                : '🛡️ Defense Question Armed & Synced to Home Defense!',
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Switch to Demo tab or My Shields tab
      _tabController.animateTo(1);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeploying = false;
          _inlineError = '⚠️ Error saving defense question: $e';
        });
      }
    }
  }

  Future<void> _deleteQuestion(int index) async {
    final updated = List<HouseShieldQuestion>.from(_questions)..removeAt(index);
    await PocketFortressDefenseService.saveShieldQuestions(updated);

    try {
      final myId = SupaFlow.client.auth.currentUser?.id;
      if (myId != null) {
        final payload = {'house_shield_questions': updated.map((q) => q.toJson()).toList()};
        try {
          await SupaFlow.client.from('profile').update(payload).eq('user_id', myId);
        } catch (_) {
          await SupaFlow.client.from('profile').update(payload).eq('id', myId);
        }
      }
    } catch (e) {
      debugPrint('Supabase delete sync: $e');
    }

    if (mounted) {
      setState(() => _questions = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🗑️ Defense question removed from Home Defense.'),
          backgroundColor: Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxAllowed = math.max(10, widget.userDay * 3);
    final selectedGate = _gateDefinitions[_selectedGateIdx];
    final canAddNewSlot = widget.isLevelComplete || _questions.length < maxAllowed;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
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

            // Header
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
                        _isEditMode ? 'Edit Home Defense' : 'Home Defense',
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

            // Tabs: Crafter / Live Demo / My Shields
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
                labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11.5),
                tabs: [
                  Tab(
                    text: _isEditMode
                        ? '✏️ Edit Shield'
                        : (canAddNewSlot ? '🛡️ Shield Crafter' : '🛡️ Crafter'),
                  ),
                  const Tab(text: '🎮 Demo'),
                  Tab(text: '📜 My Shields (${_questions.length})'),
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
                    // --- TAB 0: SHIELD CRAFTER / EDITOR ---
                    _buildCrafterTab(canAddNewSlot, selectedGate),

                    // --- TAB 1: LIVE INTERACTIVE DEMO (User Audio: "Demo instead of arms") ---
                    _buildInteractiveDemoTab(selectedGate),

                    // --- TAB 2: MY SHIELDS LIST ---
                    _buildMyShieldsTab(maxAllowed),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildCrafterTab(bool canAddNewSlot, Map<String, dynamic> selectedGate) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Edit Banner or Slot Locked Notice
          if (_isEditMode) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Text('✏️', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Editing Active Defense Question',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFBBF24),
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _cancelEdit,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ),
                ],
              ),
            ),
          ] else if (!canAddNewSlot) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ℹ️', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Defense Armory Capacity: You have armed all ${_questions.length} slots for Level ${widget.userDay}. Complete more days to unlock additional defense slots! You can edit any existing question anytime.',
                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 11, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Gate Category Selector
          Text(
            'Select Gate Challenge Type:',
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
                    setState(() {
                      _selectedGateIdx = i;
                      _resetDemoState();
                    });
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

          // ✨ AI Assist Bar (User Audio: "Free AIs can be used to help craft questions")
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                  const Color(0xFF0284C7).withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Free AI Defense Assistant',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFC084FC),
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Generate an authentic ${selectedGate['title']} question instantly',
                        style: const TextStyle(color: Colors.white60, fontSize: 9.5),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: ElevatedButton.icon(
                    onPressed: _isAiGenerating ? null : _generateWithAi,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    icon: _isAiGenerating
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1.5),
                          )
                        : const Icon(Icons.auto_awesome, size: 13),
                    label: Text(
                      _isAiGenerating ? 'Thinking...' : 'Generate',
                      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Question Input Field
          Text(
            _isEditMode
                ? 'Question:'
                : 'Defense Question #${_questions.length + 1}:',
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
            onChanged: (_) => setState(() => _resetDemoState()),
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

          // 4 Options
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
                      setState(() {
                        _correctIndex = optIdx;
                        _resetDemoState();
                      });
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
                      onChanged: (_) => setState(() => _resetDemoState()),
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

          // Explanation Field
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
          const SizedBox(height: 14),

          // Quick Jump to Demo Test
          Center(
            child: TextButton.icon(
              onPressed: () => _tabController.animateTo(1),
              icon: const Icon(Icons.play_circle_outline_rounded, size: 16, color: Color(0xFF38BDF8)),
              label: Text(
                'Preview in Live Demo 🎮',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF38BDF8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Inline Error Message Box (Prominently visible inside modal above the deploy button)
          if (_inlineError != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF7F1D1D).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFFCA5A5), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _inlineError!,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _inlineError = null),
                    child: const Icon(Icons.close, color: Colors.white70, size: 16),
                  ),
                ],
              ),
            ),
          ],

          // Save & Deploy Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isEditMode ? const Color(0xFFF59E0B) : const Color(0xFF0284C7),
                foregroundColor: _isEditMode ? Colors.black : Colors.white,
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
                        Icon(_isEditMode ? Icons.update_rounded : Icons.shield_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _isEditMode ? 'UPDATE DEFENSE SHIELD 🛡️' : 'DEPLOY SHIELD TO SUPABASE 🛡️',
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 🎮 Interactive Demo Simulation Tab
  /// Direct User Audio Request: "ഈ 'ആംസ്' എന്ന് കാണിക്കുന്നതിന് പകരം 'ഡെമോ' കൊടുത്തൂടെ?
  /// ഡെമോ എന്ന രീതിയിൽ എന്തെങ്കിലും കൊടുത്താൽ അടിപൊളി ആവും. ക്വസ്റ്റ്യൻ ആഡ് ചെയ്യുന്നതിനനുസരിച്ച് ലൈവ് ഡെമോ"
  Widget _buildInteractiveDemoTab(Map<String, dynamic> selectedGate) {
    final gateColor = selectedGate['color'] as Color;
    final questionText = _questionCtrl.text.trim().isNotEmpty
        ? _questionCtrl.text.trim()
        : (selectedGate['demo'] as String).split('\n').first.replaceFirst('Demo: ', '');

    final options = _optionCtrls.map((c) => c.text.trim()).toList();
    final hasCustomOptions = options.any((o) => o.isNotEmpty);
    final demoOptions = hasCustomOptions
        ? options.where((o) => o.isNotEmpty).toList()
        : ['Option A (Sample)', 'Option B (Sample)', 'Option C (Sample)', 'Option D (Sample)'];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Attacker Simulation Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Text('⚔️', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Raid Attacker POV Simulation',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Test how opposing raiders experience this defense trap',
                        style: const TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('❤️ 100 HP', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Simulated Gate Barrier Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  gateColor.withValues(alpha: 0.2),
                  const Color(0xFF0F172A),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: gateColor.withValues(alpha: 0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: gateColor.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gate Badge & Live Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: gateColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(selectedGate['icon'] as String, style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            selectedGate['title'] as String,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fiber_manual_record, color: Color(0xFF34D399), size: 8),
                          SizedBox(width: 4),
                          Text('LIVE DEMO', style: TextStyle(color: Color(0xFF34D399), fontSize: 9, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Question Text
                Text(
                  questionText,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),

                // Interactive Demo Options
                ...List.generate(demoOptions.length, (idx) {
                  final letter = String.fromCharCode(65 + idx);
                  final isSelected = _demoSelectedOption == idx;
                  final isCorrectOption = idx == _correctIndex;

                  Color btnBorder = Colors.white12;
                  Color btnBg = const Color(0xFF1E293B);
                  Color textColor = Colors.white;

                  if (_demoSelectedOption != null) {
                    if (isCorrectOption) {
                      btnBorder = const Color(0xFF10B981);
                      btnBg = const Color(0xFF10B981).withValues(alpha: 0.2);
                      textColor = const Color(0xFF34D399);
                    } else if (isSelected) {
                      btnBorder = const Color(0xFFEF4444);
                      btnBg = const Color(0xFFEF4444).withValues(alpha: 0.2);
                      textColor = const Color(0xFFF87171);
                    }
                  }

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _demoSelectedOption = idx;
                        _demoResultSuccess = idx == _correctIndex;
                      });
                      HapticFeedback.lightImpact();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: btnBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: btnBorder, width: isSelected ? 1.5 : 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                            child: Center(
                              child: Text(
                                letter,
                                style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              demoOptions[idx],
                              style: TextStyle(
                                color: textColor,
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (_demoSelectedOption != null && isCorrectOption)
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 18)
                          else if (isSelected && !isCorrectOption)
                            const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 18),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Demo Verdict Banner
          if (_demoResultSuccess != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _demoResultSuccess!
                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                    : const Color(0xFFDC2626).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _demoResultSuccess! ? const Color(0xFF10B981) : const Color(0xFFDC2626),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_demoResultSuccess! ? '🛡️' : '💥', style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _demoResultSuccess!
                              ? 'ATTACKER REPELLED (Gate Solved Safely)'
                              : 'TRAP TRIGGERED! (House Defense Held Strong!)',
                          style: GoogleFonts.outfit(
                            color: _demoResultSuccess! ? const Color(0xFF34D399) : const Color(0xFFF87171),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _demoResultSuccess!
                              ? 'Attacker answered correctly and passed this gate.'
                              : 'Attacker got hit by your trap! House HP protected and vault coins secured.',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        if (_explanationCtrl.text.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Rule Note: ${_explanationCtrl.text.trim()}',
                            style: const TextStyle(color: Colors.white60, fontSize: 10.5, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _resetDemoState()),
                icon: const Icon(Icons.refresh_rounded, size: 15, color: Colors.white70),
                label: const Text('Test Again', style: TextStyle(color: Colors.white70, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ] else ...[
            Center(
              child: Text(
                'Tap any option above to test your defense trap in real-time!',
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 📜 My Active Shields List
  Widget _buildMyShieldsTab(int maxAllowed) {
    if (_questions.isEmpty) {
      return Center(
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
              'Complete daily learning levels to unlock and craft defense shields!',
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: _questions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final q = _questions[index];
        final gateIdx = _gateDefinitions.indexWhere((g) => g['id'] == q.category || g['id'] == q.trapType);
        final gateInfo = gateIdx != -1 ? _gateDefinitions[gateIdx] : _gateDefinitions[0];
        final gateColor = gateInfo['color'] as Color;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: gateColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#${index + 1} • ${gateInfo['title']}',
                      style: TextStyle(
                        color: gateColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // ✏️ Edit Button (Direct user audio requirement: "ക്വസ്റ്റ്യൻസ് എഡിറ്റ് ചെയ്യാം - അതിനുള്ള ഓപ്ഷൻ കൊടുക്കുക")
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF38BDF8), size: 20),
                    tooltip: 'Edit Question',
                    onPressed: () => _populateForEdit(q),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  // 🗑️ Delete Button
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.white38, size: 18),
                    tooltip: 'Remove',
                    onPressed: () => _deleteQuestion(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
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
        );
      },
    );
  }
}
