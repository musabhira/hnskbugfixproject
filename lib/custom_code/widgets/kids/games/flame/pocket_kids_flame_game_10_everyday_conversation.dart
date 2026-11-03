import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';

/// 10. 💬 EVERYDAY CONVERSATION QUEST (Interactive Dialogues)
class PocketKidsEverydayConversationQuestPage extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;
  const PocketKidsEverydayConversationQuestPage({super.key, required this.day, this.onCompleted});

  static Future<void> show(BuildContext context, {required int day, VoidCallback? onCompleted}) {
    return Navigator.push(context, MaterialPageRoute(builder: (_) => PocketKidsEverydayConversationQuestPage(day: day, onCompleted: onCompleted)));
  }

  @override
  State<PocketKidsEverydayConversationQuestPage> createState() => _PocketKidsEverydayConversationQuestPageState();
}

class _PocketKidsEverydayConversationQuestPageState extends State<PocketKidsEverydayConversationQuestPage> {
  final FlutterTts _tts = FlutterTts();
  int _step = 0;

  final List<Map<String, dynamic>> _dialogs = [
    {
      'partner': 'Mascot Leo 🦁',
      'ask': 'Good morning! How are you today?',
      'replies': ['I am wonderful! ☀️', 'Good night! 🌙', 'Goodbye! 👋'],
      'correct': 'I am wonderful! ☀️',
      'ml': 'സുപ്രഭാതം! സുഖമാണോ?',
    },
    {
      'partner': 'Mascot Leo 🦁',
      'ask': 'May I have an apple please?',
      'replies': ['Here you go! 🍎', 'I do not want. ❌', 'No thank you! 👋'],
      'correct': 'Here you go! 🍎',
      'ml': 'ഒരു ആപ്പിൾ തരാമോ?',
    },
  ];

  @override
  void initState() {
    super.initState();
    _prompt();
  }

  Future<void> _prompt() async {
    final d = _dialogs[_step];
    await _tts.speak(d['ask'] as String);
  }

  void _choose(String reply) async {
    final d = _dialogs[_step];
    if (reply == d['correct']) {
      HapticFeedback.heavyImpact();
      setState(() => _step++);
      await _tts.speak("Wonderful answer!");
      if (_step >= _dialogs.length) {
        PocketKidsService.addKidsScore(20);
        widget.onCompleted?.call();
        Navigator.pop(context);
      } else {
        _prompt();
      }
    } else {
      await _tts.speak("Let's reply politely! Try another reply!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _step < _dialogs.length ? _dialogs[_step] : _dialogs.last;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white)),
                  Text("Conversation Quest 💬", style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(onPressed: _prompt, icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700))),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF8CD837), width: 2)),
                child: Column(
                  children: [
                    const Text("🦁", style: TextStyle(fontSize: 54)),
                    const SizedBox(height: 8),
                    Text(d['partner'] as String, style: GoogleFonts.outfit(color: const Color(0xFF8CD837), fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Text("\"${d['ask']}\"", textAlign: TextAlign.center, style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("💡 ${d['ml']}", style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13)),
                  ],
                ),
              ),
              const Spacer(),
              Column(
                children: (d['replies'] as List<String>).map((r) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: () => _choose(r),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(r, style: GoogleFonts.outfit(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
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

