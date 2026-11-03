import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';

/// 8. 🗣️ PRONUNCIATION ECHO ADVENTURE
class PocketKidsPronunciationEchoPage extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;
  const PocketKidsPronunciationEchoPage(
      {super.key, required this.day, this.onCompleted});

  static Future<void> show(BuildContext context,
      {required int day, VoidCallback? onCompleted}) {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PocketKidsPronunciationEchoPage(
                day: day, onCompleted: onCompleted)));
  }

  @override
  State<PocketKidsPronunciationEchoPage> createState() =>
      _PocketKidsPronunciationEchoPageState();
}

class _PocketKidsPronunciationEchoPageState
    extends State<PocketKidsPronunciationEchoPage> {
  final FlutterTts _tts = FlutterTts();
  int _round = 0;
  bool _speaking = false;

  final List<Map<String, String>> _words = [
    {'word': 'BUTTERFLY 🦋', 'guide': '/ˈbʌt.ə.flaɪ/', 'meaning': 'പൂമ്പാറ്റ'},
    {'word': 'SUNSHINE ☀️', 'guide': '/ˈsʌn.ʃaɪn/', 'meaning': 'സൂര്യപ്രകാശം'},
    {'word': 'FRIENDSHIP 👫', 'guide': '/ˈfrend.ʃɪp/', 'meaning': 'സൗഹൃദം'},
  ];

  Future<void> _speakWord() async {
    final w = _words[_round];
    setState(() => _speaking = true);
    await _tts.speak(w['word']!.split(' ').first);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() => _speaking = false);
  }

  void _next() {
    HapticFeedback.heavyImpact();
    setState(() => _round++);
    if (_round >= _words.length) {
      PocketKidsService.addKidScore(20);
      widget.onCompleted?.call();
      Navigator.pop(context);
    } else {
      _speakWord();
    }
  }

  @override
  void initState() {
    super.initState();
    _speakWord();
  }

  @override
  Widget build(BuildContext context) {
    final w = _round < _words.length ? _words[_round] : _words.last;

    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white)),
                  Text("Echo Cave 🎙️",
                      style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(width: 48),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: _speakWord,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _speaking
                        ? const Color(0xFF38BDF8)
                        : const Color(0xFF0284C7),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                          blurRadius: 24,
                          spreadRadius: 4),
                    ],
                  ),
                  child: const Icon(Icons.volume_up_rounded,
                      size: 64, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              Text(w['word']!,
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900)),
              Text(w['guide']!,
                  style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text("💡 ${w['meaning']}",
                  style:
                      GoogleFonts.outfit(color: Colors.white60, fontSize: 14)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8CD837),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text("I SPOKE IT! NEXT 🚀",
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
