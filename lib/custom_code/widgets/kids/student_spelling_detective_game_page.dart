import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';

const Color kSBg = Color(0xFF0F172A);
const Color kSCard = Color(0xFF1E293B);
const Color kSGold = Color(0xFFFFD700);
const Color kSEm = Color(0xFF10B981);
const Color kSCy = Color(0xFF38BDF8);

class _SpellItem {
  final String sentence;
  final Map<String, List<String>> corrections;

  const _SpellItem({
    required this.sentence,
    required this.corrections,
  });
}

const List<_SpellItem> _kSpellList = [
  _SpellItem(
    sentence: 'The princpal gave a wonderfull speech today .',
    corrections: {
      'princpal': ['principal', 'principle', 'princaple'],
      'wonderfull': ['wonderful', 'wonderfal', 'wondeful'],
    },
  ),
  _SpellItem(
    sentence: 'My freind will recieve a prize .',
    corrections: {
      'freind': ['friend', 'freend', 'frend'],
      'recieve': ['receive', 'receeve', 'receve'],
    },
  ),
  _SpellItem(
    sentence: 'We went to the libary to borow books .',
    corrections: {
      'libary': ['library', 'librery', 'liberry'],
      'borow': ['borrow', 'borrough', 'borraw'],
    },
  ),
];

/// 🔍 Step 11: Gamified Spelling Detective (Word-Bank Snap Engine)
class StudentSpellingDetectiveGamePage extends StatefulWidget {
  final int day;
  final int stepIndex;
  final String? userId;
  final void Function(int finishedStep)? onStepFinished;

  const StudentSpellingDetectiveGamePage({
    super.key,
    this.day = 1,
    this.stepIndex = 11,
    this.userId,
    this.onStepFinished,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    int stepIndex = 11,
    String? userId,
    void Function(int finishedStep)? onStepFinished,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentSpellingDetectiveGamePage(
          day: day,
          stepIndex: stepIndex,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<StudentSpellingDetectiveGamePage> createState() =>
      _StudentSpellingDetectiveGameState();
}

class _StudentSpellingDetectiveGameState extends State<StudentSpellingDetectiveGamePage> {
  final FlutterTts _tts = FlutterTts();
  int _roundIdx = 0;
  int _xp = 35;
  late List<String> _tokens;
  final Set<int> _fixedIndices = {};
  int? _selectedTokenIdx;
  List<String> _currentOptions = [];

  _SpellItem get _item => _kSpellList[_roundIdx];

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadRound();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
    } catch (_) {}
  }

  void _loadRound() {
    setState(() {
      _tokens = _item.sentence.split(' ');
      _fixedIndices.clear();
      _selectedTokenIdx = null;
      _currentOptions = [];
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  String _clean(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

  void _onTokenTap(int idx) {
    if (_fixedIndices.contains(idx)) return;
    final rawWord = _tokens[idx];
    final cleanWord = _clean(rawWord);

    if (_item.corrections.containsKey(cleanWord)) {
      PocketGameSfx.instance.playTilePop();
      setState(() {
        _selectedTokenIdx = idx;
        _currentOptions = List<String>.from(_item.corrections[cleanWord]!)..shuffle();
      });
    } else {
      PocketGameSfx.instance.playErrorBuzz();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔍 That word is spelled correctly! Keep investigating.'),
          duration: Duration(milliseconds: 900),
          backgroundColor: Color(0xFF334155),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onOptionTap(String opt) {
    if (_selectedTokenIdx == null) return;
    final targetIdx = _selectedTokenIdx!;
    final cleanTarget = _clean(_tokens[targetIdx]);
    final correct = _item.corrections[cleanTarget]![0];

    if (opt == correct) {
      PocketGameSfx.instance.playSnapCorrect();
      _tts.speak(opt);
      setState(() {
        _tokens[targetIdx] = opt;
        _fixedIndices.add(targetIdx);
        _selectedTokenIdx = null;
        _currentOptions = [];
      });

      if (_fixedIndices.length == _item.corrections.length) {
        _onSentenceComplete();
      }
    } else {
      PocketGameSfx.instance.playErrorBuzz();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Not the right spelling, try another one!'),
          duration: Duration(milliseconds: 900),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onSentenceComplete() async {
    PocketGameSfx.instance.playVictory();
    _tts.speak(_tokens.join(' '));
    setState(() => _xp += 30);
    widget.onStepFinished?.call(widget.stepIndex);

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: kSCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: kSGold, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔍 ✨ 🕵️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(
                'Case Solved! All Typos Fixed',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kSGold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                '+30 XP  •  ⭐⭐⭐',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kSEm,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  if (_roundIdx < _kSpellList.length - 1) {
                    setState(() {
                      _roundIdx++;
                      _loadRound();
                    });
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
                child: Text(
                  _roundIdx < _kSpellList.length - 1 ? 'NEXT MYSTERY ▶' : 'FINISH QUEST 🏆',
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
      backgroundColor: kSBg,
      appBar: AppBar(
        backgroundColor: kSBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Spelling Detective 🔍',
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
                  color: kSCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kSGold.withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, color: kSGold, size: 16),
                    Text(' $_xp XP', style: GoogleFonts.outfit(color: kSGold, fontWeight: FontWeight.bold, fontSize: 13)),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Mystery Case ${_roundIdx + 1} of ${_kSpellList.length}',
                    style: GoogleFonts.outfit(color: kSGold, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const Spacer(),
                  Text(
                    'Found: ${_fixedIndices.length} / ${_item.corrections.length}',
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Crime Scene Chalkboard / Note Card
            Expanded(
              flex: 4,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: kSCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kSCy.withValues(alpha: 0.4), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_rounded, color: kSGold, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Tap the misspelled word below:',
                            style: GoogleFonts.outfit(color: kSGold, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          for (int i = 0; i < _tokens.length; i++)
                            GestureDetector(
                              onTap: () => _onTokenTap(i),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _fixedIndices.contains(i)
                                      ? kSEm.withValues(alpha: 0.25)
                                      : _selectedTokenIdx == i
                                          ? kSGold.withValues(alpha: 0.25)
                                          : Colors.white10,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _fixedIndices.contains(i)
                                        ? kSEm
                                        : _selectedTokenIdx == i
                                            ? kSGold
                                            : Colors.white24,
                                    width: _selectedTokenIdx == i || _fixedIndices.contains(i) ? 2 : 1,
                                  ),
                                ),
                                child: Text(
                                  _tokens[i],
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _fixedIndices.contains(i)
                                        ? kSEm
                                        : _selectedTokenIdx == i
                                            ? kSGold
                                            : Colors.white,
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

            // Options Word Bank
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              decoration: BoxDecoration(
                color: const Color(0xFF162032),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: kSGold.withValues(alpha: 0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedTokenIdx != null
                        ? 'Select the correct spelling for: "${_tokens[_selectedTokenIdx!]}"'
                        : 'Tap a suspicious word in the sentence above to reveal correct choices!',
                    style: GoogleFonts.outfit(
                      color: _selectedTokenIdx != null ? kSGold : Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_currentOptions.isNotEmpty)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final opt in _currentOptions)
                          GestureDetector(
                            onTap: () => _onOptionTap(opt),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: kSEm.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: kSEm, width: 1.8),
                              ),
                              child: Text(
                                opt,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Center(
                        child: Text(
                          '🔎 Tap words above to inspect',
                          style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
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
