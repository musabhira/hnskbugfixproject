import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';

/// 3. 🔍 LISTENING DETECTIVE (Acoustic Ear Training & Mystery Object Reveal)
class PocketKidsListeningDetectivePage extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;

  const PocketKidsListeningDetectivePage({
    super.key,
    required this.day,
    this.onCompleted,
  });

  static Future<void> show(BuildContext context, {required int day, VoidCallback? onCompleted}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PocketKidsListeningDetectivePage(day: day, onCompleted: onCompleted),
      ),
    );
  }

  @override
  State<PocketKidsListeningDetectivePage> createState() => _PocketKidsListeningDetectivePageState();
}

class _PocketKidsListeningDetectivePageState extends State<PocketKidsListeningDetectivePage> {
  final FlutterTts _tts = FlutterTts();
  int _round = 0;
  bool _revealed = false;

  final List<Map<String, dynamic>> _clues = [
    {
      'spokenPrompt': 'I am sweet, red, and crunch when you bite me! Who am I?',
      'answer': 'Apple',
      'emoji': '🍎',
      'options': ['Apple 🍎', 'Banana 🍌', 'Carrot 🥕'],
      'translation': 'മധുരമുള്ള ചുവന്ന പഴം (ആപ്പിൾ)',
    },
    {
      'spokenPrompt': 'I have four wheels, honk my horn, and drive on the road! Who am I?',
      'answer': 'Car',
      'emoji': '🚗',
      'options': ['Boat ⛵', 'Car 🚗', 'Plane ✈️'],
      'translation': 'റോഡിലൂടെ പോകുന്ന വണ്ടി (കാർ)',
    },
    {
      'spokenPrompt': 'I bark cheerfully and wag my tail when I see you! Who am I?',
      'answer': 'Dog',
      'emoji': '🐶',
      'options': ['Cat 🐱', 'Fish 🐟', 'Dog 🐶'],
      'translation': 'വാലാട്ടി കുരയ്ക്കുന്ന ഓമനമൃഗം (പട്ടി)',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.38);
      await _tts.setPitch(1.15);
    } catch (_) {}
    _playClue();
  }

  Future<void> _playClue() async {
    final c = _clues[_round];
    await _tts.stop();
    await _tts.speak("Listen Detective! ${c['spokenPrompt']}");
  }

  void _choose(String opt) async {
    if (_revealed) return;
    final c = _clues[_round];
    final bool isCorrect = opt.startsWith(c['answer'] as String);

    if (isCorrect) {
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playVictorySfx();
      setState(() => _revealed = true);
      await _tts.speak("Aha! Correct! It is ${c['answer']}!");

      await Future.delayed(const Duration(milliseconds: 1400));
      if (!mounted) return;

      if (_round + 1 < _clues.length) {
        setState(() {
          _round++;
          _revealed = false;
        });
        _playClue();
      } else {
        PocketKidsService.addKidsScore(20);
        widget.onCompleted?.call();
        _showSuccess();
      }
    } else {
      HapticFeedback.lightImpact();
      await _tts.speak("Not quite! Tap the speaker to listen to the clue again!");
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B4B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Center(
          child: Column(
            children: [
              const Text("🔍 🕵️ ⭐", style: TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text(
                "DETECTIVE BADGE EARNED!",
                style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8CD837)),
              child: const Text("CONTINUE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    final c = _clues[_round];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  ),
                  Text("Mystery ${_round + 1} / ${_clues.length}", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: _playClue,
                    icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700), size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF6366F1), width: 2),
                ),
                child: Column(
                  children: [
                    Text(_revealed ? (c['emoji'] as String) : "❓", style: const TextStyle(fontSize: 64)),
                    const SizedBox(height: 12),
                    Text(
                      c['spokenPrompt'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "💡 ${c['translation']}",
                      style: GoogleFonts.outfit(color: const Color(0xFF818CF8), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Column(
                children: (c['options'] as List<String>).map((opt) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: () => _choose(opt),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(
                        opt,
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

