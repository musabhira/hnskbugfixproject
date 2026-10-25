import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';

/// 🦁 Model for Matching Pairs
class MatchPairItem {
  final String id;
  final String emoji;
  final String name;
  final String phonicsLetter;
  final Color themeColor;

  const MatchPairItem({
    required this.id,
    required this.emoji,
    required this.name,
    required this.phonicsLetter,
    required this.themeColor,
  });
}

/// 🔗 Pocket Kids Match It & Line Connector Page (Reference Image 2 Screen 2 & Image 5 Screen 3)
///
/// Features:
/// - Screen 1 Mode: Line-Connector Matching (Match animals to their names with connecting lines)
/// - Screen 2 Mode: 2x2 Picture-to-Letter Grid (Match picture with correct letter)
/// - Cheerful TTS voice pronunciation
/// - Instant feedback with green snap lines and chimes
/// - Awards +15 Kids Score (KS) & Star Cookies
class PocketKidsMatchItPage extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;

  const PocketKidsMatchItPage({
    super.key,
    this.day = 1,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    VoidCallback? onCompleted,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKidsMatchItPage(
          day: day,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketKidsMatchItPage> createState() => _PocketKidsMatchItPageState();
}

class _PocketKidsMatchItPageState extends State<PocketKidsMatchItPage> {
  final FlutterTts _tts = FlutterTts();

  // Curated animal sets
  static const List<MatchPairItem> _animalsPool = [
    MatchPairItem(id: '1', emoji: '🦁', name: 'Lion', phonicsLetter: 'L', themeColor: Color(0xFFFBBF24)),
    MatchPairItem(id: '2', emoji: '🐘', name: 'Elephant', phonicsLetter: 'E', themeColor: Color(0xFF93C5FD)),
    MatchPairItem(id: '3', emoji: '🐼', name: 'Panda', phonicsLetter: 'P', themeColor: Color(0xFF94A3B8)),
    MatchPairItem(id: '4', emoji: '🦊', name: 'Fox', phonicsLetter: 'F', themeColor: Color(0xFFFB923C)),
  ];

  static const List<MatchPairItem> _alphabetPicturesPool = [
    MatchPairItem(id: 'a', emoji: '🍎', name: 'Apple', phonicsLetter: 'A', themeColor: Color(0xFFEF4444)),
    MatchPairItem(id: 'b', emoji: '⚽', name: 'Ball', phonicsLetter: 'B', themeColor: Color(0xFF3B82F6)),
    MatchPairItem(id: 'c', emoji: '🐱', name: 'Cat', phonicsLetter: 'C', themeColor: Color(0xFFF59E0B)),
    MatchPairItem(id: 'd', emoji: '🦆', name: 'Duck', phonicsLetter: 'D', themeColor: Color(0xFF10B981)),
  ];

  int _currentMode = 0; // 0 = Line Connector (Animals), 1 = 2x2 Picture-to-Letter
  
  // Mode 0: Line Connector State
  late List<MatchPairItem> _leftItems;
  late List<MatchPairItem> _rightItems;
  String? _selectedLeftId;
  String? _selectedRightId;
  final Map<String, String> _connectedPairs = {}; // leftId -> rightId
  final Map<String, bool> _pairResults = {}; // leftId -> isCorrect

  // Mode 1: 2x2 Picture-to-Letter State
  final Map<String, String?> _pictureSlots = {}; // pictureId -> letter
  final Set<String> _usedLetters = {};

  int _score = 0;
  bool _isAnswerChecked = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _setupMode0();
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

  void _setupMode0() {
    _leftItems = List.from(_animalsPool);
    _rightItems = List.from(_animalsPool)..shuffle();
    _connectedPairs.clear();
    _pairResults.clear();
    _selectedLeftId = null;
    _selectedRightId = null;
    _isAnswerChecked = false;
    _speak("Match the animals to their names!");
    setState(() {});
  }

  void _setupMode1() {
    _pictureSlots.clear();
    for (final p in _alphabetPicturesPool) {
      _pictureSlots[p.id] = null;
    }
    _usedLetters.clear();
    _isAnswerChecked = false;
    _speak("Match the picture with the correct letter!");
    setState(() {});
  }

  // Line Connector Handlers
  void _onLeftItemTap(String id) {
    if (_isAnswerChecked) return;
    HapticFeedback.selectionClick();
    PocketGameAudioService.instance.playPopSound();
    final item = _leftItems.firstWhere((x) => x.id == id);
    _speak(item.name);

    setState(() {
      if (_selectedRightId != null) {
        // A right word was selected, now tapped an animal -> CONNECT THEM!
        _connectedPairs[id] = _selectedRightId!;
        _selectedLeftId = null;
        _selectedRightId = null;
      } else if (_selectedLeftId == id) {
        // Toggle off
        _selectedLeftId = null;
      } else {
        _selectedLeftId = id;
      }
    });
  }

  void _onRightItemTap(String id) {
    if (_isAnswerChecked) return;
    HapticFeedback.selectionClick();
    PocketGameAudioService.instance.playPopSound();
    final item = _rightItems.firstWhere((x) => x.id == id);
    _speak(item.name);

    setState(() {
      if (_selectedLeftId != null) {
        // A left animal was selected, now tapped a word -> CONNECT THEM!
        _connectedPairs[_selectedLeftId!] = id;
        _selectedLeftId = null;
        _selectedRightId = null;
      } else if (_selectedRightId == id) {
        // Toggle off
        _selectedRightId = null;
      } else {
        _selectedRightId = id;
      }
    });
  }

  void _checkMode0Answers() {
    bool allCorrect = true;
    for (final left in _leftItems) {
      final rightId = _connectedPairs[left.id];
      final isCorrect = rightId == left.id;
      _pairResults[left.id] = isCorrect;
      if (!isCorrect) allCorrect = false;
    }

    setState(() {
      _isAnswerChecked = true;
    });

    if (allCorrect) {
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playCoinSound();
      _score += 15;
      PocketKidsService.addKidsScore(15);
      PocketKidsService.addStars(1);
      _speak("Brilliant matching! All correct!");
    } else {
      HapticFeedback.heavyImpact();
      PocketGameSfx.instance.playErrorBuzz();
      _speak("Check the red lines and try again!");
    }
  }

  // 2x2 Picture-to-Letter Handlers
  void _onLetterChoiceTap(String letter) {
    if (_isAnswerChecked || _usedLetters.contains(letter)) return;

    // Find first empty picture slot
    for (final p in _alphabetPicturesPool) {
      if (_pictureSlots[p.id] == null) {
        HapticFeedback.selectionClick();
        PocketGameAudioService.instance.playPopSound();
        _speak(letter);
        setState(() {
          _pictureSlots[p.id] = letter;
          _usedLetters.add(letter);
        });
        return;
      }
    }
  }

  void _onPictureSlotTap(String picId) {
    if (_isAnswerChecked) return;
    final letter = _pictureSlots[picId];
    if (letter != null) {
      HapticFeedback.selectionClick();
      setState(() {
        _usedLetters.remove(letter);
        _pictureSlots[picId] = null;
      });
    }
  }

  void _checkMode1Answers() {
    bool allCorrect = true;
    for (final p in _alphabetPicturesPool) {
      final placed = _pictureSlots[p.id];
      if (placed != p.phonicsLetter) {
        allCorrect = false;
        break;
      }
    }

    setState(() {
      _isAnswerChecked = true;
    });

    if (allCorrect) {
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playCoinSound();
      _score += 15;
      PocketKidsService.addKidsScore(15);
      PocketKidsService.addStars(1);
      _speak("Fantastic job! A for Apple, B for Ball, C for Cat, D for Duck!");
    } else {
      HapticFeedback.heavyImpact();
      PocketGameSfx.instance.playErrorBuzz();
      _speak("Let's try that again!");
    }
  }

  void _onContinue() {
    if (_currentMode == 0) {
      // Advance to Mode 1
      setState(() {
        _currentMode = 1;
      });
      _setupMode1();
    } else {
      // Finished all rounds!
      widget.onCompleted?.call();
      _showVictoryDialog();
    }
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉 🌟 🦁', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Match Master!',
              style: GoogleFonts.fredoka(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You connected all pictures & letters perfectly!\n+$_score KS & 2 Star Cookies 🍪',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.black87, fontSize: 14),
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
                'Done 🚀',
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF9), // Cream Soft Minimalist Background
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header Bar: Close X, Pink Progress Bar, Gem Counter (Image 5 Screen 3)
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
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _currentMode == 0 ? 0.5 : 1.0,
                        minHeight: 10,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEC4899)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
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

            // 2. Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: _currentMode == 0
                    ? _buildLineConnectorMode()
                    : _buildPictureToLetterGridMode(),
              ),
            ),

            // 3. Bottom Button
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
              child: SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    if (_currentMode == 0) {
                      if (_isAnswerChecked) {
                        final allRight = _pairResults.values.every((v) => v);
                        if (allRight) {
                          _onContinue();
                        } else {
                          _setupMode0(); // retry
                        }
                      } else if (_connectedPairs.length == _leftItems.length) {
                        _checkMode0Answers();
                      }
                    } else {
                      if (_isAnswerChecked) {
                        _onContinue();
                      } else if (!_pictureSlots.values.contains(null)) {
                        _checkMode1Answers();
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _isAnswerChecked ? 'Continue ➔' : 'Check Answers',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // MODE 0: LINE CONNECTOR (Match animals to their names - Image 5 Screen 3)
  // --------------------------------------------------------------------------
  Widget _buildLineConnectorMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Match It',
          style: GoogleFonts.outfit(
            color: const Color(0xFF94A3B8),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        Text(
          'Match the animals to their names',
          style: GoogleFonts.fredoka(
            color: const Color(0xFF0F172A),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),

        // 4 Animal Cards Left vs 4 Word Pills Right
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _leftItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, idx) {
            final left = _leftItems[idx];
            final right = _rightItems[idx];

            // Left card state
            final isLeftSelected = _selectedLeftId == left.id;
            final targetRightId = _connectedPairs[left.id];
            final isLeftConnected = targetRightId != null;
            final matchedRightItem = isLeftConnected
                ? _rightItems.where((x) => x.id == targetRightId).firstOrNull
                : null;

            // Right card state
            final isRightSelected = _selectedRightId == right.id;
            String? connectedLeftId;
            for (final entry in _connectedPairs.entries) {
              if (entry.value == right.id) {
                connectedLeftId = entry.key;
                break;
              }
            }
            final isRightConnected = connectedLeftId != null;
            final matchedLeftItem = isRightConnected
                ? _leftItems.where((x) => x.id == connectedLeftId).firstOrNull
                : null;

            // Borders and Colors
            Color borderLeft = isLeftSelected
                ? const Color(0xFF0284C7)
                : (isLeftConnected ? const Color(0xFF10B981) : const Color(0xFFE2E8F0));
            Color bgLeft = isLeftSelected
                ? const Color(0xFFF0F9FF)
                : (isLeftConnected ? const Color(0xFFECFDF5) : Colors.white);

            if (_isAnswerChecked && isLeftConnected) {
              borderLeft = (_pairResults[left.id] ?? false)
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFEF4444);
              bgLeft = (_pairResults[left.id] ?? false)
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEE2E2);
            }

            Color borderRight = isRightSelected
                ? const Color(0xFF0284C7)
                : (isRightConnected ? const Color(0xFF10B981) : const Color(0xFFE2E8F0));
            Color bgRight = isRightSelected
                ? const Color(0xFFF0F9FF)
                : (isRightConnected ? const Color(0xFFECFDF5) : Colors.white);

            if (_isAnswerChecked && isRightConnected) {
              borderRight = (_pairResults[connectedLeftId] ?? false)
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFEF4444);
              bgRight = (_pairResults[connectedLeftId] ?? false)
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEE2E2);
            }

            return Row(
              children: [
                // Left Animal Card
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onLeftItemTap(left.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: bgLeft,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: borderLeft,
                          width: (isLeftSelected || isLeftConnected) ? 2.5 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: borderLeft.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(left.emoji, style: const TextStyle(fontSize: 34)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: matchedRightItem != null
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      matchedRightItem.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : isLeftSelected
                                    ? Text(
                                        'Tapped! 👉',
                                        style: GoogleFonts.outfit(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0284C7),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                          ),
                          const SizedBox(width: 4),
                          // Connector Dot
                          Container(
                            width: 16,
                            height: 16,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isLeftConnected
                                  ? const Color(0xFF10B981)
                                  : (isLeftSelected ? const Color(0xFF0284C7) : const Color(0xFFCBD5E1)),
                              shape: BoxShape.circle,
                            ),
                            child: isLeftConnected
                                ? const Icon(Icons.check, size: 11, color: Colors.white)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Right Word Pill Card
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onRightItemTap(right.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      decoration: BoxDecoration(
                        color: bgRight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: borderRight,
                          width: (isRightSelected || isRightConnected) ? 2.5 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: borderRight.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Left connector dot
                          Container(
                            width: 16,
                            height: 16,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isRightConnected
                                  ? const Color(0xFF10B981)
                                  : (isRightSelected ? const Color(0xFF0284C7) : const Color(0xFFCBD5E1)),
                              shape: BoxShape.circle,
                            ),
                            child: isRightConnected
                                ? const Icon(Icons.check, size: 11, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          if (matchedLeftItem != null) ...[
                            Text(matchedLeftItem.emoji, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              right.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isRightConnected
                                    ? const Color(0xFF065F46)
                                    : (isRightSelected
                                        ? const Color(0xFF0369A1)
                                        : const Color(0xFF1E293B)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // MODE 1: 2x2 PICTURE-TO-LETTER GRID (Image 2 Screen 2)
  // --------------------------------------------------------------------------
  Widget _buildPictureToLetterGridMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Match & Learn',
          style: GoogleFonts.outfit(
            color: const Color(0xFF94A3B8),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        Text(
          'Match the picture with the correct letter',
          style: GoogleFonts.fredoka(
            color: const Color(0xFF0F172A),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        // 2x2 Picture Cards Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _alphabetPicturesPool.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, idx) {
            final pic = _alphabetPicturesPool[idx];
            final placedLetter = _pictureSlots[pic.id];

            Color slotBorder = const Color(0xFFCBD5E1);
            Color slotBg = const Color(0xFFF8FAFC);
            if (_isAnswerChecked && placedLetter != null) {
              final isRight = placedLetter == pic.phonicsLetter;
              slotBorder = isRight ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
              slotBg = isRight ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
            }

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(pic.emoji, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 10),
                  // Dashed / Filled Slot
                  GestureDetector(
                    onTap: () => _onPictureSlotTap(pic.id),
                    child: Container(
                      width: 50,
                      height: 44,
                      decoration: BoxDecoration(
                        color: slotBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: slotBorder, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        placedLetter ?? '',
                        style: GoogleFonts.fredoka(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Letter Choice Pills Row [ A ] [ B ] [ C ] [ D ] (Image 2 Screen 2)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _alphabetPicturesPool.map((p) {
            final isUsed = _usedLetters.contains(p.phonicsLetter);

            return GestureDetector(
              onTap: () => _onLetterChoiceTap(p.phonicsLetter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 58,
                height: 54,
                decoration: BoxDecoration(
                  color: isUsed ? const Color(0xFFF1F5F9) : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isUsed ? const Color(0xFFE2E8F0) : const Color(0xFF86EFAC),
                    width: 2,
                  ),
                  boxShadow: isUsed
                      ? null
                      : [
                          BoxShadow(
                            color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                alignment: Alignment.center,
                child: Text(
                  p.phonicsLetter,
                  style: GoogleFonts.fredoka(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isUsed ? Colors.black26 : const Color(0xFF15803D),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
