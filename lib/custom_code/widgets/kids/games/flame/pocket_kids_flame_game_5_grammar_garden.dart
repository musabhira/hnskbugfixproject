import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';

/// 5. 🌸 GRAMMAR GARDEN (Singular vs Plural, A vs An)
class PocketKidsGrammarGardenPage extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;
  const PocketKidsGrammarGardenPage({super.key, required this.day, this.onCompleted});

  static Future<void> show(BuildContext context, {required int day, VoidCallback? onCompleted}) {
    return Navigator.push(context, MaterialPageRoute(builder: (_) => PocketKidsGrammarGardenPage(day: day, onCompleted: onCompleted)));
  }

  @override
  State<PocketKidsGrammarGardenPage> createState() => _PocketKidsGrammarGardenPageState();
}

class _PocketKidsGrammarGardenPageState extends State<PocketKidsGrammarGardenPage> {
  final FlutterTts _tts = FlutterTts();
  int _round = 0;
  int _blooms = 0;

  final List<Map<String, dynamic>> _grammarTasks = [
    {'prompt': 'One cat, but many...', 'options': ['cats', 'cates', 'caties'], 'answer': 'cats', 'meaning': 'പൂച്ചകൾ'},
    {'prompt': 'Fill the blank: ___ apple', 'options': ['An', 'A', 'Them'], 'answer': 'An', 'meaning': 'ഒരു ആപ്പിൾ'},
    {'prompt': 'One dog, two...', 'options': ['dogs', 'doges', 'dogies'], 'answer': 'dogs', 'meaning': 'പട്ടികൾ'},
  ];

  void _choose(String opt) async {
    final t = _grammarTasks[_round];
    if (opt == t['answer']) {
      HapticFeedback.heavyImpact();
      setState(() {
        _blooms++;
        _round++;
      });
      await _tts.speak("A flower bloomed! Correct grammar!");
      if (_round >= _grammarTasks.length) {
        PocketKidsService.addKidsScore(20);
        widget.onCompleted?.call();
        Navigator.pop(context);
      }
    } else {
      await _tts.speak("Watch the petal wobble! Try another petal!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _round < _grammarTasks.length ? _grammarTasks[_round] : _grammarTasks.last;

    return Scaffold(
      backgroundColor: const Color(0xFF064E3B), // Deep garden emerald
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white)),
                  Text("Garden Blooms: $_blooms 🌸", style: GoogleFonts.outfit(color: const Color(0xFF6EE7B7), fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 48),
                ],
              ),
              const Spacer(),
              Text("🌸 🌷 🌺", style: TextStyle(fontSize: 36 + (_blooms * 10).toDouble())),
              const SizedBox(height: 16),
              Text(t['prompt'] as String, textAlign: TextAlign.center, style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text("💡 ${t['meaning']}", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
              const Spacer(),
              Column(
                children: (t['options'] as List<String>).map((opt) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: () => _choose(opt),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
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

