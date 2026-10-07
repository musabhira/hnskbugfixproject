import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🎯 Day 1 Quick Diagnostic Bottom Sheet (User Audio Directive!)
/// Instead of fixed Zero/Middle/Higher level tags:
/// Asks user directly:
/// 1. "Do you know the English Alphabet?" (If yes -> skip alphabet step; if no -> step 1 is alphabet).
/// 2. "Do you know basic beginner vocabularies?" (Shows words with ticks).
class PocketDay1DiagnosticSheet extends StatefulWidget {
  final String? userId;
  final Function(bool knowsAlphabet, bool knowsVocab)? onCompleted;

  const PocketDay1DiagnosticSheet({
    super.key,
    this.userId,
    this.onCompleted,
  });

  static Future<Map<String, bool>?> show(
    BuildContext context, {
    String? userId,
    Function(bool knowsAlphabet, bool knowsVocab)? onCompleted,
  }) {
    return showModalBottomSheet<Map<String, bool>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PocketDay1DiagnosticSheet(
        userId: userId,
        onCompleted: onCompleted,
      ),
    );
  }

  @override
  State<PocketDay1DiagnosticSheet> createState() =>
      _PocketDay1DiagnosticSheetState();
}

class _PocketDay1DiagnosticSheetState extends State<PocketDay1DiagnosticSheet> {
  bool _knowsAlphabet = false;
  bool _knowsVocab = false;
  final Set<String> _knownWords = {};

  final List<Map<String, String>> _sampleVocabWords = const [
    {'word': 'Apple', 'emoji': '🍎', 'ml': 'ആപ്പിൾ'},
    {'word': 'Book', 'emoji': '📖', 'ml': 'പുസ്തകം'},
    {'word': 'Water', 'emoji': '💧', 'ml': 'വെള്ളം'},
    {'word': 'Dog', 'emoji': '🐶', 'ml': 'നായ'},
    {'word': 'Cat', 'emoji': '🐱', 'ml': 'പൂച്ച'},
    {'word': 'Friend', 'emoji': '🤝', 'ml': 'സുഹൃത്ത്'},
  ];

  @override
  void initState() {
    super.initState();
    _loadPrevious();
  }

  Future<void> _loadPrevious() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = widget.userId ?? 'guest';
    final a = prefs.getBool('pm_day1_knows_alphabet_$uid') ?? false;
    final v = prefs.getBool('pm_day1_knows_vocab_$uid') ?? false;
    if (mounted) {
      setState(() {
        _knowsAlphabet = a;
        _knowsVocab = v;
        if (v) {
          _knownWords.addAll(_sampleVocabWords.map((e) => e['word']!));
        }
      });
    }
  }

  Future<void> _saveAndProceed() async {
    HapticFeedback.heavyImpact();
    final prefs = await SharedPreferences.getInstance();
    final uid = widget.userId ?? 'guest';
    await prefs.setBool('pm_day1_knows_alphabet_$uid', _knowsAlphabet);
    await prefs.setBool('pm_day1_knows_vocab_$uid', _knowsVocab);
    await prefs.setBool('pm_day1_diagnostic_done_$uid', true);

    widget.onCompleted?.call(_knowsAlphabet, _knowsVocab);
    if (mounted) {
      Navigator.pop(context, {
        'knowsAlphabet': _knowsAlphabet,
        'knowsVocab': _knowsVocab,
        'skipStep1': _knowsAlphabet,
        'skipStep2': _knowsVocab,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Color(0xFF38BDF8), width: 2)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🎯', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day 1 Quick English Check',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'നിങ്ങളുടെ നിലവാരം ക്രമീകരിക്കാൻ 2 ചോദ്യങ്ങൾ:',
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Question 1: Alphabet Knowledge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _knowsAlphabet ? const Color(0xFF10B981) : Colors.white12,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🔤', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '1. Did you know the English Alphabet (A–Z)?',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ഇംഗ്ലീഷ് അക്ഷരങ്ങളും (A–Z) അവയുടെ ശബ്ദങ്ങളും അറിയാമോ?',
                    style: GoogleFonts.inter(color: Colors.white60, fontSize: 11.5),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: !_knowsAlphabet
                                ? const Color(0xFF38BDF8).withValues(alpha: 0.2)
                                : const Color(0xFF0F172A),
                            side: BorderSide(
                              color: !_knowsAlphabet ? const Color(0xFF38BDF8) : Colors.white12,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            setState(() => _knowsAlphabet = false);
                          },
                          child: Text(
                            '❌ Start with ABCD',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _knowsAlphabet
                                ? const Color(0xFF10B981).withValues(alpha: 0.25)
                                : const Color(0xFF0F172A),
                            side: BorderSide(
                              color: _knowsAlphabet ? const Color(0xFF10B981) : Colors.white12,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            setState(() => _knowsAlphabet = true);
                          },
                          child: Text(
                            '✅ Yes, I know Alphabet!',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_knowsAlphabet)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '⚡ Step 1 (Alphabet basics) will be marked as mastered!',
                        style: GoogleFonts.inter(color: const Color(0xFF6EE7B7), fontSize: 11),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Question 2: Beginner Vocabulary Level
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _knowsVocab ? const Color(0xFF10B981) : Colors.white12,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('📖', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '2. Do you know these beginner words?',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'താഴെയുള്ള വാക്കുകൾ തൊട്ട് അറിയാവുന്നവ ടിക്ക് ചെയ്യുക:',
                    style: GoogleFonts.inter(color: Colors.white60, fontSize: 11.5),
                  ),
                  const SizedBox(height: 12),

                  // Word chips to tick
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sampleVocabWords.map((item) {
                      final w = item['word']!;
                      final emoji = item['emoji']!;
                      final isSelected = _knownWords.contains(w);

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            if (isSelected) {
                              _knownWords.remove(w);
                            } else {
                              _knownWords.add(w);
                            }
                            _knowsVocab = _knownWords.length >= 4;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF10B981).withValues(alpha: 0.25)
                                : const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF10B981) : Colors.white24,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(emoji, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text(
                                w,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 14),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_knownWords.length} of ${_sampleVocabWords.length} words ticked',
                        style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            if (_knownWords.length == _sampleVocabWords.length) {
                              _knownWords.clear();
                              _knowsVocab = false;
                            } else {
                              _knownWords.addAll(_sampleVocabWords.map((e) => e['word']!));
                              _knowsVocab = true;
                            }
                          });
                        },
                        child: Text(
                          _knownWords.length == _sampleVocabWords.length ? 'Clear' : 'Tick All ✓',
                          style: GoogleFonts.outfit(color: const Color(0xFF38BDF8), fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                ),
                onPressed: _saveAndProceed,
                child: Text(
                  'CONFIRM & START DAY 1 ➔',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
