import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';

/// 2. 🌉 WORD BRIDGE BUILDER (Flame 2D Wooden Plank River Crossing)
/// Children place stone and plank word blocks across a river to let the puppy cross
class WordBridgeBuilderGame extends FlameGame {
  @override
  Color backgroundColor() => Colors.transparent;
}

class PocketKidsWordBridgeBuilderPage extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;

  const PocketKidsWordBridgeBuilderPage({
    super.key,
    required this.day,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    required int day,
    VoidCallback? onCompleted,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PocketKidsWordBridgeBuilderPage(
          day: day,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketKidsWordBridgeBuilderPage> createState() =>
      _PocketKidsWordBridgeBuilderPageState();
}

class _PocketKidsWordBridgeBuilderPageState
    extends State<PocketKidsWordBridgeBuilderPage> {
  final FlutterTts _tts = FlutterTts();
  late WordBridgeBuilderGame _flameGame;

  int _roundIndex = 0;
  final List<String?> _placedPlanks = [];
  List<String> _trayOptions = [];

  final List<Map<String, dynamic>> _bridges = [
    {
      'targetSentence': ['The', 'cat', 'can', 'jump'],
      'translationMl': 'പൂച്ചയ്ക്ക് ചാടാൻ കഴിയും 🐱',
      'translationHi': 'बिल्ली कूद सकती है 🐱',
      'scrambled': ['jump', 'The', 'can', 'cat'],
    },
    {
      'targetSentence': ['I', 'see', 'a', 'star'],
      'translationMl': 'ഞാൻ ഒരു നക്ഷത്രം കാണുന്നു ⭐',
      'translationHi': 'मैं एक तारा देखता हूँ ⭐',
      'scrambled': ['a', 'star', 'I', 'see'],
    },
    {
      'targetSentence': ['The', 'dog', 'is', 'happy'],
      'translationMl': 'പട്ടി സന്തോഷവാനാണ് 🐶',
      'translationHi': 'कुत्ता खुश है 🐶',
      'scrambled': ['is', 'happy', 'The', 'dog'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _flameGame = WordBridgeBuilderGame();
    _initTts();
    _setupRound();
  }

  void _setupRound() {
    final b = _bridges[_roundIndex];
    final target = b['targetSentence'] as List<String>;
    _placedPlanks.clear();
    _placedPlanks.addAll(List.filled(target.length, null));
    _trayOptions = List.from(b['scrambled'] as List<String>);
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.38);
      await _tts.setPitch(1.15);
    } catch (_) {}
    _promptBridge();
  }

  Future<void> _promptBridge() async {
    final b = _bridges[_roundIndex];
    final full = (b['targetSentence'] as List<String>).join(' ');
    await _tts.stop();
    await _tts.speak("Build the bridge for puppy! $full");
  }

  void _tapTrayWord(String word) {
    HapticFeedback.lightImpact();
    _tts.speak(word);

    final emptyIdx = _placedPlanks.indexOf(null);
    if (emptyIdx != -1) {
      setState(() {
        _trayOptions.remove(word);
        _placedPlanks[emptyIdx] = word;
      });

      if (!_placedPlanks.contains(null)) {
        _verifyBridge();
      }
    }
  }

  void _tapPlacedWord(int idx) {
    final word = _placedPlanks[idx];
    if (word != null) {
      HapticFeedback.selectionClick();
      setState(() {
        _placedPlanks[idx] = null;
        _trayOptions.add(word);
      });
    }
  }

  void _verifyBridge() async {
    final b = _bridges[_roundIndex];
    final target = b['targetSentence'] as List<String>;
    bool correct = true;
    for (int i = 0; i < target.length; i++) {
      if (_placedPlanks[i] != target[i]) {
        correct = false;
        break;
      }
    }

    if (correct) {
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playVictorySfx();
      await _tts.speak("Splendid! The puppy safely crossed the river! 🐶🎉");

      await Future.delayed(const Duration(milliseconds: 1400));
      if (!mounted) return;

      if (_roundIndex + 1 < _bridges.length) {
        setState(() {
          _roundIndex++;
          _setupRound();
        });
        _promptBridge();
      } else {
        PocketKidsService.addKidScore(20);
        widget.onCompleted?.call();
        _showFinishedModal();
      }
    } else {
      HapticFeedback.lightImpact();
      await _tts
          .speak("Splash! The words wobble! Tap a plank to fix the bridge!");
    }
  }

  void _showFinishedModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Center(
          child: Column(
            children: [
              const Text("🌉 🐶 🏆", style: TextStyle(fontSize: 38)),
              const SizedBox(height: 8),
              Text(
                "BRIDGE MASTER!",
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
        content: Text(
          "All river bridge sentences completed successfully!",
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8CD837),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: Text("CONTINUE 🚀",
                  style: GoogleFonts.outfit(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = _bridges[_roundIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0C4A6E), // Deep river blue
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "River ${_roundIndex + 1} / ${_bridges.length}",
                      style: GoogleFonts.outfit(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: _promptBridge,
                    icon: const Icon(Icons.volume_up_rounded,
                        color: Color(0xFFFFD700)),
                  ),
                ],
              ),
            ),

            // Hint Box
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "💡 ${b['translationMl']}",
                style: GoogleFonts.outfit(
                    color: const Color(0xFFBAE6FD),
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              ),
            ),

            const Spacer(),

            // River Crossing Canvas Representation
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0369A1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF38BDF8), width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("🌳 Shore",
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold)),
                      Text("🐶 Puppy Crossing",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900)),
                      Text("🏡 Goal",
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Planks in river
                  Row(
                    children: List.generate(_placedPlanks.length, (idx) {
                      final word = _placedPlanks[idx];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _tapPlacedWord(idx),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 64,
                            decoration: BoxDecoration(
                              color: word != null
                                  ? const Color(0xFFB45309)
                                  : Colors.white12,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: word != null
                                    ? const Color(0xFFFDE68A)
                                    : Colors.white30,
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              word ?? "Plank ${idx + 1}",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: word != null ? 16 : 11,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Scrambled Tray Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _trayOptions.map((word) {
                  return GestureDetector(
                    onTap: () => _tapTrayWord(word),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        word,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
