import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'pocket_fortress_defense_service.dart';

/// 🎮 Interactive Teacher-Guided Game Modal
/// Replaces dry text-based theory with a 1-on-1 personalized teacher experience:
/// - Interactive voice/dialogue turns
/// - Lego-style sentence building
/// - Scrambled block puzzles
/// - Bilingual helper hints (English + Malayalam)
/// - Rewarding celebrations and Pocket Score marks
class PocketInteractiveTeacherGameModal extends StatefulWidget {
  final int day;
  final String? userId;
  final VoidCallback onCompleted;

  const PocketInteractiveTeacherGameModal({
    super.key,
    required this.day,
    this.userId,
    required this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    required int day,
    String? userId,
    required VoidCallback onCompleted,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      builder: (_) => PocketInteractiveTeacherGameModal(
        day: day,
        userId: userId,
        onCompleted: onCompleted,
      ),
    );
  }

  @override
  State<PocketInteractiveTeacherGameModal> createState() =>
      _PocketInteractiveTeacherGameModalState();
}

class _PocketInteractiveTeacherGameModalState
    extends State<PocketInteractiveTeacherGameModal>
    with SingleTickerProviderStateMixin {
  late final FlutterTts _tts;
  bool _isSpeaking = false;
  bool _showMalayalam = true;

  // Game Stage Index:
  // 0 = Intro & Welcome
  // 1 = Subject Block
  // 2 = Verb Block
  // 3 = Object Block
  // 4 = Sentence Assembly
  // 5 = Scramble Challenge
  // 6 = Victory & Score Award
  int _currentStage = 0;

  // Selections for the builder
  String? _selectedSubject;
  String? _selectedVerb;
  String? _selectedObject;

  // Scramble puzzle state
  late List<String> _scrambleAvailable;
  final List<String> _scrambleSelected = [];
  bool _scrambleError = false;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _initTts();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _resetScramble();
    _playIntroSpeech();
  }

  void _resetScramble() {
    _scrambleAvailable = ['speaks', 'She', 'English']..shuffle();
    _scrambleSelected.clear();
    _scrambleError = false;
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.48);
      await _tts.setPitch(1.05);
      _tts.setStartHandler(() {
        if (mounted) setState(() => _isSpeaking = true);
      });
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isSpeaking = false);
      });
      _tts.setErrorHandler((_) {
        if (mounted) setState(() => _isSpeaking = false);
      });
    } catch (_) {}
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void _playIntroSpeech() {
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _speak(
          "Hello my friend! I am your English Guide. Today, let's build your very first English sentences like Lego blocks! Are you ready?",
        );
      }
    });
  }

  @override
  void dispose() {
    _tts.stop();
    _pulseController.dispose();
    super.dispose();
  }

  void _onNextStage() {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentStage++;
    });

    switch (_currentStage) {
      case 1:
        _speak("Every English sentence begins with someone doing the action: the Subject. Choose who is speaking!");
        break;
      case 2:
        _speak("Super! Now choose what action we are doing. Pick the Verb!");
        break;
      case 3:
        _speak("Awesome! Now what are we learning? Pick the Object!");
        break;
      case 4:
        _speak("Amazing! Look how your blocks connect together: I learn English!");
        break;
      case 5:
        _speak("Challenge time! Can you put these blocks in the right order: She speaks English?");
        break;
      case 6:
        _speak("Congratulations! You mastered sentence structure! You are ready to climb!");
        _awardPoints();
        break;
    }
  }

  Future<void> _awardPoints() async {
    final uid = widget.userId;
    try {
      await PocketFortressDefenseService.recordTrainingPoints(30, uid);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final maxH = screenH * 0.92;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 32,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle & top bar
          _buildTopBar(),

          // Main game content area
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  // Friendly Teacher Avatar with speech bubble
                  _buildTeacherSection(),

                  const SizedBox(height: 20),

                  // Interactive Stage Canvas
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: _buildCurrentStageView(),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Navigation Bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 10, left: 20, right: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.school_rounded, color: Colors.white, size: 14),
                const SizedBox(width: 5),
                Text(
                  'DAY ${widget.day} • STEP 1 GAME',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Malayalam Helper toggle
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _showMalayalam = !_showMalayalam);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: _showMalayalam
                    ? const Color(0xFF10B981).withOpacity(0.18)
                    : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _showMalayalam
                      ? const Color(0xFF10B981)
                      : const Color(0xFF334155),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'മലയാളം',
                    style: GoogleFonts.notoSansMalayalam(
                      color: _showMalayalam
                          ? const Color(0xFF34D399)
                          : const Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _showMalayalam
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    size: 13,
                    color: _showMalayalam
                        ? const Color(0xFF34D399)
                        : const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.6),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated Teacher Avatar
          AnimatedBuilder(
            animation: _pulseController,
            builder: (ctx, child) {
              final scale = 1.0 + (_pulseController.value * 0.04);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _isSpeaking
                            ? const Color(0xFF38BDF8).withOpacity(0.6)
                            : const Color(0xFFF59E0B).withOpacity(0.35),
                        blurRadius: _isSpeaking ? 20 : 12,
                        spreadRadius: _isSpeaking ? 4 : 1,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: VectorAvatarWidget(
                      config: const VectorAvatarConfig(
                        species: 'human',
                        gender: 'female',
                        outfitStyle: 'blazer',
                        accessory: 'round_glasses',
                        auraStyle: 'electric_blue',
                      ),
                      size: 70,
                      showAura: true,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 14),

          // Speech Bubble
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Teacher Maya',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF38BDF8),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (_isSpeaking)
                      Row(
                        children: List.generate(
                          3,
                          (i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            width: 3,
                            height: 10 + (i * 4).toDouble(),
                            decoration: BoxDecoration(
                              color: const Color(0xFF38BDF8),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    const Spacer(),
                    // Replay voice button
                    GestureDetector(
                      onTap: () => _speak(_getTeacherPromptText()),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.volume_up_rounded,
                          size: 16,
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _getTeacherPromptText(),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_showMalayalam && _getMalayalamPromptText().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    _getMalayalamPromptText(),
                    style: GoogleFonts.notoSansMalayalam(
                      color: const Color(0xFF94A3B8),
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTeacherPromptText() {
    switch (_currentStage) {
      case 0:
        return "Hello my friend! 👋 Welcome to Day ${widget.day}! Today we're learning how English sentences are built—just like playing with Lego blocks! Are you ready?";
      case 1:
        return "Step 1: Every English sentence begins with someone doing the action (The Subject). Choose who is speaking:";
      case 2:
        return "Step 2: Great! Now what action are we doing? Pick the Verb:";
      case 3:
        return "Step 3: Super! Now what are we learning? Pick the Object:";
      case 4:
        return "Look at your sentence come alive! Connect the 3 blocks together:";
      case 5:
        return "Game Challenge! 🧩 Put the blocks in the correct order to say: 'She speaks English'!";
      case 6:
        return "Fantastic! 🎉 You've mastered English sentence structure without any confusing theory! Keep climbing!";
      default:
        return "";
    }
  }

  String _getMalayalamPromptText() {
    switch (_currentStage) {
      case 0:
        return "ഇംഗ്ലീഷ് വാക്യങ്ങൾ ലെഗോ ബ്ലോക്ക് പോലെ ലളിതമായി ഉണ്ടാക്കാൻ നമുക്ക് ഒരുമിച്ച് പഠിക്കാം!";
      case 1:
        return "ആരാണ് ഇവിടെ പ്രവർത്തി ചെയ്യുന്നത് (Subject)? ഒരാളെ തിരഞ്ഞെടുക്കുക:";
      case 2:
        return "അടുത്തത് പ്രവൃത്തി (Verb) ആണ്. എന്ത് കാര്യമാണ് ചെയ്യുന്നത് എന്ന് തിരഞ്ഞെടുക്കുക:";
      case 3:
        return "എന്തിനെക്കുറിച്ചാണ് പഠിക്കുന്നത് (Object)? അത് തിരഞ്ഞെടുക്കുക:";
      case 4:
        return "ഇതാ നിങ്ങളുടെ ആദ്യ വാക്യം പൂർത്തിയായി! S + V + O ഫോർമുല ഓർക്കുക.";
      case 5:
        return "വാക്കുകൾ ശരിയായ ക്രമത്തിൽ തൊട്ട് ക്രമീകരിക്കുക:";
      case 6:
        return "നിങ്ങൾ വിജയകരമായി ഒന്നാമത്തെ സ്റ്റെപ്പ് പൂർത്തിയാക്കി! +30 പോക്കറ്റ് സ്കോർ ലഭിച്ചു!";
      default:
        return "";
    }
  }

  Widget _buildCurrentStageView() {
    switch (_currentStage) {
      case 0:
        return _buildStage0Welcome();
      case 1:
        return _buildStage1Subject();
      case 2:
        return _buildStage2Verb();
      case 3:
        return _buildStage3Object();
      case 4:
        return _buildStage4Assembly();
      case 5:
        return _buildStage5Scramble();
      case 6:
        return _buildStage6Victory();
      default:
        return const SizedBox.shrink();
    }
  }

  // --- STAGE 0: WELCOME & THE FORMULA ---
  Widget _buildStage0Welcome() {
    return Column(
      key: const ValueKey('stage0'),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(
                'The Golden English Formula',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF38BDF8),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFormulaPill('SUBJECT', 'Who?', const Color(0xFF3B82F6)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text('+', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  _buildFormulaPill('VERB', 'Action', const Color(0xFF10B981)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text('+', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  _buildFormulaPill('OBJECT', 'What?', const Color(0xFFF59E0B)),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Unlike Malayalam (SOV), English always uses SVO!\nSubject + Verb + Object',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFFCBD5E1),
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormulaPill(String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- STAGE 1: SUBJECT PICKER ---
  Widget _buildStage1Subject() {
    final options = [
      {'word': 'I', 'mal': 'ഞാൻ', 'sub': '1st Person'},
      {'word': 'She', 'mal': 'അവൾ', 'sub': '3rd Person (Singular)'},
      {'word': 'They', 'mal': 'അവർ', 'sub': '3rd Person (Plural)'},
    ];

    return Column(
      key: const ValueKey('stage1'),
      children: options.map((opt) {
        final isSelected = _selectedSubject == opt['word'];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildOptionCard(
            title: opt['word']!,
            subtitle: opt['sub']!,
            malayalam: opt['mal']!,
            color: const Color(0xFF3B82F6),
            isSelected: isSelected,
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedSubject = opt['word']);
              _speak(opt['word']!);
            },
          ),
        );
      }).toList(),
    );
  }

  // --- STAGE 2: VERB PICKER ---
  Widget _buildStage2Verb() {
    final options = [
      {'word': 'learn', 'mal': 'പഠിക്കുന്നു', 'sub': 'Mental Action'},
      {'word': 'speak', 'mal': 'സംസാരിക്കുന്നു', 'sub': 'Communication Action'},
      {'word': 'play', 'mal': 'കളിക്കുന്നു', 'sub': 'Physical Action'},
    ];

    return Column(
      key: const ValueKey('stage2'),
      children: options.map((opt) {
        final isSelected = _selectedVerb == opt['word'];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildOptionCard(
            title: opt['word']!,
            subtitle: opt['sub']!,
            malayalam: opt['mal']!,
            color: const Color(0xFF10B981),
            isSelected: isSelected,
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedVerb = opt['word']);
              _speak(opt['word']!);
            },
          ),
        );
      }).toList(),
    );
  }

  // --- STAGE 3: OBJECT PICKER ---
  Widget _buildStage3Object() {
    final options = [
      {'word': 'English 🇬🇧', 'raw': 'English', 'mal': 'ഇംഗ്ലീഷ് ഭാഷ', 'sub': 'Language'},
      {'word': 'Cricket 🏏', 'raw': 'Cricket', 'mal': 'ക്രിക്കറ്റ്', 'sub': 'Game'},
      {'word': 'Music 🎵', 'raw': 'Music', 'mal': 'സംഗീതം', 'sub': 'Art'},
    ];

    return Column(
      key: const ValueKey('stage3'),
      children: options.map((opt) {
        final isSelected = _selectedObject == opt['raw'];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildOptionCard(
            title: opt['word']!,
            subtitle: opt['sub']!,
            malayalam: opt['mal']!,
            color: const Color(0xFFF59E0B),
            isSelected: isSelected,
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedObject = opt['raw']);
              _speak(opt['raw']!);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required String malayalam,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : const Color(0xFF334155),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected ? color : const Color(0xFF0F172A),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? Icons.check_rounded : Icons.add_rounded,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (_showMalayalam)
              Text(
                malayalam,
                style: GoogleFonts.notoSansMalayalam(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- STAGE 4: SENTENCE ASSEMBLY ---
  Widget _buildStage4Assembly() {
    final sub = _selectedSubject ?? 'I';
    final verb = _selectedVerb ?? 'learn';
    final obj = _selectedObject ?? 'English';
    final sentence = '$sub $verb $obj.';

    return Column(
      key: const ValueKey('stage4'),
      children: [
        // The Connected Lego Blocks
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF10B981), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.2),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildLegoTile(sub, const Color(0xFF3B82F6), 'Subject'),
                  _buildLegoTile(verb, const Color(0xFF10B981), 'Verb'),
                  _buildLegoTile(obj, const Color(0xFFF59E0B), 'Object'),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '"$sentence"',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF10B981)),
                      onPressed: () => _speak(sentence),
                    ),
                  ],
                ),
              ),
              if (_showMalayalam) ...[
                const SizedBox(height: 10),
                Text(
                  'മലയാളം: "ഞാൻ ഇംഗ്ലീഷ് പഠിക്കുന്നു!"',
                  style: GoogleFonts.notoSansMalayalam(
                    color: const Color(0xFF34D399),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegoTile(String text, Color color, String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            text,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            role,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.85),
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- STAGE 5: SCRAMBLE PUZZLE ---
  Widget _buildStage5Scramble() {
    const targetOrder = ['She', 'speaks', 'English'];

    return Column(
      key: const ValueKey('stage5'),
      children: [
        // Target prompt
        Text(
          'Target Sentence:',
          style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          '"She speaks English"',
          style: GoogleFonts.outfit(
            color: const Color(0xFF38BDF8),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (_showMalayalam)
          Text(
            'അവൾ ഇംഗ്ലീഷ് സംസാരിക്കുന്നു',
            style: GoogleFonts.notoSansMalayalam(
              color: const Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
        const SizedBox(height: 20),

        // Selected Slot Area
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _scrambleError
                ? const Color(0xFFEF4444).withOpacity(0.15)
                : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _scrambleError ? const Color(0xFFEF4444) : const Color(0xFF334155),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _scrambleSelected.isEmpty
                ? [
                    Text(
                      'Tap blocks below in order...',
                      style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13),
                    ),
                  ]
                : _scrambleSelected.map((word) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        word,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
          ),
        ),

        const SizedBox(height: 20),

        // Available blocks
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: _scrambleAvailable.map((word) {
            final isPicked = _scrambleSelected.contains(word);
            return GestureDetector(
              onTap: isPicked
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _scrambleSelected.add(word);
                        _scrambleError = false;
                      });
                      _speak(word);

                      if (_scrambleSelected.length == targetOrder.length) {
                        // Check match
                        bool correct = true;
                        for (int i = 0; i < targetOrder.length; i++) {
                          if (_scrambleSelected[i] != targetOrder[i]) {
                            correct = false;
                            break;
                          }
                        }
                        if (correct) {
                          HapticFeedback.heavyImpact();
                          _speak("Perfect! She speaks English!");
                          Future.delayed(const Duration(milliseconds: 600), () {
                            if (mounted) _onNextStage();
                          });
                        } else {
                          HapticFeedback.vibrate();
                          setState(() => _scrambleError = true);
                          _speak("Oops! In English, Subject comes first, then Verb, then Object. Try again!");
                          Future.delayed(const Duration(milliseconds: 1400), () {
                            if (mounted) setState(() => _resetScramble());
                          });
                        }
                      }
                    },
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isPicked ? 0.3 : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF475569)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 3)),
                    ],
                  ),
                  child: Text(
                    word,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- STAGE 6: VICTORY & ADVANCE ---
  Widget _buildStage6Victory() {
    return Column(
      key: const ValueKey('stage6'),
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(Icons.star_rounded, color: Colors.white, size: 54),
        ),
        const SizedBox(height: 16),
        Text(
          'STEP 1 MASTERED! 🌟',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You constructed S + V + O sentences like a natural speaker!',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: const Color(0xFFCBD5E1),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        // Score Award Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF59E0B)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🪙', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                '+30 Pocket Score Earned',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFF59E0B),
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- BOTTOM ACTION NAVIGATION BAR ---
  Widget _buildBottomBar() {
    final isStage0 = _currentStage == 0;
    final isStage1Ready = _currentStage == 1 && _selectedSubject != null;
    final isStage2Ready = _currentStage == 2 && _selectedVerb != null;
    final isStage3Ready = _currentStage == 3 && _selectedObject != null;
    final isStage4 = _currentStage == 4;
    final isStage6 = _currentStage == 6;

    final canProceed = isStage0 ||
        isStage1Ready ||
        isStage2Ready ||
        isStage3Ready ||
        isStage4 ||
        isStage6;

    if (_currentStage == 5) {
      // Scramble stage handles its own automatic transition on success
      return const SizedBox(height: 20);
    }

    String buttonLabel = 'CONTINUE ➔';
    if (isStage0) buttonLabel = "LET'S BUILD! 🚀";
    if (isStage4) buttonLabel = "TEST MY SKILLS IN PUZZLE 🧩";
    if (isStage6) buttonLabel = "FINISH & CLIMB TRAIL 🏔️";

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(top: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: canProceed
                ? () {
                    if (isStage6) {
                      Navigator.pop(context);
                      widget.onCompleted();
                    } else {
                      _onNextStage();
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isStage6
                  ? const Color(0xFF10B981)
                  : const Color(0xFF3B82F6),
              disabledBackgroundColor: const Color(0xFF334155),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              buttonLabel,
              style: GoogleFonts.outfit(
                color: canProceed ? Colors.white : const Color(0xFF94A3B8),
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
