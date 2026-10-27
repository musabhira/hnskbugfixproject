import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';

const Color kBBg = Color(0xFF0A111F);
const Color kBCard = Color(0xFF142038);
const Color kBGold = Color(0xFFFFD700);
const Color kBEm = Color(0xFF10B981);
const Color kBCy = Color(0xFF38BDF8);

class _BioHero {
  final String icon;
  final String category;
  final String name;
  final String born;
  final String profession;
  final String deed;
  final List<String> possibleProfessions;
  final List<String> possibleDeeds;
  final List<String> traits;

  const _BioHero({
    required this.icon,
    required this.category,
    required this.name,
    required this.born,
    required this.profession,
    required this.deed,
    required this.possibleProfessions,
    required this.possibleDeeds,
    required this.traits,
  });
}

const List<_BioHero> _kHeroes = [
  _BioHero(
    icon: '🔬',
    category: 'Legendary Scientist',
    name: 'Marie Curie',
    born: '1867, Warsaw',
    profession: 'Physicist & Chemist',
    deed: 'Discovered radioactivity and won 2 Nobel Prizes',
    possibleProfessions: ['Physicist & Chemist', 'Doctor', 'Astronaut'],
    possibleDeeds: [
      'Discovered radioactivity and won 2 Nobel Prizes',
      'Walked on the moon',
      'Built a wooden ship',
    ],
    traits: ['Curious', 'Brave', 'Hardworking', 'Humble'],
  ),
  _BioHero(
    icon: '🏏',
    category: 'Legendary Sports Hero',
    name: 'Sachin Tendulkar',
    born: '1973, Mumbai',
    profession: 'Master Cricketer',
    deed: 'Scored 100 international centuries for India',
    possibleProfessions: ['Master Cricketer', 'Swimmer', 'Pilot'],
    possibleDeeds: [
      'Scored 100 international centuries for India',
      'Climbed Mount Everest',
      'Invented the telephone',
    ],
    traits: ['Disciplined', 'Determined', 'Team Player', 'Humble'],
  ),
];

/// 👤 Step 8: Gamified Legend Bio Creator (Word-Bank Snap Engine)
class StudentBioCreatorGamePage extends StatefulWidget {
  final int day;
  final int stepIndex;
  final String? userId;
  final void Function(int finishedStep)? onStepFinished;

  const StudentBioCreatorGamePage({
    super.key,
    this.day = 1,
    this.stepIndex = 8,
    this.userId,
    this.onStepFinished,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    int stepIndex = 8,
    String? userId,
    void Function(int finishedStep)? onStepFinished,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentBioCreatorGamePage(
          day: day,
          stepIndex: stepIndex,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<StudentBioCreatorGamePage> createState() => _StudentBioCreatorGameState();
}

class _StudentBioCreatorGameState extends State<StudentBioCreatorGamePage> {
  final FlutterTts _tts = FlutterTts();
  int _heroIdx = 0;
  int _xp = 35;
  String? _selectedProfession;
  String? _selectedDeed;
  final Set<String> _selectedTraits = {};

  _BioHero get _hero => _kHeroes[_heroIdx];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
    } catch (_) {}
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  bool get _isComplete =>
      _selectedProfession != null &&
      _selectedDeed != null &&
      _selectedTraits.length >= 2;

  void _onProfessionTap(String prof) {
    if (prof == _hero.profession) {
      PocketGameSfx.instance.playSnapCorrect();
      _tts.speak(prof);
      setState(() => _selectedProfession = prof);
    } else {
      PocketGameSfx.instance.playErrorBuzz();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Not quite! Try the correct profession for ${_hero.name}'),
          duration: const Duration(seconds: 1),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onDeedTap(String deed) {
    if (deed == _hero.deed) {
      PocketGameSfx.instance.playSnapCorrect();
      _tts.speak(deed);
      setState(() => _selectedDeed = deed);
    } else {
      PocketGameSfx.instance.playErrorBuzz();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Try the greatest achievement of ${_hero.name}'),
          duration: const Duration(seconds: 1),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onTraitTap(String trait) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedTraits.contains(trait)) {
        _selectedTraits.remove(trait);
      } else {
        _selectedTraits.add(trait);
      }
    });
  }

  Future<void> _onFinishCard() async {
    PocketGameSfx.instance.playVictory();
    final cardBio =
        '${_hero.name}, born ${_hero.born}. ${_hero.profession}. ${_hero.deed}. Traits: ${_selectedTraits.join(', ')}.';
    _tts.speak(cardBio);

    setState(() => _xp += 30);
    widget.onStepFinished?.call(widget.stepIndex);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: kBCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: kBGold, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏅 ✨ 🌟', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(
                'Legend Profile Unlocked!',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kBGold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                '+30 XP  •  ⭐⭐⭐',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kBEm,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  if (_heroIdx < _kHeroes.length - 1) {
                    setState(() {
                      _heroIdx++;
                      _selectedProfession = null;
                      _selectedDeed = null;
                      _selectedTraits.clear();
                    });
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
                child: Text(
                  _heroIdx < _kHeroes.length - 1 ? 'NEXT HERO PROFILE ▶' : 'FINISH QUEST 🏆',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBBg,
      appBar: AppBar(
        backgroundColor: kBBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Legend Bio Creator 👤',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kBCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBGold.withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, color: kBGold, size: 16),
                    Text(' $_xp XP', style: GoogleFonts.outfit(color: kBGold, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Hero Card Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Card ${_heroIdx + 1} of ${_kHeroes.length}: ${_hero.category}',
                    style: GoogleFonts.outfit(color: kBGold, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const Spacer(),
                  Text(_hero.icon, style: const TextStyle(fontSize: 20)),
                ],
              ),
            ),

            // Visual 3D Hero Profile Card
            Expanded(
              flex: 4,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF0F3D33)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kBGold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: kBGold.withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(_hero.icon, style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _hero.name,
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Born: ${_hero.born}',
                                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: kBEm,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'HERO',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, thickness: 1, color: Colors.white24),

                      // Profession
                      Text(
                        'Profession / Title:',
                        style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedProfession != null
                              ? kBEm.withValues(alpha: 0.2)
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedProfession != null ? kBEm : Colors.white24,
                          ),
                        ),
                        child: Text(
                          _selectedProfession ?? 'Tap profession from bank below...',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _selectedProfession != null ? kBEm : Colors.white38,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Achievement
                      Text(
                        'Greatest Deed:',
                        style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedDeed != null
                              ? kBGold.withValues(alpha: 0.2)
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedDeed != null ? kBGold : Colors.white24,
                          ),
                        ),
                        child: Text(
                          _selectedDeed ?? 'Tap achievement from bank below...',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _selectedDeed != null ? kBGold : Colors.white38,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Trait Badges
                      Text(
                        'Personality Traits (Pick 2+):',
                        style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final t in _hero.traits)
                            GestureDetector(
                              onTap: () => _onTraitTap(t),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: _selectedTraits.contains(t)
                                      ? kBEm
                                      : Colors.white12,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedTraits.contains(t) ? kBEm : Colors.white24,
                                  ),
                                ),
                                child: Text(
                                  t,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedTraits.contains(t) ? Colors.black : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Word Bank Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: kBCard,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: kBEm.withValues(alpha: 0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step 1: Pick Profession  •  Step 2: Pick Deed',
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Professions Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final p in _hero.possibleProfessions)
                        GestureDetector(
                          onTap: () => _onProfessionTap(p),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedProfession == p
                                  ? kBEm.withValues(alpha: 0.3)
                                  : kBBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _selectedProfession == p ? kBEm : kBCy,
                              ),
                            ),
                            child: Text(
                              p,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Deeds Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final d in _hero.possibleDeeds)
                        GestureDetector(
                          onTap: () => _onDeedTap(d),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedDeed == d
                                  ? kBGold.withValues(alpha: 0.3)
                                  : kBBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _selectedDeed == d ? kBGold : Colors.white24,
                              ),
                            ),
                            child: Text(
                              d,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBGold,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: Colors.white12,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isComplete ? _onFinishCard : null,
                      child: Text(
                        'Unlock Legend Card 🏅',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _isComplete ? Colors.black : Colors.white38,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
