import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';

/// 🐮 Word Builder Model with Cute Cartoon Illustration & Sound Phonics
class KumiWordItem {
  final String word;
  final String emoji;
  final String category;
  final String meaningMl;
  final Color themeColor;

  const KumiWordItem({
    required this.word,
    required this.emoji,
    required this.category,
    required this.meaningMl,
    required this.themeColor,
  });
}

/// 🐮 Kumi Word Builder Page (Reference Image 1 Screen 2 & Image 5 Screen 2)
///
/// Features:
/// - Cute cartoon animal/object vector card (Cow 🐮, Zebra 🦓, Lion 🦁, Elephant 🐘, etc.)
/// - Soft pastel rounded square letter slots [ C ] [ O ] [ W ] [ _ ]
/// - Scrambled letter keyboard tiles below
/// - Hint button with lightbulb icon 💡 (reveals next letter)
/// - Check button verifying solution, cheering with confetti and TTS audio
class PocketKidsKumiWordBuilderPage extends StatefulWidget {
  final String category;
  final int day;
  final VoidCallback? onCompleted;

  const PocketKidsKumiWordBuilderPage({
    super.key,
    this.category = 'Animals',
    this.day = 1,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    String category = 'Animals',
    int day = 1,
    VoidCallback? onCompleted,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKidsKumiWordBuilderPage(
          category: category,
          day: day,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketKidsKumiWordBuilderPage> createState() =>
      _PocketKidsKumiWordBuilderPageState();
}

class _PocketKidsKumiWordBuilderPageState
    extends State<PocketKidsKumiWordBuilderPage>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();

  // Curated database of cute cartoon words
  static const List<KumiWordItem> _allWords = [
    KumiWordItem(word: 'COW', emoji: '🐮', category: 'Animals', meaningMl: 'പശു / Cow', themeColor: Color(0xFF60A5FA)),
    KumiWordItem(word: 'ZEBRA', emoji: '🦓', category: 'Animals', meaningMl: 'സീബ്ര / Zebra', themeColor: Color(0xFFA78BFA)),
    KumiWordItem(word: 'LION', emoji: '🦁', category: 'Animals', meaningMl: 'സിംഹം / Lion', themeColor: Color(0xFFFBBF24)),
    KumiWordItem(word: 'CAT', emoji: '🐱', category: 'Animals', meaningMl: 'പൂച്ച / Cat', themeColor: Color(0xFFF472B6)),
    KumiWordItem(word: 'DOG', emoji: '🐶', category: 'Animals', meaningMl: 'പട്ടി / Dog', themeColor: Color(0xFF34D399)),
    KumiWordItem(word: 'DUCK', emoji: '🦆', category: 'Animals', meaningMl: 'താറാവ് / Duck', themeColor: Color(0xFFF97316)),
    KumiWordItem(word: 'PANDA', emoji: '🐼', category: 'Animals', meaningMl: 'പാണ്ട / Panda', themeColor: Color(0xFF64748B)),
    KumiWordItem(word: 'FROG', emoji: '🐸', category: 'Animals', meaningMl: 'തവള / Frog', themeColor: Color(0xFF10B981)),
    KumiWordItem(word: 'APPLE', emoji: '🍎', category: 'Fruits', meaningMl: 'ആപ്പിൾ / Apple', themeColor: Color(0xFFEF4444)),
    KumiWordItem(word: 'MANGO', emoji: '🥭', category: 'Fruits', meaningMl: 'മാങ്ങ / Mango', themeColor: Color(0xFFF59E0B)),
    KumiWordItem(word: 'BANANA', emoji: '🍌', category: 'Fruits', meaningMl: 'വാഴപ്പഴം / Banana', themeColor: Color(0xFFFACC15)),
    KumiWordItem(word: 'GRAPES', emoji: '🍇', category: 'Fruits', meaningMl: 'മുന്തിരി / Grapes', themeColor: Color(0xFF8B5CF6)),
    KumiWordItem(word: 'CARROT', emoji: '🥕', category: 'Vegetables', meaningMl: 'കാരറ്റ് / Carrot', themeColor: Color(0xFFEA580C)),
    KumiWordItem(word: 'TOMATO', emoji: '🍅', category: 'Vegetables', meaningMl: 'തക്കാളി / Tomato', themeColor: Color(0xFFDC2626)),
    KumiWordItem(word: 'CORN', emoji: '🌽', category: 'Vegetables', meaningMl: 'ചോളം / Corn', themeColor: Color(0xFFEAB308)),
    KumiWordItem(word: 'STAR', emoji: '⭐', category: 'Knowledge', meaningMl: 'നക്ഷത്രം / Star', themeColor: Color(0xFFF59E0B)),
    KumiWordItem(word: 'MOON', emoji: '🌙', category: 'Knowledge', meaningMl: 'ചന്ദ്രൻ / Moon', themeColor: Color(0xFF38BDF8)),
    KumiWordItem(word: 'SUN', emoji: '☀️', category: 'Knowledge', meaningMl: 'സൂര്യൻ / Sun', themeColor: Color(0xFFF97316)),
    KumiWordItem(word: 'TREE', emoji: '🌳', category: 'Knowledge', meaningMl: 'മരം / Tree', themeColor: Color(0xFF059669)),
  ];

  late List<KumiWordItem> _sessionWords;
  int _currentIndex = 0;
  List<String> _targetLetters = [];
  final List<String?> _placedLetters = [];
  List<String> _scrambledKeyboard = [];
  final Set<int> _usedKeyIndices = {};

  int _hintsLeft = 3;
  int _score = 0;
  bool _isChecked = false;
  bool _isCorrect = false;

  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _initTts();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Filter by requested category or fallback to all
    final filtered = _allWords
        .where((w) => w.category.toLowerCase() == widget.category.toLowerCase())
        .toList();
    _sessionWords = filtered.isNotEmpty ? filtered : _allWords;
    _sessionWords.shuffle(math.Random(widget.day));

    _loadCurrentWord();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.3);
      await _tts.setSpeechRate(0.42);
    } catch (_) {}
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void _loadCurrentWord() {
    final item = _sessionWords[_currentIndex % _sessionWords.length];
    _targetLetters = item.word.toUpperCase().split('');
    _placedLetters.clear();
    for (int i = 0; i < _targetLetters.length; i++) {
      _placedLetters.add(null);
    }
    _usedKeyIndices.clear();
    _isChecked = false;
    _isCorrect = false;

    // Generate keyboard letters: target letters + distractors to make 10 keys (2 rows of 5)
    final pool = List<String>.from(_targetLetters);
    const dist = ['A', 'E', 'O', 'I', 'U', 'R', 'T', 'S', 'B', 'P', 'D', 'M'];
    final rng = math.Random();
    while (pool.length < 10) {
      final pick = dist[rng.nextInt(dist.length)];
      pool.add(pick);
    }
    pool.shuffle();
    _scrambledKeyboard = pool;

    _speak("Build the word for ${item.word}!");
    setState(() {});
  }

  void _onKeyboardLetterTap(int keyIndex, String letter) {
    if (_usedKeyIndices.contains(keyIndex) || _isChecked) return;

    // Find first empty slot
    final emptySlot = _placedLetters.indexOf(null);
    if (emptySlot == -1) return;

    HapticFeedback.lightImpact();
    PocketGameAudioService.instance.playPopSound();

    setState(() {
      _placedLetters[emptySlot] = letter;
      _usedKeyIndices.add(keyIndex);
    });

    _speak(letter.toLowerCase());
  }

  void _onPlacedLetterTap(int slotIndex) {
    if (_isChecked) return;
    final letter = _placedLetters[slotIndex];
    if (letter == null) return;

    HapticFeedback.selectionClick();

    // Release the key index
    for (int i = 0; i < _scrambledKeyboard.length; i++) {
      if (_scrambledKeyboard[i] == letter && _usedKeyIndices.contains(i)) {
        _usedKeyIndices.remove(i);
        break;
      }
    }

    setState(() {
      _placedLetters[slotIndex] = null;
    });
  }

  void _useHint() {
    if (_hintsLeft <= 0 || _isChecked) return;

    // Find next empty or incorrect slot
    for (int i = 0; i < _targetLetters.length; i++) {
      if (_placedLetters[i] != _targetLetters[i]) {
        // Remove whatever was there
        if (_placedLetters[i] != null) {
          _onPlacedLetterTap(i);
        }
        // Find matching key
        final neededLetter = _targetLetters[i];
        for (int k = 0; k < _scrambledKeyboard.length; k++) {
          if (_scrambledKeyboard[k] == neededLetter &&
              !_usedKeyIndices.contains(k)) {
            _onKeyboardLetterTap(k, neededLetter);
            break;
          }
        }
        _hintsLeft--;
        HapticFeedback.heavyImpact();
        PocketGameAudioService.instance.playCoinSound();
        _speak(neededLetter);
        setState(() {});
        return;
      }
    }
  }

  Future<void> _checkWord() async {
    final spelled = _placedLetters.join('');
    final target = _targetLetters.join('');

    setState(() {
      _isChecked = true;
      _isCorrect = spelled == target;
    });

    if (_isCorrect) {
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playCoinSound();
      _bounceController.forward(from: 0.0);
      _score += 15;
      await PocketKidsService.addKidsScore(15);
      await PocketKidsService.addStars(1);
      _speak("Awesome! $target! ${_sessionWords[_currentIndex].meaningMl}");
    } else {
      HapticFeedback.heavyImpact();
      PocketGameSfx.instance.playErrorBuzz();
      _speak("Try again! You can do it!");
    }
  }

  void _nextWord() {
    if (_currentIndex < _sessionWords.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _loadCurrentWord();
    } else {
      // Completed all words in session!
      widget.onCompleted?.call();
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆 🌟 🎈', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Word Champion!',
              style: GoogleFonts.fredoka(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You built all the words!\n+$_score Kids Score (KS) & Star Cookies 🍪',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: Text(
                'Continue Adventure 🚀',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final curWord = _sessionWords[_currentIndex % _sessionWords.length];
    final progress = (_currentIndex + 1) / _sessionWords.length;
    final allSlotsFilled = !_placedLetters.contains(null);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF9), // Cream Soft Minimalist Background
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header Bar: Close Button, Pink Progress Bar, Gem Counter (Image 1 Screen 2)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Pink Progress Bar
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEC4899)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Gem Counter Pill: 💎 25
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF2F8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFBCFE8), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Text('💎', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text(
                          '${25 + _score}',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFDB2777),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Main Content Area (Scrollable to prevent any overflow on smaller devices)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    // Title Header
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Spelling • ${curWord.category}',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Build the word',
                            style: GoogleFonts.fredoka(
                              color: const Color(0xFF0F172A),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cute Cartoon Animal Card (Image 1 Screen 2 & Image 5 Screen 2)
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: curWord.themeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: curWord.themeColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Soft background landscape curve
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 60,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF86EFAC).withValues(alpha: 0.35),
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
                              ),
                            ),
                          ),
                          // Big Cartoon Emoji Mascot
                          ScaleTransition(
                            scale: Tween<double>(begin: 1.0, end: 1.15).animate(
                              CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
                            ),
                            child: Text(
                              curWord.emoji,
                              style: const TextStyle(fontSize: 90),
                            ),
                          ),
                          // Audio Speak Mascot Button
                          Positioned(
                            bottom: 12,
                            right: 14,
                            child: GestureDetector(
                              onTap: () => _speak(curWord.word),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.volume_up_rounded, color: Color(0xFF0284C7), size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Target Letter Slot Trays [ Z ] [ E ] [ B ] [ R ] [ _ ]
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: List.generate(_targetLetters.length, (slotIdx) {
                        final placed = _placedLetters[slotIdx];
                        final isSlotEmpty = placed == null;

                        Color slotBg = const Color(0xFFEDE9FE); // Soft pastel purple
                        Color textColor = const Color(0xFF6D28D9);
                        Border border = Border.all(color: Colors.transparent);

                        if (_isChecked) {
                          if (_isCorrect) {
                            slotBg = const Color(0xFFDCFCE7);
                            textColor = const Color(0xFF15803D);
                            border = Border.all(color: const Color(0xFF22C55E), width: 2);
                          } else {
                            slotBg = const Color(0xFFFEE2E2);
                            textColor = const Color(0xFFB91C1C);
                            border = Border.all(color: const Color(0xFFEF4444), width: 2);
                          }
                        }

                        return GestureDetector(
                          onTap: () => _onPlacedLetterTap(slotIdx),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 52,
                            height: 54,
                            decoration: BoxDecoration(
                              color: isSlotEmpty ? Colors.white : slotBg,
                              borderRadius: BorderRadius.circular(16),
                              border: isSlotEmpty
                                  ? Border.all(
                                      color: const Color(0xFFCBD5E1),
                                      width: 2,
                                      style: BorderStyle.solid,
                                    )
                                  : border,
                              boxShadow: isSlotEmpty
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.06),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              placed ?? '',
                              style: GoogleFonts.fredoka(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 24),

                    // Scrambled Letter Keyboard Grid (2 Rows of 5 Rounded Square Tiles)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _scrambledKeyboard.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.0,
                      ),
                      itemBuilder: (context, keyIdx) {
                        final letter = _scrambledKeyboard[keyIdx];
                        final isUsed = _usedKeyIndices.contains(keyIdx);

                        return GestureDetector(
                          onTap: () => _onKeyboardLetterTap(keyIdx, letter),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: isUsed ? const Color(0xFFF1F5F9) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isUsed
                                    ? const Color(0xFFE2E8F0)
                                    : const Color(0xFFCBD5E1),
                                width: 1.5,
                              ),
                              boxShadow: isUsed
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.06),
                                        blurRadius: 4,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              letter,
                              style: GoogleFonts.fredoka(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isUsed ? Colors.black26 : const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // 3. Bottom Action Bar: [ 💡 Hint (3) ] and [ Check / Next ] Button (Image 1 Screen 2)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 💡 Hint Button
                  GestureDetector(
                    onTap: _useHint,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(
                            'Hint',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF475569),
                              fontSize: 14,
                            ),
                          ),
                          if (_hintsLeft > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEC4899),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$_hintsLeft',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Check / Next Action Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_isChecked) {
                          if (_isCorrect) {
                            _nextWord();
                          } else {
                            // Retry current word
                            _loadCurrentWord();
                          }
                        } else if (allSlotsFilled) {
                          _checkWord();
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _isChecked
                              ? (_isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                              : (allSlotsFilled ? const Color(0xFF38BDF8) : const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: allSlotsFilled
                              ? [
                                  BoxShadow(
                                    color: (_isChecked
                                            ? (_isCorrect
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFEF4444))
                                            : const Color(0xFF38BDF8))
                                        .withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _isChecked
                              ? (_isCorrect ? 'Next Word ➔' : 'Try Again 🔄')
                              : 'Check',
                          style: GoogleFonts.outfit(
                            color: allSlotsFilled || _isChecked
                                ? Colors.white
                                : const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
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
