import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';

/// 6. ⚖️ OPPOSITE WORLD CHALLENGE (Hot vs Cold, Fast vs Slow, Big vs Small)
class PocketKidsOppositeWorldChallengePage extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;
  const PocketKidsOppositeWorldChallengePage({super.key, required this.day, this.onCompleted});

  static Future<void> show(BuildContext context, {required int day, VoidCallback? onCompleted}) {
    return Navigator.push(context, MaterialPageRoute(builder: (_) => PocketKidsOppositeWorldChallengePage(day: day, onCompleted: onCompleted)));
  }

  @override
  State<PocketKidsOppositeWorldChallengePage> createState() => _PocketKidsOppositeWorldChallengePageState();
}

class _PocketKidsOppositeWorldChallengePageState extends State<PocketKidsOppositeWorldChallengePage> {
  final FlutterTts _tts = FlutterTts();
  int _round = 0;

  final List<Map<String, dynamic>> _pairs = [
    {'word': 'HOT 🔥', 'opposite': 'COLD ❄️', 'options': ['COLD ❄️', 'WARM ☀️', 'WET 💧'], 'meaning': 'ചൂട് ➔ തണുപ്പ്'},
    {'word': 'FAST 🐆', 'opposite': 'SLOW 🐢', 'options': ['QUICK ⚡', 'SLOW 🐢', 'TALL 🦒'], 'meaning': 'വേഗത ➔ പതുക്കെ'},
    {'word': 'BIG 🐘', 'opposite': 'SMALL 🐜', 'options': ['HUGE 🐋', 'HEAVY 🪨', 'SMALL 🐜'], 'meaning': 'വലുത് ➔ ചെറുത്'},
  ];

  void _choose(String opt) async {
    final p = _pairs[_round];
    if (opt == p['opposite']) {
      HapticFeedback.heavyImpact();
      setState(() => _round++);
      await _tts.speak("Opposites match! ${p['word']} and ${p['opposite']}!");
      if (_round >= _pairs.length) {
        PocketKidsService.addKidsScore(20);
        widget.onCompleted?.call();
        Navigator.pop(context);
      }
    } else {
      await _tts.speak("Think of the opposite! What is opposite to ${p['word'].toString().split(' ').first}?");
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _round < _pairs.length ? _pairs[_round] : _pairs.last;

    return Scaffold(
      backgroundColor: const Color(0xFF312E81),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white)),
                  Text("Opposite Challenge ⚖️", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 48),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(24)),
                child: Column(
                  children: [
                    Text("What is the opposite of:", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(p['word'] as String, style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 36, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text("💡 ${p['meaning']}", style: GoogleFonts.outfit(color: const Color(0xFFA5B4FC), fontSize: 13)),
                  ],
                ),
              ),
              const Spacer(),
              Column(
                children: (p['options'] as List<String>).map((opt) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: () => _choose(opt),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      child: Text(opt, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

