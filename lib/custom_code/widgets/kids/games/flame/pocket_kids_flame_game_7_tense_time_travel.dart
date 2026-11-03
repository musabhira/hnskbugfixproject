import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';

/// 7. ⏳ TENSE TIME TRAVEL (Yesterday, Today, Tomorrow)
class PocketKidsTenseTimeTravelPage extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;
  const PocketKidsTenseTimeTravelPage({super.key, required this.day, this.onCompleted});

  static Future<void> show(BuildContext context, {required int day, VoidCallback? onCompleted}) {
    return Navigator.push(context, MaterialPageRoute(builder: (_) => PocketKidsTenseTimeTravelPage(day: day, onCompleted: onCompleted)));
  }

  @override
  State<PocketKidsTenseTimeTravelPage> createState() => _PocketKidsTenseTimeTravelPageState();
}

class _PocketKidsTenseTimeTravelPageState extends State<PocketKidsTenseTimeTravelPage> {
  final FlutterTts _tts = FlutterTts();
  int _round = 0;

  final List<Map<String, dynamic>> _tenseTasks = [
    {'prompt': 'Today I play, Yesterday I...', 'options': ['played', 'play', 'will play'], 'answer': 'played', 'ml': 'ഇന്നലെ ഞാൻ കളിച്ചു (Past)'},
    {'prompt': 'Today I eat, Yesterday I...', 'options': ['ate', 'eated', 'eat'], 'answer': 'ate', 'ml': 'ഇന്നലെ ഞാൻ കഴിച്ചു (Past)'},
    {'prompt': 'Tomorrow I will...', 'options': ['run', 'ran', 'running'], 'answer': 'run', 'ml': 'നാളെ ഞാൻ ഓടും (Future)'},
  ];

  void _choose(String opt) async {
    final t = _tenseTasks[_round];
    if (opt == t['answer']) {
      HapticFeedback.heavyImpact();
      setState(() => _round++);
      await _tts.speak("Time machine locked into the past! Super job!");
      if (_round >= _tenseTasks.length) {
        PocketKidsService.addKidsScore(20);
        widget.onCompleted?.call();
        Navigator.pop(context);
      }
    } else {
      await _tts.speak("Time wobble! Pick the correct past or future word!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _round < _tenseTasks.length ? _tenseTasks[_round] : _tenseTasks.last;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1B4B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white)),
                  Text("Tense Time Machine ⏳", style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 48),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF818CF8))),
                child: Column(
                  children: [
                    const Text("⏳ 🚀 🕰️", style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(t['prompt'] as String, textAlign: TextAlign.center, style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("💡 ${t['ml']}", style: GoogleFonts.outfit(color: const Color(0xFFC7D2FE), fontSize: 13)),
                  ],
                ),
              ),
              const Spacer(),
              Column(
                children: (t['options'] as List<String>).map((opt) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: () => _choose(opt),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4338CA), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
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

