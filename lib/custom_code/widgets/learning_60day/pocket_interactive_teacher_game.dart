import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'pocket_fortress_defense_service.dart';

/// 🎙️ Dynamic Voice Option
class TeacherVoiceOption {
  final String label;
  final String locale;
  final double pitch;
  final double rate;
  final String? voiceName;

  const TeacherVoiceOption({
    required this.label,
    required this.locale,
    required this.pitch,
    required this.rate,
    this.voiceName,
  });
}

/// 🎮 Bright & Vibrant Interactive Speaking Tutor Page
/// User Directive:
/// - "എന്തോ ഒരു darkness പോലെ... അത് മാറ്റി നല്ല ഫ്രഷ് ആയിരിക്കണം" (Bright, joyful, luminous aesthetics)
/// - "ഒരു ട്യൂട്ടർ എങ്ങനെയാണ് പഠിപ്പിച്ചു കൊടുക്കുക... 'What is your name?' ചോദിക്കുന്നു... ഇങ്ങോട്ട് പറയുന്നു..."
/// - "സംസാരിക്കുന്നതിന്റെ വോയിസ് എങ്കിലും ചേഞ്ച് ചെയ്യാൻ പറ്റുമോ എന്ന് നോക്ക്... ആപ്പ് ഇങ്ങോട്ട് പറഞ്ഞു തന്നു പഠിപ്പിക്കുക"
class PocketInteractiveTeacherGamePage extends StatefulWidget {
  final int day;
  final String? userId;
  final VoidCallback onCompleted;

  const PocketInteractiveTeacherGamePage({
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
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketInteractiveTeacherGamePage(
          day: day,
          userId: userId,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketInteractiveTeacherGamePage> createState() =>
      _PocketInteractiveTeacherGamePageState();
}

/// Backward compatibility alias
typedef PocketInteractiveTeacherGameModal = PocketInteractiveTeacherGamePage;

class _PocketInteractiveTeacherGamePageState
    extends State<PocketInteractiveTeacherGamePage>
    with TickerProviderStateMixin {
  late final FlutterTts _tts;
  late final stt.SpeechToText _speech;
  bool _speechAvailable = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _showMalayalam = true;

  // Curated natural voices
  List<TeacherVoiceOption> _availableVoices = [
    const TeacherVoiceOption(label: 'Maya (Warm & Natural) 👩‍🏫', locale: 'en-US', pitch: 1.08, rate: 0.44),
    const TeacherVoiceOption(label: 'Emma (British Accent) 🇬🇧', locale: 'en-GB', pitch: 1.02, rate: 0.43),
    const TeacherVoiceOption(label: 'Alex (Friendly Male) 👨‍🏫', locale: 'en-US', pitch: 0.94, rate: 0.45),
    const TeacherVoiceOption(label: 'Zoya (Cheerful AI) ✨', locale: 'en-US', pitch: 1.25, rate: 0.46),
  ];
  int _selectedVoiceIndex = 0;

  // Conversation turns:
  // 0: Greeting & "What is your name?"
  // 1: Name response acknowledged & "Where are you from?"
  // 2: Place acknowledged & Sentence breakdown ("I" + "learn" + "English")
  // 3: Spoken Repeat Challenge ("I speak English")
  // 4: Interactive Word Puzzle
  // 5: Victory celebration & +30 PS
  int _turnIndex = 0;

  String _userName = '';
  final TextEditingController _textInputCtrl = TextEditingController();

  // Spoken recognition feedback
  String _recognizedWords = '';
  bool _spokeCorrectly = false;

  // Puzzle state for Turn 4
  final List<String> _puzzleAvailable = ['English', 'I', 'speak'];
  final List<String> _puzzleSelected = [];
  bool _puzzleError = false;

  late final AnimationController _pulseCtrl;
  late final AnimationController _sunbeamCtrl;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _sunbeamCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _initSpeechRecognizer();
    _initTts();
  }

  Future<void> _initSpeechRecognizer() async {
    try {
      final available = await _speech.initialize(
        onError: (_) {
          if (mounted) setState(() => _isListening = false);
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
      );
      if (mounted) setState(() => _speechAvailable = available);
    } catch (_) {}
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    try {
      // Discover high-quality natural installed voices on device
      final dynamic rawVoices = await _tts.getVoices;
      if (rawVoices is List && rawVoices.isNotEmpty) {
        final List<TeacherVoiceOption> dynamicList = [];
        for (var v in rawVoices) {
          if (v is Map) {
            final name = v['name']?.toString() ?? '';
            final locale = v['locale']?.toString() ?? '';
            if (locale.startsWith('en') && (name.contains('natural') || name.contains('local') || name.contains('neural') || name.contains('female'))) {
              dynamicList.add(
                TeacherVoiceOption(
                  label: name.contains('female') ? 'Natural Voice 🎙️' : 'Smooth English 🗣️',
                  locale: locale,
                  pitch: 1.05,
                  rate: 0.44,
                  voiceName: name,
                ),
              );
            }
          }
        }
        if (dynamicList.isNotEmpty) {
          _availableVoices = [...dynamicList.take(2), ..._availableVoices];
        }
      }
      await _applyVoice();
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

    // First teacher greeting aloud
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _speak("Hello friend! Welcome to Day ${widget.day}! I am your personal English tutor. What is your name?");
      }
    });
  }

  Future<void> _applyVoice() async {
    final v = _availableVoices[_selectedVoiceIndex];
    try {
      await _tts.setLanguage(v.locale);
      await _tts.setSpeechRate(v.rate);
      await _tts.setPitch(v.pitch);
      if (v.voiceName != null) {
        await _tts.setVoice({'name': v.voiceName!, 'locale': v.locale});
      }
    } catch (_) {}
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void _startListening({required Function(String) onResult}) async {
    HapticFeedback.lightImpact();
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎙️ Please type below or tap options if microphone is busy.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    await _tts.stop();
    setState(() {
      _isListening = true;
      _recognizedWords = '';
    });
    try {
      await _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _recognizedWords = result.recognizedWords;
            });
            if (result.finalResult || result.recognizedWords.isNotEmpty) {
              onResult(result.recognizedWords);
            }
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.confirmation,
          cancelOnError: true,
          partialResults: true,
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _isListening = false);
    }
  }

  void _stopListening() async {
    try {
      await _speech.stop();
    } catch (_) {}
    if (mounted) setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _tts.stop();
    _speech.stop();
    _pulseCtrl.dispose();
    _sunbeamCtrl.dispose();
    _textInputCtrl.dispose();
    super.dispose();
  }

  void _advanceTurn(int next) {
    HapticFeedback.mediumImpact();
    setState(() => _turnIndex = next);

    switch (next) {
      case 1:
        _speak("Wonderful to meet you, $_userName! Where are you learning English from?");
        break;
      case 2:
        _speak("Awesome! Look at what you just said: I am $_userName. You just built a real English sentence: Subject, Verb, and Object!");
        break;
      case 3:
        _speak("Now repeat after me: I speak English! Tap the microphone and say it aloud.");
        break;
      case 4:
        _speak("Puzzle test! Put the words in order: I speak English!");
        break;
      case 5:
        _speak("Super job! You completed Step 1 like a natural speaker! +30 Pocket Score earned!");
        _awardScore();
        break;
    }
  }

  Future<void> _awardScore() async {
    final uid = widget.userId;
    try {
      await PocketFortressDefenseService.recordTrainingPoints(30, uid);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Vibrant, luminous, cheerful sky gradient (No darkness!)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0F2FE), // Fresh morning sky
              Color(0xFFBAE6FD), // Sky blue
              Color(0xFFF0FDF4), // Emerald garden mist
              Color(0xFFDCFCE7), // Vibrant grass glow
            ],
            stops: [0.0, 0.35, 0.70, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bright Nav Bar with Voice Switcher
              _buildTopBar(),

              // Conversational Canvas
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Column(
                    children: [
                      // Warm, smiling Teacher Avatar with Live Speech Bubble
                      _buildTutorHero(),

                      const SizedBox(height: 18),

                      // Interactive Stage Card (Bright & Frosted Glass)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        child: _buildCurrentTurnCard(),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Bright Bar
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final curVoice = _availableVoices[_selectedVoiceIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.school_rounded, color: Colors.white, size: 14),
                const SizedBox(width: 5),
                Text(
                  'DAY ${widget.day} • LIVE TUTOR',
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

          // 🎙️ Voice Switcher Menu (User Audio Directive: "സംസാരിക്കുന്നതിന്റെ വോയിസ് എങ്കിലും ചേഞ്ച് ചെയ്യാൻ പറ്റുമോ എന്ന് നോക്ക്")
          PopupMenuButton<int>(
            tooltip: 'Choose Natural Tutor Voice',
            initialValue: _selectedVoiceIndex,
            onSelected: (idx) async {
              HapticFeedback.selectionClick();
              setState(() => _selectedVoiceIndex = idx);
              await _applyVoice();
              _speak("Hello! I am ready to teach you English today.");
            },
            color: Colors.white,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
            ),
            itemBuilder: (ctx) => List.generate(
              _availableVoices.length,
              (i) => PopupMenuItem<int>(
                value: i,
                child: Row(
                  children: [
                    Icon(
                      _selectedVoiceIndex == i ? Icons.check_circle_rounded : Icons.circle_outlined,
                      color: _selectedVoiceIndex == i ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _availableVoices[i].label,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF0F172A),
                        fontWeight: _selectedVoiceIndex == i ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.record_voice_over_rounded, color: Color(0xFF0284C7), size: 15),
                  const SizedBox(width: 4),
                  Text(
                    curVoice.label.split(' ')[0],
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF0F172A),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Malayalam helper toggle
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _showMalayalam = !_showMalayalam);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: _showMalayalam ? const Color(0xFF10B981).withValues(alpha: 0.15) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _showMalayalam ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                ),
              ),
              child: Text(
                'മലയാളം',
                style: GoogleFonts.notoSansMalayalam(
                  color: _showMalayalam ? const Color(0xFF047857) : const Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorHero() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Smiling Teacher Avatar with pulse
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (ctx, _) {
              final scale = 1.0 + (_pulseCtrl.value * 0.04);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF38BDF8), Color(0xFF818CF8)],
                    ),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: _isSpeaking
                            ? const Color(0xFF0284C7).withValues(alpha: 0.5)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.3),
                        blurRadius: _isSpeaking ? 20 : 10,
                        spreadRadius: _isSpeaking ? 4 : 1,
                      ),
                    ],
                  ),
                  child: const ClipOval(
                    child: VectorAvatarWidget(
                      config: VectorAvatarConfig(
                        species: 'human',
                        gender: 'female',
                        hairStyle: 'classic_side',
                        hairColor: '#4A2E18',
                        outfitStyle: 'blazer',
                        outfitColor: '#2563EB',
                        accessory: 'round_glasses',
                        auraStyle: 'electric_blue',
                      ),
                      size: 76,
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
                        color: const Color(0xFF0284C7),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
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
                              color: const Color(0xFF0284C7),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _speak(_getTutorSpeechText()),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.volume_up_rounded,
                          size: 18,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _getTutorSpeechText(),
                  style: GoogleFonts.inter(
                    color: const Color(0xFF0F172A),
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_showMalayalam && _getMalayalamSubText().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    _getMalayalamSubText(),
                    style: GoogleFonts.notoSansMalayalam(
                      color: const Color(0xFF475569),
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

  String _getTutorSpeechText() {
    switch (_turnIndex) {
      case 0:
        return "Hello friend! 👋 I'm your teacher. Let's start with a simple question: What is your name?";
      case 1:
        return "Wonderful to meet you, $_userName! Where are you from?";
      case 2:
        return "Notice what you just did? You made sentences naturally: 'I am $_userName'. In English: YOU are the Subject, what you DO is the Verb, and WHAT is the Object!";
      case 3:
        return "Now say it with me: 'I speak English!' Tap the microphone and say it aloud!";
      case 4:
        return "Puzzle Time! 🧩 Tap the words in the right order to build: 'I speak English'!";
      case 5:
        return "Outstanding! 🎉 You just spoke and framed your first English sentences without reading boring theory!";
      default:
        return "";
    }
  }

  String _getMalayalamSubText() {
    switch (_turnIndex) {
      case 0:
        return "നിങ്ങളുടെ പേരെന്താണ്? മൈക്കിൽ പറയുകയോ താഴെ ടൈപ്പ് ചെയ്യുകയോ ചെയ്യുക:";
      case 1:
        return "താങ്കൾ എവിടെ നിന്നാണ്? ഉദാഹരണത്തിന്: Kerala, Dubai, Bangalore...";
      case 2:
        return "നിങ്ങൾ ഇപ്പോൾ പറഞ്ഞത് ശ്രദ്ധിച്ചോ? ഇംഗ്ലീഷിൽ Subject (ആൾ) + Verb (പ്രവൃത്തി) + Object (കാര്യം) എന്ന ക്രമത്തിലാണ് വാക്യങ്ങൾ വരുന്നത്.";
      case 3:
        return "'I speak English' എന്ന് ഉറക്കെ പറയൂ. മൈക്ക് ബട്ടണിൽ തൊട്ട് സംസാരിക്കുക:";
      case 4:
        return "വാക്കുകൾ തൊട്ട് ശരിയായ ക്രമത്തിൽ വാക്യം ഉണ്ടാക്കുക:";
      case 5:
        return "നിങ്ങൾ ആദ്യത്തെ സ്റ്റെപ്പ് മികച്ച രീതിയിൽ പൂർത്തിയാക്കി! +30 പോക്കറ്റ് സ്കോർ നേടി!";
      default:
        return "";
    }
  }

  Widget _buildCurrentTurnCard() {
    switch (_turnIndex) {
      case 0:
        return _buildTurn0NameInput();
      case 1:
        return _buildTurn1LocationInput();
      case 2:
        return _buildTurn2FormulaBreakdown();
      case 3:
        return _buildTurn3SpeakingChallenge();
      case 4:
        return _buildTurn4Puzzle();
      case 5:
        return _buildTurn5Victory();
      default:
        return const SizedBox.shrink();
    }
  }

  // --- TURN 0: WHAT IS YOUR NAME? ---
  Widget _buildTurn0NameInput() {
    return Container(
      key: const ValueKey('turn0'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Answer Teacher Maya:',
            style: GoogleFonts.outfit(
              color: const Color(0xFF0284C7),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Mic Button for direct speech
          GestureDetector(
            onTap: () {
              if (_isListening) {
                _stopListening();
              } else {
                _startListening(onResult: (spoken) {
                  final clean = spoken.replaceAll(RegExp(r'my name is|i am', caseSensitive: false), '').trim();
                  if (clean.isNotEmpty) {
                    setState(() {
                      _userName = clean;
                      _textInputCtrl.text = clean;
                    });
                  }
                });
              }
            },
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isListening
                      ? [const Color(0xFFEF4444), const Color(0xFFF97316)]
                      : [const Color(0xFF2563EB), const Color(0xFF38BDF8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isListening
                        ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                        : const Color(0xFF2563EB).withValues(alpha: 0.35),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isListening ? 'Listening to your name...' : 'Tap Mic & Say: "My name is..."',
            style: GoogleFonts.inter(
              color: _isListening ? const Color(0xFFDC2626) : const Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),
          // Or type name
          TextField(
            controller: _textInputCtrl,
            onChanged: (v) => setState(() => _userName = v.trim()),
            decoration: InputDecoration(
              hintText: 'Or type your name here...',
              hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
              ),
            ),
          ),

          const SizedBox(height: 12),
          // Quick suggestions
          Wrap(
            spacing: 8,
            children: ['Musab', 'Rahul', 'Fathima', 'John'].map((n) {
              return ActionChip(
                label: Text(n, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12)),
                backgroundColor: const Color(0xFFEFF6FF),
                side: const BorderSide(color: Color(0xFFBFDBFE)),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _userName = n;
                    _textInputCtrl.text = n;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- TURN 1: WHERE ARE YOU FROM? ---
  Widget _buildTurn1LocationInput() {
    final places = [
      {'name': 'Kerala 🌴', 'val': 'Kerala'},
      {'name': 'Dubai 🏙️', 'val': 'Dubai'},
      {'name': 'Bangalore 💻', 'val': 'Bangalore'},
      {'name': 'Mumbai 🇮🇳', 'val': 'Mumbai'},
    ];

    return Container(
      key: const ValueKey('turn1'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Where do you live, $_userName?',
            style: GoogleFonts.outfit(
              color: const Color(0xFF0284C7),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ...places.map((p) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF0FDF4),
                  foregroundColor: const Color(0xFF065F46),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFF86EFAC), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _speak("I am from ${p['val']}");
                  _advanceTurn(2);
                },
                child: Text(
                  'I am from ${p['name']}',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- TURN 2: FORMULA BREAKDOWN ---
  Widget _buildTurn2FormulaBreakdown() {
    return Container(
      key: const ValueKey('turn2'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF10B981), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'The Secret Formula You Just Used!',
            style: GoogleFonts.outfit(
              color: const Color(0xFF047857),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFormulaBrick('I', 'Subject (ആര്?)', const Color(0xFF2563EB)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text('+', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              ),
              _buildFormulaBrick('speak', 'Verb (എന്ത് ചെയ്യുന്നു?)', const Color(0xFF059669)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text('+', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              ),
              _buildFormulaBrick('English', 'Object (എന്തിനെ?)', const Color(0xFFD97706)),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Malayalam puts the verb at the end, but in English: The Action (Verb) is always in the middle!',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1E3A8A),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaBrick(String title, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            sub,
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- TURN 3: SPEAKING CHALLENGE ---
  Widget _buildTurn3SpeakingChallenge() {
    return Container(
      key: const ValueKey('turn3'),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _spokeCorrectly ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.12),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Target Phrase to Say:',
            style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            '"I speak English"',
            style: GoogleFonts.outfit(
              color: const Color(0xFF1E40AF),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),

          // Big Mic Button
          GestureDetector(
            onTap: () {
              if (_isListening) {
                _stopListening();
              } else {
                _startListening(onResult: (spoken) {
                  final lower = spoken.toLowerCase();
                  if (lower.contains('speak') || lower.contains('english') || lower.contains('i speak')) {
                    HapticFeedback.heavyImpact();
                    setState(() {
                      _spokeCorrectly = true;
                    });
                    _speak("Brilliant pronunciation! You said it like a natural!");
                    Future.delayed(const Duration(milliseconds: 1400), () {
                      if (mounted) _advanceTurn(4);
                    });
                  }
                });
              }
            },
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _spokeCorrectly
                      ? [const Color(0xFF10B981), const Color(0xFF059669)]
                      : (_isListening
                          ? [const Color(0xFFEF4444), const Color(0xFFF97316)]
                          : [const Color(0xFF2563EB), const Color(0xFF38BDF8)]),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_spokeCorrectly ? const Color(0xFF10B981) : const Color(0xFF2563EB))
                        .withValues(alpha: 0.45),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Icon(
                _spokeCorrectly ? Icons.check_circle_rounded : (_isListening ? Icons.mic_rounded : Icons.mic_none_rounded),
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _spokeCorrectly
                ? '✅ Excellent speech verified!'
                : (_isListening ? 'Listening... Speak now!' : 'Tap mic and say: "I speak English"'),
            style: GoogleFonts.outfit(
              color: _spokeCorrectly ? const Color(0xFF059669) : const Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_recognizedWords.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Heard: "$_recognizedWords"',
              style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  // --- TURN 4: PUZZLE ---
  Widget _buildTurn4Puzzle() {
    const targetOrder = ['I', 'speak', 'English'];

    return Container(
      key: const ValueKey('turn4'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            'Arrange words in S + V + O order:',
            style: GoogleFonts.outfit(color: const Color(0xFF0284C7), fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),

          // Slot
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: _puzzleError ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _puzzleError ? const Color(0xFFEF4444) : const Color(0xFFCBD5E1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _puzzleSelected.isEmpty
                  ? [
                      Text(
                        'Tap words below in order...',
                        style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
                      ),
                    ]
                  : _puzzleSelected.map((w) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          w,
                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
            ),
          ),

          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            children: _puzzleAvailable.map((word) {
              final isPicked = _puzzleSelected.contains(word);
              return ActionChip(
                label: Text(
                  word,
                  style: GoogleFonts.outfit(
                    color: isPicked ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                backgroundColor: isPicked ? const Color(0xFFE2E8F0) : const Color(0xFFEFF6FF),
                side: BorderSide(color: isPicked ? const Color(0xFFCBD5E1) : const Color(0xFF93C5FD)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                onPressed: isPicked
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _puzzleSelected.add(word);
                          _puzzleError = false;
                        });
                        _speak(word);

                        if (_puzzleSelected.length == targetOrder.length) {
                          bool match = true;
                          for (int i = 0; i < targetOrder.length; i++) {
                            if (_puzzleSelected[i] != targetOrder[i]) match = false;
                          }
                          if (match) {
                            HapticFeedback.heavyImpact();
                            _speak("Correct! I speak English!");
                            Future.delayed(const Duration(milliseconds: 600), () {
                              if (mounted) _advanceTurn(5);
                            });
                          } else {
                            HapticFeedback.vibrate();
                            setState(() => _puzzleError = true);
                            _speak("Try again! In English, who is doing it comes first: I!");
                            Future.delayed(const Duration(milliseconds: 1300), () {
                              if (mounted) {
                                setState(() {
                                  _puzzleSelected.clear();
                                  _puzzleError = false;
                                });
                              }
                            });
                          }
                        }
                      },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- TURN 5: VICTORY & REWARD ---
  Widget _buildTurn5Victory() {
    return Container(
      key: const ValueKey('turn5'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFF59E0B), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                  blurRadius: 24,
                ),
              ],
            ),
            child: const Icon(Icons.stars_rounded, color: Colors.white, size: 52),
          ),
          const SizedBox(height: 16),
          Text(
            'STEP 1 COMPLETED! 🌟',
            style: GoogleFonts.outfit(
              color: const Color(0xFF0F172A),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$_userName, you learned to construct English sentences naturally with your tutor!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: const Color(0xFF475569), fontSize: 13),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF59E0B)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  '+30 Pocket Score Earned',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFB45309),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    final isTurn0Ready = _turnIndex == 0 && _userName.isNotEmpty;
    final isTurn2 = _turnIndex == 2;
    final isTurn3Ready = _turnIndex == 3 && _spokeCorrectly;
    final isTurn5 = _turnIndex == 5;

    final canProceed = isTurn0Ready || isTurn2 || isTurn3Ready || isTurn5;

    if (_turnIndex == 1 || _turnIndex == 4) {
      // These turns handle their own interactive transitions
      return const SizedBox(height: 14);
    }

    String label = 'NEXT ➔';
    if (_turnIndex == 0) label = "YES, THAT'S MY NAME! 🚀";
    if (_turnIndex == 2) label = "LET'S PRACTICE SPEAKING 🎙️";
    if (_turnIndex == 3) label = "CONTINUE TO PUZZLE 🧩";
    if (_turnIndex == 5) label = "FINISH & CLIMB TO STEP 2 🏔️";

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: canProceed
              ? () {
                  if (isTurn5) {
                    Navigator.pop(context);
                    widget.onCompleted();
                  } else {
                    _advanceTurn(_turnIndex + 1);
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isTurn5 ? const Color(0xFF10B981) : const Color(0xFF2563EB),
            disabledBackgroundColor: const Color(0xFFCBD5E1),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: canProceed ? Colors.white : const Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}
