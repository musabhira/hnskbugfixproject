import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'english_tasks_master_hub.dart';
import 'flame_english_house_game.dart';
import 'pocket_fortress_defense_service.dart';

import 'pocket_defense_question_bank.dart';

/// 🛡️ Dedicated House Defense Shield Command Page (Days 1 to 16+)
/// Overhauled based on User Audio Directives:
/// - Minimal, crystal-clear UX without overlapping audio or verbose chat walls.
/// - Top section showcases House visual (HouseMasterPainter) + dynamic HP Shield bar (0/100 HP -> 100/100 HP).
/// - Dynamic question bank customized for each specific day (never repeats!).
class PocketHouseDefenseChatPage extends StatefulWidget {
  final int day;
  final String? userId;
  final Function(int)? onStepFinished;

  const PocketHouseDefenseChatPage({
    super.key,
    this.day = 1,
    this.userId,
    this.onStepFinished,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    String? userId,
    Function(int)? onStepFinished,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketHouseDefenseChatPage(
          day: day,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<PocketHouseDefenseChatPage> createState() =>
      _PocketHouseDefenseChatPageState();
}

class _PocketHouseDefenseChatPageState
    extends State<PocketHouseDefenseChatPage> with TickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  final FlutterTts _tts = FlutterTts();

  late AnimationController _pulseController;
  late AnimationController _shieldAnimController;
  late Animation<double> _shieldHpAnimation;

  bool _soundEnabled = true;
  bool _isShieldArmed = false;
  bool _isChoosingMode = false;
  int _shieldHp = 0; // 0 to 100

  List<HouseShieldQuestion> _activeQuestions = [];

  // Curated research-backed starter defense questions for Level 1 House
  static const List<HouseShieldQuestion> _defaultDay1Bank = [
    HouseShieldQuestion(
      id: 'h1_def_1',
      question: 'Good morning! What is your name?',
      options: ['My name is Alex.', 'I am sleeping.', 'Water is cold.', 'Goodbye.'],
      correctIndex: 0,
      explanation: 'Greeting defense: "My name is..." is the standard self-introduction.',
      category: 'spoken',
      trapType: 'vocab_gate',
    ),
    HouseShieldQuestion(
      id: 'h1_def_2',
      question: 'How are you feeling today?',
      options: ['I am fine, thank you.', 'The tree is tall.', 'My shoe is blue.', 'Tomorrow yesterday.'],
      correctIndex: 0,
      explanation: 'Spoken reply: "I am fine, thank you" is polite and natural.',
      category: 'spoken',
      trapType: 'vocab_gate',
    ),
    HouseShieldQuestion(
      id: 'h1_def_3',
      question: 'What are sweet green grapes?',
      options: ['A delicious fruit', 'A flying bird', 'A wooden table', 'A warm bed'],
      correctIndex: 0,
      explanation: 'Vocabulary shield: Grapes are sweet fruits that grow in bunches.',
      category: 'vocab',
      trapType: 'vocab_gate',
    ),
    HouseShieldQuestion(
      id: 'h1_def_4',
      question: 'Where was the friendly cat sleeping in today\'s story?',
      options: ['On the soft bed', 'In the river', 'On the car roof', 'Under the rock'],
      correctIndex: 0,
      explanation: 'Story detail: The cat was peacefully sleeping on the soft bed.',
      category: 'reading',
      trapType: 'vocab_gate',
    ),
    HouseShieldQuestion(
      id: 'h1_def_5',
      question: 'What transparent liquid do all humans need to drink?',
      options: ['Fresh water', 'Black ink', 'Cold glue', 'Red paint'],
      correctIndex: 0,
      explanation: 'Basic noun: Water is essential for all living beings.',
      category: 'vocab',
      trapType: 'vocab_gate',
    ),
    HouseShieldQuestion(
      id: 'h1_def_6',
      question: 'Which word means a place where we live with family?',
      options: ['House', 'Car', 'Pen', 'Cloud'],
      correctIndex: 0,
      explanation: 'House is the building where people live.',
      category: 'vocab',
      trapType: 'vocab_gate',
    ),
    HouseShieldQuestion(
      id: 'h1_def_7',
      question: 'What is the clever black bird from our story called?',
      options: ['Crow', 'Fish', 'Elephant', 'Horse'],
      correctIndex: 0,
      explanation: 'Crow is the clever black bird in Day 1 story.',
      category: 'vocab',
      trapType: 'vocab_gate',
    ),
    HouseShieldQuestion(
      id: 'h1_def_8',
      question: 'Complete the sentence: "I ___ happy to learn English today."',
      options: ['am', 'is', 'are', 'were'],
      correctIndex: 0,
      explanation: 'Grammar shield: First person singular "I" takes "am".',
      category: 'grammar',
      trapType: 'syntax_wall',
    ),
    HouseShieldQuestion(
      id: 'h1_def_9',
      question: 'What do you say when someone helps you?',
      options: ['Thank you very much!', 'Go away!', 'I am sleeping.', 'No idea.'],
      correctIndex: 0,
      explanation: 'Courtesy defense: "Thank you" shows gratitude.',
      category: 'spoken',
      trapType: 'vocab_gate',
    ),
    HouseShieldQuestion(
      id: 'h1_def_10',
      question: 'How do you ask for permission to enter a room?',
      options: ['May I come in, please?', 'I will come now.', 'Open door fast!', 'Door is here.'],
      correctIndex: 0,
      explanation: 'Polite permission shield: "May I come in, please?" is standard polite English.',
      category: 'spoken',
      trapType: 'vocab_gate',
    ),
  ];

  late final List<HouseShieldQuestion> _curatedBank;

  List<HouseShieldQuestion> _buildQuestionsForDay(int day) {
    if (day == 1) return _defaultDay1Bank;
    final list = <HouseShieldQuestion>[];
    final gates = ['vocab_gate', 'grammar_defusal', 'speed_blitz', 'idiom_shield', 'riddle_sphinx'];
    final count = math.max(10, day + 5);
    for (int i = 0; i < count; i++) {
      final gate = gates[i % gates.length];
      list.add(PocketDefenseQuestionBank.getRandomHouseShieldQuestion(
        gate,
        day: day,
        idPrefix: 'h${day}_def_${i + 1}',
      ));
    }
    return list;
  }

  @override
  void initState() {
    super.initState();

    _curatedBank = _buildQuestionsForDay(widget.day);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _shieldAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _shieldHpAnimation = Tween<double>(begin: 0.0, end: 100.0).animate(
      CurvedAnimation(parent: _shieldAnimController, curve: Curves.easeOutBack),
    )..addListener(() {
        setState(() {
          _shieldHp = _shieldHpAnimation.value.toInt();
        });
      });

    _initAudioAndTts();
    _checkExistingDefense();
  }

  /// 🛡️ User Audio Directive: Each day completed adds 1 defense!
  /// Day 1 has 1 defense, Day 10 has 10 defenses, Day 90 has 90 defenses!
  int get targetShieldCount => widget.day.clamp(1, 90);

  Future<void> _checkExistingDefense() async {
    final prefs = await SharedPreferences.getInstance();
    final isActive = prefs.getBool('pocket_house_${widget.day}_defense_active') ?? false;
    if (isActive) {
      setState(() {
        _isShieldArmed = true;
        _shieldHp = 100;
        _activeQuestions = _curatedBank.take(targetShieldCount).toList();
      });
    } else {
      // Speak brief initial prompt
      _speak(
        "Protect House ${widget.day}! Add defense questions so rival learners cannot loot your points.",
      );
    }
  }

  Future<void> _initAudioAndTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.44);
      await _tts.setPitch(1.05);
      _tts.setCompletionHandler(() {});
      _tts.setErrorHandler((_) {});
    } catch (e) {
      debugPrint('TTS setup error: $e');
    }

    try {
      PocketGameAudioService.instance.playAmbientAppTheme();
      PocketGameAudioService.instance.setVolume(0.16);
    } catch (_) {}
  }

  Future<void> _speak(String text) async {
    if (!_soundEnabled || text.isEmpty) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> _handleAutoEquip() async {
    HapticFeedback.heavyImpact();
    await _tts.stop();

    final questions = _curatedBank.take(targetShieldCount).toList();
    setState(() {
      _activeQuestions = questions;
      _isChoosingMode = false;
      _isShieldArmed = true;
    });

    _shieldAnimController.forward(from: 0.0);
    await _saveDefenseQuestions(questions);

    _speak(
      "Excellent choice! House number ${widget.day} defense shield is fully activated with $targetShieldCount defense ${targetShieldCount == 1 ? 'question' : 'questions'}. Shield health is 100 percent.",
    );
  }

  void _handleManualMode() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isChoosingMode = false;
    });
    _showManualPickerBottomSheet();
  }

  Future<void> _saveDefenseQuestions(List<HouseShieldQuestion> questions) async {
    try {
      final uid = widget.userId ?? _supabase.auth.currentUser?.id;
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('pocket_house_${widget.day}_defense_active', true);
      await prefs.setInt('pocket_house_${widget.day}_hp', 100);
      if (uid != null) {
        await prefs.setBool('pocket_day_${uid}_${widget.day}_step_7_done', true);
      }

      await PocketFortressDefenseService.saveShieldQuestions(questions);
      await PocketFortressDefenseService.recordTrainingPoints(50, uid);
    } catch (e) {
      debugPrint('Error saving house defense: $e');
    }
  }

  Future<void> _completeAndExit() async {
    HapticFeedback.heavyImpact();
    await _tts.stop();
    widget.onStepFinished?.call(7);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shieldAnimController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(),

            // Main Content Area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    // 1. House 1 Visual Card + Shield Status
                    _buildHouseAndShieldCard(),

                    const SizedBox(height: 18),

                    // 2. CyberCat Minimal Prompt
                    _buildCyberCatPrompt(),

                    const SizedBox(height: 20),

                    // 3. Selection or Action Cards
                    if (!_isShieldArmed && _isChoosingMode)
                      _buildChoiceOptions()
                    else if (!_isShieldArmed)
                      _buildInitialAddButton()
                    else
                      _buildArmedActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF10B981).withValues(alpha: 0.25),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              _tts.stop();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 4),

          // CyberCat badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF047857)],
              ),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
            ),
            child: const Center(
              child: Text('🐱', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 10),

          // Titles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Step 7: House ${widget.day} Defense Shield',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                  ),
                ),
                Text(
                  _isShieldArmed ? '🛡️ Shield 100% Active • Protected' : 'Equip English Defense Shield',
                  style: GoogleFonts.inter(
                    color: _isShieldArmed ? const Color(0xFF34D399) : const Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Sound Toggle
          IconButton(
            onPressed: () {
              setState(() => _soundEnabled = !_soundEnabled);
              if (!_soundEnabled) _tts.stop();
            },
            icon: Icon(
              _soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: _soundEnabled ? const Color(0xFF10B981) : Colors.white38,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  /// 🏡 House Visual Widget with Dynamic Shield Barrier and HP Gauge
  Widget _buildHouseAndShieldCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131C2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isShieldArmed
              ? const Color(0xFF10B981).withValues(alpha: 0.6)
              : const Color(0xFFF59E0B).withValues(alpha: 0.4),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isShieldArmed ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
                .withValues(alpha: 0.15),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  '🏡 HOUSE #${widget.day}: CITADEL',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _isShieldArmed
                      ? const Color(0xFF064E3B)
                      : const Color(0xFF7F1D1D),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isShieldArmed
                        ? const Color(0xFF34D399)
                        : const Color(0xFFF87171),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isShieldArmed ? Icons.shield_rounded : Icons.shield_outlined,
                      color: _isShieldArmed ? const Color(0xFF34D399) : const Color(0xFFF87171),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isShieldArmed ? '100% PROTECTED' : 'VULNERABLE ⚠️',
                      style: GoogleFonts.outfit(
                        color: _isShieldArmed ? const Color(0xFF34D399) : const Color(0xFFF87171),
                        fontWeight: FontWeight.bold,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // House Canvas Master Painter with glowing shield
          Stack(
            alignment: Alignment.center,
            children: [
              // House Rendering
              SizedBox(
                width: 200,
                height: 130,
                child: CustomPaint(
                  size: const Size(200, 130),
                  painter: HouseMasterPainter(
                    day: widget.day,
                    palette: HousePalette.presets[(widget.day - 1) % HousePalette.presets.length],
                    isPresident: false,
                    lightsOn: true,
                  ),
                ),
              ),

              // Animated Shield Overlay when active
              if (_isShieldArmed)
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    return Container(
                      width: 220,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(
                            alpha: 0.4 + (_pulseController.value * 0.4),
                          ),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(
                              alpha: 0.2 + (_pulseController.value * 0.2),
                            ),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),

          const SizedBox(height: 14),

          // HP Shield Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DEFENSE SHIELD INTEGRITY',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '$_shieldHp / 100 HP 🛡️',
                    style: GoogleFonts.outfit(
                      color: _isShieldArmed ? const Color(0xFF34D399) : const Color(0xFFF59E0B),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _shieldHp / 100.0,
                  minHeight: 10,
                  backgroundColor: const Color(0xFF0F172A),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isShieldArmed ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🐱 Single Clean CyberCat Prompt Bubble
  Widget _buildCyberCatPrompt() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111C2B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CyberCat Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
            ),
            child: const Center(child: Text('🐱', style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),

          // Message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CyberCat',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (_isShieldArmed) {
                          _speak(
                            "House number ${widget.day} defense shield is fully activated! Shield health is 100 percent. Your house is completely protected.",
                          );
                        } else {
                          _speak(
                            "Protect House ${widget.day}! Add defense questions so rival learners cannot loot your points.",
                          );
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Icon(Icons.volume_up_rounded, color: Color(0xFF10B981), size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _isShieldArmed
                      ? "🎉 House #${widget.day} Defense Shield is fully activated! 100/100 HP. Your house is completely protected from rival raids."
                      : "Protect House #${widget.day}! Other learners and citadels will attack to loot points. Add your English defense questions as a protective shield!",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isShieldArmed
                      ? "🎉 ഹൗസ് ${widget.day} ഡിഫൻസ് ഷീൽഡ് 100% സജ്ജമായി! വീട് പൂർണ്ണമായും സുരക്ഷിതമാണ്."
                      : "നമ്മുടെ വീട് മറ്റ് കൂട്ടുകാർ അറ്റാക്ക് ചെയ്ത് പോയിന്റ് കവരാതിരിക്കാൻ ഇംഗ്ലീഷ് ഡിഫൻസ് ഷീൽഡ് സജ്ജമാക്കുക!",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF93C5FD),
                    fontSize: 11.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🛡️ Step A: Initial Single Big Action Button
  Widget _buildInitialAddButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
            ),
            onPressed: () {
              HapticFeedback.heavyImpact();
              setState(() => _isChoosingMode = true);
            },
            icon: const Icon(Icons.shield_rounded, size: 24),
            label: Text(
              '🛡️ ADD DEFENSE SHIELD',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 🛡️ Step B: 2 Clean Options (AI vs Manual)
  Widget _buildChoiceOptions() {
    return Column(
      children: [
        // Option 1: AI Auto-Equip (5 questions, curated bank)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF064E3B), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF10B981), width: 1.6),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _handleAutoEquip,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.auto_awesome_rounded, color: Colors.black, size: 24),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '✨ Auto-Add with AI',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'POPULAR',
                                  style: GoogleFonts.outfit(
                                    color: Colors.black,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Instantly arms $targetShieldCount high-yield Spoken English ${targetShieldCount == 1 ? 'question' : 'questions'} (100 HP Shield).',
                            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF10B981), size: 16),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Option 2: Manual Pick
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF131D2D),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24, width: 1.0),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _handleManualMode,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2937),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.edit_note_rounded, color: Colors.white70, size: 24),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✍️ Add Manually',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Inspect and pick questions from our Spoken English database.',
                            style: GoogleFonts.inter(color: Colors.white60, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 🛡️ Step C: Actions when Armed ([View & Test] + [Complete & Continue])
  Widget _buildArmedActions() {
    return Column(
      children: [
        // Button 1: View & Test Defense Questions
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFFD700),
              side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _showViewAndTestDefenseBottomSheet,
            icon: const Icon(Icons.remove_red_eye_rounded, size: 20),
            label: Text(
              '👁️ VIEW & TEST DEFENSE (RIVALS VIEW)',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Button 2: Complete Step 7 & Continue
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
            ),
            onPressed: _completeAndExit,
            icon: const Icon(Icons.check_circle_rounded, size: 24),
            label: Text(
              'COMPLETE STEP 7 & CONTINUE ➔',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 👁️ Bottom Sheet: Shows the 5 equipped defense questions and provides a "Test Defense" simulator
  void _showViewAndTestDefenseBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.82,
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFF10B981), width: 2.0)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'House ${widget.day} Defense Shield ($targetShieldCount ${targetShieldCount == 1 ? 'Question' : 'Questions'})',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rivals must solve these to loot points from your house!',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF93C5FD),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white12, height: 1),

              // Question List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(18),
                  itemCount: _activeQuestions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final q = _activeQuestions[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131D2D),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'QUESTION #${i + 1} • SHIELD #${i + 1}',
                                  style: GoogleFonts.outfit(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const Text('🛡️ SHIELD ACTIVE', style: TextStyle(color: Color(0xFF34D399), fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            q.question,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Options with correct answer highlighted
                          ...q.options.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final opt = entry.value;
                            final isCorrect = idx == q.correctIndex;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 5),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isCorrect
                                    ? const Color(0xFF10B981).withValues(alpha: 0.18)
                                    : const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isCorrect
                                      ? const Color(0xFF10B981)
                                      : Colors.white10,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isCorrect ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                    color: isCorrect ? const Color(0xFF34D399) : Colors.white38,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      opt,
                                      style: GoogleFonts.inter(
                                        color: isCorrect ? const Color(0xFF6EE7B7) : Colors.white70,
                                        fontSize: 12,
                                        fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Attack Simulator button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _startRivalSimulatorDialog();
                    },
                    icon: const Icon(Icons.sports_kabaddi_rounded, size: 20),
                    label: Text(
                      'TEST HOW RIVALS EXPERIENCE THIS ATTACK ⚔️',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ⚔️ Rival Simulator: lets the user test answering their own defense questions
  void _startRivalSimulatorDialog() {
    int currentIdx = 0;
    int correctCount = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dlgCtx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            final isDone = currentIdx >= _activeQuestions.length;
            if (isDone) {
              return AlertDialog(
                backgroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Text(
                  '⚔️ Rival Attack Simulated!',
                  style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontWeight: FontWeight.bold),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Rival answered $correctCount of ${_activeQuestions.length} defense questions correctly.',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      correctCount == _activeQuestions.length
                          ? '⚠️ Perfect score would breach shield! Great questions.'
                          : '🛡️ DEFENSE SUCCESSFUL! Your House repels the attacker and guards your points!',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF34D399),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                    onPressed: () => Navigator.pop(dlgCtx),
                    child: const Text('DONE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ],
              );
            }

            final q = _activeQuestions[currentIdx];
            return AlertDialog(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Text('⚔️ ', style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: Text(
                      'Rival Challenge ${currentIdx + 1}/${_activeQuestions.length}',
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    q.question,
                    style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  ...q.options.asMap().entries.map((entry) {
                    final optIdx = entry.key;
                    final opt = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          onPressed: () {
                            if (optIdx == q.correctIndex) {
                              correctCount++;
                            }
                            setDlgState(() {
                              currentIdx++;
                            });
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              opt,
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// ✍️ Manual Question Picker Bottom Sheet
  void _showManualPickerBottomSheet() {
    final selectedIds = <String>{};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(ctx).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: Color(0xFF10B981), width: 2.0)),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 8),
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose $targetShieldCount Defense ${targetShieldCount == 1 ? 'Question' : 'Questions'}',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Selected: ${selectedIds.length} / $targetShieldCount',
                              style: GoogleFonts.inter(
                                color: selectedIds.length == targetShieldCount
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFFFFD700),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Colors.white12, height: 1),

                  // Question list
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _curatedBank.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final q = _curatedBank[i];
                        final isSel = selectedIds.contains(q.id);
                        return InkWell(
                          onTap: () {
                            setSheetState(() {
                              if (isSel) {
                                selectedIds.remove(q.id);
                              } else {
                                if (selectedIds.length < targetShieldCount) {
                                  selectedIds.add(q.id);
                                }
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                  : const Color(0xFF131D2D),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel ? const Color(0xFF10B981) : Colors.white12,
                                width: isSel ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSel ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                  color: isSel ? const Color(0xFF10B981) : Colors.white38,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
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
                                      Text(
                                        'Answer: ${q.options[q.correctIndex]}',
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF93C5FD),
                                          fontSize: 11,
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
                    ),
                  ),

                  // Confirm button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedIds.length == targetShieldCount
                              ? const Color(0xFF10B981)
                              : Colors.white24,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: selectedIds.length == targetShieldCount
                            ? () async {
                                final chosen = _curatedBank
                                    .where((q) => selectedIds.contains(q.id))
                                    .toList();
                                Navigator.pop(ctx);
                                setState(() {
                                  _activeQuestions = chosen;
                                  _isShieldArmed = true;
                                });
                                _shieldAnimController.forward(from: 0.0);
                                await _saveDefenseQuestions(chosen);
                                _speak("Manual defense shield equipped! Shield health 100 percent.");
                              }
                            : null,
                        icon: const Icon(Icons.shield_rounded, size: 20),
                        label: Text(
                          selectedIds.length == 5
                              ? 'EQUIP 5 SELECTED QUESTIONS 🛡️'
                              : 'SELECT ${5 - selectedIds.length} MORE QUESTIONS',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
