import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';

class _GermanTraceLetter {
  final String letter;
  final String sound;
  final String example;
  final String meaning;

  const _GermanTraceLetter({
    required this.letter,
    required this.sound,
    required this.example,
    required this.meaning,
  });
}

/// ✍️ Gamified German Alphabet Writing & Tracing Canvas
class GermanAlphabetWritingGamePage extends StatefulWidget {
  final int day;
  final int stepIndex;
  final String range; // 'A-M', 'N-Z', 'UMLAUT'
  final String? userId;
  final Function(int)? onStepFinished;

  const GermanAlphabetWritingGamePage({
    super.key,
    this.day = 1,
    this.stepIndex = 6,
    this.range = 'A-M',
    this.userId,
    this.onStepFinished,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    int stepIndex = 6,
    String range = 'A-M',
    String? userId,
    Function(int)? onStepFinished,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GermanAlphabetWritingGamePage(
          day: day,
          stepIndex: stepIndex,
          range: range,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<GermanAlphabetWritingGamePage> createState() =>
      _GermanAlphabetWritingGamePageState();
}

class _GermanAlphabetWritingGamePageState
    extends State<GermanAlphabetWritingGamePage> {
  final FlutterTts _tts = FlutterTts();
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  int _index = 0;
  int _stars = 0;

  late final List<_GermanTraceLetter> _letters;

  @override
  void initState() {
    super.initState();
    _letters = _buildLetters(widget.range);
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('de-DE');
      await _tts.setSpeechRate(0.42);
    } catch (_) {}
  }

  List<_GermanTraceLetter> _buildLetters(String range) {
    if (range == 'NUMBERS') {
      return const [
        _GermanTraceLetter(letter: '1', sound: 'eins (ഐൻസ്)', example: 'Eins', meaning: 'One'),
        _GermanTraceLetter(letter: '2', sound: 'zwei (ത്സ്വൈ)', example: 'Zwei', meaning: 'Two'),
        _GermanTraceLetter(letter: '3', sound: 'drei (ദ്രൈ)', example: 'Drei', meaning: 'Three'),
        _GermanTraceLetter(letter: '4', sound: 'vier (ഫിയർ)', example: 'Vier', meaning: 'Four'),
        _GermanTraceLetter(letter: '5', sound: 'fünf (ഫ്യൂൺഫ്)', example: 'Fünf', meaning: 'Five'),
        _GermanTraceLetter(letter: '6', sound: 'sechs (സെക്സ്)', example: 'Sechs', meaning: 'Six'),
        _GermanTraceLetter(letter: '7', sound: 'sieben (സീബൻ)', example: 'Sieben', meaning: 'Seven'),
        _GermanTraceLetter(letter: '8', sound: 'acht (അഖ്ത്)', example: 'Acht', meaning: 'Eight'),
        _GermanTraceLetter(letter: '9', sound: 'neun (നോയ്ൻ)', example: 'Neun', meaning: 'Nine'),
        _GermanTraceLetter(letter: '10', sound: 'zehn (ത്‌സേൻ)', example: 'Zehn', meaning: 'Ten'),
      ];
    }
    if (range == 'N-Z') {
      return const [
        _GermanTraceLetter(letter: 'N', sound: 'en (എൻ)', example: 'Nacht', meaning: 'Night'),
        _GermanTraceLetter(letter: 'O', sound: 'oh (ഓ)', example: 'Ohr', meaning: 'Ear'),
        _GermanTraceLetter(letter: 'P', sound: 'peh (പേ)', example: 'Post', meaning: 'Mail'),
        _GermanTraceLetter(letter: 'R', sound: 'er (എർ)', example: 'Rot', meaning: 'Red'),
        _GermanTraceLetter(letter: 'S', sound: 'es (എസ്)', example: 'Sonne', meaning: 'Sun'),
        _GermanTraceLetter(letter: 'T', sound: 'teh (തേ)', example: 'Tag', meaning: 'Day'),
        _GermanTraceLetter(letter: 'W', sound: 'veh (വേ)', example: 'Wasser', meaning: 'Water'),
        _GermanTraceLetter(letter: 'Z', sound: 'tset (റ്റ്സെറ്റ്)', example: 'Zeit', meaning: 'Time'),
      ];
    }
    if (range == 'UMLAUT') {
      return const [
        _GermanTraceLetter(letter: 'Ä', sound: 'eh (ഏ)', example: 'Äpfel', meaning: 'Apples'),
        _GermanTraceLetter(letter: 'Ö', sound: 'oe (ഓ+ഏ)', example: 'Öl', meaning: 'Oil'),
        _GermanTraceLetter(letter: 'Ü', sound: 'ue (ഊ+ഈ)', example: 'Über', meaning: 'Over'),
        _GermanTraceLetter(letter: 'ß', sound: 'ess-tset (സ്സ്)', example: 'Straße', meaning: 'Street'),
      ];
    }
    return const [
      _GermanTraceLetter(letter: 'A', sound: 'ah (ആ)', example: 'Apfel', meaning: 'Apple'),
      _GermanTraceLetter(letter: 'B', sound: 'beh (ബേ)', example: 'Buch', meaning: 'Book'),
      _GermanTraceLetter(letter: 'C', sound: 'tseh (റ്റ്സേ)', example: 'Café', meaning: 'Café'),
      _GermanTraceLetter(letter: 'D', sound: 'deh (ദേ)', example: 'Danke', meaning: 'Thank you'),
      _GermanTraceLetter(letter: 'E', sound: 'eh (ഏ)', example: 'Essen', meaning: 'Food'),
      _GermanTraceLetter(letter: 'G', sound: 'geh (ഗേ)', example: 'Guten Morgen', meaning: 'Good morning'),
      _GermanTraceLetter(letter: 'H', sound: 'hah (ഹാ)', example: 'Hallo', meaning: 'Hello'),
      _GermanTraceLetter(letter: 'M', sound: 'em (എം)', example: 'Morgen', meaning: 'Morning'),
    ];
  }

  Future<void> _speakCurrent() async {
    final item = _letters[_index];
    try {
      await _tts.stop();
      await _tts.speak('${item.letter}. ${item.example}');
    } catch (_) {}
  }

  bool get _hasDrawn =>
      _strokes.fold<int>(0, (sum, s) => sum + s.length) >= 6;

  Future<void> _nextLetter() async {
    HapticFeedback.mediumImpact();
    PocketGameSfx.instance.playSnapCorrect();
    setState(() {
      _stars += 10;
      _strokes.clear();
      _currentStroke = [];
    });

    if (_index + 1 < _letters.length) {
      setState(() => _index++);
      _speakCurrent();
    } else {
      await _finishStep();
    }
  }

  Future<void> _finishStep() async {
    final uid = widget.userId ?? SupaFlow.client.auth.currentUser?.id;
    final prefs = await SharedPreferences.getInstance();
    if (uid != null && uid.isNotEmpty) {
      await prefs.setBool(
          'pocket_day_${uid}_${widget.day}_step_${widget.stepIndex}_done', true);
    }
    await prefs.setBool(
        'pocket_day_guest_${widget.day}_step_${widget.stepIndex}_done', true);
    await PocketFortressDefenseService.recordTrainingPoints(35, uid);
    widget.onStepFinished?.call(widget.stepIndex);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = _letters[_index];
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '✍️ Write German (${widget.range})',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFFFFCE00).withValues(alpha: 0.5)),
            ),
            child: Text(
              '⭐ $_stars • ${_index + 1}/${_letters.length}',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFCE00),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Sound & Meaning Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF131D2D),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sound: ${item.sound}',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFCE00),
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.example} = ${item.meaning}',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _speakCurrent,
                      icon: const Icon(Icons.volume_up_rounded,
                          color: Color(0xFF38BDF8), size: 28),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Interactive Tracing Canvas
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _hasDrawn
                          ? const Color(0xFF10B981)
                          : const Color(0xFFFFCE00).withValues(alpha: 0.45),
                      width: 1.8,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        item.letter,
                        style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.12),
                          fontSize: 210,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      GestureDetector(
                        onPanStart: (d) {
                          setState(() {
                            _currentStroke = [d.localPosition];
                            _strokes.add(_currentStroke);
                          });
                        },
                        onPanUpdate: (d) {
                          setState(() {
                            _currentStroke.add(d.localPosition);
                          });
                        },
                        child: CustomPaint(
                          painter: _TracePainter(_strokes),
                          size: Size.infinite,
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: IconButton(
                          tooltip: 'Clear',
                          onPressed: () {
                            setState(() {
                              _strokes.clear();
                              _currentStroke = [];
                            });
                          },
                          icon: const Icon(Icons.refresh_rounded,
                              color: Colors.white54),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasDrawn
                        ? const Color(0xFF10B981)
                        : const Color(0xFF334155),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _hasDrawn ? _nextLetter : null,
                  icon: Icon(_index + 1 < _letters.length
                      ? Icons.arrow_forward_rounded
                      : Icons.check_circle_rounded),
                  label: Text(
                    _hasDrawn
                        ? (_index + 1 < _letters.length
                            ? 'NEXT LETTER (+10 ⭐)'
                            : 'COMPLETE WRITING (+35 PS) 🎉')
                        : 'Trace the letter above with your finger ✍️',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TracePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  _TracePainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFCE00)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TracePainter oldDelegate) => true;
}
