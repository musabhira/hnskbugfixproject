import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';

/// 9. 📖 STORY SEQUENCE ADVENTURE (First, Then, Finally)
class PocketKidsStorySequenceAdventurePage extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;
  const PocketKidsStorySequenceAdventurePage({super.key, required this.day, this.onCompleted});

  static Future<void> show(BuildContext context, {required int day, VoidCallback? onCompleted}) {
    return Navigator.push(context, MaterialPageRoute(builder: (_) => PocketKidsStorySequenceAdventurePage(day: day, onCompleted: onCompleted)));
  }

  @override
  State<PocketKidsStorySequenceAdventurePage> createState() => _PocketKidsStorySequenceAdventurePageState();
}

class _PocketKidsStorySequenceAdventurePageState extends State<PocketKidsStorySequenceAdventurePage> {
  final FlutterTts _tts = FlutterTts();
  final List<String> _slots = [
    '1. First, wake up ⏰',
    '2. Then, brush teeth 🪥',
    '3. Finally, eat breakfast 🥞',
  ];

  @override
  Widget build(BuildContext context) {
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
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white)),
                  Text("Story Sequence 📖", style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 20),
              Text("ORDER THE DAILY STORY", style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              const Spacer(),
              Column(
                children: _slots.map((s) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF1D4ED8).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Text(s, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  );
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    PocketKidsService.addKidsScore(20);
                    widget.onCompleted?.call();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8CD837),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text("STORY COMPLETE! 🌟", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

