import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';

/// 4. 🚀 VOCABULARY ROCKET RUN
class PocketKidsVocabularyRocketRunPage extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;
  const PocketKidsVocabularyRocketRunPage({super.key, required this.day, this.onCompleted});

  static Future<void> show(BuildContext context, {required int day, VoidCallback? onCompleted}) {
    return Navigator.push(context, MaterialPageRoute(builder: (_) => PocketKidsVocabularyRocketRunPage(day: day, onCompleted: onCompleted)));
  }

  @override
  State<PocketKidsVocabularyRocketRunPage> createState() => _PocketKidsVocabularyRocketRunPageState();
}

class _PocketKidsVocabularyRocketRunPageState extends State<PocketKidsVocabularyRocketRunPage> {
  final FlutterTts _tts = FlutterTts();
  int _altitude = 100;
  int _fuelRounds = 0;

  final List<Map<String, dynamic>> _targets = [
    {'target': 'SUN ☀️', 'meaning': 'സൂര്യൻ', 'options': ['SUN ☀️', 'MOON 🌙', 'CLOUD ☁️']},
    {'target': 'TREE 🌳', 'meaning': 'മരം', 'options': ['FLOWER 🌸', 'TREE 🌳', 'LEAF 🍃']},
    {'target': 'BIRD 🐦', 'meaning': 'പക്ഷി', 'options': ['BIRD 🐦', 'FISH 🐟', 'FROG 🐸']},
  ];

  @override
  void initState() {
    super.initState();
    _prompt();
  }

  Future<void> _prompt() async {
    final t = _targets[_fuelRounds];
    await _tts.speak("Fuel the rocket! Find ${t['target'].toString().split(' ').first}!");
  }

  void _tapOpt(String opt) async {
    final t = _targets[_fuelRounds];
    if (opt == t['target']) {
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playCoinSound();
      setState(() {
        _altitude += 250;
        _fuelRounds++;
      });
      await _tts.speak("Blast off! Rocket zoomed higher!");

      if (_fuelRounds < _targets.length) {
        _prompt();
      } else {
        PocketKidsService.addKidsScore(20);
        widget.onCompleted?.call();
        _showVictory();
      }
    } else {
      HapticFeedback.lightImpact();
      await _tts.speak("Engine sputtering! Look for ${t['target'].toString().split(' ').first}!");
    }
  }

  void _showVictory() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Center(child: Text("🚀 🌌 🌟\nORBIT REACHED!", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold))),
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
  Widget build(BuildContext context) {
    final t = _fuelRounds < _targets.length ? _targets[_fuelRounds] : _targets.last;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white)),
                  Text("Altitude: ${_altitude}km 🚀", style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(onPressed: _prompt, icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700))),
                ],
              ),
            ),
            const Spacer(),
            Text("🚀", style: TextStyle(fontSize: 60 + (_fuelRounds * 15).toDouble())),
            const SizedBox(height: 12),
            Text("Target: ${t['target']}", style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            Text("💡 ${t['meaning']}", style: GoogleFonts.outfit(color: Colors.white60, fontSize: 14)),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: (t['options'] as List<String>).map((opt) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: () => _tapOpt(opt),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEC4899), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      child: Text(opt, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

